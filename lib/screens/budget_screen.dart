import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_theme.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final monthStr = DateFormat('yyyy-MM').format(now);

    double totalBudget = 0;
    double totalSpent = 0;

    final activeBudgets = provider.budgets
        .where((b) => b['month'] == monthStr)
        .toList();

    for (var b in activeBudgets) {
      totalBudget += (b['limit'] ?? 0.0);
      totalSpent +=
          provider.getSpentForCategory(b['category'] ?? '');
    }

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                const Text(
                  'Budget',
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  DateFormat('MMM yyyy').format(now),
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white54 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Monthly Budget',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(
                            '${provider.currency}${totalBudget.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Spent',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(
                            '${provider.currency}${totalSpent.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: totalBudget > 0
                          ? (totalSpent / totalBudget).clamp(0.0, 1.0)
                          : 0,
                      backgroundColor: Colors.white24,
                      color: totalSpent > totalBudget
                          ? AppTheme.expense
                          : Colors.white,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    totalBudget > 0
                        ? '${provider.currency}${(totalBudget - totalSpent).toStringAsFixed(0)} remaining'
                        : 'No budgets set',
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Category Budgets',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                TextButton.icon(
                  onPressed: () =>
                      _showAddBudgetDialog(context, provider),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: activeBudgets.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.savings_outlined,
                          size: 64,
                          color: isDark
                              ? Colors.white12
                              : Colors.grey.shade300,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No budgets set',
                          style: TextStyle(
                            color: isDark ? Colors.white38 : Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap "Add" to create a budget',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? Colors.white24
                                : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: activeBudgets.length,
                    itemBuilder: (context, index) {
                      final budget = activeBudgets[index];
                      final category = budget['category'] ?? 'Other';
                      final limit = (budget['limit'] ?? 0.0).toDouble();
                      final spent =
                          provider.getSpentForCategory(category);
                      final progress =
                          limit > 0 ? (spent / limit) : 0.0;
                      final cat =
                          provider.categoryForDisplay(category, 'expense');

                      Color progressColor;
                      if (progress >= 0.9) {
                        progressColor = AppTheme.expense;
                      } else if (progress >= 0.7) {
                        progressColor = AppTheme.warning;
                      } else {
                        progressColor = AppTheme.income;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppTheme.darkCard
                              : AppTheme.lightCard,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            Row(
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
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(category,
                                          style: const TextStyle(
                                              fontWeight:
                                                  FontWeight.w500)),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${provider.currency}${spent.toStringAsFixed(0)} / ${provider.currency}${limit.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark
                                              ? Colors.white38
                                              : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${(progress * 100).clamp(0, 999).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: progressColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress.clamp(0.0, 1.0),
                                backgroundColor: isDark
                                    ? Colors.white10
                                    : Colors.grey.shade200,
                                color: progressColor,
                                minHeight: 6,
                              ),
                            ),
                            if (progress >= 0.9)
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 8),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      size: 14,
                                      color: progressColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      progress >= 1.0
                                          ? 'Budget exceeded!'
                                          : 'Almost at limit!',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: progressColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
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
    );
  }

  void _showAddBudgetDialog(
      BuildContext context, TransactionProvider provider) {
    final expenseCats = provider.categoriesForType('expense');
    String selectedCategory = expenseCats.first.name;
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: const Text('Set Budget'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(ctx).brightness == Brightness.dark
                              ? Colors.white54
                              : Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        isExpanded: true,
                        value: selectedCategory,
                        items: expenseCats.map((c) {
                          return DropdownMenuItem(
                            value: c.name,
                            child: Row(
                              children: [
                                Icon(c.icon, color: c.color, size: 20),
                                const SizedBox(width: 10),
                                Text(c.name),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => selectedCategory = val!),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                            decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Budget Limit',
                      prefixText: '${provider.currency} ',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final amount =
                        double.tryParse(amountController.text);
                    if (amount != null && amount > 0) {
                      provider.saveBudget(selectedCategory, amount);
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
