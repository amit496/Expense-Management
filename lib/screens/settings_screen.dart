import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/backup_flow.dart';
import '../utils/message_helper.dart';
import 'accounts_screen.dart';
import 'categories_screen.dart';
import 'scheduled_email_backup_screen.dart';
import 'security_settings_screen.dart';
import 'tutorial_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionTitle('Appearance'),
          const SizedBox(height: 10),
          _buildSettingCard(
            isDark: isDark,
            child: SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: Text(
                isDark ? 'Dark theme active' : 'Light theme active',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.grey,
                ),
              ),
              value: provider.isDarkMode,
              onChanged: (_) => provider.toggleTheme(),
              activeTrackColor: AppTheme.primary,
              secondary: Icon(
                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: AppTheme.primary,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          const SizedBox(height: 24),
          _buildSectionTitle('Currency'),
          const SizedBox(height: 10),
          _buildSettingCard(
            isDark: isDark,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.currency_exchange_rounded,
                      color: AppTheme.secondary, size: 22),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text('Currency Symbol',
                        style: TextStyle(fontSize: 15)),
                  ),
                  DropdownButton<String>(
                    value: provider.currency,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: '₹', child: Text('₹ INR')),
                      DropdownMenuItem(value: '\$', child: Text('\$ USD')),
                      DropdownMenuItem(value: '€', child: Text('€ EUR')),
                      DropdownMenuItem(value: '£', child: Text('£ GBP')),
                      DropdownMenuItem(value: '¥', child: Text('¥ JPY')),
                    ],
                    onChanged: (val) {
                      if (val != null) provider.setCurrency(val);
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          _buildSectionTitle('Savings Goal'),
          const SizedBox(height: 10),
          _buildSettingCard(
            isDark: isDark,
            child: ListTile(
              leading: const Icon(Icons.savings_rounded,
                  color: AppTheme.secondary),
              title: const Text('Monthly Savings Goal'),
              subtitle: Text(
                provider.savingsGoal > 0
                    ? '${provider.currency}${provider.savingsGoal.toStringAsFixed(0)} per month'
                    : 'Not set',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.grey,
                ),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: provider.savingsGoal > 0
                      ? AppTheme.income.withValues(alpha: 0.1)
                      : AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  provider.savingsGoal > 0 ? 'Edit' : 'Set',
                  style: TextStyle(
                    color: provider.savingsGoal > 0
                        ? AppTheme.income
                        : AppTheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              onTap: () => _showSavingsGoalDialog(context, provider),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),

          const SizedBox(height: 24),
          _buildSectionTitle('Security'),
          const SizedBox(height: 10),
          Builder(builder: (context) {
            final auth = Provider.of<AuthProvider>(context);
            return _buildSettingCard(
              isDark: isDark,
              child: ListTile(
                leading: Icon(
                  Icons.shield_rounded,
                  color: auth.isPinEnabled
                      ? AppTheme.income
                      : isDark
                          ? Colors.white38
                          : Colors.grey,
                ),
                title: const Text('App Lock & Security'),
                subtitle: Text(
                  auth.isPinEnabled
                      ? 'PIN lock is active${auth.isBiometricEnabled ? ' • ${auth.biometricLabel} enabled' : ''}'
                      : 'Set up PIN or biometric lock',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : Colors.grey,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (auth.isPinEnabled)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.income.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'ON',
                          style: TextStyle(
                            color: AppTheme.income,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: isDark ? Colors.white24 : Colors.grey.shade400,
                    ),
                  ],
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SecuritySettingsScreen(),
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16),
              ),
            );
          }),

          const SizedBox(height: 24),
          _buildSectionTitle('Accounts'),
          const SizedBox(height: 10),
          _buildSettingCard(
            isDark: isDark,
            child: ListTile(
              leading: Icon(
                Icons.account_balance_wallet_outlined,
                color: AppTheme.secondary,
              ),
              title: const Text('Accounts & wallets'),
              subtitle: Text(
                'Add bank, UPI, or custom wallets for transactions',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.grey,
                ),
              ),
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: isDark ? Colors.white24 : Colors.grey.shade400,
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AccountsScreen()),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),

          const SizedBox(height: 24),
          _buildSectionTitle('Categories'),
          const SizedBox(height: 10),
          _buildSettingCard(
            isDark: isDark,
            child: ListTile(
              leading: Icon(
                Icons.category_outlined,
                color: AppTheme.secondary,
              ),
              title: const Text('Custom categories'),
              subtitle: Text(
                'Add your own income & expense labels',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.grey,
                ),
              ),
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: isDark ? Colors.white24 : Colors.grey.shade400,
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CategoriesScreen()),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),

          const SizedBox(height: 24),
          _buildSectionTitle('Backup'),
          const SizedBox(height: 10),
          _buildSettingCard(
            isDark: isDark,
            child: ListTile(
              leading: Icon(
                Icons.backup_rounded,
                color: AppTheme.income,
              ),
              title: const Text('Export full backup'),
              subtitle: Text(
                'JSON file — transactions, budgets & settings (offline)',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.grey,
                ),
              ),
              trailing: Icon(
                Icons.ios_share_rounded,
                color: isDark ? Colors.white38 : Colors.grey.shade600,
              ),
              onTap: () => exportFullBackup(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          const SizedBox(height: 10),
          _buildSettingCard(
            isDark: isDark,
            child: ListTile(
              leading: Icon(
                Icons.restore_rounded,
                color: AppTheme.primary,
              ),
              title: const Text('Restore from backup'),
              subtitle: Text(
                'Replaces all data from a .json backup file',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.grey,
                ),
              ),
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: isDark ? Colors.white24 : Colors.grey.shade400,
              ),
              onTap: () => confirmAndRestoreBackup(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          const SizedBox(height: 10),
          _buildSettingCard(
            isDark: isDark,
            child: ListTile(
              leading: Icon(
                Icons.mark_email_unread_outlined,
                color: AppTheme.secondary,
              ),
              title: const Text('Scheduled email backup'),
              subtitle: Text(
                'Choose time & email — reminder opens mail when online',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.grey,
                ),
              ),
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: isDark ? Colors.white24 : Colors.grey.shade400,
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ScheduledEmailBackupScreen(),
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),

          const SizedBox(height: 24),
          _buildSectionTitle('Data'),
          const SizedBox(height: 10),
          _buildSettingCard(
            isDark: isDark,
            child: ListTile(
              leading: const Icon(Icons.info_outline_rounded,
                  color: AppTheme.primary),
              title: const Text('Transaction Count'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${provider.allTransactions.length}',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),

          const SizedBox(height: 10),

          _buildSettingCard(
            isDark: isDark,
            child: ListTile(
              leading: const Icon(Icons.delete_forever_rounded,
                  color: AppTheme.expense),
              title: const Text('Clear All Data'),
              subtitle: Text(
                'Delete all transactions and budgets',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.grey,
                ),
              ),
              onTap: () => _showClearDialog(context, provider),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),

          const SizedBox(height: 24),
          _buildSectionTitle('Help'),
          const SizedBox(height: 10),
          _buildSettingCard(
            isDark: isDark,
            child: ListTile(
              leading: const Icon(
                Icons.school_rounded,
                color: AppTheme.primary,
              ),
              title: const Text('How to use — Tutorial'),
              subtitle: Text(
                'Step-by-step guide for all app features',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.grey,
                ),
              ),
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: isDark ? Colors.white24 : Colors.grey.shade400,
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TutorialScreen()),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),

          const SizedBox(height: 24),
          _buildSectionTitle('About'),
          const SizedBox(height: 10),
          _buildSettingCard(
            isDark: isDark,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 36,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'ExpenseTracker',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Advanced Expense Management App\nBuilt with Flutter',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white54 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppTheme.primary,
      ),
    );
  }

  Widget _buildSettingCard({required bool isDark, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }

  void _showSavingsGoalDialog(
      BuildContext context, TransactionProvider provider) {
    final controller = TextEditingController(
      text: provider.savingsGoal > 0
          ? provider.savingsGoal.toStringAsFixed(0)
          : '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Savings Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'How much do you want to save each month?',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white54
                    : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: InputDecoration(
                prefixText: '${provider.currency} ',
                hintText: '0',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          if (provider.savingsGoal > 0)
            TextButton(
              onPressed: () {
                provider.setSavingsGoal(0);
                Navigator.pop(ctx);
                MessageHelper.showInfo(context, 'Savings goal removed');
              },
              child: const Text('Remove',
                  style: TextStyle(color: AppTheme.expense)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(controller.text) ?? 0;
              if (amount > 0) {
                provider.setSavingsGoal(amount);
                Navigator.pop(ctx);
                MessageHelper.showSuccess(
                  context,
                  'Savings goal set to ${provider.currency}${amount.toStringAsFixed(0)}/month',
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showClearDialog(
      BuildContext context, TransactionProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will permanently delete all your transactions and budgets. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.clearAllData();
              Navigator.pop(ctx);
              MessageHelper.showWarning(
                  context, 'All transactions and budgets have been deleted');
            },
            child: const Text('Delete All',
                style: TextStyle(color: AppTheme.expense)),
          ),
        ],
      ),
    );
  }
}
