import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/CityStocksRedefinedDir/models.dart';


// ─────────────────────────────────────────────
//  Stock Status Chip
// ─────────────────────────────────────────────
class StockStatusChip extends StatelessWidget {
  final StockStatus status;
  const StockStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _chipConfig();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.$1,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: config.$2, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: config.$3),
          ),
          const SizedBox(width: 5),
          Text(config.$4,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: config.$3)),
        ],
      ),
    );
  }

  (Color, Color, Color, String) _chipConfig() {
    switch (status) {
      case StockStatus.critical:
        return (ColorConst.criticalRedLight, const Color(0xFFFECACA), ColorConst.criticalRed, 'Critical');
      case StockStatus.low:
        return (ColorConst.criticalRedLight, const Color(0xFFFECACA), ColorConst.criticalRed, 'Low');
      case StockStatus.warn:
        return (ColorConst.criticalYellowLight, const Color(0xFFFDE68A), ColorConst.criticalYellowLightText, 'Warning');
      case StockStatus.ok:
        return (ColorConst.primaryExtraLightGreen, const Color(0xFFBBF7D0), const Color(0xFF166534), 'OK');
    }
  }
}

// ─────────────────────────────────────────────
//  Priority Badge
// ─────────────────────────────────────────────
class PriorityBadge extends StatelessWidget {
  final RequestPriority priority;
  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    final config = _config();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: config.$1,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(config.$2,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
            color: config.$3, letterSpacing: 0.4)),
    );
  }

  (Color, String, Color) _config() {
    switch (priority) {
      case RequestPriority.normal:
        return (const Color(0xFFEFF6FF), 'NORMAL', const Color(0xFF1D4ED8));
      case RequestPriority.urgent:
        return (ColorConst.criticalYellowLight, 'URGENT', ColorConst.criticalYellowLightText);
      case RequestPriority.critical:
        return (ColorConst.criticalRedLight, 'CRITICAL', ColorConst.criticalRed);
    }
  }
}

// ─────────────────────────────────────────────
//  Request Status Pill
// ─────────────────────────────────────────────
class RequestStatusPill extends StatelessWidget {
  final RequestStatus status;
  const RequestStatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _config();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: config.$1,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: config.$2),
      ),
      child: Text(config.$3,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: config.$4)),
    );
  }

  (Color, Color, String, Color) _config() {
    switch (status) {
      case RequestStatus.pending:
        return (ColorConst.criticalYellowLight, const Color(0xFFFDE68A), 'Pending', ColorConst.criticalYellowLightText);
      case RequestStatus.approved:
        return (ColorConst.primaryExtraLightGreen, const Color(0xFFBBF7D0), 'Approved', const Color(0xFF166534));
      case RequestStatus.rejected:
        return (ColorConst.criticalRedLight, const Color(0xFFFECACA), 'Rejected', ColorConst.criticalRed);
      case RequestStatus.partial:
        return (ColorConst.criticalBlueLight, const Color(0xFFBAE6FD), 'Partial', ColorConst.criticalBlue);
    }
  }
}

// ─────────────────────────────────────────────
//  Shipment Status Pill
// ─────────────────────────────────────────────
class ShipmentStatusPill extends StatelessWidget {
  final ShipmentStatus status;
  const ShipmentStatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _config();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: config.$1,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: config.$2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6,
              decoration: BoxDecoration(shape: BoxShape.circle, color: config.$4)),
          const SizedBox(width: 5),
          Text(config.$3,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: config.$4)),
        ],
      ),
    );
  }

  (Color, Color, String, Color) _config() {
    switch (status) {
      case ShipmentStatus.pending:
        return (ColorConst.containerGrey, ColorConst.borderColor, 'Pending', ColorConst.textSecondary);
      case ShipmentStatus.inTransit:
        return (ColorConst.criticalBlueLight, const Color(0xFFBAE6FD), 'In Transit', ColorConst.criticalBlue);
      case ShipmentStatus.arrived:
        return (ColorConst.criticalYellowLight, const Color(0xFFFDE68A), 'Arrived', ColorConst.criticalYellowLightText);
      case ShipmentStatus.confirmed:
        return (ColorConst.primaryExtraLightGreen, const Color(0xFFBBF7D0), 'Confirmed', const Color(0xFF166534));
    }
  }
}

// ─────────────────────────────────────────────
//  Section Header
// ─────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  const SectionHeader({super.key, required this.title, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800,
                    color: ColorConst.kTextHead, letterSpacing: -0.3)),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!,
                  style: const TextStyle(fontSize: 12, color: ColorConst.textSecondary)),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Green Primary Button
// ─────────────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool isSmall;
  const PrimaryButton({
    super.key, required this.label, required this.onTap,
    this.icon, this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColorConst.primaryGreen,
      borderRadius: BorderRadius.circular(isSmall ? 8 : 11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isSmall ? 8 : 11),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: isSmall ? 14 : 18,
              vertical: isSmall ? 8 : 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: isSmall ? 15 : 17, color: Colors.white),
                const SizedBox(width: 6),
              ],
              Text(label,
                style: TextStyle(
                    fontSize: isSmall ? 12 : 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Outline Button (light green)
// ─────────────────────────────────────────────
class OutlineGreenButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool isSmall;
  const OutlineGreenButton({
    super.key, required this.label, required this.onTap,
    this.icon, this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColorConst.primaryExtraLightGreen,
      borderRadius: BorderRadius.circular(isSmall ? 8 : 11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isSmall ? 8 : 11),
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: isSmall ? 12 : 16,
              vertical: isSmall ? 7 : 10),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFBBF7D0)),
            borderRadius: BorderRadius.circular(isSmall ? 8 : 11),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: isSmall ? 14 : 16, color: ColorConst.primaryGreen),
                const SizedBox(width: 5),
              ],
              Text(label,
                style: TextStyle(
                    fontSize: isSmall ? 11 : 13,
                    fontWeight: FontWeight.w700,
                    color: ColorConst.primaryGreen)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  App Card wrapper
// ─────────────────────────────────────────────
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? borderColor;
  const AppCard({super.key, required this.child, this.padding, this.onTap, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColorConst.cardColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: borderColor ?? ColorConst.borderColor, width: borderColor != null ? 1.5 : 1),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Qty Stepper
// ─────────────────────────────────────────────
class QtyStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const QtyStepper({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepBtn(icon: Icons.remove, onTap: value > 0 ? () => onChanged(value - 1) : null),
        Container(
          width: 46,
          alignment: Alignment.center,
          child: Text('$value',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
                color: ColorConst.kTextHead)),
        ),
        _StepBtn(icon: Icons.add, onTap: () => onChanged(value + 1), isAdd: true),
      ],
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isAdd;
  const _StepBtn({required this.icon, this.onTap, this.isAdd = false});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: isAdd && enabled ? ColorConst.primaryExtraLightGreen : ColorConst.containerGrey,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: isAdd && enabled
                  ? const Color(0xFFBBF7D0)
                  : ColorConst.borderColor),
        ),
        child: Icon(icon, size: 15,
            color: isAdd && enabled
                ? ColorConst.primaryGreen
                : enabled ? ColorConst.textSecondary : ColorConst.borderColor),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Stat Card (dashboard)
// ─────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? sub;
  final Color iconBg;
  final Color valueColor;
  final IconData icon;
  final Color iconColor;
  const StatCard({
    super.key,
    required this.label, required this.value,
    this.sub, required this.iconBg,
    required this.valueColor, required this.icon, required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: ColorConst.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColorConst.borderColor),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30, height: 30,
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 15, color: iconColor),
              ),
              const SizedBox(width: 12),
              Text(label,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                      color: ColorConst.textSecondary, letterSpacing: 0.5)),
            ],
          ),

          const SizedBox(height: 3),
          Text(value,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800,
                color: valueColor, letterSpacing: -0.5)),
          if (sub != null) ...[
            const SizedBox(height: 3),
            Text(sub!, style: const TextStyle(fontSize: 11, color: ColorConst.textSecondary)),
          ],
        ],
      ),
    );
  }
}
