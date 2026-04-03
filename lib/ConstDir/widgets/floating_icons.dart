import 'dart:math';

import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';

class FloatingIcons extends StatelessWidget {
  const FloatingIcons({super.key});

  @override
  Widget build(BuildContext context) {
    final icons = [
      Icons.shopping_cart,
      Icons.local_grocery_store,
      Icons.fastfood,
      Icons.eco,
      Icons.fastfood,
    ];

    return Stack(
      children: List.generate(8, (index) {
        final random = Random(index);
        return Positioned(
          left: random.nextDouble() * MediaQuery.of(context).size.width,
          top: random.nextDouble() * MediaQuery.of(context).size.height,
          child: TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: Duration(seconds: 6 + index),
            builder: (_, double value, child) {
              return Transform.translate(
                offset: Offset(0, -50 * value),
                child: Opacity(
                  opacity: 0.1,
                  child: Icon(
                    icons[index % icons.length],
                    size: 40,
                    color: ColorConst.white,
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
