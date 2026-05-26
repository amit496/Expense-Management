import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_theme.dart';

class TransactionTile extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final String currency;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDelete;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.currency,
    this.onTap,
    this.onLongPress,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final type = transaction['type'] ?? 'expense';
    final entryType = (transaction['entryType'] ?? 'transaction').toString();
    final isPayment = entryType == 'payment';
    final paymentDirection =
        (transaction['paymentDirection'] ?? '').toString();
    final cat = context.watch<TransactionProvider>().categoryForDisplay(
        transaction['category'] ?? 'Other', type);
    final date = DateTime.tryParse(transaction['date'] ?? '');
    final isExpense = type == 'expense';
    final amount = (transaction['amount'] ?? 0.0).toDouble();
    final account = transaction['account'] ?? '';
    final paymentMode = (transaction['paymentMode'] ?? '').toString();
    final partyName = (transaction['partyName'] ?? '').toString();
    final purpose = (transaction['paymentPurpose'] ?? '').toString();
    final serviceFrom =
        DateTime.tryParse(transaction['serviceFromDate'] ?? '');
    final serviceTo = DateTime.tryParse(transaction['serviceToDate'] ?? '');
    final reference = (transaction['reference'] ?? '').toString();

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (cat.color).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                cat.icon,
                color: cat.color,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction['title'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        [
                          transaction['category'] ?? '',
                          if (date != null) DateFormat('MMM dd').format(date),
                          if (paymentMode.isNotEmpty) paymentMode,
                          if (account.isNotEmpty) account,
                        ].join('  •  '),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white38 : Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isPayment) ...[
                        const SizedBox(height: 4),
                        Text(
                          [
                            paymentDirection == 'received'
                                ? 'Payment Received'
                                : 'Payment Given',
                            if (paymentMode.isNotEmpty) paymentMode,
                            if (partyName.isNotEmpty) partyName,
                            if (purpose.isNotEmpty) purpose,
                            if (serviceFrom != null && serviceTo != null)
                              '${DateFormat('dd MMM').format(serviceFrom)} - ${DateFormat('dd MMM').format(serviceTo)}',
                            if (serviceFrom != null && serviceTo == null)
                              'From ${DateFormat('dd MMM').format(serviceFrom)}',
                            if (serviceFrom == null && serviceTo != null)
                              'To ${DateFormat('dd MMM').format(serviceTo)}',
                            if (reference.isNotEmpty) 'Ref: $reference',
                          ].join('  •  '),
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white54 : Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (isPayment)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (paymentDirection == 'received'
                              ? AppTheme.income
                              : AppTheme.expense)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      paymentDirection == 'received' ? 'Received' : 'Given',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: paymentDirection == 'received'
                            ? AppTheme.income
                            : AppTheme.expense,
                      ),
                    ),
                  ),
                const SizedBox(height: 6),
                Text(
                  '${isExpense ? '-' : '+'}$currency${amount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isExpense ? AppTheme.expense : AppTheme.income,
                  ),
                ),
              ],
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onDelete,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: 19,
                    color: isDark
                        ? Colors.white24
                        : Colors.grey.shade400,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
