import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import '../providers/stock_provider.dart';
import '../models/models.dart';

class CategoryTree extends StatefulWidget {
  const CategoryTree({super.key});
  @override
  State<CategoryTree> createState() => _CategoryTreeState();
}

class _CategoryTreeState extends State<CategoryTree> {
  final Set<String> _expanded = {};

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StockProvider>();
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
          child: Row(
            children: [
              const Icon(Icons.category_outlined, color: ColorConst.primaryGreen, size: 15),
              const SizedBox(width: 6),
              const Text('Categories', style: TextStyle(color: ColorConst.textSecondary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
              const Spacer(),
              if (provider.selectedCategoryId != null)
                GestureDetector(
                  onTap: () => provider.selectCategory(null),
                  child: const Icon(Icons.close, color: ColorConst.textGrey, size: 14),
                ),
            ],
          ),
        ),
        _allItem(provider),
        const SizedBox(height: 4),
        Expanded(
          child: ListView(
            children: provider.categories.map((c) => _catItem(c, provider)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _allItem(StockProvider provider) {
    final sel = provider.selectedCategoryId == null;
    return _tile(
      icon: Icons.all_inclusive,
      label: 'All Products',
      selected: sel,
      onTap: () => provider.selectCategory(null),
      indent: 0,
    );
  }

  Widget _catItem(Category cat, StockProvider provider) {
    final expanded = _expanded.contains(cat.id);
    final sel = provider.selectedCategoryId == cat.id && provider.selectedSubCategoryId == null;
    return Column(
      children: [
        _tile(
          icon: cat.icon,
          label: cat.name,
          selected: sel,
          onTap: () {
            setState(() => expanded ? _expanded.remove(cat.id) : _expanded.add(cat.id));
            provider.selectCategory(cat.id);
          },
          indent: 0,
          trailing: Icon(expanded ? Icons.expand_less : Icons.expand_more, color: ColorConst.textGrey, size: 16),
        ),
        if (expanded)
          ...cat.subCategories.map((sub) {
            final ssel = provider.selectedSubCategoryId == sub.id;
            return _tile(
              icon: null,
              label: sub.name,
              selected: ssel,
              onTap: () { provider.selectCategory(sub.categoryId); provider.selectSubCategory(sub.id); },
              indent: 26,
            );
          }),
      ],
    );
  }

  Widget _tile({IconData? icon, required String label, required bool selected, required VoidCallback onTap, required double indent, Widget? trailing}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(left: indent + 8, right: 8, top: 2, bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? ColorConst.greenPale : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: selected ? Border.all(color: ColorConst.stroke) : null,
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: selected ? ColorConst.primaryGreen : ColorConst.textGrey, size: 16),
              const SizedBox(width: 8),
            ] else ...[
              Container(width: 5, height: 5, decoration: BoxDecoration(color: selected ? ColorConst.primaryGreen : ColorConst.inkLight, shape: BoxShape.circle)),
              const SizedBox(width: 8),
            ],
            Expanded(child: Text(label, style: TextStyle(color: selected ? ColorConst.primaryGreen : ColorConst.textSecondary, fontSize: 13, fontWeight: selected ? FontWeight.w700 : FontWeight.w400))),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}
