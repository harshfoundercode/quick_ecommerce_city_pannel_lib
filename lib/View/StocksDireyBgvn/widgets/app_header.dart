import 'package:flutter/material.dart';

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
        left: 20,
        right: 20,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F22),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.07)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3D5AFE), Color(0xFF651FFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.inventory, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.admin_panel_settings, color: Color(0xFF3D5AFE), size: 14),
                SizedBox(width: 6),
                Text('Admin', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
