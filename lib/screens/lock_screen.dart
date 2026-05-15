import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen>
    with SingleTickerProviderStateMixin {
  String _enteredPin = '';
  bool _hasError = false;
  String _errorText = '';
  int _attempts = 0;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 24).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryBiometric();
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _tryBiometric() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.isBiometricEnabled && auth.isBiometricAvailable) {
      final success = await auth.authenticateWithBiometric();
      if (success && mounted) {
        _navigateToHome();
      }
    }
  }

  void _onKeyTap(String key) {
    HapticFeedback.lightImpact();

    if (_enteredPin.length >= 4) return;

    setState(() {
      _enteredPin += key;
      _hasError = false;
      _errorText = '';
    });

    if (_enteredPin.length == 4) {
      _verifyPin();
    }
  }

  void _onBackspace() {
    HapticFeedback.lightImpact();
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _hasError = false;
        _errorText = '';
      });
    }
  }

  void _verifyPin() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.verifyPin(_enteredPin)) {
      _navigateToHome();
    } else {
      _attempts++;
      _shakeController.forward(from: 0);
      HapticFeedback.heavyImpact();
      setState(() {
        _hasError = true;
        _errorText = _attempts >= 3
            ? 'Wrong PIN! $_attempts failed attempts'
            : 'Incorrect PIN. Try again.';
      });
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() => _enteredPin = '');
        }
      });
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, anim, __, child) {
          return FadeTransition(opacity: anim, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF0D1117), const Color(0xFF161B22)]
                : [const Color(0xFFF6F8FA), const Color(0xFFE8ECF0)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                      blurRadius: 25,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  size: 40,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Enter your PIN to continue',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white38 : Colors.grey,
                ),
              ),

              const SizedBox(height: 32),

              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  final dx = _shakeController.isAnimating
                      ? _shakeAnimation.value *
                          ((_shakeController.value * 10).toInt().isEven
                              ? 1
                              : -1) *
                          (1 - _shakeController.value)
                      : 0.0;
                  return Transform.translate(
                      offset: Offset(dx, 0), child: child);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) {
                    final isFilled = i < _enteredPin.length;
                    final isActive = i == _enteredPin.length;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: isFilled ? 20 : 16,
                      height: isFilled ? 20 : 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _hasError
                            ? AppTheme.expense
                            : isFilled
                                ? AppTheme.primary
                                : Colors.transparent,
                        border: Border.all(
                          color: _hasError
                              ? AppTheme.expense
                              : isActive
                                  ? AppTheme.primary
                                  : isDark
                                      ? Colors.white24
                                      : Colors.grey.shade400,
                          width: 2,
                        ),
                        boxShadow: isFilled
                            ? [
                                BoxShadow(
                                  color: (_hasError
                                          ? AppTheme.expense
                                          : AppTheme.primary)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 8,
                                )
                              ]
                            : null,
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 16),

              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                child: _hasError
                    ? Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _errorText,
                          style: const TextStyle(
                            color: AppTheme.expense,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : const SizedBox(height: 20),
              ),

              const Spacer(),

              _buildKeypad(auth, isDark),

              const SizedBox(height: 16),

              if (auth.isBiometricEnabled && auth.isBiometricAvailable)
                TextButton.icon(
                  onPressed: _tryBiometric,
                  icon: Icon(auth.biometricIcon, size: 18),
                  label: Text('Use ${auth.biometricLabel}'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                  ),
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad(AuthProvider auth, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKey('1', isDark),
              _buildKey('2', isDark),
              _buildKey('3', isDark),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKey('4', isDark),
              _buildKey('5', isDark),
              _buildKey('6', isDark),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKey('7', isDark),
              _buildKey('8', isDark),
              _buildKey('9', isDark),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              auth.isBiometricEnabled && auth.isBiometricAvailable
                  ? _buildActionKey(
                      auth.biometricIcon,
                      _tryBiometric,
                      isDark,
                      color: AppTheme.primary,
                    )
                  : const SizedBox(width: 72),
              _buildKey('0', isDark),
              _buildActionKey(
                Icons.backspace_outlined,
                _onBackspace,
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String digit, bool isDark) {
    return GestureDetector(
      onTap: () => _onKeyTap(digit),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        child: Center(
          child: Text(
            digit,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionKey(
      IconData icon, VoidCallback onTap, bool isDark,
      {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 72,
        height: 72,
        child: Center(
          child: Icon(
            icon,
            size: 26,
            color: color ?? (isDark ? Colors.white54 : Colors.grey),
          ),
        ),
      ),
    );
  }
}
