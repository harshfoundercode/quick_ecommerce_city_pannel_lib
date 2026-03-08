import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/text_const.dart';

/// 🔴 Smart Server Error Dialog with auto-dismiss when server is back online
void showSmartServerErrorDialog({
  required BuildContext context,
  required String errorCode,
  required String serverUrl,
}) {
  showGeneralDialog(
    context: context,
    barrierLabel: "Server Error",
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.7),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, animation1, animation2) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation1, curve: Curves.easeInOut),
        child: _SmartServerErrorDialogContent(
          errorCode: errorCode,
          serverUrl: serverUrl,
        ),
      );
    },
  );
}

/// Stateful widget for smart server error dialog
class _SmartServerErrorDialogContent extends StatefulWidget {
  final String errorCode;
  final String serverUrl;

  const _SmartServerErrorDialogContent({
    required this.errorCode,
    required this.serverUrl,
  });

  @override
  State<_SmartServerErrorDialogContent> createState() =>
      _SmartServerErrorDialogContentState();
}

class _SmartServerErrorDialogContentState extends State<_SmartServerErrorDialogContent>
    with SingleTickerProviderStateMixin {
  Timer? _checkTimer;
  int _retryCount = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _startServerCheck();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startServerCheck() {
    _checkTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (mounted) {
        setState(() {
          _retryCount++;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: Center(
        child: Container(
          width: Sizes.screenWidth * 0.85,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.2),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
              BoxShadow(
                color: ColorConst.error.withValues(alpha:0.1),
                blurRadius: 40,
                spreadRadius: -10,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top decorative bar
                Container(
                  height: 6,
                  width: 60,
                  margin: const EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    color: ColorConst.error.withValues(alpha:0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated Status Icon
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Pulse effect
                          ScaleTransition(
                            scale: _pulseAnimation,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: ColorConst.error.withValues(alpha:0.15),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: ColorConst.error.withValues(alpha:0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.cloud_off_rounded,
                              color: ColorConst.error,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Title with gradient
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [ColorConst.error, ColorConst.error.withValues(alpha:0.8)],
                        ).createShader(bounds),
                        child: CustomText.bold(
                          'Connection Lost',
                          fontSize: Sizes.fontSizeSix,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Error code chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: ColorConst.error.withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: ColorConst.error.withValues(alpha:0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 16,
                              color: ColorConst.error,
                            ),
                            const SizedBox(width: 6),
                            CustomText.regular(
                              'Error ${widget.errorCode}',
                              fontSize: Sizes.fontSizeTwo,
                              color: ColorConst.error,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Main message with better typography
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            CustomText.regular(
                              'Unable to reach server',
                              fontSize: Sizes.fontSizeFour,
                              color: ColorConst.black,
                            ),
                            const SizedBox(height: 8),
                            CustomText.regular(
                              'We\'re having trouble connecting....',
                              fontSize: Sizes.fontSizeThree,
                              color: ColorConst.textGrey,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Server checking status
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: ColorConst.primaryGreen.withValues(alpha:0.05),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  ColorConst.primaryGreen,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            CustomText.regular(
                              'Auto-retry in ${3 - (_retryCount % 3)}s...',
                              fontSize: Sizes.fontSizeTwo,
                              color: ColorConst.primaryGreen,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              label: 'Cancel',
                              isPrimary: false,
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActionButton(
                              label: 'Retry',
                              isPrimary: true,
                              onPressed: null, // Disabled when server is down
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required bool isPrimary,
    required VoidCallback? onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: isPrimary && onPressed != null
            ? [
          BoxShadow(
            color: ColorConst.primaryGreen.withValues(alpha:0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ]
            : null,
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: isPrimary
              ? (onPressed != null ? ColorConst.primaryGreen : ColorConst.primaryGreen.withValues(alpha:0.3))
              : Colors.grey.shade100,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: CustomText.bold(
          label,
          color: isPrimary ? Colors.white : ColorConst.primaryGreen,
          fontSize: Sizes.fontSizeThree,
        ),
      ),
    );
  }
}