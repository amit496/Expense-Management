import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  static const _sections = [
    _TutorialSection(
      title: 'Getting started',
      steps: [
        _TutorialStep(
          icon: Icons.home_rounded,
          color: AppTheme.primary,
          title: 'Home dashboard',
          description:
              'See your total balance, income, expenses, and recent transactions at a glance.',
          tips: [
            'Pull down to refresh your data.',
            'Tap the month label to view the current period.',
          ],
        ),
        _TutorialStep(
          icon: Icons.add_rounded,
          color: AppTheme.secondary,
          title: 'Add a transaction',
          description:
              'Tap the purple + button on any tab to record income or expense.',
          tips: [
            'Choose type: Income or Expense.',
            'Pick a category, amount, date, and account.',
            'Add an optional note for reference.',
          ],
        ),
      ],
    ),
    _TutorialSection(
      title: 'Track & analyze',
      steps: [
        _TutorialStep(
          icon: Icons.receipt_long_rounded,
          color: AppTheme.primaryLight,
          title: 'Transaction history',
          description:
              'Open the History tab to view, search, filter, and swipe to edit or delete entries.',
          tips: [
            'Filter by type, category, or date range.',
            'Swipe left on a row to edit or delete.',
          ],
        ),
        _TutorialStep(
          icon: Icons.bar_chart_rounded,
          color: AppTheme.income,
          title: 'Stats & charts',
          description:
              'The Stats tab shows spending breakdowns, trends, and category-wise charts.',
          tips: [
            'Switch date ranges to compare periods.',
            'Use insights to spot top spending categories.',
          ],
        ),
        _TutorialStep(
          icon: Icons.savings_rounded,
          color: AppTheme.warning,
          title: 'Budgets',
          description:
              'Set monthly budgets per category and track how much you have left.',
          tips: [
            'Go to the Budget tab to add or edit limits.',
            'Bars turn red when you exceed a budget.',
          ],
        ),
      ],
    ),
    _TutorialSection(
      title: 'Customize',
      steps: [
        _TutorialStep(
          icon: Icons.account_balance_wallet_outlined,
          color: AppTheme.secondary,
          title: 'Accounts & wallets',
          description:
              'Manage Cash, Bank, UPI, and custom wallets in Settings → Accounts.',
          tips: [
            'Assign an account when adding each transaction.',
          ],
        ),
        _TutorialStep(
          icon: Icons.category_outlined,
          color: AppTheme.primary,
          title: 'Custom categories',
          description:
              'Add your own income and expense labels in Settings → Custom categories.',
          tips: [
            'Built-in categories are always available.',
          ],
        ),
        _TutorialStep(
          icon: Icons.dark_mode_rounded,
          color: AppTheme.primaryLight,
          title: 'Theme & currency',
          description:
              'Toggle dark mode and change currency symbol (₹, \$, €, etc.) in Settings.',
        ),
      ],
    ),
    _TutorialSection(
      title: 'Security & backup',
      steps: [
        _TutorialStep(
          icon: Icons.shield_rounded,
          color: AppTheme.income,
          title: 'App lock',
          description:
              'Set a PIN or enable Face ID / fingerprint in Settings → App Lock & Security.',
          tips: [
            'The app locks when you switch away.',
            'Use your PIN if biometrics fail.',
          ],
        ),
        _TutorialStep(
          icon: Icons.backup_rounded,
          color: AppTheme.primary,
          title: 'Export & restore',
          description:
              'Back up all data as a JSON file from Settings → Export full backup.',
          tips: [
            'Restore from backup replaces all current data.',
            'Keep backup files private — they may include your PIN.',
          ],
        ),
        _TutorialStep(
          icon: Icons.mark_email_unread_outlined,
          color: AppTheme.secondary,
          title: 'Scheduled email backup',
          description:
              'Set a weekly or monthly reminder to email your backup when online.',
          tips: [
            'Configure time, frequency, and email in Settings.',
            'Tap the notification to open your mail app with the file attached.',
          ],
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('How to use'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            _buildHeader(isDark),
            const SizedBox(height: 24),
            ..._sections.expand(
              (section) => [
                _buildSectionTitle(section.title),
                const SizedBox(height: 12),
                ...section.steps.map((step) => _TutorialStepCard(
                      step: step,
                      isDark: isDark,
                    )),
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ExpenseTracker Guide',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Learn every feature step by step',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
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
}

class _TutorialSection {
  const _TutorialSection({required this.title, required this.steps});

  final String title;
  final List<_TutorialStep> steps;
}

class _TutorialStep {
  const _TutorialStep({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    this.tips = const [],
  });

  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final List<String> tips;
}

class _TutorialStepCard extends StatefulWidget {
  const _TutorialStepCard({
    required this.step,
    required this.isDark,
  });

  final _TutorialStep step;
  final bool isDark;

  @override
  State<_TutorialStepCard> createState() => _TutorialStepCardState();
}

class _TutorialStepCardState extends State<_TutorialStepCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final step = widget.step;
    final isDark = widget.isDark;
    final hasTips = step.tips.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: hasTips ? () => setState(() => _expanded = !_expanded) : null,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: step.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(step.icon, color: step.color, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            step.description,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              color: isDark ? Colors.white54 : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (hasTips)
                      Icon(
                        _expanded
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                        color: isDark ? Colors.white38 : Colors.grey,
                      ),
                  ],
                ),
                if (hasTips && _expanded) ...[
                  const SizedBox(height: 14),
                  ...step.tips.map(
                    (tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              tip,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.35,
                                color: isDark
                                    ? Colors.white70
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
