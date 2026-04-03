// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ConstDir/text_const.dart';
//
//
// class Utils {
//   static OverlayEntry? _overlayEntry;
//   static bool _isShowing = false;
//
//   /// Show a general message with custom color
//   static void show(String message, BuildContext context, {Color? color}) {
//     _showMessage(
//       message: message,
//       context: context,
//       backgroundColor: color ?? Colors.black87,
//       icon: Icons.info,
//       iconColor: Colors.white,
//     );
//   }
//
//   /// Show success message (Blue with checkmark)
//   static void showSuccess(String message, BuildContext context) {
//     _showMessage(
//       message: message,
//       context: context,
//       backgroundColor: ColorConst.primaryGreen,
//       icon: Icons.check_circle,
//       iconColor: Colors.white,
//     );
//   }
//
//   /// Show error message (Red with error icon)
//   static void showError(String message, BuildContext context) {
//     _showMessage(
//       message: message,
//       context: context,
//       backgroundColor: ColorConst.error,
//       icon: Icons.error,
//       iconColor: Colors.white,
//     );
//   }
//
//   /// Show info message (Blue with info icon)
//   static void showInfo(String message, BuildContext context) {
//     _showMessage(
//       message: message,
//       context: context,
//       backgroundColor: ColorConst.primaryGreen,
//       icon: Icons.info_outline,
//       iconColor: Colors.white,
//     );
//   }
//
//   /// Show warning message (Red with warning icon)
//   static void showWarning(String message, BuildContext context) {
//     _showMessage(
//       message: message,
//       context: context,
//       backgroundColor: ColorConst.error,
//       icon: Icons.warning_amber,
//       iconColor: Colors.white,
//     );
//   }
//
//   static void _showMessage({
//     required String message,
//     required BuildContext context,
//     required Color backgroundColor,
//     required IconData icon,
//     required Color iconColor,
//   }) {
//     if (_isShowing) {
//       _overlayEntry?.remove();
//     }
//
//     _overlayEntry = OverlayEntry(
//       builder: (BuildContext context) {
//         return Positioned(
//           bottom: 50,
//           left: 20,
//           right: 20,
//           child: Material(
//             color: Colors.transparent,
//             child: AnimatedSlide(
//               duration: const Duration(milliseconds: 300),
//               offset: const Offset(0, 0),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                 decoration: BoxDecoration(
//                   color: backgroundColor,
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withValues(alpha:0.2),
//                       blurRadius: 8,
//                       offset: const Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(icon, color: iconColor, size: 22),
//                      SizedBox(width: 10),
//                     Flexible(
//                       child: CustomText.regular(
//                         message,
//                           color: Colors.white,
//
//
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//
//     Overlay.of(context).insert(_overlayEntry!);
//     _isShowing = true;
//
//     _startTimer();
//   }
//
//   static void _startTimer() {
//     Timer(const Duration(seconds: 3), () {
//       if (_overlayEntry != null && _isShowing) {
//         try {
//           _overlayEntry!.remove();
//         } catch (e) {
//           // Overlay already removed or disposed
//         } finally {
//           _isShowing = false;
//           _overlayEntry = null;
//         }
//       }
//     });
//   }
// }
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/text_const.dart';

class Utils {
  static final List<OverlayEntry> _entries = [];

  /// General
  static void show(String message, BuildContext context, {Color? color}) {
    _showMessage(
      message: message,
      context: context,
      backgroundColor: color ?? ColorConst.inkDark,
      icon: Icons.info_outline,
    );
  }

  /// Success
  static void showSuccess(String message, BuildContext context) {
    _showMessage(
      message: message,
      context: context,
      backgroundColor: ColorConst.success,
      icon: Icons.check_circle_outline,
    );
  }

  /// Error
  static void showError(String message, BuildContext context) {
    _showMessage(
      message: message,
      context: context,
      backgroundColor: ColorConst.error,
      icon: Icons.error_outline,
    );
  }

  /// Info
  static void showInfo(String message, BuildContext context) {
    _showMessage(
      message: message,
      context: context,
      backgroundColor: ColorConst.info,
      icon: Icons.info_outline,
    );
  }

  /// Warning
  static void showWarning(String message, BuildContext context) {
    _showMessage(
      message: message,
      context: context,
      backgroundColor: ColorConst.warning,
      icon: Icons.warning_amber_rounded,
    );
  }

  /// CORE
  static void _showMessage({
    required String message,
    required BuildContext context,
    required Color backgroundColor,
    required IconData icon,
  }) {
    final overlay = Overlay.of(context);

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        final index = _entries.indexOf(entry);

        return Positioned(
          top: 20 + (index * 70), // 🔥 stack from top-right
          right: 20,
          child: _AnimatedToast(
            message: message,
            icon: icon,
            backgroundColor: backgroundColor,
            onDismiss: () {
              entry.remove();
              _entries.remove(entry);
            },
          ),
        );
      },
    );

    _entries.add(entry);
    overlay.insert(entry);

    /// Auto remove
    Timer(const Duration(seconds: 3), () {
      if (_entries.contains(entry)) {
        entry.remove();
        _entries.remove(entry);
      }
    });
  }
}

/// 🔥 Animated Toast Widget (Admin Style)
class _AnimatedToast extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color backgroundColor;
  final VoidCallback onDismiss;

  const _AnimatedToast({
    required this.message,
    required this.icon,
    required this.backgroundColor,
    required this.onDismiss,
  });

  @override
  State<_AnimatedToast> createState() => _AnimatedToastState();
}

class _AnimatedToastState extends State<_AnimatedToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _slide = Tween<Offset>(
      begin: const Offset(1, 0), // slide from right
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fade = Tween<double>(begin: 0, end: 1).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 320,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: ColorConst.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ColorConst.borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: widget.backgroundColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.icon,
                    size: 18,
                    color: widget.backgroundColor,
                  ),
                ),
                const SizedBox(width: 10),

                /// Text
                Expanded(
                  child: CustomText.regular(
                    widget.message,
                    color: ColorConst.textBlack,
                  ),
                ),

                /// Close
                GestureDetector(
                  onTap: widget.onDismiss,
                  child: const Icon(
                    Icons.close,
                    size: 16,
                    color: ColorConst.textGrey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
