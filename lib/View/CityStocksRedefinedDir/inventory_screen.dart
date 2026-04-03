import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/CityStocksRedefinedDir/common_widgets.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/CityStocksRedefinedDir/demo_data.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/CityStocksRedefinedDir/models.dart';
import 'request_modal.dart';

class InventoryScreen extends StatefulWidget {
  final List<CartItem> cart;
  final VoidCallback onCartUpdated;

  const InventoryScreen({
    super.key,
    required this.cart,
    required this.onCartUpdated,
  });

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  // Navigation levels: 'main' | 'category' | 'sub' | 'products'
  String _level = 'main';
  MainCategory? _selMain;
  Category? _selCat;
  SubCategory? _selSub;

  // Expanded product rows
  final Set<String> _expandedProducts = {};

  // Per-variant requested qty map (variantId → qty)
  final Map<String, int> _reqQty = {};

  List<Category> get _filteredCategories =>
      demoCategories.where((c) => c.mainCategoryId == _selMain?.id).toList();

  List<SubCategory> get _filteredSubs =>
      demoSubCategories.where((s) => s.categoryId == _selCat?.id).toList();

  List<Product> get _filteredProducts =>
      demoProducts.where((p) => p.subCategoryId == _selSub?.id).toList();

  void _goMain() => setState(() {
    _level = 'main';
    _selMain = null;
    _selCat = null;
    _selSub = null;
  });
  void _goCat() => setState(() {
    _level = 'category';
    _selCat = null;
    _selSub = null;
  });
  void _goSub() => setState(() {
    _level = 'sub';
    _selSub = null;
  });

  void _addToCart(Product p, ProductVariant v, int qty) {
    if (qty <= 0) return;
    final existing = widget.cart.indexWhere((c) => c.variantId == v.id);
    if (existing >= 0) {
      widget.cart[existing].qty = qty;
    } else {
      widget.cart.add(
        CartItem(
          productId: p.id,
          productName: p.name,
          variantId: v.id,
          variantLabel: v.label,
          subCategory: _selSub?.name ?? '',
          qty: qty,
        ),
      );
    }
    widget.onCartUpdated();
  }

  void _removeFromCart(String variantId) {
    widget.cart.removeWhere((c) => c.variantId == variantId);
    widget.onCartUpdated();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        // ── Stats row ──
        _buildStats(),
        const SizedBox(height: 18),

        // ── Breadcrumb ──
        _buildBreadcrumb(),
        const SizedBox(height: 14),

        // ── Cart preview (when items in cart and on products level) ──
        if (widget.cart.isNotEmpty && _level == 'products') ...[
          _buildCartPreview(),
          const SizedBox(height: 14),
        ],

        // ── Content by level ──
        Expanded(child: _buildLevelContent()),
      ],
    );
  }

  // ── Stats ──────────────────────────────────
  Widget _buildStats() {
    final lowCount = demoProducts
        .where(
          (p) =>
              p.overallStatus == StockStatus.low ||
              p.overallStatus == StockStatus.critical,
        )
        .length;
    final pendingCount = demoRequests
        .where((r) => r.status == RequestStatus.pending)
        .length;
    final incCount = demoShipments
        .where(
          (s) =>
              s.status == ShipmentStatus.arrived ||
              s.status == ShipmentStatus.inTransit,
        )
        .length;

    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.1,
      ),
      children: [
        StatCard(
          label: 'TOTAL PRODUCTS',
          value: '${demoProducts.length}',
          sub: '${demoMainCategories.length} main categories',
          iconBg: ColorConst.primaryExtraLightGreen,
          valueColor: ColorConst.primaryGreen,
          icon: Icons.inventory_2_rounded,
          iconColor: ColorConst.primaryGreen,
        ),
        StatCard(
          label: 'LOW STOCK',
          value: '$lowCount',
          sub: 'Need immediate restock',
          iconBg: ColorConst.criticalRedLight,
          valueColor: ColorConst.criticalRed,
          icon: Icons.warning_amber_rounded,
          iconColor: ColorConst.criticalRed,
        ),
        StatCard(
          label: 'PENDING REQUESTS',
          value: '$pendingCount',
          sub: 'Awaiting admin approval',
          iconBg: ColorConst.criticalYellowLight,
          valueColor: ColorConst.criticalYellowLightText,
          icon: Icons.pending_actions_rounded,
          iconColor: ColorConst.criticalYellowLightText,
        ),
        StatCard(
          label: 'INCOMING',
          value: '$incCount',
          sub: 'Active shipments',
          iconBg: ColorConst.criticalBlueLight,
          valueColor: ColorConst.criticalBlue,
          icon: Icons.local_shipping_rounded,
          iconColor: ColorConst.criticalBlue,
        ),
      ],
    );
  }

  // ── Breadcrumb ──────────────────────────────
  Widget _buildBreadcrumb() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: ColorConst.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ColorConst.borderColor),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.grid_view_rounded,
            size: 14,
            color: ColorConst.textSecondary,
          ),
          const SizedBox(width: 6),
          _BcCrumb(
            label: 'Main Category',
            isActive: _level == 'main',
            onTap: _level != 'main' ? _goMain : null,
          ),
          if (_selMain != null) ...[
            const _BcArrow(),
            _BcCrumb(
              label: _selMain!.name,
              isActive: _level == 'category',
              onTap: _level != 'category' ? _goCat : null,
            ),
          ],
          if (_selCat != null) ...[
            const _BcArrow(),
            _BcCrumb(
              label: _selCat!.name,
              isActive: _level == 'sub',
              onTap: _level != 'sub' ? _goSub : null,
            ),
          ],
          if (_selSub != null) ...[
            const _BcArrow(),
            _BcCrumb(
              label: _selSub!.name,
              isActive: _level == 'products',
              onTap: null,
            ),
          ],
        ],
      ),
    );
  }

  // ── Cart Preview ────────────────────────────
  Widget _buildCartPreview() {
    return Container(
      decoration: BoxDecoration(
        color: ColorConst.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBBF7D0), width: 1.5),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                const Icon(
                  Icons.shopping_cart_outlined,
                  size: 18,
                  color: ColorConst.primaryGreen,
                ),
                const SizedBox(width: 8),
                Text(
                  'Request Cart',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: ColorConst.kTextHead,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: ColorConst.primaryGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${widget.cart.length}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    widget.cart.clear();
                    _reqQty.clear();
                    widget.onCartUpdated();
                  },
                  child: const Text(
                    'Clear All',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: ColorConst.criticalRed,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFBBF7D0)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.cart
                  .map(
                    (item) => _CartChip(
                      item: item,
                      onRemove: () {
                        _removeFromCart(item.variantId);
                        setState(() {});
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: 'Send Bulk Request to Admin',
                icon: Icons.send_rounded,
                onTap: () => _openBulkSendModal(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openBulkSendModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RequestModal(
        cart: List.from(widget.cart),
        onSent: () {
          widget.cart.clear();
          _reqQty.clear();
          widget.onCartUpdated();
          setState(() {});
        },
      ),
    );
  }

  // ── Level Content ───────────────────────────
  Widget _buildLevelContent() {
    switch (_level) {
      case 'main':
        return _buildMainCategories();
      case 'category':
        return _buildCategories();
      case 'sub':
        return _buildSubCategories();
      case 'products':
        return _buildProducts();
      default:
        return const SizedBox();
    }
  }

  // ── Main Categories ─────────────────────────
  Widget _buildMainCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Main Categories',
          subtitle: 'Select a category to browse inventory',
        ),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.builder(
            itemCount: demoMainCategories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
            ),
            itemBuilder: (_, i) {
              final mc = demoMainCategories[i];
              final catCount = demoCategories
                  .where((c) => c.mainCategoryId == mc.id)
                  .length;
              final prodCount = demoProducts.where((p) {
                final sub = demoSubCategories.firstWhere(
                  (s) => s.id == p.subCategoryId,
                  orElse: () =>
                      SubCategory(id: '', name: '', emoji: '', categoryId: ''),
                );
                final cat = demoCategories.firstWhere(
                  (c) => c.id == sub.categoryId,
                  orElse: () => Category(
                    id: '',
                    name: '',
                    emoji: '',
                    mainCategoryId: '',
                    colorHex: '',
                  ),
                );
                return cat.mainCategoryId == mc.id;
              }).length;
              final bgColor = Color(int.parse('0xFF${mc.bgColorHex}'));
              return _MainCatCard(
                mc: mc,
                bgColor: bgColor,
                catCount: catCount,
                prodCount: prodCount,
                onTap: () => setState(() {
                  _selMain = mc;
                  _level = 'category';
                }),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Categories ──────────────────────────────
  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: _selMain!.name, subtitle: 'Select category'),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.builder(
            itemCount: _filteredCategories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.25,
            ),
            itemBuilder: (_, i) {
              final cat = _filteredCategories[i];
              final subCount = demoSubCategories
                  .where((s) => s.categoryId == cat.id)
                  .length;
              final bgColor = Color(int.parse('0xFF${cat.colorHex}'));
              return _CatCard(
                cat: cat,
                bgColor: bgColor,
                subCount: subCount,
                onTap: () => setState(() {
                  _selCat = cat;
                  _level = 'sub';
                }),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Sub-Categories ──────────────────────────
  Widget _buildSubCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: _selCat!.name, subtitle: 'Select sub-category'),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: _filteredSubs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final sub = _filteredSubs[i];
              final prods = demoProducts
                  .where((p) => p.subCategoryId == sub.id)
                  .toList();
              final lowCount = prods
                  .where(
                    (p) =>
                        p.overallStatus == StockStatus.low ||
                        p.overallStatus == StockStatus.critical,
                  )
                  .length;
              return _SubCatTile(
                sub: sub,
                prodCount: prods.length,
                lowCount: lowCount,
                onTap: () => setState(() {
                  _selSub = sub;
                  _level = 'products';
                }),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Products ────────────────────────────────
  Widget _buildProducts() {
    final products = _filteredProducts;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: _selSub!.name,
          subtitle: '${products.length} products',
          trailing: widget.cart.isEmpty
              ? OutlineGreenButton(
                  label: 'Send Request',
                  icon: Icons.send_rounded,
                  onTap: _openBulkSendModal,
                  isSmall: true,
                )
              : null,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: products.length,
            itemBuilder: (_, i) {
              final p = products[i];
              final expanded = _expandedProducts.contains(p.id);
              return _ProductCard(
                product: p,
                expanded: expanded,
                reqQtyMap: _reqQty,
                cart: widget.cart,
                onToggle: () => setState(() {
                  if (expanded) {
                    _expandedProducts.remove(p.id);
                  } else {
                    _expandedProducts.add(p.id);
                  }
                }),
                onQtyChanged: (v, qty) {
                  setState(() {
                    _reqQty[v.id] = qty;
                  });
                  _addToCart(p, v, qty);
                },
                onAddVariants: (variants) {
                  for (final v in variants) {
                    final qty = _reqQty[v.id] ?? 0;
                    if (qty > 0) _addToCart(p, v, qty);
                  }
                  setState(() {});
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Main Category Card
// ─────────────────────────────────────────────
class _MainCatCard extends StatelessWidget {
  final MainCategory mc;
  final Color bgColor;
  final int catCount, prodCount;
  final VoidCallback onTap;
  const _MainCatCard({
    required this.mc,
    required this.bgColor,
    required this.catCount,
    required this.prodCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColorConst.cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ColorConst.borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Center(
                  child: Text(mc.emoji, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const Spacer(),
              Text(
                mc.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: ColorConst.kTextHead,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  _MetaPill(text: '$catCount cats'),
                  const SizedBox(width: 6),
                  _MetaPill(text: '$prodCount products'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final String text;
  const _MetaPill({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: ColorConst.containerGrey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: ColorConst.textSecondary,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Category Card
// ─────────────────────────────────────────────
class _CatCard extends StatelessWidget {
  final Category cat;
  final Color bgColor;
  final int subCount;
  final VoidCallback onTap;
  const _CatCard({
    required this.cat,
    required this.bgColor,
    required this.subCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColorConst.cardColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: ColorConst.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(cat.emoji, style: const TextStyle(fontSize: 20)),
                ),
              ),
              const Spacer(),
              Text(
                cat.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: ColorConst.kTextHead,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '$subCount sub-categories',
                style: const TextStyle(
                  fontSize: 11,
                  color: ColorConst.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Sub-Category Tile
// ─────────────────────────────────────────────
class _SubCatTile extends StatelessWidget {
  final SubCategory sub;
  final int prodCount, lowCount;
  final VoidCallback onTap;
  const _SubCatTile({
    required this.sub,
    required this.prodCount,
    required this.lowCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColorConst.cardColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: ColorConst.borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: ColorConst.primaryExtraLightGreen,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Center(
                  child: Text(sub.emoji, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sub.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: ColorConst.kTextHead,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '$prodCount products',
                          style: const TextStyle(
                            fontSize: 12,
                            color: ColorConst.textSecondary,
                          ),
                        ),
                        if (lowCount > 0) ...[
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: ColorConst.criticalRedLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$lowCount low',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: ColorConst.criticalRed,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: ColorConst.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Product Card with expandable variants
// ─────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final Product product;
  final bool expanded;
  final Map<String, int> reqQtyMap;
  final List<CartItem> cart;
  final VoidCallback onToggle;
  final Function(ProductVariant, int) onQtyChanged;
  final Function(List<ProductVariant>) onAddVariants;

  const _ProductCard({
    required this.product,
    required this.expanded,
    required this.reqQtyMap,
    required this.cart,
    required this.onToggle,
    required this.onQtyChanged,
    required this.onAddVariants,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: ColorConst.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ColorConst.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .03),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Row ──
            InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(14),
                bottom: expanded ? Radius.zero : const Radius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    // Product Info
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: ColorConst.kTextHead,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            product.sku,
                            style: const TextStyle(
                              fontSize: 11,
                              color: ColorConst.kTextMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: ColorConst.containerGrey,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${product.variants.length} variants',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: ColorConst.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Stock Info
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '${product.totalStock}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: ColorConst.kTextHead,
                            ),
                          ),
                          const Text(
                            'total units',
                            style: TextStyle(
                              fontSize: 10,
                              color: ColorConst.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          StockStatusChip(status: product.overallStatus),
                        ],
                      ),
                    ),
                    // Chevron
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: expanded ? 0.25 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        size: 22,
                        color: ColorConst.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Variants expanded ──
            if (expanded) _buildVariants(),
          ],
        ),
      ),
    );
  }

  Widget _buildVariants() {
    return Column(
      children: [
        const Divider(height: 1, color: ColorConst.borderColor),
        Container(
          color: ColorConst.containerGrey2,
          child: Column(
            children: [
              // Table header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                child: Row(
                  children: const [
                    Expanded(flex: 2, child: _ColHead(text: 'VARIANT')),
                    Expanded(child: _ColHead(text: 'STOCK')),
                    Expanded(child: _ColHead(text: 'MIN')),
                    Expanded(child: _ColHead(text: 'STATUS')),
                    Expanded(
                      flex: 2,
                      child: _ColHead(text: 'REQ QTY', align: TextAlign.center),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: ColorConst.borderColor),
              // Variant rows
              ...product.variants.map(
                (v) => _VariantRow(
                  variant: v,
                  reqQty:
                      reqQtyMap[v.id] ??
                      (cart
                          .firstWhere(
                            (c) => c.variantId == v.id,
                            orElse: () => CartItem(
                              productId: '',
                              productName: '',
                              variantId: '',
                              variantLabel: '',
                              subCategory: '',
                              qty: 0,
                            ),
                          )
                          .qty),
                  onQtyChanged: (qty) => onQtyChanged(v, qty),
                ),
              ),
              // Add to cart footer
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlineGreenButton(
                      label: 'Add to Request Cart',
                      icon: Icons.add_shopping_cart_rounded,
                      isSmall: true,
                      onTap: () => onAddVariants(product.variants),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ColHead extends StatelessWidget {
  final String text;
  final TextAlign align;
  const _ColHead({required this.text, this.align = TextAlign.left});
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      style: const TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w800,
        color: ColorConst.textSecondary,
        letterSpacing: 0.6,
      ),
    );
  }
}

class _VariantRow extends StatelessWidget {
  final ProductVariant variant;
  final int reqQty;
  final ValueChanged<int> onQtyChanged;
  const _VariantRow({
    required this.variant,
    required this.reqQty,
    required this.onQtyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: ColorConst.borderColor)),
      ),
      child: Row(
        children: [
          Container(
            width: Sizes.screenWidth*0.06,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: ColorConst.containerGrey,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Center(
              child: Text(
                variant.label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: ColorConst.kTextHead,
                ),
              ),
            ),
          ),
          SizedBox(width: Sizes.screenWidth*0.147),
          SizedBox(
            width: Sizes.screenWidth*0.05,
              child: Center(
              child: Text(
                '${variant.currentStock}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: ColorConst.kTextHead,
                ),
              ),
            ),
          ),
          SizedBox(width: Sizes.screenWidth*0.056),
          SizedBox(
            width: Sizes.screenWidth*0.05,
            child: Center(
              child: Text(
                '${variant.minLevel}',
                style: const TextStyle(
                  fontSize: 12,
                  color: ColorConst.textSecondary,
                ),
              ),
            ),
          ),
          SizedBox(width: Sizes.screenWidth*0.068),
          SizedBox(
              width: Sizes.screenWidth*0.055,
              child: StockStatusChip(status: variant.stockStatus)),
          SizedBox(width: Sizes.screenWidth*0.15),
          QtyStepper(value: reqQty, onChanged: onQtyChanged),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Cart Chip
// ─────────────────────────────────────────────
class _CartChip extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove;
  const _CartChip({required this.item, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 7, 6, 7),
      decoration: BoxDecoration(
        color: ColorConst.containerGrey2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ColorConst.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: ColorConst.kTextHead,
                ),
              ),
              Text(
                '${item.variantLabel} · ×${item.qty}',
                style: const TextStyle(
                  fontSize: 10,
                  color: ColorConst.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: ColorConst.criticalRedLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 12,
                color: ColorConst.criticalRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Breadcrumb helpers
// ─────────────────────────────────────────────
class _BcCrumb extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;
  const _BcCrumb({required this.label, required this.isActive, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isActive
              ? ColorConst.primaryExtraLightGreen
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isActive
                ? ColorConst.primaryGreen
                : ColorConst.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _BcArrow extends StatelessWidget {
  const _BcArrow();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 2),
      child: Icon(Icons.chevron_right, size: 16, color: ColorConst.borderColor),
    );
  }
}
