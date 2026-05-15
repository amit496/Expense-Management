import 'package:flutter/material.dart';

enum MessageType { error, warning, success, info }

class MessageHelper {
  static void showError(BuildContext context, String message) {
    _show(context, message, MessageType.error);
  }

  static void showWarning(BuildContext context, String message) {
    _show(context, message, MessageType.warning);
  }

  static void showSuccess(BuildContext context, String message) {
    _show(context, message, MessageType.success);
  }

  static void showInfo(BuildContext context, String message) {
    _show(context, message, MessageType.info);
  }

  static void _show(BuildContext context, String message, MessageType type) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (ctx) => _MessageOverlay(
        message: message,
        type: type,
        onDismiss: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }
}

class _MessageOverlay extends StatefulWidget {
  final String message;
  final MessageType type;
  final VoidCallback onDismiss;

  const _MessageOverlay({
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  @override
  State<_MessageOverlay> createState() => _MessageOverlayState();
}

class _MessageOverlayState extends State<_MessageOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    final autoClose = widget.type == MessageType.success
        ? const Duration(seconds: 2)
        : const Duration(seconds: 4);

    Future.delayed(autoClose, _dismiss);
  }

  void _dismiss() {
    if (!mounted) return;
    _controller.reverse().then((_) {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 8,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onTap: _dismiss,
            onVerticalDragUpdate: (details) {
              if (details.primaryDelta != null && details.primaryDelta! < -4) {
                _dismiss();
              }
            },
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: config.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: config.shadowColor.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(config.icon, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            config.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.message,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _dismiss,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white70,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _MessageConfig _getConfig() {
    switch (widget.type) {
      case MessageType.error:
        return _MessageConfig(
          title: 'Error',
          icon: Icons.error_rounded,
          gradientColors: [const Color(0xFFDC2626), const Color(0xFFB91C1C)],
          shadowColor: const Color(0xFFDC2626),
        );
      case MessageType.warning:
        return _MessageConfig(
          title: 'Warning',
          icon: Icons.warning_amber_rounded,
          gradientColors: [const Color(0xFFF59E0B), const Color(0xFFD97706)],
          shadowColor: const Color(0xFFF59E0B),
        );
      case MessageType.success:
        return _MessageConfig(
          title: 'Success',
          icon: Icons.check_circle_rounded,
          gradientColors: [const Color(0xFF10B981), const Color(0xFF059669)],
          shadowColor: const Color(0xFF10B981),
        );
      case MessageType.info:
        return _MessageConfig(
          title: 'Info',
          icon: Icons.info_rounded,
          gradientColors: [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
          shadowColor: const Color(0xFF3B82F6),
        );
    }
  }
}

class _MessageConfig {
  final String title;
  final IconData icon;
  final List<Color> gradientColors;
  final Color shadowColor;

  const _MessageConfig({
    required this.title,
    required this.icon,
    required this.gradientColors,
    required this.shadowColor,
  });
}
