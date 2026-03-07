import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/text_const.dart';


class Utils {
  static OverlayEntry? _overlayEntry;
  static bool _isShowing = false;

  /// Show a general message with custom color
  static void show(String message, BuildContext context, {Color? color}) {
    _showMessage(
      message: message,
      context: context,
      backgroundColor: color ?? Colors.black87,
      icon: Icons.info,
      iconColor: Colors.white,
    );
  }

  /// Show success message (Blue with checkmark)
  static void showSuccess(String message, BuildContext context) {
    _showMessage(
      message: message,
      context: context,
      backgroundColor: ColorConst.primaryGreen,
      icon: Icons.check_circle,
      iconColor: Colors.white,
    );
  }

  /// Show error message (Red with error icon)
  static void showError(String message, BuildContext context) {
    _showMessage(
      message: message,
      context: context,
      backgroundColor: ColorConst.error,
      icon: Icons.error,
      iconColor: Colors.white,
    );
  }

  /// Show info message (Blue with info icon)
  static void showInfo(String message, BuildContext context) {
    _showMessage(
      message: message,
      context: context,
      backgroundColor: ColorConst.primaryGreen,
      icon: Icons.info_outline,
      iconColor: Colors.white,
    );
  }

  /// Show warning message (Red with warning icon)
  static void showWarning(String message, BuildContext context) {
    _showMessage(
      message: message,
      context: context,
      backgroundColor: ColorConst.error,
      icon: Icons.warning_amber,
      iconColor: Colors.white,
    );
  }

  static void _showMessage({
    required String message,
    required BuildContext context,
    required Color backgroundColor,
    required IconData icon,
    required Color iconColor,
  }) {
    if (_isShowing) {
      _overlayEntry?.remove();
    }

    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return Positioned(
          bottom: 50,
          left: 20,
          right: 20,
          child: Material(
            color: Colors.transparent,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 300),
              offset: const Offset(0, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: iconColor, size: 22),
                     SizedBox(width: 10),
                    Flexible(
                      child: CustomText.regular(
                        message,
                          color: Colors.white,


                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    _isShowing = true;

    _startTimer();
  }

  static void _startTimer() {
    Timer(const Duration(seconds: 3), () {
      if (_overlayEntry != null && _isShowing) {
        try {
          _overlayEntry!.remove();
        } catch (e) {
          // Overlay already removed or disposed
        } finally {
          _isShowing = false;
          _overlayEntry = null;
        }
      }
    });
  }
}
