import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/city_stock_model.dart';

class ProductPickerSheet {
  static Future<CityStockData?> show(
      BuildContext context, {
        required List<CityStockData> items,
        CityStockData? selected,
      }) {
    return showModalBottomSheet<CityStockData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProductPickerSheet(items: items, selected: selected),
    );
  }
}

class _ProductPickerSheet extends StatefulWidget {
  final List<CityStockData> items;
  final CityStockData? selected;
  const _ProductPickerSheet({required this.items, this.selected});
  @override
  State<_ProductPickerSheet> createState() => _ProductPickerSheetState();
}

class _ProductPickerSheetState extends State<_ProductPickerSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  List<CityStockData> get _filtered => _query.isEmpty
      ? widget.items
      : widget.items
      .where((i) => (i.product?.name ?? '').toLowerCase().contains(_query.toLowerCase()))
      .toList();

  Color _stockColor(int s) {
    if (s == 0) return const Color(0xFFEF4444);
    if (s < 10) return const Color(0xFFDC2626);
    if (s < 20) return const Color(0xFFD97706);
    return ColorConst.primaryGreen;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(children: [
        const SizedBox(height: 10),
        Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2))),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: ColorConst.primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.inventory_2_outlined, color: ColorConst.primaryGreen, size: 18),
            ),
            const SizedBox(width: 10),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Select Product', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
              Text('All products shown — out of stock are greyed', style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
            ])),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(width: 32, height: 32,
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(9)),
                  child: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF374151))),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Container(
            height: 44,
            decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))),
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              onChanged: (v) => setState(() => _query = v),
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search by product name…',
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded, size: 18, color: ColorConst.primaryGreen),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.close_rounded, size: 15, color: Color(0xFF9CA3AF)),
                    onPressed: () { _searchCtrl.clear(); setState(() => _query = ''); })
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 6),
          child: Row(children: [
            Text('${filtered.length} products', style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
            const Spacer(),
            _dot(ColorConst.primaryGreen, 'In stock'),
            const SizedBox(width: 10),
            _dot(const Color(0xFFDC2626), 'Low'),
            const SizedBox(width: 10),
            _dot(const Color(0xFFEF4444), 'Out'),
          ]),
        ),
        const Divider(height: 1, color: Color(0xFFF3F4F6)),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('No products found', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14)))
              : ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF9FAFB)),
            itemBuilder: (_, i) {
              final item  = filtered[i];
              final stock = item.stock ?? 0;
              final isOut = stock == 0;
              final color = _stockColor(stock);
              final isSel = widget.selected?.productid == item.productid;
              return InkWell(
                onTap: () => Navigator.pop(context, item),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSel ? ColorConst.primaryGreen.withOpacity(0.06) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isSel ? Border.all(color: ColorConst.primaryGreen.withOpacity(0.3)) : null,
                  ),
                  child: Row(children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(item.product?.name ?? '',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                              color: isOut ? const Color(0xFF9CA3AF) : const Color(0xFF111827))),
                      const SizedBox(height: 2),
                      Row(children: [
                        Text(isOut ? 'Out of stock' : '$stock units available',
                            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
                        if (item.variant?.name != null && item.variant?.name != 'Default') ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(color: const Color(0xFF2563EB).withOpacity(0.08), borderRadius: BorderRadius.circular(5)),
                            child: Text(item.variant?.name!, style: const TextStyle(fontSize: 9, color: Color(0xFF2563EB), fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ]),
                    ])),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(6)),
                      child: Text(item.category?.categoryName ?? '', style: const TextStyle(fontSize: 9, color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
                    ),
                    const SizedBox(width: 8),
                    if (isSel)
                      const Icon(Icons.check_circle_rounded, color: ColorConst.primaryGreen, size: 18)
                    else if (isOut)
                      const Icon(Icons.lock_outline_rounded, color: Color(0xFFD1D5DB), size: 16)
                    else
                      const Icon(Icons.chevron_right_rounded, color: Color(0xFFD1D5DB), size: 18),
                  ]),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _dot(Color c, String l) => Row(children: [
    Container(width: 7, height: 7, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
    const SizedBox(width: 4),
    Text(l, style: const TextStyle(fontSize: 9, color: Color(0xFF9CA3AF))),
  ]);
}