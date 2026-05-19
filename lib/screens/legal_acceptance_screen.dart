import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/legal_config.dart';
import '../content/legal_content.dart';
import '../providers/auth_provider.dart';
import '../services/legal_consent_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'legal_document_screen.dart';
import 'lock_screen.dart';

/// Shown once per [LegalConfig.legalConsentVersion] before the app is used.
class LegalAcceptanceScreen extends StatefulWidget {
  const LegalAcceptanceScreen({super.key});

  @override
  State<LegalAcceptanceScreen> createState() => _LegalAcceptanceScreenState();
}

class _LegalAcceptanceScreenState extends State<LegalAcceptanceScreen> {
  bool _agreed = false;

  Future<void> _continue() async {
    if (!_agreed) return;
    await LegalConsentService.accept();
    if (!mounted) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final next = auth.isLocked ? const LockScreen() : const HomeScreen();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => next),
    );
  }

  void _openDoc(LegalDocumentType type) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LegalDocumentScreen(documentType: type)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                children: [
                  Text(
                    'Before you start',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${LegalConfig.appName} stores your expense data on this device only. '
                    'We do not sell your data or show ads. Please read and accept our policies to continue.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: isDark ? Colors.white70 : Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _DocLink(
                    isDark: isDark,
                    title: 'Privacy Policy',
                    onTap: () => _openDoc(LegalDocumentType.privacyPolicy),
                  ),
                  _DocLink(
                    isDark: isDark,
                    title: 'Terms of Service',
                    onTap: () => _openDoc(LegalDocumentType.termsOfService),
                  ),
                  _DocLink(
                    isDark: isDark,
                    title: 'Disclaimer',
                    onTap: () => _openDoc(LegalDocumentType.disclaimer),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'By continuing you confirm you are at least 13 years old (or the minimum age in your region) '
                    'and agree to the Privacy Policy and Terms of Service.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: isDark ? Colors.white38 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CheckboxListTile(
                    value: _agreed,
                    onChanged: (v) => setState(() => _agreed = v ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white70 : Colors.grey.shade800,
                        ),
                        children: [
                          const TextSpan(text: 'I have read and agree to the '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () =>
                                  _openDoc(LegalDocumentType.privacyPolicy),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Terms of Service',
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () =>
                                  _openDoc(LegalDocumentType.termsOfService),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: _agreed ? _continue : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      disabledBackgroundColor:
                          AppTheme.primary.withValues(alpha: 0.35),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Agree and continue'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocLink extends StatelessWidget {
  const _DocLink({
    required this.isDark,
    required this.title,
    required this.onTap,
  });

  final bool isDark;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          dense: true,
          title: Text(title, style: const TextStyle(fontSize: 15)),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: isDark ? Colors.white24 : Colors.grey.shade400,
          ),
          onTap: onTap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
