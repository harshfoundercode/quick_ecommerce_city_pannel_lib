import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';

enum SnackBarType { success, error, warning, info }

class CustomSnackBar {
  static void show(
      BuildContext context, {
        required String message,
        required SnackBarType type,
        String? title,
        Duration duration = const Duration(seconds: 4),
        VoidCallback? onActionPressed,
        String? actionLabel,
      }) {
    final snackBarConfig = _getSnackBarConfig(type);

    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => _AnimatedSnackBar(
        message: message,
        title: title,
        backgroundColor: snackBarConfig.backgroundColor,
        iconColor: snackBarConfig.iconColor,
        textColor: snackBarConfig.textColor,
        icon: snackBarConfig.icon,
        duration: duration,
        onActionPressed: onActionPressed,
        actionLabel: actionLabel,
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(duration, () {
      overlayEntry.remove();
    });
  }
}

class _SnackBarConfig {
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final IconData icon;

  _SnackBarConfig({
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
    required this.icon,
  });
}

_SnackBarConfig _getSnackBarConfig(SnackBarType type) {
  switch (type) {
    case SnackBarType.success:
      return _SnackBarConfig(
        backgroundColor: ColorConst.primaryGreen,
        iconColor: ColorConst.primaryLightGreen,
        textColor: ColorConst.primaryLightGreen,
        icon: Icons.check_circle_rounded,
      );
    case SnackBarType.error:
      return _SnackBarConfig(
        backgroundColor: ColorConst.criticalRedLight,
        iconColor: ColorConst.criticalRed,
        textColor: ColorConst.criticalRedLightText,
        icon: Icons.error_rounded,
      );
    case SnackBarType.warning:
      return _SnackBarConfig(
        backgroundColor: ColorConst.criticalYellowLight,
        iconColor: ColorConst.criticalYellow,
        textColor: ColorConst.criticalYellowLightText,
        icon: Icons.warning_rounded,
      );
    case SnackBarType.info:
      return _SnackBarConfig(
        backgroundColor: ColorConst.criticalBlueLight,
        iconColor: ColorConst.criticalBlue,
        textColor: ColorConst.criticalBlueLightText,
        icon: Icons.info_rounded,
      );
  }
}

class _AnimatedSnackBar extends StatefulWidget {
  final String message;
  final String? title;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final IconData icon;
  final Duration duration;
  final VoidCallback? onActionPressed;
  final String? actionLabel;

  const _AnimatedSnackBar({
    required this.message,
    this.title,
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
    required this.icon,
    required this.duration,
    this.onActionPressed,
    this.actionLabel,
  });

  @override
  State<_AnimatedSnackBar> createState() => _AnimatedSnackBarState();
}

class _AnimatedSnackBarState extends State<_AnimatedSnackBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();

    // Auto dismiss animation
    Future.delayed(widget.duration - const Duration(milliseconds: 400), () {
      if (mounted) {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Icon with circular background
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.iconColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.iconColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Message content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.title != null) ...[
                          Text(
                            widget.title!,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: widget.textColor,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                        Text(
                          widget.message,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: widget.textColor.withValues(alpha: 0.85),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Action button or close button
                  if (widget.actionLabel != null &&
                      widget.onActionPressed != null) ...[
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: widget.onActionPressed,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        widget.actionLabel!,
                        style: TextStyle(
                          color: widget.iconColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        _controller.reverse();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.close,
                          color: widget.textColor.withValues(alpha: 0.5),
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Alternative: Bottom positioned snackbar
class CustomBottomSnackBar {
  static void show(
      BuildContext context, {
        required String message,
        required SnackBarType type,
        Duration duration = const Duration(seconds: 3),
        VoidCallback? onActionPressed,
        String? actionLabel,
      }) {
    final snackBarConfig = _getSnackBarConfig(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: snackBarConfig.iconColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                snackBarConfig.icon,
                color: snackBarConfig.iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: snackBarConfig.textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: snackBarConfig.backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: duration,
        action: onActionPressed != null && actionLabel != null
            ? SnackBarAction(
          label: actionLabel,
          textColor: snackBarConfig.iconColor,
          onPressed: onActionPressed,
        )
            : null,
      ),
    );
  }
}


