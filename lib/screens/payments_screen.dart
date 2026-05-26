import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';
import '../theme/app_theme.dart';
import '../utils/message_helper.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_screen.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _search = '';
  String _dateRange = 'month';
  String _directionFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Map<String, List<Map<String, dynamic>>> _groupByDate(
    List<Map<String, dynamic>> transactions,
  ) {
    final grouped = <String, List<Map<String, dynamic>>>{};

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final t in transactions) {
      final date = DateTime.tryParse(t['date'] ?? '');

      if (date == null) continue;

      final dateOnly = DateTime(date.year, date.month, date.day);

      final key = dateOnly == today
          ? 'Today'
          : dateOnly == yesterday
              ? 'Yesterday'
              : DateFormat('MMM dd, yyyy').format(date);

      grouped[key] ??= [];
      grouped[key]!.add(t);
    }

    return grouped;
  }

  List<Map<String, dynamic>> _applyFilters(
    List<Map<String, dynamic>> payments,
  ) {
    final now = DateTime.now();

    var list = List<Map<String, dynamic>>.from(payments);

    /// DATE FILTER
    list = list.where((t) {
      final date = DateTime.tryParse(t['date'] ?? '');

      if (date == null) return false;

      switch (_dateRange) {
        case 'week':
          return now.difference(date).inDays <= 7;

        case 'month':
          return date.month == now.month && date.year == now.year;

        case 'year':
          return date.year == now.year;

        default:
          return true;
      }
    }).toList();

    /// DIRECTION FILTER
    if (_directionFilter != 'All') {
      list = list.where((t) {
        return (t['paymentDirection'] ?? '').toString().toLowerCase() ==
            _directionFilter.toLowerCase();
      }).toList();
    }

    /// SEARCH FILTER
    if (_search.trim().isNotEmpty) {
      final q = _search.toLowerCase().trim();

      list = list.where((t) {
        final title = (t['title'] ?? '').toString().toLowerCase();

        final party = (t['partyName'] ?? '').toString().toLowerCase();

        final purpose = (t['paymentPurpose'] ?? '').toString().toLowerCase();

        final reference = (t['reference'] ?? '').toString().toLowerCase();

        final account = (t['account'] ?? '').toString().toLowerCase();

        final paymentMode = (t['paymentMode'] ?? '').toString().toLowerCase();

        final category = (t['category'] ?? '').toString().toLowerCase();

        return title.contains(q) ||
            party.contains(q) ||
            purpose.contains(q) ||
            reference.contains(q) ||
            account.contains(q) ||
            paymentMode.contains(q) ||
            category.contains(q);
      }).toList();
    }

    /// SORT BY DATE DESC
    list.sort((a, b) {
      final dateA = DateTime.tryParse(a['date'] ?? '') ?? DateTime(2000);

      final dateB = DateTime.tryParse(b['date'] ?? '') ?? DateTime(2000);

      return dateB.compareTo(dateA);
    });

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final payments = _applyFilters(provider.paymentTransactions);

    final grouped = _groupByDate(payments);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: SafeArea(
        child: Column(
          children: [
            /// HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                16,
                20,
                0,
              ),
              child: Row(
                children: [
                  const Text(
                    'Payments',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddTransactionScreen(
                            initialType: 'payment',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.add_rounded,
                      size: 18,
                    ),
                    label: const Text('Add'),
                  ),
                ],
              ),
            ),

            /// SEARCH
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                14,
                20,
                0,
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _search = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search payments...',
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 20,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  suffixIcon: _search.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            size: 18,
                          ),
                          onPressed: () {
                            _searchController.clear();

                            setState(() {
                              _search = '';
                            });
                          },
                        )
                      : null,
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// FILTER CHIPS
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: ['All', 'Given', 'Received'].map((type) {
                    final selected = _directionFilter == type;

                    return Padding(
                      padding: const EdgeInsets.only(
                        right: 8,
                      ),
                      child: FilterChip(
                        label: Text(type),
                        selected: selected,
                        showCheckmark: false,
                        onSelected: (_) {
                          setState(() {
                            _directionFilter = type;
                          });
                        },
                        backgroundColor:
                            isDark ? AppTheme.darkCard : AppTheme.lightCard,
                        selectedColor: AppTheme.secondary.withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: selected
                              ? AppTheme.secondary
                              : isDark
                                  ? Colors.white70
                                  : Colors.grey.shade700,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 13,
                        ),
                        side: BorderSide(
                          color: selected
                              ? AppTheme.secondary
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
            ),

            const SizedBox(height: 8),

            /// DATE FILTER
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: PopupMenuButton<String>(
                  onSelected: (value) {
                    setState(() {
                      _dateRange = value;
                    });
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'week',
                      child: Text('This Week'),
                    ),
                    PopupMenuItem(
                      value: 'month',
                      child: Text('This Month'),
                    ),
                    PopupMenuItem(
                      value: 'year',
                      child: Text('This Year'),
                    ),
                    PopupMenuItem(
                      value: 'all',
                      child: Text('All Time'),
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _dateRange == 'week'
                              ? 'This Week'
                              : _dateRange == 'month'
                                  ? 'This Month'
                                  : _dateRange == 'year'
                                      ? 'This Year'
                                      : 'All Time',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.expand_more,
                          size: 16,
                          color: AppTheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            /// LIST
            Expanded(
              child: payments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.payments_outlined,
                            size: 64,
                            color:
                                isDark ? Colors.white12 : Colors.grey.shade300,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No payments found',
                            style: TextStyle(
                              color: isDark ? Colors.white38 : Colors.grey,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        0,
                        20,
                        100,
                      ),
                      children: _buildGroupedList(
                        context,
                        grouped,
                        provider,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildGroupedList(
    BuildContext context,
    Map<String, List<Map<String, dynamic>>> grouped,
    TransactionProvider provider,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final widgets = <Widget>[];

    for (final entry in grouped.entries) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(
            top: 16,
            bottom: 8,
          ),
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

      for (final t in entry.value) {
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
                    left: Radius.circular(12),
                  ),
                ),
                SlidableAction(
                  onPressed: (_) {
                    final index = provider.getHiveIndex(t);

                    if (index >= 0) {
                      _showDeleteDialog(
                        context,
                        provider,
                        index,
                      );
                    }
                  },
                  backgroundColor: AppTheme.expense,
                  foregroundColor: Colors.white,
                  icon: Icons.delete_rounded,
                  label: 'Delete',
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(12),
                  ),
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
                  _showDeleteDialog(
                    context,
                    provider,
                    index,
                  );
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
    BuildContext context,
    TransactionProvider provider,
    int index,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Payment'),
        content: const Text(
          'Are you sure you want to delete this payment?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteTransaction(index);

              Navigator.pop(ctx);

              MessageHelper.showSuccess(
                context,
                'Payment deleted successfully',
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: AppTheme.expense,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
