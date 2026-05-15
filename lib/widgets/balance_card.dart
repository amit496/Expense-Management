import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class BalanceCard extends StatefulWidget {
  final double balance;
  final double income;
  final double expense;
  final String currency;
  final double? lastMonthExpense;
  final double? lastMonthIncome;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.income,
    required this.expense,
    required this.currency,
    this.lastMonthExpense,
    this.lastMonthIncome,
  });

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _balanceAnim;
  late Animation<double> _incomeAnim;
  late Animation<double> _expenseAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _setupAnimations();
    _controller.forward();
  }

  void _setupAnimations() {
    final curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _balanceAnim = Tween(begin: 0.0, end: widget.balance).animate(curve);
    _incomeAnim = Tween(begin: 0.0, end: widget.income).animate(curve);
    _expenseAnim = Tween(begin: 0.0, end: widget.expense).animate(curve);
  }

  @override
  void didUpdateWidget(BalanceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.balance != widget.balance ||
        oldWidget.income != widget.income ||
        oldWidget.expense != widget.expense) {
      final curveNew = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
      _balanceAnim = Tween(begin: _balanceAnim.value, end: widget.balance).animate(curveNew);
      _incomeAnim = Tween(begin: _incomeAnim.value, end: widget.income).animate(curveNew);
      _expenseAnim = Tween(begin: _expenseAnim.value, end: widget.expense).animate(curveNew);
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        HapticFeedback.mediumImpact();
        _showBreakdown(context);
      },
      child: AnimatedBuilder2(
        listenable: _controller,
        builder: (context, _) => Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Total Balance',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.balance >= 0 ? 'Healthy' : 'Deficit',
                      style: TextStyle(
                        color: widget.balance >= 0
                            ? Colors.greenAccent.shade100
                            : Colors.redAccent.shade100,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.currency} ${_formatAmount(_balanceAnim.value)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              if (_hasComparison) ...[
                const SizedBox(height: 6),
                _buildComparisonRow(),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildSubInfo(
                      icon: Icons.arrow_downward_rounded,
                      label: 'Income',
                      amount: _incomeAnim.value,
                      iconBgColor: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  Container(height: 40, width: 1, color: Colors.white24),
                  Expanded(
                    child: _buildSubInfo(
                      icon: Icons.arrow_upward_rounded,
                      label: 'Expense',
                      amount: _expenseAnim.value,
                      iconBgColor: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _hasComparison =>
      widget.lastMonthExpense != null && widget.lastMonthExpense! > 0;

  Widget _buildComparisonRow() {
    final lastTotal = (widget.lastMonthIncome ?? 0) - (widget.lastMonthExpense ?? 0);
    final diff = widget.balance - lastTotal;
    final isUp = diff >= 0;

    return Row(
      children: [
        Icon(
          isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
          color: isUp ? Colors.greenAccent.shade100 : Colors.redAccent.shade100,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          '${isUp ? '+' : ''}${widget.currency}${diff.abs().toStringAsFixed(0)} vs last month',
          style: TextStyle(
            color: isUp ? Colors.greenAccent.shade100 : Colors.redAccent.shade100,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showBreakdown(BuildContext context) {
    final savingsRate = widget.income > 0
        ? ((widget.income - widget.expense) / widget.income * 100)
        : 0.0;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Financial Summary',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildSummaryRow('Total Income', widget.income),
              _buildSummaryRow('Total Expense', widget.expense),
              Divider(color: Colors.white24, height: 24),
              _buildSummaryRow('Net Balance', widget.balance),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(
                      savingsRate >= 20
                          ? Icons.emoji_events_rounded
                          : Icons.tips_and_updates_rounded,
                      color: Colors.amberAccent,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Savings Rate: ${savingsRate.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            savingsRate >= 30
                                ? 'Excellent! You\'re saving well'
                                : savingsRate >= 20
                                    ? 'Good job! Keep it up'
                                    : savingsRate >= 10
                                        ? 'Try to save at least 20%'
                                        : 'Consider reducing expenses',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
          Text(
            '${widget.currency} ${_formatAmount(amount)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubInfo({
    required IconData icon,
    required String label,
    required double amount,
    required Color iconBgColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(color: Colors.white60, fontSize: 12)),
            Text(
              '${widget.currency} ${_formatAmount(amount)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    if (amount.abs() >= 100000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }
}

class AnimatedBuilder2 extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;

  const AnimatedBuilder2({
    super.key,
    required super.listenable,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, null);
  }
}
