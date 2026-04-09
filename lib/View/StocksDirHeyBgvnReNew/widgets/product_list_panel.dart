import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import '../providers/stock_provider.dart';
import '../models/models.dart';

class ProductListPanel extends StatelessWidget {
  const ProductListPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StockProvider>();
    final products = provider.filteredProducts;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: TextField(
            style: const TextStyle(color: ColorConst.textPrimary, fontSize: 14),
            onChanged: provider.setSearchQuery,
            decoration: InputDecoration(
              hintText: 'Search Product...',
              hintStyle: const TextStyle(color: ColorConst.textGrey, fontSize: 13),
              prefixIcon: const Icon(Icons.search, color: ColorConst.textGrey, size: 18),
              filled: true,
              fillColor: ColorConst.containerGrey,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
          child: Row(
            children: [
              Text('${products.length} products', style: const TextStyle(color: ColorConst.textGrey, fontSize: 12)),
              if (provider.selectedProducts.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: ColorConst.greenSoft, borderRadius: BorderRadius.circular(10), border: Border.all(color: ColorConst.stroke)),
                  child: Text('${provider.selectedProducts.length} selected', style: const TextStyle(color: ColorConst.primaryGreen, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: products.isEmpty
              ? const Center(child: Text('Koi product nahi mila', style: TextStyle(color: ColorConst.textGrey)))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  itemCount: products.length,
                  itemBuilder: (_, i) => _ProductCard(product: products[i]),
                ),
        ),
      ],
    );
  }
}

class _ProductCard extends StatefulWidget {
  final Product product;
  const _ProductCard({required this.product});
  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final issues = p.variants.where((v) => v.stockStatus != StockStatus.inStock).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: ColorConst.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.isSelected ? ColorConst.primaryGreen : ColorConst.borderColor, width: p.isSelected ? 1.5 : 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.read<StockProvider>().toggleProductSelection(p.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 20, height: 20,
                      decoration: BoxDecoration(
                        color: p.isSelected ? ColorConst.primaryGreen : Colors.transparent,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: p.isSelected ? ColorConst.primaryGreen : ColorConst.borderColor, width: 1.5),
                      ),
                      child: p.isSelected ? const Icon(Icons.check, color: Colors.white, size: 13) : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: ColorConst.greenPale, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.inventory_2_outlined, color: ColorConst.primaryGreen, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name, style: const TextStyle(color: ColorConst.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text('${p.variants.length} variants', style: const TextStyle(color: ColorConst.textGrey, fontSize: 11)),
                            const SizedBox(width: 6),
                            Text('Total: ${p.totalAvailable}', style: const TextStyle(color: ColorConst.textSecondary, fontSize: 11)),
                            if (issues > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(color: ColorConst.honeyBg, borderRadius: BorderRadius.circular(4)),
                                child: Text('$issues issues', style: const TextStyle(color: ColorConst.honey, fontSize: 10, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: ColorConst.textGrey, size: 18),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            Divider(height: 1, color: ColorConst.borderColor),
            ...p.variants.map((v) => _VariantRow(variant: v)),
          ],
        ],
      ),
    );
  }
}

class _VariantRow extends StatelessWidget {
  final ProductVariant variant;
  const _VariantRow({required this.variant});

  @override
  Widget build(BuildContext context) {
    final sc = _statusColor(variant.stockStatus);

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 9, 14, 9),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: ColorConst.containerGrey))),
      child: Row(
        children: [
          Container(width: 3, height: 34, decoration: BoxDecoration(color: sc, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(variant.name, style: const TextStyle(color: ColorConst.textPrimary, fontSize: 12, fontWeight: FontWeight.w500)),
                Text('SKU: ${variant.sku}', style: const TextStyle(color: ColorConst.textGrey, fontSize: 11)),
              ],
            ),
          ),
          Row(
            children: [
              _pill('Total', variant.stock.toString(), ColorConst.info),
              const SizedBox(width: 5),
              _pill('Reserved', variant.reservedStock.toString(), ColorConst.warning),
              const SizedBox(width: 5),
              _pill('Avail', variant.availableStock.toString(), sc),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(String label, String val, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: color.withOpacity(0.7), fontSize: 9)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(5)),
          child: Text(val, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  Color _statusColor(StockStatus s) {
    switch (s) {
      case StockStatus.inStock: return ColorConst.success;
      case StockStatus.lowStock: return ColorConst.warning;
      case StockStatus.outOfStock: return ColorConst.error;
    }
  }
}
