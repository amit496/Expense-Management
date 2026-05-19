import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/legal_config.dart';
import '../content/legal_content.dart';
import '../theme/app_theme.dart';
import '../utils/legal_text_builder.dart';
import '../utils/message_helper.dart';

class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({
    super.key,
    required this.documentType,
  });

  final LegalDocumentType documentType;

  @override
  Widget build(BuildContext context) {
    final doc = LegalContent.document(documentType);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(doc.title),
        actions: [
          IconButton(
            tooltip: 'Share',
            icon: const Icon(Icons.share_rounded),
            onPressed: () => _shareDocument(doc),
          ),
          IconButton(
            tooltip: 'Copy all',
            icon: const Icon(Icons.copy_all_rounded),
            onPressed: () => _copyDocument(context, doc),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          if (documentType == LegalDocumentType.privacyPolicy &&
              LegalConfig.privacyPolicyUrl.isNotEmpty) ...[
            _LinkCard(
              isDark: isDark,
              label: 'View online (Play Store URL)',
              onTap: () => _openUrl(context, LegalConfig.privacyPolicyUrl),
            ),
            const SizedBox(height: 16),
          ],
          ...doc.sections.map(
            (section) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.heading,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    section.body,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: isDark ? Colors.white70 : Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (documentType == LegalDocumentType.contact ||
              documentType == LegalDocumentType.privacyPolicy)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: FilledButton.icon(
                onPressed: () => _openEmail(context),
                icon: const Icon(Icons.email_outlined, size: 20),
                label: Text('Email ${LegalConfig.supportEmail}'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _shareDocument(LegalDocument doc) async {
    await Share.share(
      LegalTextBuilder.document(doc.type),
      subject: '${LegalConfig.appName} — ${doc.title}',
    );
  }

  Future<void> _copyDocument(BuildContext context, LegalDocument doc) async {
    final buffer = StringBuffer('${doc.title}\n\n');
    for (final s in doc.sections) {
      buffer.writeln(s.heading);
      buffer.writeln(s.body);
      buffer.writeln();
    }
    await Clipboard.setData(ClipboardData(text: buffer.toString().trim()));
    if (context.mounted) {
      MessageHelper.showSuccess(context, 'Copied to clipboard');
    }
  }

  Future<void> _openEmail(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: LegalConfig.supportEmail,
      queryParameters: {
        'subject': '${LegalConfig.appName} support',
      },
    );
    if (!await launchUrl(uri)) {
      if (context.mounted) {
        MessageHelper.showInfo(
          context,
          'Email: ${LegalConfig.supportEmail}',
        );
      }
    }
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        MessageHelper.showError(context, 'Could not open link');
      }
    }
  }
}

class _LinkCard extends StatelessWidget {
  const _LinkCard({
    required this.isDark,
    required this.label,
    required this.onTap,
  });

  final bool isDark;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Icon(Icons.open_in_new_rounded, color: AppTheme.primary),
              const SizedBox(width: 12),
              Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? Colors.white24 : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
