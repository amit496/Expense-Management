import 'package:flutter/material.dart';

import '../services/scheduled_email_backup_service.dart';
import '../theme/app_theme.dart';
import '../utils/message_helper.dart';

class ScheduledEmailBackupScreen extends StatefulWidget {
  const ScheduledEmailBackupScreen({super.key});

  @override
  State<ScheduledEmailBackupScreen> createState() =>
      _ScheduledEmailBackupScreenState();
}

class _ScheduledEmailBackupScreenState extends State<ScheduledEmailBackupScreen> {
  late bool _enabled;
  late TextEditingController _email;
  late String _frequency;
  late int _weekday;
  late int _dayOfMonth;
  late TimeOfDay _time;

  @override
  void initState() {
    super.initState();
    _enabled = ScheduledEmailBackupService.isScheduledBackupEnabled;
    _email = TextEditingController(
      text: ScheduledEmailBackupService.scheduledBackupEmail,
    );
    _frequency = ScheduledEmailBackupService.scheduledBackupFrequency;
    if (_frequency != 'monthly') _frequency = 'weekly';
    _weekday = ScheduledEmailBackupService.scheduledBackupWeekday;
    _dayOfMonth = ScheduledEmailBackupService.scheduledBackupDayOfMonth;
    _time = TimeOfDay(
      hour: ScheduledEmailBackupService.scheduledBackupHour,
      minute: ScheduledEmailBackupService.scheduledBackupMinute,
    );
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    final email = _email.text.trim();
    if (_enabled && (email.isEmpty || !email.contains('@'))) {
      MessageHelper.showError(context, 'Enter a valid email when backup is on');
      return;
    }
    await ScheduledEmailBackupService.saveScheduleSettings(
      enabled: _enabled,
      email: email,
      frequency: _frequency,
      weekday: _weekday,
      dayOfMonth: _dayOfMonth,
      hour: _time.hour,
      minute: _time.minute,
    );
    if (mounted) {
      MessageHelper.showSuccess(context, 'Backup schedule saved');
      if (_enabled &&
          !ScheduledEmailBackupService.isNotificationPluginReady) {
        MessageHelper.showWarning(
          context,
          'Scheduled reminders need a full restart: stop the app completely, '
          'then run again (hot restart does not load new native code).',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Scheduled email backup')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (!ScheduledEmailBackupService.isNotificationPluginReady)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.warning.withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                'Reminders are not active until you fully restart the app '
                '(stop + run). Hot restart does not load new native plugins.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ),
          Text(
            'At the time you choose, you get a reminder. If internet is available, '
            'the app opens your mail app with a backup file attached — you tap Send. '
            'If there is no internet, you are told to use manual export from Settings.',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: isDark ? Colors.white54 : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            title: const Text('Enable scheduled reminder'),
            subtitle: Text(
              _enabled ? 'Reminder is on' : 'Off — no automatic reminders',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white38 : Colors.grey,
              ),
            ),
            value: _enabled,
            onChanged: (v) => setState(() => _enabled = v),
            activeTrackColor: AppTheme.primary,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            decoration: const InputDecoration(
              labelText: 'Backup email',
              hintText: 'you@example.com',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Repeat',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white54 : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'weekly', label: Text('Weekly')),
              ButtonSegment(value: 'monthly', label: Text('Monthly')),
            ],
            selected: {_frequency},
            onSelectionChanged: (s) =>
                setState(() => _frequency = s.first),
          ),
          const SizedBox(height: 16),
          if (_frequency == 'weekly') ...[
            Text(
              'Day of week',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white54 : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            InputDecorator(
              decoration: const InputDecoration(border: OutlineInputBorder()),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: _weekday,
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Monday')),
                    DropdownMenuItem(value: 2, child: Text('Tuesday')),
                    DropdownMenuItem(value: 3, child: Text('Wednesday')),
                    DropdownMenuItem(value: 4, child: Text('Thursday')),
                    DropdownMenuItem(value: 5, child: Text('Friday')),
                    DropdownMenuItem(value: 6, child: Text('Saturday')),
                    DropdownMenuItem(value: 7, child: Text('Sunday')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _weekday = v);
                  },
                ),
              ),
            ),
          ] else ...[
            Text(
              'Day of month (1–28)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white54 : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            InputDecorator(
              decoration: const InputDecoration(border: OutlineInputBorder()),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: _dayOfMonth.clamp(1, 28),
                  items: List.generate(
                    28,
                    (i) => DropdownMenuItem(
                      value: i + 1,
                      child: Text('${i + 1}'),
                    ),
                  ),
                  onChanged: (v) {
                    if (v != null) setState(() => _dayOfMonth = v);
                  },
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Time'),
            subtitle: Text(
              _time.format(context),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: const Icon(Icons.schedule_rounded),
            onTap: _pickTime,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: _save,
              child: const Text('Save schedule'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () async {
                await ScheduledEmailBackupService.sendBackupEmailTo(
                  _email.text.trim(),
                );
              },
              child: const Text('Send backup email now'),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Note: Email is sent from your own mail app (Gmail, Outlook, etc.). '
            'The app cannot send mail in the background without you.',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white38 : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
