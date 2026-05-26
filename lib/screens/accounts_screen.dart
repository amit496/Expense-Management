import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';
import '../theme/app_theme.dart';
import '../utils/message_helper.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<TransactionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank / Wallet Accounts'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        children: [
          Text(
            'Use separate bank accounts or wallets for each source of money. '
            'Examples: Cash Wallet, UPI Wallet, SBI Bank, HDFC Bank.',
            style: TextStyle(
              fontSize: 13,
              height: 1.35,
              color: isDark ? Colors.white54 : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 20),
          ...provider.accounts.map((name) {
            final inUse = provider.isAccountInUse(name);
            final onlyAccountLeft = provider.accounts.length <= 1;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.account_balance_wallet_outlined,
                    color: AppTheme.primary.withValues(alpha: 0.9),
                  ),
                  title: Text(name),
                  subtitle: Text(
                    onlyAccountLeft
                        ? 'At least one account is required'
                        : inUse
                            ? 'In use by transactions'
                            : 'Not used',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : Colors.grey,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded),
                    color: AppTheme.expense,
                    tooltip: 'Remove',
                    onPressed: onlyAccountLeft || inUse
                        ? null
                        : () => _confirmRemove(context, provider, name),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context, provider),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Add bank / wallet',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context, TransactionProvider provider) {
    final controller = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkCard : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('New bank / wallet'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'e.g. SBI Bank, UPI Wallet',
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
              final name = controller.text.trim();
              if (name.isEmpty) {
                MessageHelper.showError(ctx, 'Enter a name');
                return;
              }
              final err = await provider.addAccount(name);
              if (!ctx.mounted) return;
              if (err != null) {
                MessageHelper.showError(ctx, err);
                return;
              }
              Navigator.pop(ctx);
              if (context.mounted) {
                MessageHelper.showSuccess(context, 'Bank / wallet added');
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmRemove(
    BuildContext context,
    TransactionProvider provider,
    String name,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkCard : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove bank / wallet?'),
        content: Text('Remove “$name” from the list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final err = await provider.removeAccount(name);
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              if (context.mounted) {
                if (err != null) {
                  MessageHelper.showError(context, err);
                } else {
                  MessageHelper.showSuccess(context, 'Bank / wallet removed');
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
