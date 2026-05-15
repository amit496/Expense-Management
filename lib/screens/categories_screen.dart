import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';
import '../theme/app_theme.dart';
import '../utils/message_helper.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<TransactionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom categories'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'Expense'),
            Tab(text: 'Income'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _CategoryListPanel(
            type: 'expense',
            isDark: isDark,
            names: provider.customCategoryNamesOnly('expense'),
            provider: provider,
          ),
          _CategoryListPanel(
            type: 'income',
            isDark: isDark,
            names: provider.customCategoryNamesOnly('income'),
            provider: provider,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final type = _tab.index == 0 ? 'expense' : 'income';
          _showAddDialog(context, provider, type);
        },
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add category', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showAddDialog(
    BuildContext context,
    TransactionProvider provider,
    String type,
  ) {
    final controller = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final label = type == 'income' ? 'income' : 'expense';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkCard : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('New $label category'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'e.g. Gym, Childcare',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final err =
                  await provider.addCustomCategory(type, controller.text);
              if (!ctx.mounted) return;
              if (err != null) {
                MessageHelper.showError(ctx, err);
                return;
              }
              Navigator.pop(ctx);
              if (context.mounted) {
                MessageHelper.showSuccess(context, 'Category added');
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _CategoryListPanel extends StatelessWidget {
  const _CategoryListPanel({
    required this.type,
    required this.isDark,
    required this.names,
    required this.provider,
  });

  final String type;
  final bool isDark;
  final List<String> names;
  final TransactionProvider provider;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
        Text(
          type == 'expense'
              ? 'These appear alongside built-in expense categories when you add '
                  'or edit a transaction. Built-in categories (Food, Bills, etc.) '
                  'cannot be removed.'
              : 'Same for income — e.g. Bonus, Rent received. Built-in income '
                  'categories stay as they are.',
          style: TextStyle(
            fontSize: 13,
            height: 1.35,
            color: isDark ? Colors.white54 : Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 20),
        if (names.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Center(
              child: Text(
                'No custom categories yet.\nTap “Add category”.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.grey,
                ),
              ),
            ),
          )
        else
          ...names.map((name) {
            final inUse = provider.isCategoryInUse(name);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.label_outline_rounded,
                    color: AppTheme.primary.withValues(alpha: 0.9),
                  ),
                  title: Text(name),
                  subtitle: Text(
                    inUse ? 'In use by transactions' : 'Not used',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : Colors.grey,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded),
                    color: AppTheme.expense,
                    tooltip: 'Remove',
                    onPressed: inUse
                        ? null
                        : () => _confirmRemove(context, provider, type, name),
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  void _confirmRemove(
    BuildContext context,
    TransactionProvider provider,
    String type,
    String name,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkCard : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove category?'),
        content: Text('Remove “$name” from your custom list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final err = await provider.removeCustomCategory(type, name);
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              if (context.mounted) {
                if (err != null) {
                  MessageHelper.showError(context, err);
                } else {
                  MessageHelper.showSuccess(context, 'Category removed');
                }
              }
            },
            child: const Text('Remove', style: TextStyle(color: AppTheme.expense)),
          ),
        ],
      ),
    );
  }
}
