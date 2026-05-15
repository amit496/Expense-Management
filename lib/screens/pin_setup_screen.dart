import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/message_helper.dart';

enum PinSetupMode { create, change }

class PinSetupScreen extends StatefulWidget {
  final PinSetupMode mode;

  const PinSetupScreen({
    super.key,
    this.mode = PinSetupMode.create,
  });

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen>
    with SingleTickerProviderStateMixin {
  int _step = 0;
  String _enteredPin = '';
  String _firstPin = '';
  bool _hasError = false;
  String _errorText = '';

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  bool get _isChanging => widget.mode == PinSetupMode.change;
  int get _totalSteps => _isChanging ? 3 : 2;

  String get _title {
    if (_isChanging) {
      if (_step == 0) return 'Enter Current PIN';
      if (_step == 1) return 'Enter New PIN';
      return 'Confirm New PIN';
    }
    if (_step == 0) return 'Create PIN';
    return 'Confirm PIN';
  }

  String get _subtitle {
    if (_isChanging) {
      if (_step == 0) return 'Verify your current PIN first';
      if (_step == 1) return 'Choose a new 4-digit PIN';
      return 'Re-enter your new PIN';
    }
    if (_step == 0) return 'Choose a 4-digit PIN to secure your app';
    return 'Re-enter the same PIN to confirm';
  }

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
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
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
      _processStep();
    }
  }

  void _onBackspace() {
    HapticFeedback.lightImpact();
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _hasError = false;
      });
    }
  }

  void _processStep() {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (_isChanging && _step == 0) {
      if (auth.verifyPin(_enteredPin)) {
        _goToNextStep();
      } else {
        _showError('Incorrect current PIN');
      }
      return;
    }

    final createStep = _isChanging ? 1 : 0;
    final confirmStep = _isChanging ? 2 : 1;

    if (_step == createStep) {
      _firstPin = _enteredPin;
      _goToNextStep();
    } else if (_step == confirmStep) {
      if (_enteredPin == _firstPin) {
        if (_isChanging) {
          auth.changePin(_enteredPin);
          MessageHelper.showSuccess(context, 'PIN changed successfully!');
        } else {
          auth.setPin(_enteredPin);
          MessageHelper.showSuccess(
              context, 'App lock enabled with PIN!');
        }
        Navigator.pop(context, true);
      } else {
        _showError('PINs don\'t match. Start over.');
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) {
            setState(() {
              _step = _isChanging ? 1 : 0;
              _enteredPin = '';
              _firstPin = '';
            });
          }
        });
      }
    }
  }

  void _goToNextStep() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _step++;
          _enteredPin = '';
        });
      }
    });
  }

  void _showError(String message) {
    _shakeController.forward(from: 0);
    HapticFeedback.heavyImpact();
    setState(() {
      _hasError = true;
      _errorText = message;
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _enteredPin = '');
    });
  }

  @override
  Widget build(BuildContext context) {
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                    const Spacer(),
                    Text(
                      'Step ${_step + 1} of $_totalSteps',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white38 : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
              ),

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: List.generate(_totalSteps, (i) {
                    return Expanded(
                      child: Container(
                        height: 3,
                        margin: EdgeInsets.only(
                            right: i < _totalSteps - 1 ? 6 : 0),
                        decoration: BoxDecoration(
                          color: i <= _step
                              ? AppTheme.primary
                              : isDark
                                  ? Colors.white12
                                  : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const Spacer(flex: 2),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Icon(
                  _step == 0 && _isChanging
                      ? Icons.lock_open_rounded
                      : _step == (_isChanging ? 2 : 1)
                          ? Icons.check_circle_outline_rounded
                          : Icons.lock_rounded,
                  size: 36,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 24),

              Text(
                _title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  _subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white38 : Colors.grey,
                  ),
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
                              : isFilled
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
                    ? Text(
                        _errorText,
                        style: const TextStyle(
                          color: AppTheme.expense,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    : const SizedBox(height: 18),
              ),

              const Spacer(),

              _buildKeypad(isDark),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          for (var row in [
            ['1', '2', '3'],
            ['4', '5', '6'],
            ['7', '8', '9'],
          ]) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row
                  .map((d) => _buildKey(d, isDark))
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 72),
              _buildKey('0', isDark),
              GestureDetector(
                onTap: _onBackspace,
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: Center(
                    child: Icon(
                      Icons.backspace_outlined,
                      size: 24,
                      color: isDark ? Colors.white54 : Colors.grey,
                    ),
                  ),
                ),
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
}
