import 'package:flutter/material.dart';

import '../constants/legal_config.dart';
import '../content/legal_content.dart';
import 'package:share_plus/share_plus.dart';

import '../theme/app_theme.dart';
import '../utils/legal_text_builder.dart';
import '../utils/message_helper.dart';
import 'legal_document_screen.dart';

/// All legal and policy documents for Play Store and in-app compliance.
class LegalHubScreen extends StatelessWidget {
  const LegalHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Legal & Policies')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _InfoBanner(isDark: isDark),
          const SizedBox(height: 20),
          _buildSectionTitle('Required policies'),
          const SizedBox(height: 10),
          _PolicyTile(
            isDark: isDark,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'How we handle your data (local-first, no ads)',
            onTap: () => _open(context, LegalDocumentType.privacyPolicy),
          ),
          _PolicyTile(
            isDark: isDark,
            icon: Icons.gavel_rounded,
            title: 'Terms of Service',
            subtitle: 'Rules for using the app',
            onTap: () => _open(context, LegalDocumentType.termsOfService),
          ),
          _PolicyTile(
            isDark: isDark,
            icon: Icons.description_outlined,
            title: 'End User License Agreement',
            subtitle: 'Software license and restrictions',
            onTap: () => _open(context, LegalDocumentType.eula),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Information'),
          const SizedBox(height: 10),
          _PolicyTile(
            isDark: isDark,
            icon: Icons.info_outline_rounded,
            title: 'About Us',
            subtitle: 'Who we are and what the app does',
            onTap: () => _open(context, LegalDocumentType.aboutUs),
          ),
          _PolicyTile(
            isDark: isDark,
            icon: Icons.warning_amber_rounded,
            title: 'Disclaimer',
            subtitle: 'Not financial or tax advice',
            onTap: () => _open(context, LegalDocumentType.disclaimer),
          ),
          _PolicyTile(
            isDark: isDark,
            icon: Icons.child_care_outlined,
            title: 'Children\'s Privacy',
            subtitle: 'Not for users under 13',
            onTap: () => _open(context, LegalDocumentType.childrenPrivacy),
          ),
          _PolicyTile(
            isDark: isDark,
            icon: Icons.shield_outlined,
            title: 'Your Privacy Rights',
            subtitle: 'GDPR / CCPA-style rights on your device',
            onTap: () => _open(context, LegalDocumentType.userRights),
          ),
          _PolicyTile(
            isDark: isDark,
            icon: Icons.block_rounded,
            title: 'Do Not Sell My Info',
            subtitle: 'We do not sell personal data',
            onTap: () => _open(context, LegalDocumentType.doNotSell),
          ),
          _PolicyTile(
            isDark: isDark,
            icon: Icons.rule_rounded,
            title: 'Acceptable Use Policy',
            subtitle: 'Permitted and prohibited use',
            onTap: () => _open(context, LegalDocumentType.acceptableUse),
          ),
          _PolicyTile(
            isDark: isDark,
            icon: Icons.payments_outlined,
            title: 'Refund Policy',
            subtitle: 'Free app; no in-app purchases',
            onTap: () => _open(context, LegalDocumentType.refundPolicy),
          ),
          _PolicyTile(
            isDark: isDark,
            icon: Icons.perm_device_information_outlined,
            title: 'App Permissions Explained',
            subtitle: 'Why each permission is requested',
            onTap: () => _open(context, LegalDocumentType.permissionsGuide),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Google Play'),
          const SizedBox(height: 10),
          _PolicyTile(
            isDark: isDark,
            icon: Icons.security_rounded,
            title: 'Data Safety Guide',
            subtitle: 'Help filling Play Console Data safety form',
            onTap: () => _open(context, LegalDocumentType.dataSafety),
          ),
          _PolicyTile(
            isDark: isDark,
            icon: Icons.checklist_rounded,
            title: 'Play Store Release Checklist',
            subtitle: 'Steps before publishing your app',
            onTap: () => _open(context, LegalDocumentType.playStoreChecklist),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Other'),
          const SizedBox(height: 10),
          _PolicyTile(
            isDark: isDark,
            icon: Icons.code_rounded,
            title: 'Open Source Licenses',
            subtitle: 'Third-party software notices',
            onTap: () => _open(context, LegalDocumentType.openSource),
          ),
          _PolicyTile(
            isDark: isDark,
            icon: Icons.email_outlined,
            title: 'Contact Us',
            subtitle: LegalConfig.supportEmail,
            onTap: () => _open(context, LegalDocumentType.contact),
          ),
          _ShareAllPoliciesTile(isDark: isDark),
          _PolicyTile(
            isDark: isDark,
            icon: Icons.article_outlined,
            title: 'View all package licenses',
            subtitle: 'Full Flutter dependency license page',
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: LegalConfig.appName,
                applicationVersion: LegalConfig.appVersion,
                applicationLegalese: '© ${DateTime.now().year} ${LegalConfig.developerName}',
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Last updated: ${LegalConfig.lastUpdated}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white38 : Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _open(BuildContext context, LegalDocumentType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LegalDocumentScreen(documentType: type),
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

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.storefront_outlined, color: AppTheme.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Google Play requires a Privacy Policy URL in the store listing '
              'that matches this in-app policy. Host the same text on a website '
              'and add the URL in lib/constants/legal_config.dart before release.',
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: isDark ? Colors.white70 : Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareAllPoliciesTile extends StatelessWidget {
  const _ShareAllPoliciesTile({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(14),
        child: ListTile(
          leading: const Icon(Icons.share_rounded, color: AppTheme.secondary),
          title: const Text('Share all policies (text)', style: TextStyle(fontSize: 15)),
          subtitle: Text(
            'Export for your website or Play Store hosting',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white38 : Colors.grey,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: isDark ? Colors.white24 : Colors.grey.shade400,
          ),
          onTap: () async {
            try {
              await Share.share(
                LegalTextBuilder.allPoliciesForHosting(),
                subject: '${LegalConfig.appName} — Legal policies',
              );
            } catch (e) {
              if (context.mounted) {
                MessageHelper.showError(context, 'Share failed: $e');
              }
            }
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

class _PolicyTile extends StatelessWidget {
  const _PolicyTile({
    required this.isDark,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool isDark;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(14),
        child: ListTile(
          leading: Icon(icon, color: AppTheme.primary),
          title: Text(title, style: const TextStyle(fontSize: 15)),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white38 : Colors.grey,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: isDark ? Colors.white24 : Colors.grey.shade400,
          ),
          onTap: onTap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
