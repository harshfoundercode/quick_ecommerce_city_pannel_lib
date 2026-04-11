import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/DisputeHubDir/dispute_model.dart';

class SummaryBar extends StatelessWidget {
  final List<DisputeItem> disputes;
  const SummaryBar({super.key, required this.disputes});

  @override
  Widget build(BuildContext context) {
    final defective = disputes.where((d) => d.type == DisputeType.defective).length;
    final missing = disputes.where((d) => d.type == DisputeType.missing).length;
    final pending = disputes.where((d) => d.type == DisputeType.pending).length;
    final sentToCity = disputes.where((d) => d.status == DisputeStatus.sentToCity).length;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFE6F1FB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.inventory_2_outlined, size: 16, color: Color(0xFF185FA5)),
          ),
          const SizedBox(width: 10),
          const Text(
            'Hub Dispute & Missing Stock',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF1A1A1A)),
          ),
          const Spacer(),
          _Chip(label: '$defective Defective', bg: const Color(0xFFFCEBEB), fg: const Color(0xFFA32D2D)),
          const SizedBox(width: 6),
          _Chip(label: '$missing Missing', bg: const Color(0xFFFAEEDA), fg: const Color(0xFF854F0B)),
          const SizedBox(width: 6),
          _Chip(label: '$pending Pending', bg: const Color(0xFFE6F1FB), fg: const Color(0xFF185FA5)),
          const SizedBox(width: 6),
          _Chip(label: '$sentToCity Sent to City', bg: const Color(0xFFEAF3DE), fg: const Color(0xFF3B6D11)),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const _Chip({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: fg)),
    );
  }
}