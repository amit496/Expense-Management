import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'backup_service.dart';
import 'db_service.dart';

/// Local schedule + connectivity-aware backup email flow.
/// Actual send opens the device mail app with attachment (user may tap Send once).
class ScheduledEmailBackupService {
  ScheduledEmailBackupService._();

  static const int _notificationId = 9001;
  static const String _payload = 'scheduled_backup';
  static const String _channelId = 'scheduled_backup';

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static GlobalKey<NavigatorState>? _navigatorKey;
  static bool _initialized = false;
  static bool _pluginReady = false;

  static GlobalKey<NavigatorState>? get navigatorKey => _navigatorKey;

  /// False after hot-restart without native rebuild, or if init failed.
  static bool get isNotificationPluginReady => _pluginReady;

  static Future<void> init(GlobalKey<NavigatorState> navigatorKey) async {
    if (_initialized) return;
    _initialized = true;
    _navigatorKey = navigatorKey;
    _pluginReady = false;

    if (Platform.isLinux || Platform.isWindows) {
      return;
    }

    try {
      tz_data.initializeTimeZones();
      try {
        final name = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(name));
      } catch (_) {
        try {
          tz.setLocalLocation(tz.getLocation('UTC'));
        } catch (_) {}
      }

      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinInit = DarwinInitializationSettings();
      await _plugin.initialize(
        const InitializationSettings(
          android: androidInit,
          iOS: darwinInit,
          macOS: darwinInit,
        ),
        onDidReceiveNotificationResponse: _onNotificationResponse,
      );

      await _ensureAndroidChannel();

      if (Platform.isIOS) {
        await _plugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, badge: true, sound: true);
      }
      if (Platform.isAndroid) {
        await _plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
      }

      _pluginReady = true;

      await rescheduleFromSettings();
      final details = await _plugin.getNotificationAppLaunchDetails();
      if (details?.didNotificationLaunchApp == true &&
          details!.notificationResponse?.payload == _payload) {
        Future.delayed(const Duration(milliseconds: 800), () {
          handleBackupTap(fromNotification: true);
        });
      }
    } on MissingPluginException catch (e, st) {
      debugPrint(
        'ScheduledEmailBackupService: local notifications not linked ($e). '
        'Stop the app completely and run again (flutter run) — hot restart '
        'does not load new native plugins. $st',
      );
      _pluginReady = false;
    } catch (e, st) {
      debugPrint('ScheduledEmailBackupService init failed: $e $st');
      _pluginReady = false;
    }
  }

  static Future<void> _ensureAndroidChannel() async {
    if (!Platform.isAndroid) return;
    const channel = AndroidNotificationChannel(
      _channelId,
      'Scheduled backups',
      description: 'Reminders to email your ExpenseTracker backup',
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static void _onNotificationResponse(NotificationResponse response) {
    if (response.payload == _payload) {
      handleBackupTap(fromNotification: true);
    }
  }

  static bool get isScheduledBackupEnabled =>
      DbService.getSetting('scheduledBackupEnabled', defaultValue: false) ==
      true;

  static String get scheduledBackupEmail =>
      (DbService.getSetting('scheduledBackupEmail', defaultValue: '') ?? '')
          .toString()
          .trim();

  static String get scheduledBackupFrequency =>
      (DbService.getSetting('scheduledBackupFrequency', defaultValue: 'weekly') ??
              'weekly')
          .toString();

  static int get scheduledBackupWeekday =>
      (DbService.getSetting('scheduledBackupWeekday', defaultValue: 1) as num)
          .toInt()
          .clamp(1, 7);

  static int get scheduledBackupDayOfMonth =>
      (DbService.getSetting('scheduledBackupDayOfMonth', defaultValue: 1) as num)
          .toInt()
          .clamp(1, 28);

  static int get scheduledBackupHour =>
      (DbService.getSetting('scheduledBackupHour', defaultValue: 9) as num)
          .toInt()
          .clamp(0, 23);

  static int get scheduledBackupMinute =>
      (DbService.getSetting('scheduledBackupMinute', defaultValue: 0) as num)
          .toInt()
          .clamp(0, 59);

  static Future<bool> hasNetworkConnection() async {
    final results = await Connectivity().checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  /// After settings change or app start.
  static Future<void> rescheduleFromSettings() async {
    if (!_pluginReady) return;
    try {
      await _plugin.cancel(_notificationId);

      if (!isScheduledBackupEnabled) return;
      final email = scheduledBackupEmail;
      if (email.isEmpty || !email.contains('@')) return;

      final hour = scheduledBackupHour;
      final minute = scheduledBackupMinute;
      final freq = scheduledBackupFrequency;

      final tz.TZDateTime first;
      final DateTimeComponents? match;

      if (freq == 'monthly') {
        first = _nextMonthDay(scheduledBackupDayOfMonth, hour, minute);
        match = DateTimeComponents.dayOfMonthAndTime;
      } else {
        first = _nextWeekday(scheduledBackupWeekday, hour, minute);
        match = DateTimeComponents.dayOfWeekAndTime;
      }

      const android = AndroidNotificationDetails(
        _channelId,
        'Scheduled backups',
        channelDescription: 'ExpenseTracker backup reminder',
        importance: Importance.high,
        priority: Priority.high,
      );
      const darwin = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      const details = NotificationDetails(
        android: android,
        iOS: darwin,
        macOS: darwin,
      );

      await _plugin.zonedSchedule(
        _notificationId,
        'ExpenseTracker — backup time',
        'Internet on? Open to send backup to $email. '
        'No internet? Use Settings → Export full backup when you are online.',
        first,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.wallClockTime,
        matchDateTimeComponents: match,
        payload: _payload,
      );
    } catch (e, st) {
      debugPrint('ScheduledEmailBackupService reschedule: $e $st');
    }
  }

  static tz.TZDateTime _nextWeekday(int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var t = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    for (var i = 0; i < 400; i++) {
      if (t.weekday == weekday && t.isAfter(now)) {
        return t;
      }
      t = t.add(const Duration(days: 1));
      t = tz.TZDateTime(tz.local, t.year, t.month, t.day, hour, minute);
    }
    return t;
  }

  static tz.TZDateTime _nextMonthDay(int day, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var t = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      day.clamp(1, 28),
      hour,
      minute,
    );
    if (!t.isAfter(now)) {
      final nextMonth = now.month == 12 ? 1 : now.month + 1;
      final nextYear = now.month == 12 ? now.year + 1 : now.year;
      t = tz.TZDateTime(
        tz.local,
        nextYear,
        nextMonth,
        day.clamp(1, 28),
        hour,
        minute,
      );
    }
    return t;
  }

  /// Sends current backup JSON via the device mail app (any email).
  static Future<void> sendBackupEmailTo(String email) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty || !trimmed.contains('@')) {
      _snack('Enter a valid email address.');
      return;
    }
    final online = await hasNetworkConnection();
    if (!online) {
      await DbService.setSetting('backupMissedOffline', true);
      _snack(
        'No internet. When online: open this screen again and tap send, '
        'or use Settings → Export full backup.',
      );
      return;
    }
    await DbService.setSetting('backupMissedOffline', false);
    try {
      final path = await BackupService.writeTempBackupFile();
      await FlutterEmailSender.send(Email(
        body:
            'Attached: ExpenseTracker full backup (JSON).\n'
            'Keep this file private — it may include your app PIN in settings.\n',
        subject:
            'ExpenseTracker backup ${DateTime.now().toIso8601String().split('T').first}',
        recipients: [trimmed],
        attachmentPaths: [path],
      ));
      _snack('Mail app opened — confirm and tap Send on your device.');
    } catch (e) {
      _snack('Could not open email app. Use Settings → Export full backup. ($e)');
    }
  }

  /// Notification tap — uses the email saved in schedule settings.
  static Future<void> handleBackupTap({bool fromNotification = false}) async {
    if (fromNotification && !isScheduledBackupEnabled) return;
    final email = scheduledBackupEmail;
    if (email.isEmpty) {
      _snack('Set your backup email in Settings → Scheduled email backup.');
      return;
    }
    await sendBackupEmailTo(email);
  }

  static void _snack(String message) {
    final ctx = _navigatorKey?.currentContext;
    if (ctx == null || !ctx.mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Call when app returns to foreground (e.g. user was offline at backup time).
  static Future<void> onAppResumed() async {
    final missed = DbService.getSetting('backupMissedOffline', defaultValue: false) == true;
    if (!missed) return;

    final online = await hasNetworkConnection();
    if (!online) return;

    await DbService.setSetting('backupMissedOffline', false);
    _snack(
      'Internet is back. Tap Settings → Scheduled email backup → '
      '"Send backup email now" or wait for the next reminder.',
    );
  }

  static Future<void> saveScheduleSettings({
    required bool enabled,
    required String email,
    required String frequency,
    required int weekday,
    required int dayOfMonth,
    required int hour,
    required int minute,
  }) async {
    await DbService.setSetting('scheduledBackupEnabled', enabled);
    await DbService.setSetting('scheduledBackupEmail', email.trim());
    await DbService.setSetting('scheduledBackupFrequency', frequency);
    await DbService.setSetting('scheduledBackupWeekday', weekday);
    await DbService.setSetting('scheduledBackupDayOfMonth', dayOfMonth);
    await DbService.setSetting('scheduledBackupHour', hour);
    await DbService.setSetting('scheduledBackupMinute', minute);
    await rescheduleFromSettings();
  }
}
