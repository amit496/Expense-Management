import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/backup_service.dart';
import '../services/scheduled_email_backup_service.dart';
import '../theme/app_theme.dart';
import 'message_helper.dart';

Future<void> exportFullBackup(BuildContext context) async {
  try {
    await BackupService.exportAndShare();
    if (context.mounted) {
      MessageHelper.showInfo(
        context,
        'Pick where to save or share — file may include your app PIN if set; keep it private.',
      );
    }
  } catch (e) {
    if (context.mounted) {
      MessageHelper.showError(context, 'Export failed: $e');
    }
  }
}

Future<void> confirmAndRestoreBackup(BuildContext context) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final go = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: isDark ? AppTheme.darkCard : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Restore backup?'),
      content: const Text(
        'This replaces all transactions, budgets, and settings on this device '
        'with the backup file. Current data will be lost. '
        'Backup files can contain your PIN — only use files you trust.\n\n'
        'Continue?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Choose file',
              style: TextStyle(color: AppTheme.primary)),
        ),
      ],
    ),
  );
  if (go != true || !context.mounted) return;

  final pick = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: const ['json'],
  );
  if (pick == null || pick.files.isEmpty || !context.mounted) return;

  final path = pick.files.single.path;
  if (path == null) {
    MessageHelper.showError(context, 'Could not read file path');
    return;
  }

  final parsed = await BackupService.parseFile(path);
  if (!parsed.ok) {
    if (context.mounted) {
      MessageHelper.showError(context, parsed.errorMessage ?? 'Invalid file');
    }
    return;
  }

  if (!context.mounted) return;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: isDark ? AppTheme.darkCard : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Confirm restore'),
      content: Text(
        'Import ${parsed.transactions.length} transactions and '
        '${parsed.budgets.length} budget entries?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Restore',
              style: TextStyle(color: AppTheme.expense)),
        ),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;

  final txn = Provider.of<TransactionProvider>(context, listen: false);
  final auth = Provider.of<AuthProvider>(context, listen: false);
  await txn.applyFullBackup(
    transactions: parsed.transactions,
    budgets: parsed.budgets,
    settings: parsed.settings,
  );
  auth.refreshFromDb();
  await ScheduledEmailBackupService.rescheduleFromSettings();
  if (context.mounted) {
    MessageHelper.showSuccess(
      context,
      'Backup restored successfully',
    );
  }
}
