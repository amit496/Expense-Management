import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_theme.dart';
import '../utils/message_helper.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_screen.dart';
import 'payments_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
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
            child: const Text(
              'Transactions',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: TextField(
              onChanged: provider.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search title, category, account, note, amount...',
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon: provider.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => provider.setSearchQuery(''),
                      )
                    : null,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: _buildDateRangeFilter(context, provider),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PaymentsScreen(),
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppTheme.secondary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.payments_outlined,
                          size: 16, color: AppTheme.secondary),
                      SizedBox(width: 6),
                      Text(
                        'View Payments',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
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
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 13,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppTheme.primary : Colors.transparent,
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
                          color: isDark ? Colors.white12 : Colors.grey.shade300,
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
                  borderRadius:
                      const BorderRadius.horizontal(left: Radius.circular(12)),
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
                  borderRadius:
                      const BorderRadius.horizontal(right: Radius.circular(12)),
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
            child:
                const Text('Delete', style: TextStyle(color: AppTheme.expense)),
          ),
        ],
      ),
    );
  }

  Future<void> _setQuickDateRange(
    BuildContext context,
    TransactionProvider provider,
    String option,
  ) async {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate = DateTime(now.year, now.month, now.day);

    switch (option) {
      case 'thisMonth':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'lastMonth':
        final lastMonth = now.month == 1 ? 12 : now.month - 1;
        final lastYear = now.month == 1 ? now.year - 1 : now.year;
        startDate = DateTime(lastYear, lastMonth, 1);
        endDate =
            DateTime(lastYear, lastMonth, _daysInMonth(lastYear, lastMonth));
        break;
      case 'last3Months':
        startDate = _subtractMonths(now, 3);
        break;
      case 'last6Months':
        startDate = _subtractMonths(now, 6);
        break;
      case 'thisYear':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        provider.setDateRange('all');
        return;
    }

    provider.setCustomDateRange(startDate, endDate);
  }

  bool _isSelectedQuickRange(TransactionProvider provider, String option) {
    if (provider.dateRange != 'custom' || provider.customStartDate == null) {
      return option == 'thisMonth' && provider.dateRange == 'month';
    }

    final now = DateTime.now();
    final start = provider.customStartDate!;
    final end = provider.customEndDate!;

    switch (option) {
      case 'lastMonth':
        final lastMonth = now.month == 1 ? 12 : now.month - 1;
        final lastYear = now.month == 1 ? now.year - 1 : now.year;
        return start == DateTime(lastYear, lastMonth, 1) &&
            end ==
                DateTime(
                    lastYear, lastMonth, _daysInMonth(lastYear, lastMonth));
      case 'last3Months':
        return start == _subtractMonths(now, 3) &&
            end == DateTime(now.year, now.month, now.day);
      case 'last6Months':
        return start == _subtractMonths(now, 6) &&
            end == DateTime(now.year, now.month, now.day);
      default:
        return false;
    }
  }

  DateTime _subtractMonths(DateTime date, int months) {
    final yearOffset = ((date.month - months - 1) / 12).floor();
    final targetYear = date.year + yearOffset;
    final targetMonth = date.month - months - yearOffset * 12;
    final targetDay = date.day;
    final maxDay = _daysInMonth(targetYear, targetMonth);
    return DateTime(targetYear, targetMonth, targetDay.clamp(1, maxDay));
  }

  int _daysInMonth(int year, int month) {
    if (month == 2) {
      return (year % 4 == 0) ? 29 : 28;
    }
    return [1, 3, 5, 7, 8, 10, 12].contains(month) ? 31 : 30;
  }

  Widget _buildDateRangeFilter(
    BuildContext context,
    TransactionProvider provider,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFilterButton(
              'This Month',
              provider.dateRange == 'month',
              () => provider.setDateRange('month'),
              isDark,
            ),
            _buildFilterButton(
              'Last Month',
              _isSelectedQuickRange(provider, 'lastMonth'),
              () => _setQuickDateRange(context, provider, 'lastMonth'),
              isDark,
            ),
            _buildFilterButton(
              'Last 3m',
              _isSelectedQuickRange(provider, 'last3Months'),
              () => _setQuickDateRange(context, provider, 'last3Months'),
              isDark,
            ),
            _buildFilterButton(
              'Last 6m',
              _isSelectedQuickRange(provider, 'last6Months'),
              () => _setQuickDateRange(context, provider, 'last6Months'),
              isDark,
            ),
            _buildFilterButton(
              'This Year',
              provider.dateRange == 'year',
              () => provider.setDateRange('year'),
              isDark,
            ),
            _buildFilterButton(
              'All Time',
              provider.dateRange == 'all',
              () => provider.setDateRange('all'),
              isDark,
            ),
            GestureDetector(
              onTap: () => _openCustomDatePicker(context, provider),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: provider.dateRange == 'custom'
                      ? AppTheme.primary.withValues(alpha: 0.2)
                      : isDark
                          ? Colors.white10
                          : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: provider.dateRange == 'custom'
                        ? AppTheme.primary
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: provider.dateRange == 'custom'
                          ? AppTheme.primary
                          : isDark
                              ? Colors.white70
                              : Colors.grey.shade700,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Pick Date',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: provider.dateRange == 'custom'
                            ? AppTheme.primary
                            : isDark
                                ? Colors.white70
                                : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (provider.dateRange == 'custom' &&
            provider.customStartDate != null &&
            provider.customEndDate != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Range: ${DateFormat('MMM d').format(provider.customStartDate!)} - ${DateFormat('MMM d, yyyy').format(provider.customEndDate!)}',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white60 : Colors.grey.shade600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFilterButton(
    String label,
    bool isSelected,
    VoidCallback onPressed,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withValues(alpha: 0.2)
              : isDark
                  ? Colors.white10
                  : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primary : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected
                ? AppTheme.primary
                : isDark
                    ? Colors.white70
                    : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Future<void> _openCustomDatePicker(
    BuildContext context,
    TransactionProvider provider,
  ) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange:
          provider.customStartDate != null && provider.customEndDate != null
              ? DateTimeRange(
                  start: provider.customStartDate!,
                  end: provider.customEndDate!,
                )
              : null,
    );

    if (picked != null) {
      provider.setCustomDateRange(picked.start, picked.end);
    }
  }
}
