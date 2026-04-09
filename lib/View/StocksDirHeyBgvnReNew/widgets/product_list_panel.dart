// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
// import 'package:quick_ecommerce_city_panel_redefined/View/StocksDirHeyBgvnReNew/providers/stock_provider_new.dart';
// import '../providers/stock_provider.dart';
// import '../models/models.dart';
//
// class ProductListPanel extends StatelessWidget {
//   const ProductListPanel({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<StockProvider>();
//     final products = provider.filteredProducts;
//
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(14),
//           child: TextField(
//             style: const TextStyle(color: ColorConst.textPrimary, fontSize: 14),
//             onChanged: provider.setSearchQuery,
//             decoration: InputDecoration(
//               hintText: 'Search Product...',
//               hintStyle: const TextStyle(color: ColorConst.textGrey, fontSize: 13),
//               prefixIcon: const Icon(Icons.search, color: ColorConst.textGrey, size: 18),
//               filled: true,
//               fillColor: ColorConst.containerGrey,
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
//               contentPadding: const EdgeInsets.symmetric(vertical: 10),
//             ),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
//           child: Row(
//             children: [
//               Text('${products.length} products', style: const TextStyle(color: ColorConst.textGrey, fontSize: 12)),
//               if (provider.selectedProducts.isNotEmpty) ...[
//                 const SizedBox(width: 8),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                   decoration: BoxDecoration(color: ColorConst.greenSoft, borderRadius: BorderRadius.circular(10), border: Border.all(color: ColorConst.stroke)),
//                   child: Text('${provider.selectedProducts.length} selected', style: const TextStyle(color: ColorConst.primaryGreen, fontSize: 11, fontWeight: FontWeight.w600)),
//                 ),
//               ],
//             ],
//           ),
//         ),
//         Expanded(
//           child: products.isEmpty
//               ? const Center(child: Text('Koi product nahi mila', style: TextStyle(color: ColorConst.textGrey)))
//               : ListView.builder(
//                   padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
//                   itemCount: products.length,
//                   itemBuilder: (_, i) => _ProductCard(product: products[i]),
//                 ),
//         ),
//       ],
//     );
//   }
// }
//
// class _ProductCard extends StatefulWidget {
//   final Product product;
//   const _ProductCard({required this.product});
//   @override
//   State<_ProductCard> createState() => _ProductCardState();
// }
//
// class _ProductCardState extends State<_ProductCard> {
//   bool _expanded = false;
//
//   @override
//   Widget build(BuildContext context) {
//     final p = widget.product;
//     final issues = p.variants.where((v) => v.stockStatus != StockStatus.inStock).length;
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       decoration: BoxDecoration(
//         color: ColorConst.cardColor,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: p.isSelected ? ColorConst.primaryGreen : ColorConst.borderColor, width: p.isSelected ? 1.5 : 1),
//         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
//       ),
//       child: Column(
//         children: [
//           GestureDetector(
//             onTap: () => setState(() => _expanded = !_expanded),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
//               child: Row(
//                 children: [
//                   GestureDetector(
//                     onTap: () => context.read<StockProvider>().toggleProductSelection(p.id),
//                     child: AnimatedContainer(
//                       duration: const Duration(milliseconds: 150),
//                       width: 20, height: 20,
//                       decoration: BoxDecoration(
//                         color: p.isSelected ? ColorConst.primaryGreen : Colors.transparent,
//                         borderRadius: BorderRadius.circular(5),
//                         border: Border.all(color: p.isSelected ? ColorConst.primaryGreen : ColorConst.borderColor, width: 1.5),
//                       ),
//                       child: p.isSelected ? const Icon(Icons.check, color: Colors.white, size: 13) : null,
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Container(
//                     width: 36, height: 36,
//                     decoration: BoxDecoration(color: ColorConst.greenPale, borderRadius: BorderRadius.circular(8)),
//                     child: const Icon(Icons.inventory_2_outlined, color: ColorConst.primaryGreen, size: 18),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(p.name, style: const TextStyle(color: ColorConst.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
//                         const SizedBox(height: 2),
//                         Row(
//                           children: [
//                             Text('${p.variants.length} variants', style: const TextStyle(color: ColorConst.textGrey, fontSize: 11)),
//                             const SizedBox(width: 6),
//                             Text('Total: ${p.totalAvailable}', style: const TextStyle(color: ColorConst.textSecondary, fontSize: 11)),
//                             if (issues > 0) ...[
//                               const SizedBox(width: 6),
//                               Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
//                                 decoration: BoxDecoration(color: ColorConst.honeyBg, borderRadius: BorderRadius.circular(4)),
//                                 child: Text('$issues issues', style: const TextStyle(color: ColorConst.honey, fontSize: 10, fontWeight: FontWeight.w600)),
//                               ),
//                             ],
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: ColorConst.textGrey, size: 18),
//                 ],
//               ),
//             ),
//           ),
//           if (_expanded) ...[
//             Divider(height: 1, color: ColorConst.borderColor),
//             ...p.variants.map((v) => _VariantRow(variant: v)),
//           ],
//         ],
//       ),
//     );
//   }
// }
//
// class _VariantRow extends StatelessWidget {
//   final ProductVariant variant;
//   const _VariantRow({required this.variant});
//
//   @override
//   Widget build(BuildContext context) {
//     final sc = _statusColor(variant.stockStatus);
//
//     return Container(
//       padding: const EdgeInsets.fromLTRB(22, 9, 14, 9),
//       decoration: BoxDecoration(border: Border(bottom: BorderSide(color: ColorConst.containerGrey))),
//       child: Row(
//         children: [
//           Container(width: 3, height: 34, decoration: BoxDecoration(color: sc, borderRadius: BorderRadius.circular(2))),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(variant.name, style: const TextStyle(color: ColorConst.textPrimary, fontSize: 12, fontWeight: FontWeight.w500)),
//                 Text('SKU: ${variant.sku}', style: const TextStyle(color: ColorConst.textGrey, fontSize: 11)),
//               ],
//             ),
//           ),
//           Row(
//             children: [
//               _pill('Total', variant.stock.toString(), ColorConst.info),
//               const SizedBox(width: 5),
//               _pill('Reserved', variant.reservedStock.toString(), ColorConst.warning),
//               const SizedBox(width: 5),
//               _pill('Avail', variant.availableStock.toString(), sc),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _pill(String label, String val, Color color) {
//     return Column(
//       children: [
//         Text(label, style: TextStyle(color: color.withOpacity(0.7), fontSize: 9)),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//           decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(5)),
//           child: Text(val, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
//         ),
//       ],
//     );
//   }
//
//   Color _statusColor(StockStatus s) {
//     switch (s) {
//       case StockStatus.inStock: return ColorConst.success;
//       case StockStatus.lowStock: return ColorConst.warning;
//       case StockStatus.outOfStock: return ColorConst.error;
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/StocksDirHeyBgvnReNew/providers/stock_provider_new.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/StocksDirHeyBgvnReNew/models/main_catsubcat_all_data_model.dart';

class ProductListPanel extends StatelessWidget {
  const ProductListPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StockProvider>(
      builder: (context, provider, child) {
        // Determine which products to show based on selection
        List<Products> displayProducts = [];

        if (provider.selectedSubCategoryIndex != null) {
          // Show products from selected subcategory
          displayProducts = provider.productsForSelectedSubCategory;
        } else if (provider.selectedCategoryIndex != null) {
          // Show all products from selected category (all subcategories)
          for (var subCat in provider.subcategoriesForSelectedCategory) {
            displayProducts.addAll(subCat.products ?? []);
          }
        } else if (provider.selectedMainCategoryIndex != null) {
          // Show all products from selected main category
          for (var cat in provider.categoriesForSelectedMain) {
            for (var subCat in cat.subcategories ?? []) {
              displayProducts.addAll(subCat.products ?? []);
            }
          }
        } else {
          // Show all products
          for (var mainCat in provider.mainCategories) {
            for (var cat in mainCat.categories ?? []) {
              for (var subCat in cat.subcategories ?? []) {
                displayProducts.addAll(subCat.products ?? []);
              }
            }
          }
        }

        // Apply search filter if any
        if (provider.searchQuery.isNotEmpty) {
          displayProducts = displayProducts.where((p) {
            return p.name
                .toString()
                .toLowerCase()
                .contains(provider.searchQuery.toLowerCase());
          }).toList();
        }

        return Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(14),
              child: TextField(
                style: const TextStyle(
                  color: ColorConst.textPrimary,
                  fontSize: 14,
                ),
                onChanged: provider.setSearchQuery,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: const TextStyle(
                    color: ColorConst.textGrey,
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: ColorConst.textGrey,
                    size: 18,
                  ),
                  suffixIcon: provider.searchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => provider.setSearchQuery(''),
                  )
                      : null,
                  filled: true,
                  fillColor: ColorConst.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),

            // Header with product count and selection info
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
              child: Row(
                children: [
                  Text(
                    '${displayProducts.length} products',
                    style: const TextStyle(
                      color: ColorConst.textGrey,
                      fontSize: 12,
                    ),
                  ),
                  if (provider.selectedProductIds.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: ColorConst.greenSoft,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: ColorConst.stroke),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${provider.selectedProductIds.length} selected',
                            style: const TextStyle(
                              color: ColorConst.primaryGreen,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => provider.clearProductSelection(),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: ColorConst.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const Spacer(),
                  // Select All button (only show when in subcategory view)
                  if (provider.selectedSubCategoryIndex != null &&
                      displayProducts.isNotEmpty)
                    TextButton.icon(
                      onPressed: provider.selectAllProductsInCurrentView,
                      icon: const Icon(Icons.select_all, size: 16),
                      label: const Text('Select All'),
                      style: TextButton.styleFrom(
                        foregroundColor: ColorConst.primaryGreen,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                ],
              ),
            ),

            // Product List or Empty State
            Expanded(
              child: displayProducts.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 48,
                      color: ColorConst.textGrey.withOpacity(0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      provider.searchQuery.isNotEmpty
                          ? 'No products found for "${provider.searchQuery}"'
                          : 'No products in this category',
                      style: const TextStyle(
                        color: ColorConst.textGrey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                itemCount: displayProducts.length,
                itemBuilder: (_, index) {
                  return _ProductCard(
                    product: displayProducts[index],
                    provider: provider,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProductCard extends StatefulWidget {
  final Products product;
  final StockProvider provider;

  const _ProductCard({
    required this.product,
    required this.provider,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _expanded = false;

  int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  int get totalStock => _parseInt(widget.product.totalStock);

  List<Variants> get variants => widget.product.variants ?? [];

  bool get isSelected {
    final id = widget.product.productId.toString();
    final selected = widget.provider.isProductSelected(id);
    print('Product ${widget.product.name} (ID: $id) isSelected: $selected');
    return selected;
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final hasIssues = totalStock == 0 || totalStock <= 5;
    final issuesCount = variants.where((v) {
      final stock = _parseInt(v.stock);
      return stock == 0 || stock <= 5;
    }).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: ColorConst.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? ColorConst.primaryGreen : ColorConst.borderColor,
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Product Header
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              child: Row(
                children: [
                  // Selection Checkbox
                  GestureDetector(
                    onTap: () => widget.provider
                        .toggleProductSelection(product.productId.toString()),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? ColorConst.primaryGreen
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: isSelected
                              ? ColorConst.primaryGreen
                              : ColorConst.borderColor,
                          width: 1.5,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 13)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Product Image
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: ColorConst.greenPale,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: product.img != null &&
                        product.img.toString().isNotEmpty
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product.img.toString(),
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.inventory_2_outlined,
                          color: ColorConst.primaryGreen,
                          size: 18,
                        ),
                      ),
                    )
                        : const Icon(
                      Icons.inventory_2_outlined,
                      color: ColorConst.primaryGreen,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Product Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name?.toString() ?? 'Unnamed',
                          style: const TextStyle(
                            color: ColorConst.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              '${variants.length} variants',
                              style: const TextStyle(
                                color: ColorConst.textGrey,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: widget.provider
                                    .getStockStatusColor(totalStock)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Total: $totalStock',
                                style: TextStyle(
                                  color: widget.provider
                                      .getStockStatusColor(totalStock),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (issuesCount > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: ColorConst.honeyBg,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '$issuesCount issues',
                                  style: const TextStyle(
                                    color: ColorConst.honey,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: widget.provider
                          .getStockStatusColor(totalStock)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.provider.getStockStatusText(totalStock),
                      style: TextStyle(
                        color: widget.provider.getStockStatusColor(totalStock),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Expand/Collapse Icon
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: ColorConst.textGrey,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

          // Expanded Variants Section
          if (_expanded && variants.isNotEmpty) ...[
            const Divider(height: 1, color: ColorConst.borderColor),
            ...variants.map((variant) => _VariantRow(variant: variant)),
          ],
        ],
      ),
    );
  }
}

class _VariantRow extends StatelessWidget {
  final Variants variant;

  const _VariantRow({required this.variant});

  int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  int get stock => _parseInt(variant.stock);
  double get price => _parseDouble(variant.price);
  double get discountPrice => _parseDouble(variant.discountPrice);

  Color _getStatusColor() {
    if (stock == 0) return ColorConst.error;
    if (stock <= 5) return ColorConst.warning;
    return ColorConst.success;
  }

  String _getStatusText() {
    if (stock == 0) return 'Out of Stock';
    if (stock <= 5) return 'Low Stock';
    return 'In Stock';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final hasDiscount = discountPrice > 0 && discountPrice < price;

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 9, 14, 9),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: ColorConst.containerGrey),
        ),
      ),
      child: Row(
        children: [
          // Status Indicator
          Container(
            width: 3,
            height: 34,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),

          // Variant Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  variant.value?.toString() ?? 'Default',
                  style: const TextStyle(
                    color: ColorConst.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (hasDiscount) ...[
                      Text(
                        '₹${price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: ColorConst.textGrey,
                          fontSize: 11,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '₹${discountPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: ColorConst.primaryGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ] else if (price > 0) ...[
                      Text(
                        '₹${price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: ColorConst.textPrimary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Stock Info
          Row(
            children: [
              _StockPill(
                label: 'Stock',
                value: stock.toString(),
                color: statusColor,
              ),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  _getStatusText(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StockPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StockPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: color.withOpacity(0.7),
            fontSize: 9,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}