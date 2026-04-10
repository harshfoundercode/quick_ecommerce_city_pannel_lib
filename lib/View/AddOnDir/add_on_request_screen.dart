import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/AddOnDir/UrgentAddOnModelDir/category_from_maincat_model_urgent.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/AddOnDir/UrgentAddOnModelDir/main_category_list_model_urgent.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/AddOnDir/UrgentAddOnViewModel/urgent_add_on_view_model.dart';


class CartItem {
  final Products product;
  final Variants variant;
  int qty;

  CartItem({required this.product, required this.variant, this.qty = 1});

  double get unitPrice =>
      double.tryParse(variant.discountPrice?.toString() ?? '') ??
          double.tryParse(variant.price?.toString() ?? '') ??
          0.0;

  double get total => unitPrice * qty;
}

const kNavy   = Color(0xFF0D47A1);
const kNavyL  = Color(0xFF1565C0);
const kAccent = Color(0xFFFF6D00);
const kBg     = Color(0xFFF0F4F8);
const kSurf   = Colors.white;
const kBorder = Color(0xFFDDE3EC);
const kT1     = Color(0xFF0D1B2A);
const kT2     = Color(0xFF5A6A7E);

// ════════════════════════════════════════════════════════════════════════════════
// MAIN SCREEN
// ════════════════════════════════════════════════════════════════════════════════

class UrgentAddOnScreen extends StatefulWidget {
  const UrgentAddOnScreen({super.key});

  @override
  State<UrgentAddOnScreen> createState() => _UrgentAddOnScreenState();
}

class _UrgentAddOnScreenState extends State<UrgentAddOnScreen> {
  // ── Left-panel selections ──────────────────────────────────────────────────
  UrgentMainCategoryData? _selMain;
  Categories?             _selCat;
  Subcategories?          _selSub;
  Products?               _selProduct;
  Variants?               _selVariant;
  int                     _qty = 1;

  // ── Cart ───────────────────────────────────────────────────────────────────
  final List<CartItem> _cart = [];

  // ── Computed ───────────────────────────────────────────────────────────────
  double get _subtotal  => _cart.fold(0.0, (s, i) => s + i.total);
  double get _tax       => _subtotal * 0.05;
  double get _grandTotal => _subtotal + _tax;

  // ── Init ───────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch main categories on open
      context.read<UrgentAddOnViewModel>().getMainCategoryDataApi(context);
    });
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  void _onMainCatTap(UrgentMainCategoryData mc) {
    setState(() {
      _selMain    = mc;
      _selCat     = null;
      _selSub     = null;
      _selProduct = null;
      _selVariant = null;
    });
    // Fetch categories+subcategories+products for selected main category
    context.read<UrgentAddOnViewModel>()
        .getCategoryFromMainCatIdApi(context, mainCatId: mc.id.toString());
  }

  void _onCatTap(Categories cat) => setState(() {
    _selCat     = cat;
    _selSub     = null;
    _selProduct = null;
    _selVariant = null;
  });

  void _onSubTap(Subcategories sub) => setState(() {
    _selSub     = sub;
    _selProduct = null;
    _selVariant = null;
  });

  void _onProductTap(Products p) => setState(() {
    _selProduct = p;
    _selVariant = null;
  });

  void _onVariantTap(Variants v) => setState(() => _selVariant = v);

  void _changeQty(int delta) =>
      setState(() => _qty = (_qty + delta).clamp(1, 9999));

  void _addToCart() {
    if (_selProduct == null || _selVariant == null) return;
    setState(() {
      final match = _cart.where((c) =>
      c.product.productId == _selProduct!.productId &&
          c.variant.variantId == _selVariant!.variantId);
      if (match.isNotEmpty) {
        match.first.qty += _qty;
      } else {
        _cart.add(CartItem(product: _selProduct!, variant: _selVariant!, qty: _qty));
      }
      _selProduct = null;
      _selVariant = null;
      _qty = 1;
    });
  }

  void _removeCartItem(int i) => setState(() => _cart.removeAt(i));

  void _changeCartQty(CartItem item, int delta) => setState(() {
    item.qty += delta;
    if (item.qty <= 0) _cart.remove(item);
  });

  void _confirmOrder() {
    if (_cart.isEmpty) return;

    // ── Build items payload matching addOnInventoryApi format ──────────────
    final items = _cart.map((c) => {
      "productid" : c.product.productId,
      "qty"  : c.qty,
    }).toList();

    // Pass to ViewModel — adjust signature in your ViewModel to accept items
    context.read<UrgentAddOnViewModel>().addOnInventoryApi(context, items: items);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Column(children: [
        _TopBar(cartCount: _cart.length, total: _grandTotal),
        Expanded(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ── LEFT ────────────────────────────────────────────────────────
            Expanded(flex: 55, child: _buildLeft()),
            Container(width: 1, color: kBorder),
            // ── RIGHT ───────────────────────────────────────────────────────
            Expanded(flex: 45, child: _buildRight()),
          ]),
        ),
      ]),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // LEFT  — 5-step selection
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildLeft() {
    return Consumer<UrgentAddOnViewModel>(
      builder: (context, vm, _) {
        return Column(children: [
          _panelHeader('🔍  Select Product', kNavy),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── STEP 1: Main Category ──────────────────────────────
                  _StepBlock(
                    step: 1, label: 'Main Category',
                    child: vm.urgentMainCategoryListModel == null
                        ? _loader()
                        : (vm.urgentMainCategoryListModel!.data?.isEmpty ?? true)
                        ? _emptyHint('No main categories found')
                        : _MainCategoryGrid(
                      items:    vm.urgentMainCategoryListModel!.data!,
                      selected: _selMain,
                      onTap:    _onMainCatTap,
                    ),
                  ),

                  // ── STEP 2: Category ───────────────────────────────────
                  if (_selMain != null) ...[
                    const _Connector(),
                    _StepBlock(
                      step: 2, label: 'Category',
                      hint: _selMain!.name?.toString(),
                      child: vm.categoryFromMainCategoryListModel == null
                          ? _loader()
                          : Builder(builder: (_) {
                        // Flatten all categories from response
                        final allCats = vm.categoryFromMainCategoryListModel!.data
                            ?.expand((d) => d.categories ?? <Categories>[])
                            .toList() ?? [];
                        return allCats.isEmpty
                            ? _emptyHint('No categories found')
                            : _ChipList<Categories>(
                          items:    allCats,
                          selected: _selCat,
                          label:    (c) => c.categoryName?.toString() ?? '',
                          onTap:    _onCatTap,
                        );
                      }),
                    ),
                  ],

                  // ── STEP 3: Sub Category ───────────────────────────────
                  if (_selCat != null) ...[
                    const _Connector(),
                    _StepBlock(
                      step: 3, label: 'Sub Category',
                      hint: _selCat!.categoryName?.toString(),
                      child: (_selCat!.subcategories?.isEmpty ?? true)
                          ? _emptyHint('No sub-categories found')
                          : _ChipList<Subcategories>(
                        items:    _selCat!.subcategories!,
                        selected: _selSub,
                        label:    (s) => s.subcatName?.toString() ?? '',
                        onTap:    _onSubTap,
                      ),
                    ),
                  ],

                  // ── STEP 4: Product ────────────────────────────────────
                  if (_selSub != null) ...[
                    const _Connector(),
                    _StepBlock(
                      step: 4, label: 'Product',
                      hint: _selSub!.subcatName?.toString(),
                      child: (_selSub!.products?.isEmpty ?? true)
                          ? _emptyHint('No products found')
                          : _ProductGrid(
                        items:    _selSub!.products!,
                        selected: _selProduct,
                        onTap:    _onProductTap,
                      ),
                    ),
                  ],

                  // ── STEP 5: Variant + Qty + Add ────────────────────────
                  if (_selProduct != null) ...[
                    const _Connector(),
                    _StepBlock(
                      step: 5, label: 'Variant & Qty',
                      hint: _selProduct!.productName?.toString(),
                      child: _VariantQtyPanel(
                        product:      _selProduct!,
                        selVariant:   _selVariant,
                        qty:          _qty,
                        onVariantTap: _onVariantTap,
                        onQtyChange:  _changeQty,
                        onAddToCart:  _selVariant != null ? _addToCart : null,
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ]);
      },
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // RIGHT — Cart
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildRight() {
    return Consumer<UrgentAddOnViewModel>(
      builder: (context, vm, _) => Column(children: [
        _panelHeader('🛒  Order Cart  (${_cart.length})', kAccent),
        Expanded(
          child: _cart.isEmpty
              ? _emptyCart()
              : ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: _cart.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _CartTile(
              item:        _cart[i],
              onRemove:    () => _removeCartItem(i),
              onQtyChange: (d) => _changeCartQty(_cart[i], d),
            ),
          ),
        ),
        // ── Summary footer ─────────────────────────────────────────────────
        Container(
          decoration: const BoxDecoration(
            color: kSurf,
            border: Border(top: BorderSide(color: kBorder)),
          ),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
          child: Column(children: [
            _summaryRow('Items',    '${_cart.length}'),
            _summaryRow('Subtotal', '₹${_subtotal.toStringAsFixed(0)}'),
            _summaryRow('Tax (5%)', '₹${_tax.toStringAsFixed(0)}'),
            const Divider(color: kBorder, height: 16),
            Row(children: [
              const Text('TOTAL', style: TextStyle(fontWeight: FontWeight.w900,
                  fontSize: 14, color: kNavy, letterSpacing: 0.5)),
              const Spacer(),
              Text('₹${_grandTotal.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.w900,
                      fontSize: 18, color: kNavy)),
            ]),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: vm.addLoading
                  ? const Center(child: CircularProgressIndicator(color: kNavy))
                  : ElevatedButton.icon(
                onPressed: _cart.isEmpty ? null : _confirmOrder,
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: const Text('Confirm Order',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _cart.isEmpty ? Colors.grey.shade300 : kAccent,
                  foregroundColor: _cart.isEmpty ? Colors.grey : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: _cart.isEmpty ? 0 : 3,
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  // ── Small helpers ──────────────────────────────────────────────────────────

  Widget _loader() => const Padding(
    padding: EdgeInsets.symmetric(vertical: 10),
    child: Center(child: SizedBox(
        width: 22, height: 22,
        child: CircularProgressIndicator(strokeWidth: 2, color: kNavy))),
  );

  Widget _emptyCart() => Center(child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: const [
      Text('🛒', style: TextStyle(fontSize: 48)),
      SizedBox(height: 12),
      Text('Cart is empty',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: kT1)),
      SizedBox(height: 4),
      Text('Select products from the left panel',
          style: TextStyle(color: kT2, fontSize: 12)),
    ],
  ));

  Widget _summaryRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(children: [
      Text(label, style: const TextStyle(fontSize: 12, color: kT2)),
      const Spacer(),
      Text(value, style: const TextStyle(
          fontSize: 12, fontWeight: FontWeight.w700, color: kT1)),
    ]),
  );
}

// ════════════════════════════════════════════════════════════════════════════════
// TOP BAR
// ════════════════════════════════════════════════════════════════════════════════

class _TopBar extends StatelessWidget {
  final int cartCount;
  final double total;
  const _TopBar({required this.cartCount, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [kNavy, kNavyL]),
        boxShadow: [BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(children: [
        const Icon(Icons.location_city, color: Colors.white, size: 22),
        const SizedBox(width: 10),
        const Text('City Panel',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800,
                fontSize: 17, letterSpacing: 0.4)),
        const Text('  ·  Urgent Add-On',
            style: TextStyle(color: Colors.white60, fontSize: 13)),
        const Spacer(),
        if (cartCount > 0) ...[
          const Icon(Icons.shopping_cart_outlined, color: Colors.white70, size: 18),
          const SizedBox(width: 5),
          Text('$cartCount item${cartCount > 1 ? 's' : ''}  •  ₹${total.toStringAsFixed(0)}',
              style: const TextStyle(color: Colors.white,
                  fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// STEP BLOCK
// ════════════════════════════════════════════════════════════════════════════════

class _StepBlock extends StatelessWidget {
  final int step;
  final String label;
  final String? hint;
  final Widget child;
  const _StepBlock({required this.step, required this.label,
    this.hint, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kSurf, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
        boxShadow: const [BoxShadow(
            color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: const BoxDecoration(
            color: Color(0xFFF7F9FC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            border: Border(bottom: BorderSide(color: kBorder)),
          ),
          child: Row(children: [
            Container(
              width: 22, height: 22, alignment: Alignment.center,
              decoration: const BoxDecoration(color: kNavy, shape: BoxShape.circle),
              child: Text('$step', style: const TextStyle(color: Colors.white,
                  fontSize: 11, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700,
                fontSize: 13, color: kT1)),
            if (hint != null) ...[
              const SizedBox(width: 6),
              Flexible(child: Text('· $hint', overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: kT2))),
            ],
          ]),
        ),
        Padding(padding: const EdgeInsets.all(12), child: child),
      ]),
    );
  }
}

class _Connector extends StatelessWidget {
  const _Connector();
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 22, top: 4, bottom: 4),
    child: Container(width: 2, height: 14, color: kBorder),
  );
}

// ════════════════════════════════════════════════════════════════════════════════
// MAIN CATEGORY GRID  (uses UrgentMainCategoryData)
// ════════════════════════════════════════════════════════════════════════════════

class _MainCategoryGrid extends StatelessWidget {
  final List<UrgentMainCategoryData> items;
  final UrgentMainCategoryData? selected;
  final ValueChanged<UrgentMainCategoryData> onTap;
  const _MainCategoryGrid({required this.items, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 3.0,
      children: items.map((mc) {
        final sel = selected?.id == mc.id;
        return GestureDetector(
          onTap: () => onTap(mc),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: sel ? kNavy : const Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: sel ? kNavy : kBorder),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              // Use Image.network if img is available, else icon
              if (mc.img != null && mc.img.toString().isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(mc.img.toString(),
                      width: 24, height: 24, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Icon(Icons.category, size: 20,
                              color: sel ? Colors.white : kNavy)),
                )
              else
                Icon(Icons.category, size: 20,
                    color: sel ? Colors.white : kNavy),
              const SizedBox(width: 7),
              Flexible(child: Text(mc.name?.toString() ?? '',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12,
                      color: sel ? Colors.white : kT1))),
            ]),
          ),
        );
      }).toList(),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// GENERIC CHIP LIST
// ════════════════════════════════════════════════════════════════════════════════

class _ChipList<T> extends StatelessWidget {
  final List<T> items;
  final T? selected;
  final String Function(T) label;
  final ValueChanged<T> onTap;
  const _ChipList({required this.items, required this.selected,
    required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 6, runSpacing: 6,
      children: items.map((item) {
        final sel = selected == item;
        return GestureDetector(
          onTap: () => onTap(item),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: sel ? kAccent : const Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: sel ? kAccent : kBorder),
            ),
            child: Text(label(item), style: TextStyle(fontSize: 12,
                fontWeight: FontWeight.w600,
                color: sel ? Colors.white : kT2)),
          ),
        );
      }).toList(),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// PRODUCT GRID  (uses Products model)
// ════════════════════════════════════════════════════════════════════════════════

class _ProductGrid extends StatelessWidget {
  final List<Products> items;
  final Products? selected;
  final ValueChanged<Products> onTap;
  const _ProductGrid({required this.items, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2, shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 2.6,
      children: items.map((p) {
        final sel = selected?.productId == p.productId;
        return GestureDetector(
          onTap: () => onTap(p),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: sel ? kNavy.withOpacity(0.07) : const Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: sel ? kNavy : kBorder,
                  width: sel ? 1.5 : 1),
            ),
            child: Row(children: [
              // product image
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: (p.productImg != null && p.productImg.toString().isNotEmpty)
                    ? Image.network(p.productImg.toString(),
                    width: 34, height: 34, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _productPlaceholder(sel))
                    : _productPlaceholder(sel),
              ),
              const SizedBox(width: 8),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(p.productName?.toString() ?? '',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12,
                          color: sel ? kNavy : kT1)),
                  if (p.brandName != null)
                    Text(p.brandName.toString(),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10, color: kT2)),
                  Text('${p.variants?.length ?? 0} variant${(p.variants?.length ?? 0) != 1 ? 's' : ''}',
                      style: const TextStyle(fontSize: 10, color: kT2)),
                ],
              )),
              if (sel)
                const Icon(Icons.check_circle_rounded, color: kNavy, size: 16),
            ]),
          ),
        );
      }).toList(),
    );
  }

  Widget _productPlaceholder(bool sel) => Container(
    width: 34, height: 34,
    decoration: BoxDecoration(
      color: sel ? kNavy.withOpacity(0.15) : kBg,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Icon(Icons.inventory_2_outlined, size: 18,
        color: sel ? kNavy : kT2),
  );
}

// ════════════════════════════════════════════════════════════════════════════════
// VARIANT + QTY PANEL  (uses Variants model)
// ════════════════════════════════════════════════════════════════════════════════

class _VariantQtyPanel extends StatelessWidget {
  final Products       product;
  final Variants?      selVariant;
  final int            qty;
  final ValueChanged<Variants> onVariantTap;
  final ValueChanged<int>      onQtyChange;
  final VoidCallback?          onAddToCart;

  const _VariantQtyPanel({
    required this.product,    required this.selVariant,
    required this.qty,        required this.onVariantTap,
    required this.onQtyChange, required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final variants = product.variants ?? [];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      // ── Variant chips ──────────────────────────────────────────────────────
      const Text('Variant', style: TextStyle(fontSize: 11,
          fontWeight: FontWeight.w700, color: kT2, letterSpacing: 0.5)),
      const SizedBox(height: 8),

      variants.isEmpty
          ? const Text('No variants available',
          style: TextStyle(color: kT2, fontSize: 12))
          : Wrap(spacing: 7, runSpacing: 7,
        children: variants.map((v) {
          final sel = selVariant?.variantId == v.variantId;
          final price = double.tryParse(v.price?.toString() ?? '') ?? 0.0;
          final dPrice = double.tryParse(v.discountPrice?.toString() ?? '');
          return GestureDetector(
            onTap: () => onVariantTap(v),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
              decoration: BoxDecoration(
                color: sel ? kAccent : const Color(0xFFF7F9FC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: sel ? kAccent : kBorder),
                boxShadow: sel
                    ? [BoxShadow(color: kAccent.withOpacity(0.3),
                    blurRadius: 6, offset: const Offset(0, 2))]
                    : [],
              ),
              child: Column(children: [
                Text(v.variantValue?.toString() ?? '',
                    style: TextStyle(fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: sel ? Colors.white : kT1)),
                const SizedBox(height: 2),
                // discount price + strikethrough original
                if (dPrice != null && dPrice < price)
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('₹${dPrice.toStringAsFixed(0)}',
                        style: TextStyle(fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: sel ? Colors.white : kNavy)),
                    const SizedBox(width: 4),
                    Text('₹${price.toStringAsFixed(0)}',
                        style: TextStyle(fontSize: 10,
                            color: sel ? Colors.white54 : kT2,
                            decoration: TextDecoration.lineThrough)),
                  ])
                else
                  Text('₹${price.toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: sel ? Colors.white70 : kNavy)),
                // current stock badge
                if (v.currentStock != null) ...[
                  const SizedBox(height: 2),
                  Text('Stock: ${v.currentStock}',
                      style: TextStyle(fontSize: 9,
                          color: sel ? Colors.white60 : kT2)),
                ],
              ]),
            ),
          );
        }).toList(),
      ),

      if (selVariant != null) ...[
        const SizedBox(height: 14),
        const Divider(color: kBorder, height: 1),
        const SizedBox(height: 12),

        // ── Qty row ──────────────────────────────────────────────────────────
        Row(children: [
          const Text('Qty', style: TextStyle(fontSize: 11,
              fontWeight: FontWeight.w700, color: kT2, letterSpacing: 0.5)),
          const SizedBox(width: 12),
          _QtyControl(qty: qty, onChanged: onQtyChange),
          const Spacer(),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            const Text('Subtotal', style: TextStyle(fontSize: 10, color: kT2)),
            Text(
              '₹${((double.tryParse(selVariant!.discountPrice?.toString() ?? '') ??
                  double.tryParse(selVariant!.price?.toString() ?? '') ??
                  0.0) * qty).toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.w900,
                  fontSize: 16, color: kNavy),
            ),
          ]),
        ]),

        const SizedBox(height: 14),

        // ── SKU row ──────────────────────────────────────────────────────────
        if (selVariant!.sku != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text('SKU: ${selVariant!.sku}',
                style: const TextStyle(fontSize: 11, color: kT2)),
          ),

        // ── Add to Cart button ────────────────────────────────────────────────
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onAddToCart,
            icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
            label: const Text('Add to Cart',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
            style: ElevatedButton.styleFrom(
              backgroundColor: kNavy, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 2,
            ),
          ),
        ),
      ],
    ]);
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// QTY CONTROL
// ════════════════════════════════════════════════════════════════════════════════

class _QtyControl extends StatelessWidget {
  final int qty;
  final ValueChanged<int> onChanged;
  const _QtyControl({required this.qty, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: kBorder),
          borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _btn(Icons.remove, () => onChanged(-1)),
        Container(width: 38, height: 36, alignment: Alignment.center,
            color: kBg,
            child: Text('$qty', style: const TextStyle(
                fontWeight: FontWeight.w800, fontSize: 15, color: kNavy))),
        _btn(Icons.add, () => onChanged(1)),
      ]),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: SizedBox(width: 34, height: 36, child: Icon(icon, size: 16, color: kNavy)),
  );
}

// ════════════════════════════════════════════════════════════════════════════════
// CART TILE
// ════════════════════════════════════════════════════════════════════════════════

class _CartTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove;
  final ValueChanged<int> onQtyChange;
  const _CartTile({required this.item, required this.onRemove, required this.onQtyChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: kSurf, borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kBorder),
        boxShadow: const [BoxShadow(
            color: Color(0x06000000), blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── product image ────────────────────────────────────────────────────
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: (item.product.productImg != null &&
              item.product.productImg.toString().isNotEmpty)
              ? Image.network(item.product.productImg.toString(),
              width: 44, height: 44, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _imgFallback())
              : _imgFallback(),
        ),
        const SizedBox(width: 10),

        // ── details ──────────────────────────────────────────────────────────
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.product.productName?.toString() ?? '',
              style: const TextStyle(fontWeight: FontWeight.w700,
                  fontSize: 13, color: kT1)),
          const SizedBox(height: 3),
          Row(children: [
            _badge(item.variant.variantValue?.toString() ?? '', kAccent),
            const SizedBox(width: 6),
            if (item.product.brandName != null)
              _badge(item.product.brandName.toString(), kNavy),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            _SmallQty(qty: item.qty, onChanged: onQtyChange),
            const Spacer(),
            Text('₹${item.total.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.w800,
                    fontSize: 14, color: kNavy)),
          ]),
        ])),

        // ── remove ──────────────────────────────────────────────────────────
        GestureDetector(
          onTap: onRemove,
          child: Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Icon(Icons.close_rounded, size: 16, color: Colors.red.shade300),
          ),
        ),
      ]),
    );
  }

  Widget _imgFallback() => Container(
    width: 44, height: 44,
    decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(8)),
    child: const Icon(Icons.inventory_2_outlined, size: 22, color: kT2),
  );

  Widget _badge(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
        color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
    child: Text(label, style: TextStyle(fontSize: 10,
        color: color, fontWeight: FontWeight.w700)),
  );
}

// ════════════════════════════════════════════════════════════════════════════════
// SMALL QTY IN CART
// ════════════════════════════════════════════════════════════════════════════════

class _SmallQty extends StatelessWidget {
  final int qty;
  final ValueChanged<int> onChanged;
  const _SmallQty({required this.qty, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      decoration: BoxDecoration(border: Border.all(color: kBorder),
          borderRadius: BorderRadius.circular(6)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _btn(Icons.remove, () => onChanged(-1), Colors.red.shade300),
        Container(width: 30, height: 26, alignment: Alignment.center,
            color: kBg,
            child: Text('$qty', style: const TextStyle(
                fontWeight: FontWeight.w800, fontSize: 13, color: kNavy))),
        _btn(Icons.add, () => onChanged(1), Colors.green.shade600),
      ]),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap, Color color) =>
      GestureDetector(
        onTap: onTap,
        child: SizedBox(width: 28, height: 26,
            child: Icon(icon, size: 14, color: color)),
      );
}

// ════════════════════════════════════════════════════════════════════════════════
// SHARED HELPERS
// ════════════════════════════════════════════════════════════════════════════════

Widget _panelHeader(String title, Color color) => Container(
  width: double.infinity,
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  color: color.withOpacity(0.06),
  child: Text(title, style: TextStyle(color: color,
      fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.3)),
);

Widget _emptyHint(String msg) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 6),
  child: Text(msg, style: const TextStyle(color: kT2, fontSize: 12)),
);