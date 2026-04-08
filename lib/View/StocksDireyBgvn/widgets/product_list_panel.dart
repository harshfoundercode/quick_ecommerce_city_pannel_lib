import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            style: const TextStyle(color: Colors.white),
            onChanged: provider.setSearchQuery,
            decoration: InputDecoration(
              hintText: 'Product search karein...',
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon: const Icon(Icons.search, color: Colors.white38),
              filled: true,
              fillColor: const Color(0xFF1A1A35),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        // Count + selection info
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              Text('${products.length} products',
                  style: const TextStyle(color: Colors.white38, fontSize: 12)),
              if (provider.selectedProducts.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D5AFE).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('${provider.selectedProducts.length} selected',
                      style: const TextStyle(color: Color(0xFF3D5AFE), fontSize: 11)),
                ),
              ],
            ],
          ),
        ),
        // Product list
        Expanded(
          child: products.isEmpty
              ? const Center(
                  child: Text('Koi product nahi mila',
                      style: TextStyle(color: Colors.white38)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final lowStockVariants = product.variants
        .where((v) => v.stockStatus != StockStatus.inStock)
        .length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF12122A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: product.isSelected
              ? const Color(0xFF3D5AFE).withOpacity(0.5)
              : Colors.white.withOpacity(0.07),
          width: product.isSelected ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          // Product header row
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Checkbox for bulk selection
                  GestureDetector(
                    onTap: () {
                      context.read<StockProvider>().toggleProductSelection(product.id);
                    },
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: product.isSelected
                            ? const Color(0xFF3D5AFE)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: product.isSelected
                              ? const Color(0xFF3D5AFE)
                              : Colors.white30,
                          width: 1.5,
                        ),
                      ),
                      child: product.isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 14)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Product icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A35),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.inventory_2_outlined,
                        color: Colors.white54, size: 20),
                  ),
                  const SizedBox(width: 12),
                  // Name + stats
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Text('${product.variants.length} variants',
                                style: const TextStyle(
                                    color: Colors.white38, fontSize: 11)),
                            const SizedBox(width: 8),
                            Text('Total: ${product.totalAvailable}',
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 11)),
                            if (lowStockVariants > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '$lowStockVariants issues',
                                  style: const TextStyle(
                                      color: Colors.orange,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.white38,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          // Variants expanded
          if (_isExpanded) ...[
            const Divider(height: 1, color: Color(0xFF1E1E40)),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: product.variants.length,
              itemBuilder: (_, i) => _VariantRow(variant: product.variants[i]),
            ),
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
    final statusColor = _statusColor(variant.stockStatus);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 10, 16, 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.04)),
        ),
      ),
      child: Row(
        children: [
          // Color indicator
          Container(
            width: 3,
            height: 36,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          // Variant info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(variant.name,
                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
                Text('SKU: ${variant.sku}',
                    style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          // Stock numbers
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  _stockPill('Total', variant.stock.toString(), Colors.blue),
                  const SizedBox(width: 6),
                  _stockPill('Reserved', variant.reservedStock.toString(), Colors.purple),
                  const SizedBox(width: 6),
                  _stockPill('Available', variant.availableStock.toString(), statusColor),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '₹${variant.price.toStringAsFixed(0)}',
                style: const TextStyle(
                    color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stockPill(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: color.withOpacity(0.7), fontSize: 9)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(value,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  Color _statusColor(StockStatus status) {
    switch (status) {
      case StockStatus.inStock:
        return Colors.green;
      case StockStatus.lowStock:
        return Colors.orange;
      case StockStatus.outOfStock:
        return Colors.red;
    }
  }
}
