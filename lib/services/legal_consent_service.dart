import '../constants/legal_config.dart';
import 'db_service.dart';

/// Tracks whether the user accepted the current Privacy Policy + Terms version.
class LegalConsentService {
  LegalConsentService._();

  static const String _settingKey = 'acceptedLegalConsentVersion';

  static bool isAccepted() {
    final stored = DbService.getSetting(_settingKey, defaultValue: '');
    return stored.toString() == LegalConfig.legalConsentVersion;
  }

  static Future<void> accept() async {
    await DbService.setSetting(_settingKey, LegalConfig.legalConsentVersion);
  }
}
