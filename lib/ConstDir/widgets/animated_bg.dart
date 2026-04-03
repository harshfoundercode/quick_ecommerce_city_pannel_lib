import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';

class PremiumBg extends StatefulWidget {
  const PremiumBg({super.key});

  @override
  State<PremiumBg> createState() => _PremiumBgState();
}

class _PremiumBgState extends State<PremiumBg>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat(reverse: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-1 + _controller.value, -1),
                  end: Alignment(1, 1),
                  colors: [



                    ColorConst.primaryGreen,
                    ColorConst.primaryExtraLightGreen,
                    ColorConst.primaryGreen,

                  ],
                ),
              ),
            );
          },
        ),

        Positioned(
          top: -60,
          left: -60,
          child: _glow(180),
        ),
        Positioned(
          bottom: -80,
          right: -40,
          child: _glow(220),
        ),
      ],
    );
  }

  Widget _glow(double size) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ColorConst.primaryLightGreen.withValues(alpha: 0.15),
        boxShadow: [
          BoxShadow(
            color: ColorConst.primaryLightGreen.withValues(alpha: 0.25),
            blurRadius: 80,
            spreadRadius: 10,
          )
        ],
      ),
    );
  }
}