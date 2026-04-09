import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const AppHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20, right: 20, bottom: 16,
      ),
      decoration: BoxDecoration(
        color: ColorConst.white,
        border: Border(bottom: BorderSide(color: ColorConst.borderColor)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [ColorConst.green, ColorConst.greenDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.inventory, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: ColorConst.textPrimary, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
              Text(subtitle, style: const TextStyle(color: ColorConst.textSecondary, fontSize: 12)),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: ColorConst.greenPale, borderRadius: BorderRadius.circular(20), border: Border.all(color: ColorConst.stroke)),
            child: const Row(
              children: [
                Icon(Icons.admin_panel_settings, color: ColorConst.primaryGreen, size: 14),
                SizedBox(width: 6),
                Text('Admin', style: TextStyle(color: ColorConst.primaryGreen, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
