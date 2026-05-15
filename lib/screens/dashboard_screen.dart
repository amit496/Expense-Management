import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_theme.dart';
import '../utils/message_helper.dart';
import '../utils/backup_flow.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_tile.dart';
import 'settings_screen.dart';
import 'add_transaction_screen.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback? onSeeAllTap;

  const DashboardScreen({super.key, this.onSeeAllTap});

  static const _tips = [
    'Track every expense, no matter how small.',
    'Follow the 50/30/20 rule: Needs, Wants, Savings.',
    'Set a monthly budget and stick to it.',
    'Review your spending every week.',
    'Avoid impulse purchases — wait 24 hours.',
    'Always pay yourself first — save before spending.',
    'Use cash for daily expenses to limit overspending.',
    'Automate your savings for consistency.',
    'Cancel unused subscriptions regularly.',
    'Set financial goals — short & long term.',
    'An emergency fund = 3-6 months of expenses.',
    'Compare prices before making big purchases.',
    'Cook at home more to save on food costs.',
  ];

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'Good Night';
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    if (hour < 21) return 'Good Evening';
    return 'Good Night';
  }

  String _getGreetingEmoji() {
    final hour = DateTime.now().hour;
    if (hour < 6) return '🌙';
    if (hour < 12) return '☀️';
    if (hour < 17) return '🌤️';
    if (hour < 21) return '🌆';
    return '🌙';
  }

  String _getTip() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    return _tips[dayOfYear % _tips.length];
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recent = provider.filteredTransactions.take(5).toList();
    final sortedExpenses = provider.categoryExpenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topSpending = sortedExpenses.take(6).toList();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _getGreeting(),
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white54 : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(_getGreetingEmoji(), style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMMM yyyy').format(DateTime.now()),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _showExportSheet(context, provider),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.file_download_outlined, size: 22),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SettingsScreen()),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.settings_outlined, size: 22),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: BalanceCard(
                balance: provider.balance,
                income: provider.totalIncome,
                expense: provider.totalExpense,
                currency: provider.currency,
                lastMonthIncome: provider.lastMonthIncome,
                lastMonthExpense: provider.lastMonthExpense,
              ),
            ),
          ),

          // Financial tip of the day
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.secondary.withValues(alpha: 0.08)
                      : AppTheme.secondary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppTheme.secondary.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.secondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.lightbulb_outline_rounded,
                        color: AppTheme.secondary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tip of the Day',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.secondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getTip(),
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white70 : Colors.grey.shade700,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (provider.savingsGoal > 0)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _buildSavingsGoalCard(context, provider, isDark),
              ),
            ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  _buildQuickAction(
                    context,
                    icon: Icons.arrow_downward_rounded,
                    label: 'Income',
                    color: AppTheme.income,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddTransactionScreen(
                              initialType: 'income'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildQuickAction(
                    context,
                    icon: Icons.arrow_upward_rounded,
                    label: 'Expense',
                    color: AppTheme.expense,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddTransactionScreen(
                              initialType: 'expense'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          if (topSpending.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Top Spending',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        GestureDetector(
                          onTap: onSeeAllTap,
                          child: Text(
                            'Details',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 108,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: topSpending.length,
                        itemBuilder: (context, index) {
                          final entry = topSpending[index];
                          final cat = provider.categoryForDisplay(
                              entry.key, 'expense');
                          final pct = provider.totalExpense > 0
                              ? (entry.value / provider.totalExpense * 100)
                              : 0.0;
                          return Container(
                            width: 100,
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppTheme.darkCard
                                  : AppTheme.lightCard,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: cat.color
                                        .withValues(alpha: 0.15),
                                    borderRadius:
                                        BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    cat.icon,
                                    color: cat.color,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${pct.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: cat.color,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Transactions',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  GestureDetector(
                    onTap: onSeeAllTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'See All',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (recent.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: Column(
                    children: [
                      _buildAnimatedEmptyIcon(isDark),
                      const SizedBox(height: 16),
                      Text(
                        'No transactions yet',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white38 : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap + to add your first transaction',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.white24
                              : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final txn = recent[index];
                  return TransactionTile(
                    transaction: txn,
                    currency: provider.currency,
                    onTap: () => _editTransaction(context, provider, txn),
                    onLongPress: () =>
                        _showOptionsSheet(context, provider, txn),
                    onDelete: () =>
                        _confirmDelete(context, provider, txn),
                  );
                },
                childCount: recent.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedEmptyIcon(bool isDark) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark
              ? AppTheme.primary.withValues(alpha: 0.08)
              : AppTheme.primary.withValues(alpha: 0.06),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.account_balance_wallet_outlined,
          size: 48,
          color: isDark ? Colors.white12 : Colors.grey.shade300,
        ),
      ),
    );
  }

  void _showExportSheet(BuildContext context, TransactionProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.darkCard : AppTheme.lightCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Export & backup',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.folder_zip_rounded,
                      color: AppTheme.primary),
                ),
                title: const Text('Full backup (JSON)'),
                subtitle: const Text(
                  'All data for this device — save or share the file',
                  style: TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(ctx);
                  exportFullBackup(context);
                },
              ),
              const SizedBox(height: 4),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.income.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.table_chart_rounded,
                      color: AppTheme.income),
                ),
                title: const Text('Export as CSV'),
                subtitle: const Text('Spreadsheet compatible format',
                    style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(ctx);
                  _exportCSV(context, provider);
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.share_rounded,
                      color: AppTheme.primary),
                ),
                title: const Text('Share Summary'),
                subtitle: const Text('Share this month\'s summary as text',
                    style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(ctx);
                  _shareSummary(context, provider);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _exportCSV(BuildContext context, TransactionProvider provider) async {
    try {
      final transactions = provider.allTransactions;
      if (transactions.isEmpty) {
        MessageHelper.showWarning(context, 'No transactions to export');
        return;
      }

      final csvRows = <String>[
        'Date,Type,Category,Title,Amount,Account,Note',
      ];

      for (var t in transactions) {
        final date = t['date'] ?? '';
        final type = t['type'] ?? '';
        final category = t['category'] ?? '';
        final title = (t['title'] ?? '').toString().replaceAll(',', ';');
        final amount = (t['amount'] ?? 0.0).toString();
        final account = t['account'] ?? '';
        final note = (t['note'] ?? '').toString().replaceAll(',', ';');
        csvRows.add('$date,$type,$category,$title,$amount,$account,$note');
      }

      final csvString = csvRows.join('\n');
      await Clipboard.setData(ClipboardData(text: csvString));

      if (context.mounted) {
        MessageHelper.showSuccess(
          context,
          'CSV data copied to clipboard (${transactions.length} transactions)',
        );
      }
    } catch (e) {
      if (context.mounted) {
        MessageHelper.showError(context, 'Export failed: $e');
      }
    }
  }

  void _shareSummary(BuildContext context, TransactionProvider provider) async {
    final now = DateTime.now();
    final monthName = DateFormat('MMMM yyyy').format(now);

    final summary = '''
📊 ExpenseTracker - $monthName

💰 Income: ${provider.currency}${provider.totalIncome.toStringAsFixed(0)}
💸 Expense: ${provider.currency}${provider.totalExpense.toStringAsFixed(0)}
📈 Balance: ${provider.currency}${provider.balance.toStringAsFixed(0)}

📝 Transactions: ${provider.thisMonthTransactionCount}
🏆 Top Category: ${provider.topExpenseCategory}
📅 Avg Daily: ${provider.currency}${provider.avgDailyExpense.toStringAsFixed(0)}

${provider.balance >= 0 ? '✅ Great! You saved ${provider.currency}${provider.balance.toStringAsFixed(0)} this month!' : '⚠️ Overspent by ${provider.currency}${provider.balance.abs().toStringAsFixed(0)} this month'}
''';

    await Clipboard.setData(ClipboardData(text: summary.trim()));
    if (context.mounted) {
      MessageHelper.showSuccess(context, 'Summary copied to clipboard!');
    }
  }

  void _editTransaction(BuildContext context,
      TransactionProvider provider, Map<String, dynamic> txn) {
    HapticFeedback.selectionClick();
    final index = provider.getHiveIndex(txn);
    if (index >= 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              AddTransactionScreen(transaction: txn, hiveIndex: index),
        ),
      );
    }
  }

  void _showOptionsSheet(BuildContext context,
      TransactionProvider provider, Map<String, dynamic> txn) {
    HapticFeedback.mediumImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isExpense = txn['type'] == 'expense';

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.darkCard : AppTheme.lightCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (isExpense
                                  ? AppTheme.expense
                                  : AppTheme.income)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isExpense
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          color:
                              isExpense ? AppTheme.expense : AppTheme.income,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(txn['title'] ?? '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15)),
                            Text(
                              '${provider.currency}${(txn['amount'] ?? 0.0).toStringAsFixed(0)} • ${txn['category'] ?? ''}',
                              style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      isDark ? Colors.white38 : Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Divider(color: isDark ? Colors.white10 : Colors.grey.shade200),
                ListTile(
                  leading:
                      const Icon(Icons.edit_rounded, color: AppTheme.primary),
                  title: const Text('Edit Transaction'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _editTransaction(context, provider, txn);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.copy_rounded,
                      color: AppTheme.secondary),
                  title: const Text('Duplicate Transaction'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _duplicateTransaction(context, provider, txn);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_rounded,
                      color: AppTheme.expense),
                  title: const Text('Delete Transaction'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _confirmDelete(context, provider, txn);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void _duplicateTransaction(BuildContext context,
      TransactionProvider provider, Map<String, dynamic> txn) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(
          initialType: txn['type'] ?? 'expense',
          duplicateFrom: txn,
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context,
      TransactionProvider provider, Map<String, dynamic> txn) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text('Delete "${txn['title']}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final index = provider.getHiveIndex(txn);
              if (index >= 0) {
                provider.deleteTransaction(index);
                MessageHelper.showSuccess(context, 'Transaction deleted');
              }
              Navigator.pop(ctx);
            },
            child: const Text('Delete',
                style: TextStyle(color: AppTheme.expense)),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsGoalCard(
      BuildContext context, TransactionProvider provider, bool isDark) {
    final progress = provider.savingsProgress;
    final saved = provider.balance > 0 ? provider.balance : 0.0;
    final goal = provider.savingsGoal;
    final pct = (progress * 100).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: progress >= 1.0
            ? Border.all(color: AppTheme.income.withValues(alpha: 0.3), width: 1.5)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                progress >= 1.0
                    ? Icons.emoji_events_rounded
                    : Icons.savings_rounded,
                color: progress >= 1.0 ? Colors.amber : AppTheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Monthly Savings Goal',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                '$pct%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: progress >= 1.0
                      ? AppTheme.income
                      : progress >= 0.5
                          ? AppTheme.secondary
                          : AppTheme.expense,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(
                    progress >= 1.0
                        ? AppTheme.income
                        : progress >= 0.5
                            ? AppTheme.secondary
                            : AppTheme.primary,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${provider.currency}${saved.toStringAsFixed(0)} saved',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.grey,
                ),
              ),
              Text(
                'Goal: ${provider.currency}${goal.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.grey,
                ),
              ),
            ],
          ),
          if (progress >= 1.0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.income.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 6),
                  Text(
                    'Goal achieved! Great job!',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.income,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
