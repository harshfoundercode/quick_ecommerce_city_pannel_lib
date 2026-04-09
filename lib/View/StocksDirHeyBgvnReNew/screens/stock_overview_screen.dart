import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import '../providers/stock_provider.dart';
import '../widgets/app_header.dart';
import '../widgets/category_tree.dart';
import '../widgets/product_list_panel.dart';

class StockOverviewScreen extends StatelessWidget {
  const StockOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AppHeader(title: 'Stock Overview', subtitle: 'Inventory manage karein'),
        const _StatsBar(),
        Expanded(
          child: Row(
            children: [
              // LEFT PANEL — Category tree
              Container(
                width: 210,
                decoration: BoxDecoration(
                  color: ColorConst.white,
                  border: Border(right: BorderSide(color: ColorConst.borderColor)),
                ),
                child: const CategoryTree(),
              ),
              // RIGHT PANEL — Product list
              const Expanded(child: ProductListPanel()),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Stats bar ─────────────────────────────────────────────────────────────────
class _StatsBar extends StatelessWidget {
  const _StatsBar();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<StockProvider>();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: ColorConst.white,
        border: Border(bottom: BorderSide(color: ColorConst.borderColor)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _StatChip(
              icon: Icons.category_outlined,
              label: 'Categories',
              value: '${p.totalCategories}',
              color: ColorConst.info,
              bg: ColorConst.criticalBlueLight,
            ),
            const SizedBox(width: 8),
            _StatChip(
              icon: Icons.inventory_2_outlined,
              label: 'Products',
              value: '${p.totalProducts}',
              color: ColorConst.primaryGreen,
              bg: ColorConst.greenPale,
            ),
            const SizedBox(width: 8),
            _StatChip(
              icon: Icons.layers_outlined,
              label: 'Total Stock',
              value: '${p.totalStock}',
              color: ColorConst.inkMid,
              bg: ColorConst.containerGrey,
            ),
            const SizedBox(width: 8),
            _StatChip(
              icon: Icons.warning_amber_outlined,
              label: 'Low Stock',
              value: '${p.lowStockCount}',
              color: ColorConst.warning,
              bg: ColorConst.honeyBg,
            ),
            const SizedBox(width: 8),
            _StatChip(
              icon: Icons.remove_shopping_cart_outlined,
              label: 'Out of Stock',
              value: '${p.outOfStockCount}',
              color: ColorConst.danger,
              bg: ColorConst.dangerBg,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color bg;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w800, height: 1.1)),
              Text(label, style: TextStyle(color: color.withOpacity(0.7), fontSize: 10, height: 1.1)),
            ],
          ),
        ],
      ),
    );
  }
}
