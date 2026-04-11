import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/DisputeHubDir/dispute_model.dart';

class HubDisputeCard extends StatelessWidget {
  final DisputeItem dispute;
  final bool isSelected;
  final VoidCallback onTap;

  const HubDisputeCard({
    super.key,
    required this.dispute,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF378ADD) : const Color(0xFFD3D1C7),
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dispute.product,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dispute.hub,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF888780)),
                      ),
                    ],
                  ),
                ),
                _TypeBadge(type: dispute.type),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 5,
              runSpacing: 4,
              children: [
                _Tag(label: dispute.category, bg: const Color(0xFFF1EFE8), fg: const Color(0xFF5F5E5A)),
                _Tag(label: dispute.sku, bg: const Color(0xFFF1EFE8), fg: const Color(0xFF5F5E5A)),
                if (dispute.defective > 0)
                  _Tag(
                    label: '${dispute.defective} defective',
                    bg: const Color(0xFFFCEBEB),
                    fg: const Color(0xFFA32D2D),
                  ),
                if (dispute.missing > 0)
                  _Tag(
                    label: '${dispute.missing} missing',
                    bg: const Color(0xFFFAEEDA),
                    fg: const Color(0xFF854F0B),
                  ),
                _SeverityTag(severity: dispute.severity),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _MetaItem(label: 'Transferred', value: '${dispute.transferred}'),
                const SizedBox(width: 16),
                _MetaItem(label: 'Date', value: dispute.date),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final DisputeType type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    String label;
    switch (type) {
      case DisputeType.defective:
        bg = const Color(0xFFFCEBEB);
        fg = const Color(0xFFA32D2D);
        label = 'Defective';
        break;
      case DisputeType.missing:
        bg = const Color(0xFFFAEEDA);
        fg = const Color(0xFF854F0B);
        label = 'Missing';
        break;
      case DisputeType.pending:
        bg = const Color(0xFFE6F1FB);
        fg = const Color(0xFF185FA5);
        label = 'Pending';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: fg)),
    );
  }
}

class _SeverityTag extends StatelessWidget {
  final DisputeSeverity severity;
  const _SeverityTag({required this.severity});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    switch (severity) {
      case DisputeSeverity.high:
        bg = const Color(0xFFFCEBEB);
        fg = const Color(0xFFA32D2D);
        break;
      case DisputeSeverity.medium:
        bg = const Color(0xFFFAEEDA);
        fg = const Color(0xFF854F0B);
        break;
      case DisputeSeverity.low:
        bg = const Color(0xFFF1EFE8);
        fg = const Color(0xFF5F5E5A);
        break;
    }
    return _Tag(
      label: '${severity.name} severity',
      bg: bg,
      fg: fg,
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const _Tag({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: fg)),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final String label;
  final String value;
  const _MetaItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ', style: const TextStyle(fontSize: 11, color: Color(0xFF888780))),
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF1A1A1A))),
      ],
    );
  }
}