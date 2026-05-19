import '../constants/legal_config.dart';

enum LegalDocumentType {
  privacyPolicy,
  termsOfService,
  eula,
  aboutUs,
  disclaimer,
  acceptableUse,
  refundPolicy,
  permissionsGuide,
  doNotSell,
  dataSafety,
  playStoreChecklist,
  openSource,
  contact,
  childrenPrivacy,
  userRights,
}

class LegalDocument {
  const LegalDocument({
    required this.type,
    required this.title,
    required this.sections,
  });

  final LegalDocumentType type;
  final String title;
  final List<LegalSection> sections;
}

class LegalSection {
  const LegalSection({required this.heading, required this.body});

  final String heading;
  final String body;
}

class LegalContent {
  LegalContent._();

  static LegalDocument document(LegalDocumentType type) {
    return switch (type) {
      LegalDocumentType.privacyPolicy => _privacyPolicy(),
      LegalDocumentType.termsOfService => _termsOfService(),
      LegalDocumentType.eula => _eula(),
      LegalDocumentType.aboutUs => _aboutUs(),
      LegalDocumentType.disclaimer => _disclaimer(),
      LegalDocumentType.acceptableUse => _acceptableUse(),
      LegalDocumentType.refundPolicy => _refundPolicy(),
      LegalDocumentType.permissionsGuide => _permissionsGuide(),
      LegalDocumentType.doNotSell => _doNotSell(),
      LegalDocumentType.dataSafety => _dataSafety(),
      LegalDocumentType.playStoreChecklist => _playStoreChecklist(),
      LegalDocumentType.openSource => _openSource(),
      LegalDocumentType.contact => _contact(),
      LegalDocumentType.childrenPrivacy => _childrenPrivacy(),
      LegalDocumentType.userRights => _userRights(),
    };
  }

  static List<LegalDocument> allDocuments() => LegalDocumentType.values
      .map(document)
      .toList();

  static String _footer() =>
      'Last updated: ${LegalConfig.lastUpdated}\n'
      '${LegalConfig.appName} v${LegalConfig.appVersion}';

  static LegalDocument _privacyPolicy() => LegalDocument(
        type: LegalDocumentType.privacyPolicy,
        title: 'Privacy Policy',
        sections: [
          LegalSection(
            heading: 'Introduction',
            body:
                'This Privacy Policy describes how ${LegalConfig.appName} '
                '(“the App”), developed by ${LegalConfig.developerName}, '
                'handles information when you use our personal expense '
                'management application on your mobile device.\n\n'
                'We designed the App to work primarily offline. We do not '
                'operate user accounts, cloud servers, or advertising networks '
                'for the App. By using the App, you agree to this Privacy Policy.',
          ),
          LegalSection(
            heading: 'Information We Collect',
            body:
                'The App stores data locally on your device only. This may include:\n\n'
                '• Financial transactions you enter (amount, category, date, notes, account)\n'
                '• Budgets, savings goals, and custom categories\n'
                '• Account and wallet labels you create\n'
                '• App preferences (theme, currency symbol, tutorial completion)\n'
                '• Optional app lock PIN (stored on your device)\n'
                '• Optional biometric unlock preference (handled by your device OS)\n'
                '• Scheduled backup settings (time, frequency, email address you provide)\n\n'
                'We do not collect your name, phone number, or government ID through the App. '
                'We do not sell your personal information.',
          ),
          LegalSection(
            heading: 'Information We Do Not Collect',
            body:
                'The App does not include:\n\n'
                '• User registration or login to our servers\n'
                '• Third-party analytics (e.g. Google Analytics, Firebase Analytics)\n'
                '• Advertising or ad identifiers\n'
                '• Automatic upload of your transactions to our servers\n'
                '• Social media integration that shares your financial data\n\n'
                'We do not track you across other companies’ apps or websites.',
          ),
          LegalSection(
            heading: 'How Data Is Stored',
            body:
                'Your data is saved in local on-device storage (Hive database) on your phone or tablet. '
                'It remains on your device unless you export it, restore a backup, clear data, or uninstall the App.\n\n'
                'If you enable App Lock, your PIN is stored on the device to verify unlock. '
                'Biometric authentication uses your device’s secure hardware and OS; '
                'we do not receive or store your fingerprint or face data.',
          ),
          LegalSection(
            heading: 'Backup, Export, and Email',
            body:
                'You may export a full backup (JSON) via the system share/save dialog, '
                'or copy transaction data as CSV to your clipboard from the Dashboard. '
                'You choose where files are saved (cloud drive, email, messaging, etc.). '
                'We do not receive those files.\n\n'
                'Scheduled email backup sends a local reminder notification. '
                'When you act on it, your device’s email app may open with a backup attachment. '
                'Sending email uses your chosen email provider; their privacy policy applies. '
                'Backup files may contain sensitive data including your PIN if app lock is enabled—'
                'protect backup files accordingly.',
          ),
          LegalSection(
            heading: 'Permissions',
            body:
                'The App may request device permissions only when needed for features you use:\n\n'
                '• Notifications — for scheduled backup reminders (optional)\n'
                '• Biometric / device credentials — for optional app lock\n'
                '• Internet / network state — to detect connectivity for backup reminders\n'
                '• Storage / files — when you pick or save backup files via the system file picker\n\n'
                'You can deny permissions; related features may not work until granted.',
          ),
          LegalSection(
            heading: 'Third-Party Services',
            body:
                'The App uses open-source Flutter packages (local database, charts, sharing, '
                'notifications, email intent, file picker, etc.). These libraries run on your device '
                'and do not send your transaction data to us.\n\n'
                'When you share or email data, third-party apps (Gmail, Drive, WhatsApp, etc.) '
                'process data under their own policies.',
          ),
          LegalSection(
            heading: 'Data Retention and Deletion',
            body:
                'Data is kept on your device until you delete it. You can:\n\n'
                '• Delete individual transactions in the App\n'
                '• Use Settings → Clear All Data to remove transactions and budgets\n'
                '• Uninstall the App to remove local app data from your device\n\n'
                'Exported backup files on other storage are your responsibility to delete.',
          ),
          LegalSection(
            heading: 'Children’s Privacy',
            body:
                'The App is not directed at children under 13 (or the minimum age in your country). '
                'We do not knowingly collect personal information from children. '
                'See “Children’s Privacy” in Settings for more detail.',
          ),
          LegalSection(
            heading: 'International Users',
            body:
                'Because data stays on your device, it is primarily under your control. '
                'If you are in the European Economic Area, UK, or other regions with privacy laws, '
                'you may have additional rights described under “Your Privacy Rights” in Settings.',
          ),
          LegalSection(
            heading: 'Security',
            body:
                'We recommend using device screen lock and optional App Lock in Settings. '
                'No method of electronic storage is 100% secure; you are responsible for '
                'protecting your device and backup files.',
          ),
          LegalSection(
            heading: 'Data Breach',
            body:
                'We do not store your transaction data on our servers. '
                'Security incidents affecting your information would most likely relate to '
                'loss or theft of your device, or compromise of backup files you stored elsewhere. '
                'Report suspected issues to ${LegalConfig.supportEmail}.',
          ),
          LegalSection(
            heading: 'California — Do Not Sell',
            body:
                'We do not sell personal information. See “Do Not Sell My Info” in Settings for details.',
          ),
          LegalSection(
            heading: 'Changes to This Policy',
            body:
                'We may update this Privacy Policy from time to time. We will update the '
                '“Last updated” date in the App. Continued use after changes means you accept '
                'the updated policy. For material changes, we may show an in-app notice.',
          ),
          LegalSection(
            heading: 'Contact Us',
            body:
                'Questions about this Privacy Policy:\n\n'
                'Email: ${LegalConfig.supportEmail}\n\n'
                '${LegalConfig.privacyPolicyUrl.isNotEmpty ? 'Web: ${LegalConfig.privacyPolicyUrl}\n\n' : ''}'
                '${_footer()}',
          ),
        ],
      );

  static LegalDocument _termsOfService() => LegalDocument(
        type: LegalDocumentType.termsOfService,
        title: 'Terms of Service',
        sections: [
          LegalSection(
            heading: 'Agreement',
            body:
                'These Terms of Service (“Terms”) govern your use of ${LegalConfig.appName} '
                'provided by ${LegalConfig.developerName}. By installing or using the App, '
                'you agree to these Terms and our Privacy Policy. If you do not agree, do not use the App.',
          ),
          LegalSection(
            heading: 'License',
            body:
                'We grant you a personal, non-exclusive, non-transferable, revocable license '
                'to use the App on devices you own or control, for personal expense tracking, '
                'subject to these Terms and applicable store rules (Google Play, App Store, etc.).',
          ),
          LegalSection(
            heading: 'Eligibility',
            body:
                'You must be old enough to enter a binding agreement in your jurisdiction '
                '(typically 18, or age of majority). The App is not for users under 13.',
          ),
          LegalSection(
            heading: 'Your Responsibilities',
            body:
                'You agree to:\n\n'
                '• Enter accurate information at your own discretion\n'
                '• Keep your device and backups secure\n'
                '• Not use the App for unlawful purposes\n'
                '• Not reverse engineer or redistribute the App except as allowed by law\n'
                '• Maintain your own backups; we are not responsible for lost device data',
          ),
          LegalSection(
            heading: 'No Financial Advice',
            body:
                'The App is a record-keeping tool only. It does not provide tax, investment, '
                'accounting, or legal advice. Consult qualified professionals for financial decisions.',
          ),
          LegalSection(
            heading: 'Free App; No Purchases',
            body:
                'The App is currently provided free of charge without in-app purchases or subscriptions. '
                'If paid features are added later, we will update these Terms and store listings.',
          ),
          LegalSection(
            heading: 'Disclaimer of Warranties',
            body:
                'THE APP IS PROVIDED “AS IS” AND “AS AVAILABLE” WITHOUT WARRANTIES OF ANY KIND, '
                'EXPRESS OR IMPLIED, INCLUDING MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, '
                'AND NON-INFRINGEMENT. WE DO NOT WARRANT THAT THE APP WILL BE ERROR-FREE OR UNINTERRUPTED.',
          ),
          LegalSection(
            heading: 'Limitation of Liability',
            body:
                'TO THE MAXIMUM EXTENT PERMITTED BY LAW, ${LegalConfig.developerName.toUpperCase()} '
                'AND ITS AFFILIATES SHALL NOT BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, '
                'CONSEQUENTIAL, OR PUNITIVE DAMAGES, OR LOSS OF DATA, PROFITS, OR GOODWILL, '
                'ARISING FROM YOUR USE OF THE APP. OUR TOTAL LIABILITY SHALL NOT EXCEED THE AMOUNT '
                'YOU PAID FOR THE APP IN THE PAST 12 MONTHS (ZERO IF THE APP IS FREE).',
          ),
          LegalSection(
            heading: 'Indemnification',
            body:
                'You agree to indemnify and hold harmless ${LegalConfig.developerName} from claims '
                'arising from your misuse of the App or violation of these Terms.',
          ),
          LegalSection(
            heading: 'Termination',
            body:
                'You may stop using the App at any time by uninstalling it. We may discontinue '
                'or modify the App without liability. Sections that by nature should survive '
                '(disclaimers, liability limits) will survive termination.',
          ),
          LegalSection(
            heading: 'Governing Law',
            body:
                'These Terms are governed by the laws applicable in your place of residence or '
                'the jurisdiction where ${LegalConfig.developerName} is established, without regard '
                'to conflict-of-law rules. Courts in that jurisdiction may have exclusive venue '
                'unless mandatory consumer protection laws in your country require otherwise.',
          ),
          LegalSection(
            heading: 'Contact',
            body:
                'Questions about these Terms: ${LegalConfig.supportEmail}\n\n${_footer()}',
          ),
        ],
      );

  static LegalDocument _aboutUs() => LegalDocument(
        type: LegalDocumentType.aboutUs,
        title: 'About Us',
        sections: [
          LegalSection(
            heading: 'Who We Are',
            body:
                '${LegalConfig.developerName} develops ${LegalConfig.appName} — a simple, '
                'privacy-focused expense manager for individuals and families who want to '
                'track spending without signing up for cloud accounts.',
          ),
          LegalSection(
            heading: 'Our Mission',
            body:
                'We believe personal finance data should stay on your device by default. '
                'Our goal is to help you understand income, expenses, budgets, and savings goals '
                'with clear charts and tools — without ads or selling your data.',
          ),
          LegalSection(
            heading: 'What the App Offers',
            body:
                '• Dashboard with balance and recent activity\n'
                '• Income and expense transactions with categories\n'
                '• Multiple accounts (cash, bank, UPI, custom wallets)\n'
                '• Budgets and monthly savings goals\n'
                '• Statistics and charts\n'
                '• Dark mode and multiple currency symbols\n'
                '• Optional PIN and biometric app lock\n'
                '• Local backup export, restore, and optional scheduled email reminders\n'
                '• Tutorial and help inside the App',
          ),
          LegalSection(
            heading: 'Privacy-First Design',
            body:
                'No account required. No ads. No analytics SDKs sending your transactions to us. '
                'You control exports and backups.',
          ),
          LegalSection(
            heading: 'Get in Touch',
            body:
                'Feedback and support: ${LegalConfig.supportEmail}\n\n'
                'Package: ${LegalConfig.packageName}\n'
                '${_footer()}',
          ),
        ],
      );

  static LegalDocument _disclaimer() => LegalDocument(
        type: LegalDocumentType.disclaimer,
        title: 'Disclaimer',
        sections: [
          LegalSection(
            heading: 'General',
            body:
                'Information in ${LegalConfig.appName} is for personal reference only. '
                'It does not constitute professional financial, tax, or legal advice.',
          ),
          LegalSection(
            heading: 'Accuracy',
            body:
                'Calculations and summaries depend on data you enter. We are not responsible '
                'for errors from incorrect input, device failure, or corrupted backup files.',
          ),
          LegalSection(
            heading: 'No Bank Connection',
            body:
                'The App does not connect to banks or payment systems automatically. '
                'Figures may differ from official bank statements.',
          ),
          LegalSection(
            heading: 'Use at Your Own Risk',
            body:
                'You use the App at your own risk. See Terms of Service for warranty and '
                'liability limitations.\n\n${_footer()}',
          ),
        ],
      );

  static LegalDocument _dataSafety() => LegalDocument(
        type: LegalDocumentType.dataSafety,
        title: 'Data Safety (Play Store)',
        sections: [
          LegalSection(
            heading: 'Summary for Google Play Data Safety',
            body:
                'Use this section when completing the Play Console “Data safety” form. '
                'Adjust answers if you change the App.',
          ),
          LegalSection(
            heading: 'Data collection',
            body:
                '• Does the app collect or share user data? — Generally NO server collection by us. '
                'Data is stored locally on the device.\n'
                '• Data is encrypted in transit — N/A for our servers (we have none). '
                'If user emails a backup, the email provider handles transit encryption.\n'
                '• Data is encrypted at rest — Depends on device full-disk encryption; '
                'app data is in local app storage.',
          ),
          LegalSection(
            heading: 'Data types (device-only, not sent to developer)',
            body:
                'Users may enter financial info (transactions, amounts, categories). '
                'Optional email address for scheduled backup reminders (stored locally). '
                'Optional PIN for app lock (stored locally). '
                'App activity is not logged on our servers.',
          ),
          LegalSection(
            heading: 'Purposes',
            body:
                'App functionality only. Not used for advertising or marketing by the developer. '
                'Not sold to third parties.',
          ),
          LegalSection(
            heading: 'Deletion',
            body:
                'Users can delete data via in-app Clear All Data or uninstall. '
                'No developer account deletion needed (no accounts).',
          ),
          LegalSection(
            heading: 'Permissions declared',
            body:
                'Internet / network — connectivity checks for backup reminders.\n'
                'Notifications — optional scheduled reminders.\n'
                'Biometric — optional app lock.\n'
                'Storage — user-initiated backup import/export.\n\n${_footer()}',
          ),
        ],
      );

  static LegalDocument _openSource() => LegalDocument(
        type: LegalDocumentType.openSource,
        title: 'Open Source Licenses',
        sections: [
          LegalSection(
            heading: 'Software',
            body:
                '${LegalConfig.appName} is built with Flutter and open-source packages including '
                'Hive, Provider, fl_chart, local_auth, share_plus, file_picker, '
                'flutter_local_notifications, connectivity_plus, and others.\n\n'
                'Tap “View all licenses” in Settings → Legal to see the full license list '
                'provided by the Flutter framework.',
          ),
          LegalSection(
            heading: 'Trademarks',
            body:
                'Google Play and Android are trademarks of Google LLC. '
                'Apple and App Store are trademarks of Apple Inc. '
                'Other names may be trademarks of their respective owners.\n\n${_footer()}',
          ),
        ],
      );

  static LegalDocument _contact() => LegalDocument(
        type: LegalDocumentType.contact,
        title: 'Contact Us',
        sections: [
          LegalSection(
            heading: 'Support',
            body:
                'For help, bug reports, privacy requests, or feedback:\n\n'
                'Email: ${LegalConfig.supportEmail}\n\n'
                'We aim to respond within a reasonable time (typically within 5–7 business days).',
          ),
          LegalSection(
            heading: 'Play Store listing',
            body:
                'App name: ${LegalConfig.appName}\n'
                'Package: ${LegalConfig.packageName}\n'
                'Version: ${LegalConfig.appVersion}\n\n${_footer()}',
          ),
        ],
      );

  static LegalDocument _childrenPrivacy() => LegalDocument(
        type: LegalDocumentType.childrenPrivacy,
        title: 'Children\'s Privacy',
        sections: [
          LegalSection(
            heading: 'Age restriction',
            body:
                '${LegalConfig.appName} is not intended for children under 13 years of age '
                '(or under 16 in the EEA where applicable). We do not knowingly collect '
                'personal information from children.',
          ),
          LegalSection(
            heading: 'Parental notice',
            body:
                'If you believe a child has provided information through the App, contact us at '
                '${LegalConfig.supportEmail}. Because data is stored locally, removing the App '
                'from the child’s device or using Clear All Data will delete local records.\n\n${_footer()}',
          ),
        ],
      );

  static LegalDocument _userRights() => LegalDocument(
        type: LegalDocumentType.userRights,
        title: 'Your Privacy Rights',
        sections: [
          LegalSection(
            heading: 'Overview',
            body:
                'Depending on where you live (e.g. EU/EEA GDPR, UK GDPR, California CCPA/CPRA), '
                'you may have rights regarding personal information. Because we do not operate '
                'accounts or store your transaction data on our servers, many requests are '
                'fulfilled directly on your device.',
          ),
          LegalSection(
            heading: 'Rights may include',
            body:
                '• Access — view your data in the App\n'
                '• Correction — edit transactions and settings\n'
                '• Deletion — Clear All Data or uninstall\n'
                '• Portability — export backup (JSON) or CSV\n'
                '• Objection / restriction — stop using optional features (notifications, biometrics)\n'
                '• Withdraw consent — disable optional permissions in system settings',
          ),
          LegalSection(
            heading: 'How to exercise rights',
            body:
                'Use in-app tools first. For questions or complaints, email ${LegalConfig.supportEmail}. '
                'You may also lodge a complaint with your local data protection authority.\n\n${_footer()}',
          ),
        ],
      );

  static LegalDocument _eula() => LegalDocument(
        type: LegalDocumentType.eula,
        title: 'End User License Agreement',
        sections: [
          LegalSection(
            heading: 'License grant',
            body:
                '${LegalConfig.developerName} grants you a limited, non-exclusive, non-transferable, '
                'revocable license to install and use ${LegalConfig.appName} on devices you own or control, '
                'solely for personal, non-commercial expense tracking.',
          ),
          LegalSection(
            heading: 'Restrictions',
            body:
                'You may not:\n\n'
                '• Copy, modify, or distribute the App except as permitted by law\n'
                '• Reverse engineer or attempt to extract source code (except where law allows)\n'
                '• Remove copyright or proprietary notices\n'
                '• Use the App to build a competing product\n'
                '• Rent, lease, or sublicense the App',
          ),
          LegalSection(
            heading: 'Ownership',
            body:
                'The App, including design, code, and branding, is owned by ${LegalConfig.developerName} '
                'and protected by copyright and other laws. This EULA does not sell you the App—only a license to use it.',
          ),
          LegalSection(
            heading: 'Updates',
            body:
                'We may provide updates through app stores. Some updates may be required for continued use. '
                'Updates are subject to this EULA unless accompanied by new terms.',
          ),
          LegalSection(
            heading: 'Termination',
            body:
                'This license ends if you violate the EULA or Terms of Service, or if you uninstall the App. '
                'Upon termination, you must stop using and delete all copies of the App.',
          ),
          LegalSection(
            heading: 'Related documents',
            body:
                'This EULA supplements the Terms of Service and Privacy Policy. '
                'If there is a conflict, the Terms of Service prevail for liability and use rules.\n\n${_footer()}',
          ),
        ],
      );

  static LegalDocument _acceptableUse() => LegalDocument(
        type: LegalDocumentType.acceptableUse,
        title: 'Acceptable Use Policy',
        sections: [
          LegalSection(
            heading: 'Purpose',
            body:
                'This policy describes permitted use of ${LegalConfig.appName}. '
                'It is part of our Terms of Service.',
          ),
          LegalSection(
            heading: 'Permitted use',
            body:
                'Use the App for lawful personal or household finance tracking, budgeting, and backups you control.',
          ),
          LegalSection(
            heading: 'Prohibited use',
            body:
                'You must not:\n\n'
                '• Use the App for illegal activity, fraud, or money laundering\n'
                '• Attempt to hack, disrupt, or overload the App\n'
                '• Upload malware through backup import features\n'
                '• Impersonate others or misrepresent financial records for deceptive purposes\n'
                '• Use the App if you are under the minimum age in your region (13+; 16+ in parts of the EEA)',
          ),
          LegalSection(
            heading: 'Enforcement',
            body:
                'We may discontinue access or report violations to authorities where required by law. '
                'Because the App is offline-first, enforcement is primarily through store removal or legal process.\n\n${_footer()}',
          ),
        ],
      );

  static LegalDocument _refundPolicy() => LegalDocument(
        type: LegalDocumentType.refundPolicy,
        title: 'Refund Policy',
        sections: [
          LegalSection(
            heading: 'Free application',
            body:
                '${LegalConfig.appName} is currently offered free of charge with no in-app purchases or subscriptions. '
                'No payment is collected by us through the App at this time.',
          ),
          LegalSection(
            heading: 'Paid features (future)',
            body:
                'If we introduce paid features or subscriptions later, refunds will follow the policies of '
                'Google Play or the Apple App Store through which you paid. Contact the store for purchase disputes.',
          ),
          LegalSection(
            heading: 'Questions',
            body:
                'Billing questions: ${LegalConfig.supportEmail}\n\n${_footer()}',
          ),
        ],
      );

  static LegalDocument _permissionsGuide() => LegalDocument(
        type: LegalDocumentType.permissionsGuide,
        title: 'App Permissions Explained',
        sections: [
          LegalSection(
            heading: 'Overview',
            body:
                'The App requests permissions only when needed. You can deny them in device Settings; '
                'some features will not work until allowed.',
          ),
          LegalSection(
            heading: 'Notifications',
            body:
                'Used for: optional scheduled backup reminders.\n'
                'When requested: enabling scheduled email backup.\n'
                'If denied: reminders will not appear; you can still export backups manually.',
          ),
          LegalSection(
            heading: 'Biometric / device credentials',
            body:
                'Used for: optional app lock (fingerprint, Face ID, or device PIN).\n'
                'When requested: enabling biometric unlock in Settings → App Lock.\n'
                'If denied: you can still use a numeric PIN if enabled.',
          ),
          LegalSection(
            heading: 'Internet & network',
            body:
                'Used for: checking if the device is online before backup email reminders.\n'
                'Data sent to us: none. No cloud sync.',
          ),
          LegalSection(
            heading: 'Storage & files',
            body:
                'Used for: choosing a backup file to restore, or saving a shared backup export.\n'
                'When requested: import/export backup actions you start.',
          ),
          LegalSection(
            heading: 'Manage permissions',
            body:
                'Android: Settings → Apps → ${LegalConfig.appName} → Permissions\n'
                'iPhone: Settings → ${LegalConfig.appName}\n\n${_footer()}',
          ),
        ],
      );

  static LegalDocument _doNotSell() => LegalDocument(
        type: LegalDocumentType.doNotSell,
        title: 'Do Not Sell My Personal Information',
        sections: [
          LegalSection(
            heading: 'California & similar laws',
            body:
                'Residents of California and certain other U.S. states have the right to opt out of the '
                '“sale” or “sharing” of personal information for cross-context behavioral advertising.',
          ),
          LegalSection(
            heading: 'Our practice',
            body:
                '${LegalConfig.developerName} does not sell your personal information. '
                'We do not share your transaction data with advertisers or data brokers. '
                'The App does not use advertising SDKs.',
          ),
          LegalSection(
            heading: 'No opt-out needed',
            body:
                'Because we do not sell personal information, there is no sale to opt out of. '
                'For privacy requests, contact ${LegalConfig.supportEmail}.\n\n${_footer()}',
          ),
        ],
      );

  static LegalDocument _playStoreChecklist() => LegalDocument(
        type: LegalDocumentType.playStoreChecklist,
        title: 'Play Store Release Checklist',
        sections: [
          LegalSection(
            heading: 'Before you publish',
            body:
                'Use this checklist when submitting to Google Play. Update legal_config.dart first.',
          ),
          LegalSection(
            heading: 'Developer account',
            body:
                '• Create a Google Play Developer account (one-time fee)\n'
                '• Complete identity and payments profile if required',
          ),
          LegalSection(
            heading: 'App listing',
            body:
                '• Unique application ID (change com.example.* in build.gradle)\n'
                '• App name, short & full description\n'
                '• Screenshots (phone; tablet if supported)\n'
                '• Feature graphic & hi-res icon\n'
                '• Privacy Policy URL (host same text as in-app; set privacyPolicyUrl)\n'
                '• Contact email (set supportEmail in legal_config.dart)\n'
                '• Category: Finance\n'
                '• Content rating questionnaire (likely Everyone / low maturity)\n'
                '• Target audience: not designed for children under 13',
          ),
          LegalSection(
            heading: 'Data safety form',
            body:
                '• Open Settings → Data Safety Guide in this app\n'
                '• Declare: no data collected by developer to servers\n'
                '• Financial info: collected on device only, not shared with developer\n'
                '• Optional: email stored locally for backup reminders\n'
                '• Security practices: data deleted on request (Clear All Data)\n'
                '• Ads: No\n'
                '• Account required: No',
          ),
          LegalSection(
            heading: 'Policies & compliance',
            body:
                '• In-app Privacy Policy & Terms (Settings → Legal)\n'
                '• First-launch consent screen included\n'
                '• Declare permissions used (notifications, biometrics, network, storage)\n'
                '• Sign release build (not debug keystore for production)\n'
                '• Test on real device before upload',
          ),
          LegalSection(
            heading: 'After upload',
            body:
                '• Complete store listing review\n'
                '• Respond to policy or rejection emails promptly\n'
                '• Bump legalConsentVersion if you materially change Privacy Policy or Terms\n\n${_footer()}',
          ),
        ],
      );
}
