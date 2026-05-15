import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_theme.dart';
import '../utils/message_helper.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  Map<String, List<Map<String, dynamic>>> _groupByDate(
      List<Map<String, dynamic>> transactions) {
    Map<String, List<Map<String, dynamic>>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (var t in transactions) {
      final date = DateTime.tryParse(t['date'] ?? '');
      if (date == null) continue;

      final dateOnly = DateTime(date.year, date.month, date.day);
      String key;

      if (dateOnly == today) {
        key = 'Today';
      } else if (dateOnly == yesterday) {
        key = 'Yesterday';
      } else {
        key = DateFormat('MMM dd, yyyy').format(date);
      }

      grouped[key] ??= [];
      grouped[key]!.add(t);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final transactions = provider.filteredTransactions;
    final grouped = _groupByDate(transactions);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                const Text(
                  'Transactions',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                _buildDateChip(context, provider),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: TextField(
              onChanged: provider.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search by name, amount, date...',
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                suffixIcon: provider.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => provider.setSearchQuery(''),
                      )
                    : null,
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: ['All', 'Income', 'Expense'].map((type) {
                final isSelected = provider.filterType == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(type),
                    selected: isSelected,
                    showCheckmark: false,
                    onSelected: (_) => provider.setFilterType(type),
                    backgroundColor:
                        isDark ? AppTheme.darkCard : AppTheme.lightCard,
                    selectedColor: AppTheme.primary.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppTheme.primary
                          : isDark
                              ? Colors.white70
                              : Colors.grey.shade700,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      fontSize: 13,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppTheme.primary
                          : Colors.transparent,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: transactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: isDark
                              ? Colors.white12
                              : Colors.grey.shade300,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No transactions found',
                          style: TextStyle(
                            color: isDark ? Colors.white38 : Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    children: _buildGroupedList(context, grouped, provider),
                  ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGroupedList(
    BuildContext context,
    Map<String, List<Map<String, dynamic>>> grouped,
    TransactionProvider provider,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    List<Widget> widgets = [];

    for (var entry in grouped.entries) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            entry.key,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white38 : Colors.grey,
            ),
          ),
        ),
      );

      for (var t in entry.value) {
        widgets.add(
          Slidable(
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              extentRatio: 0.5,
              children: [
                SlidableAction(
                  onPressed: (_) {
                    final index = provider.getHiveIndex(t);
                    if (index >= 0) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddTransactionScreen(
                            transaction: t,
                            hiveIndex: index,
                          ),
                        ),
                      );
                    }
                  },
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  icon: Icons.edit_rounded,
                  label: 'Edit',
                  borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(12)),
                ),
                SlidableAction(
                  onPressed: (_) {
                    final index = provider.getHiveIndex(t);
                    if (index >= 0) {
                      _showDeleteDialog(context, provider, index);
                    }
                  },
                  backgroundColor: AppTheme.expense,
                  foregroundColor: Colors.white,
                  icon: Icons.delete_rounded,
                  label: 'Delete',
                  borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(12)),
                ),
              ],
            ),
            child: TransactionTile(
              transaction: t,
              currency: provider.currency,
              onTap: () {
                final index = provider.getHiveIndex(t);
                if (index >= 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddTransactionScreen(
                        transaction: t,
                        hiveIndex: index,
                      ),
                    ),
                  );
                }
              },
              onDelete: () {
                final index = provider.getHiveIndex(t);
                if (index >= 0) {
                  _showDeleteDialog(context, provider, index);
                }
              },
            ),
          ),
        );
      }
    }

    return widgets;
  }

  void _showDeleteDialog(
      BuildContext context, TransactionProvider provider, int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Transaction'),
        content:
            const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteTransaction(index);
              Navigator.pop(ctx);
              MessageHelper.showSuccess(
                  context, 'Transaction deleted successfully');
            },
            child: const Text('Delete',
                style: TextStyle(color: AppTheme.expense)),
          ),
        ],
      ),
    );
  }

  Widget _buildDateChip(
      BuildContext context, TransactionProvider provider) {
    return PopupMenuButton<String>(
      onSelected: provider.setDateRange,
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'week', child: Text('This Week')),
        const PopupMenuItem(value: 'month', child: Text('This Month')),
        const PopupMenuItem(value: 'year', child: Text('This Year')),
        const PopupMenuItem(value: 'all', child: Text('All Time')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getDateRangeLabel(provider.dateRange),
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.expand_more, size: 16, color: AppTheme.primary),
          ],
        ),
      ),
    );
  }

  String _getDateRangeLabel(String range) {
    switch (range) {
      case 'week':
        return 'This Week';
      case 'month':
        return 'This Month';
      case 'year':
        return 'This Year';
      default:
        return 'All Time';
    }
  }
}
