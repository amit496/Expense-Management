import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../services/db_service.dart';

class AuthProvider extends ChangeNotifier {
  final LocalAuthentication _localAuth = LocalAuthentication();

  bool _isLocked = false;
  bool _isPinEnabled = false;
  bool _isBiometricEnabled = false;
  bool _isBiometricAvailable = false;
  String _storedPin = '';
  List<BiometricType> _availableBiometrics = [];

  AuthProvider() {
    _loadSettings();
    _checkBiometricSupport();
  }

  bool get isLocked => _isLocked;
  bool get isPinEnabled => _isPinEnabled;
  bool get isBiometricEnabled => _isBiometricEnabled;
  bool get isBiometricAvailable => _isBiometricAvailable;
  bool get hasPinSet => _storedPin.isNotEmpty;
  List<BiometricType> get availableBiometrics => _availableBiometrics;

  bool get hasFaceId =>
      _availableBiometrics.contains(BiometricType.face);
  bool get hasFingerprint =>
      _availableBiometrics.contains(BiometricType.fingerprint) ||
      _availableBiometrics.contains(BiometricType.strong) ||
      _availableBiometrics.contains(BiometricType.weak);

  String get biometricLabel {
    if (hasFaceId) return 'Face ID';
    if (hasFingerprint) return 'Fingerprint';
    return 'Biometric';
  }

  IconData get biometricIcon {
    if (hasFaceId) return Icons.face_rounded;
    return Icons.fingerprint_rounded;
  }

  void _loadSettings({bool applyLockState = true}) {
    _isPinEnabled =
        DbService.getSetting('isPinEnabled', defaultValue: false);
    _isBiometricEnabled =
        DbService.getSetting('isBiometricEnabled', defaultValue: false);
    _storedPin = DbService.getSetting('appPin', defaultValue: '');
    if (applyLockState) {
      _isLocked = _isPinEnabled && _storedPin.isNotEmpty;
    }
    notifyListeners();
  }

  /// Reload PIN flags from Hive without forcing lock (e.g. after backup restore).
  void refreshFromDb() {
    _loadSettings(applyLockState: false);
  }

  Future<void> _checkBiometricSupport() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      _isBiometricAvailable = canCheck || isSupported;

      if (_isBiometricAvailable) {
        _availableBiometrics = await _localAuth.getAvailableBiometrics();
      }
    } catch (_) {
      _isBiometricAvailable = false;
    }
    notifyListeners();
  }

  bool verifyPin(String pin) {
    if (pin == _storedPin) {
      _isLocked = false;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> authenticateWithBiometric() async {
    try {
      final success = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access ExpenseTracker',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      if (success) {
        _isLocked = false;
        notifyListeners();
      }
      return success;
    } catch (_) {
      return false;
    }
  }

  Future<void> setPin(String pin) async {
    _storedPin = pin;
    _isPinEnabled = true;
    _isLocked = false;
    await DbService.setSetting('appPin', pin);
    await DbService.setSetting('isPinEnabled', true);
    notifyListeners();
  }

  Future<void> changePin(String newPin) async {
    _storedPin = newPin;
    await DbService.setSetting('appPin', newPin);
    notifyListeners();
  }

  Future<void> disablePin() async {
    _storedPin = '';
    _isPinEnabled = false;
    _isBiometricEnabled = false;
    _isLocked = false;
    await DbService.setSetting('appPin', '');
    await DbService.setSetting('isPinEnabled', false);
    await DbService.setSetting('isBiometricEnabled', false);
    notifyListeners();
  }

  Future<void> toggleBiometric() async {
    _isBiometricEnabled = !_isBiometricEnabled;
    await DbService.setSetting('isBiometricEnabled', _isBiometricEnabled);
    notifyListeners();
  }

  void lockApp() {
    if (_isPinEnabled && _storedPin.isNotEmpty) {
      _isLocked = true;
      notifyListeners();
    }
  }
}
