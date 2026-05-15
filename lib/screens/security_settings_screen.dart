import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/message_helper.dart';
import 'pin_setup_screen.dart';

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Security')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
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
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.shield_rounded,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'App Security',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        auth.isPinEnabled
                            ? 'Your app is protected'
                            : 'Add a PIN to protect your data',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  auth.isPinEnabled
                      ? Icons.lock_rounded
                      : Icons.lock_open_rounded,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 22,
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          _buildSectionTitle('PIN Lock'),
          const SizedBox(height: 10),

          _buildCard(
            isDark: isDark,
            child: SwitchListTile(
              title: const Text('Enable App Lock'),
              subtitle: Text(
                auth.isPinEnabled
                    ? 'PIN is required to open the app'
                    : 'Protect your app with a 4-digit PIN',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.grey,
                ),
              ),
              value: auth.isPinEnabled,
              onChanged: (enabled) async {
                if (enabled) {
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PinSetupScreen(),
                    ),
                  );
                  if (result != true && context.mounted) {
                    MessageHelper.showInfo(
                        context, 'PIN setup cancelled');
                  }
                } else {
                  _showDisableDialog(context, auth);
                }
              },
              activeTrackColor: AppTheme.primary,
              secondary: Icon(
                Icons.pin_rounded,
                color: auth.isPinEnabled
                    ? AppTheme.primary
                    : isDark
                        ? Colors.white38
                        : Colors.grey,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          if (auth.isPinEnabled) ...[
            const SizedBox(height: 10),
            _buildCard(
              isDark: isDark,
              child: ListTile(
                leading:
                    const Icon(Icons.edit_rounded, color: AppTheme.primary),
                title: const Text('Change PIN'),
                subtitle: Text(
                  'Set a new 4-digit PIN',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : Colors.grey,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? Colors.white24 : Colors.grey.shade400,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PinSetupScreen(
                          mode: PinSetupMode.change),
                    ),
                  );
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ],

          const SizedBox(height: 28),

          _buildSectionTitle('Biometric'),
          const SizedBox(height: 10),

          _buildCard(
            isDark: isDark,
            child: SwitchListTile(
              title: Text('Enable ${auth.biometricLabel}'),
              subtitle: Text(
                !auth.isBiometricAvailable
                    ? 'Not available on this device'
                    : !auth.isPinEnabled
                        ? 'Enable PIN lock first'
                        : auth.isBiometricEnabled
                            ? '${auth.biometricLabel} is active'
                            : 'Quick unlock with ${auth.biometricLabel.toLowerCase()}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.grey,
                ),
              ),
              value: auth.isBiometricEnabled,
              onChanged: (auth.isPinEnabled && auth.isBiometricAvailable)
                  ? (enabled) {
                      auth.toggleBiometric();
                      if (enabled) {
                        MessageHelper.showSuccess(
                            context, '${auth.biometricLabel} enabled!');
                      } else {
                        MessageHelper.showInfo(
                            context, '${auth.biometricLabel} disabled');
                      }
                    }
                  : null,
              activeTrackColor: AppTheme.primary,
              secondary: Icon(
                auth.biometricIcon,
                color: auth.isBiometricEnabled
                    ? AppTheme.primary
                    : isDark
                        ? Colors.white38
                        : Colors.grey,
                size: 26,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          const SizedBox(height: 28),

          _buildSectionTitle('Security Tips'),
          const SizedBox(height: 10),
          _buildCard(
            isDark: isDark,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTip(
                    Icons.looks_one_rounded,
                    'Use a PIN that you can remember but others can\'t guess',
                    isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildTip(
                    Icons.looks_two_rounded,
                    'Avoid simple PINs like 1234, 0000, or your birth year',
                    isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildTip(
                    Icons.looks_3_rounded,
                    'Enable biometric for faster and more secure access',
                    isDark,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTip(IconData icon, String text, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white54 : Colors.grey.shade600,
              height: 1.4,
            ),
          ),
        ),
      ],
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

  Widget _buildCard({required bool isDark, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }

  void _showDisableDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Disable App Lock?'),
        content: const Text(
          'Your PIN and biometric settings will be removed. Anyone can access the app without authentication.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              auth.disablePin();
              Navigator.pop(ctx);
              MessageHelper.showWarning(
                  context, 'App lock has been disabled');
            },
            child: const Text('Disable',
                style: TextStyle(color: AppTheme.expense)),
          ),
        ],
      ),
    );
  }
}
