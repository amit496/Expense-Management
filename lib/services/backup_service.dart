import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'db_service.dart';

class BackupParseResult {
  final bool ok;
  final String? errorMessage;
  final List<Map<String, dynamic>> transactions;
  final List<Map<String, dynamic>> budgets;
  final Map<String, dynamic> settings;

  const BackupParseResult._({
    required this.ok,
    this.errorMessage,
    this.transactions = const [],
    this.budgets = const [],
    this.settings = const {},
  });

  factory BackupParseResult.error(String msg) =>
      BackupParseResult._(ok: false, errorMessage: msg);

  factory BackupParseResult.success({
    required List<Map<String, dynamic>> transactions,
    required List<Map<String, dynamic>> budgets,
    required Map<String, dynamic> settings,
  }) =>
      BackupParseResult._(
        ok: true,
        transactions: transactions,
        budgets: budgets,
        settings: settings,
      );
}

class BackupService {
  static const String formatId = 'expense_tracker_backup';
  static const int formatVersion = 1;

  static Map<String, dynamic> buildPayload() {
    return {
      'format': formatId,
      'version': formatVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'transactions': DbService.getAllTransactions(),
      'budgets': DbService.getAllBudgets(),
      'settings': DbService.dumpAllSettings(),
    };
  }

  /// Writes JSON to temp dir and opens share sheet (Files, Drive, AirDrop, etc.).
  static Future<void> exportAndShare() async {
    final path = await writeTempBackupFile();
    await Share.shareXFiles(
      [XFile(path)],
      subject: 'ExpenseTracker backup',
    );
  }

  /// Returns path to a temporary `.json` backup file.
  static Future<String> writeTempBackupFile() async {
    final map = buildPayload();
    final dir = await getTemporaryDirectory();
    final name =
        'expense_tracker_backup_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File('${dir.path}/$name');
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(map));
    return file.path;
  }

  static BackupParseResult parseJsonString(String text) {
    try {
      final decoded = jsonDecode(text);
      if (decoded is! Map) {
        return BackupParseResult.error('Invalid backup file');
      }
      final root = Map<String, dynamic>.from(
        decoded.map((k, v) => MapEntry(k.toString(), v)),
      );
      if (root['format'] != formatId) {
        return BackupParseResult.error('This file is not an ExpenseTracker backup');
      }
      final v = root['version'];
      if (v is! int || v != formatVersion) {
        return BackupParseResult.error('Unsupported backup version');
      }

      final txRaw = root['transactions'];
      final budRaw = root['budgets'];
      final setRaw = root['settings'];
      if (txRaw is! List || budRaw is! List || setRaw is! Map) {
        return BackupParseResult.error('Backup file is corrupted');
      }

      final transactions = <Map<String, dynamic>>[];
      for (final e in txRaw) {
        if (e is Map) {
          transactions.add(Map<String, dynamic>.from(e));
        }
      }
      final budgets = <Map<String, dynamic>>[];
      for (final e in budRaw) {
        if (e is Map) {
          budgets.add(Map<String, dynamic>.from(e));
        }
      }
      final settings = Map<String, dynamic>.from(setRaw);

      return BackupParseResult.success(
        transactions: transactions,
        budgets: budgets,
        settings: settings,
      );
    } catch (_) {
      return BackupParseResult.error('Could not read backup file');
    }
  }

  static Future<BackupParseResult> parseFile(String path) async {
    try {
      final text = await File(path).readAsString();
      return parseJsonString(text);
    } catch (_) {
      return BackupParseResult.error('Could not open file');
    }
  }
}
