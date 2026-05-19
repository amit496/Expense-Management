/// Legal and store listing metadata.
///
/// Before publishing to Google Play, update [supportEmail], [developerName],
/// and optionally [privacyPolicyUrl] (required in Play Console — must match
/// the in-app Privacy Policy).
class LegalConfig {
  LegalConfig._();

  static const String appName = 'ExpenseTracker';
  static const String appVersion = '1.0.0';
  static const String developerName = 'ExpenseTracker';
  static const String supportEmail = 'support@example.com';
  static const String privacyPolicyUrl = '';
  static const String lastUpdated = 'May 19, 2026';
  static const String packageName = 'com.example.expense_tracker_app';

  /// Bump when Privacy Policy or Terms change materially (re-prompts users).
  static const String legalConsentVersion = '1';

  /// Optional public website (About page, support page).
  static const String websiteUrl = '';
}
