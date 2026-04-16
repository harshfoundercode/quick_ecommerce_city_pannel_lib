import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/AddOnDir/UrgentAddOnModelDir/category_from_maincat_model_urgent.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/AddOnDir/UrgentAddOnModelDir/main_category_list_model_urgent.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/AddOnDir/UrgentAddOnViewModel/urgent_add_on_view_model.dart';


class UrgentAddOnScreen extends StatefulWidget {
  const UrgentAddOnScreen({super.key});

  @override
  State<UrgentAddOnScreen> createState() => _UrgentAddOnScreenState();
}

class _UrgentAddOnScreenState extends State<UrgentAddOnScreen> {
  // ── Left-panel selections ──────────────────────────────────────────────────
  UrgentMainCategoryData? _selMain;
  Categories? _selCat;
  Subcategories? _selSub;
  Products? _selProduct;
  Variants? _selVariant;
  int _qty = 1;

  // ── Cart ───────────────────────────────────────────────────────────────────
  final List<CartItem> _cart = [];

  // ── Init ───────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UrgentAddOnViewModel>().getMainCategoryDataApi(context);
    });
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  void _onMainCatTap(UrgentMainCategoryData mc) {
    setState(() {
      _selMain = mc;
      _selCat = null;
      _selSub = null;
      _selProduct = null;
      _selVariant = null;
    });
    // Fetch categories+subcategories+products for selected main category
    context.read<UrgentAddOnViewModel>().getCategoryFromMainCatIdApi(
      context,
      mainCatId: mc.id.toString(),
    );
  }

  void _onCatTap(Categories cat) => setState(() {
    _selCat = cat;
    _selSub = null;
    _selProduct = null;
    _selVariant = null;
  });

  void _onSubTap(Subcategories sub) => setState(() {
    _selSub = sub;
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
      final match = _cart.where(
        (c) =>
            c.product.productId == _selProduct!.productId &&
            c.variant.variantId == _selVariant!.variantId,
      );
      if (match.isNotEmpty) {
        match.first.qty += _qty;
      } else {
        _cart.add(
          CartItem(product: _selProduct!, variant: _selVariant!, qty: _qty),
        );
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
    final items = _cart
        .map((c) => {"productid": c.product.productId, "qty": c.qty})
        .toList();

    // Pass to ViewModel — adjust signature in your ViewModel to accept items
    context.read<UrgentAddOnViewModel>().addOnInventoryApi(
      context,
      items: items,
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.bgColor,
      body: Column(
        children: [
          _TopBar(cartCount: _cart.length),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── LEFT ────────────────────────────────────────────────────────
                Expanded(flex: 55, child: _buildLeft()),
                Container(width: 1, color: ColorConst.borderColor),
                // ── RIGHT ───────────────────────────────────────────────────────
                Expanded(flex: 45, child: _buildRight()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // LEFT  — 5-step selection
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildLeft() {
    return Consumer<UrgentAddOnViewModel>(
      builder: (context, vm, _) {
        return Column(
          children: [
            _panelHeader('🔍  Select Product', ColorConst.primaryGreen),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── STEP 1: Main Category ──────────────────────────────
                    _StepBlock(
                      step: 1,
                      label: 'Main Category',
                      child: vm.urgentMainCategoryListModel == null
                          ? _loader()
                          : (vm.urgentMainCategoryListModel!.data?.isEmpty ??
                                true)
                          ? _emptyHint('No main categories found')
                          : _MainCategoryGrid(
                              items: vm.urgentMainCategoryListModel!.data!,
                              selected: _selMain,
                              onTap: _onMainCatTap,
                            ),
                    ),

                    // ── STEP 2: Category ───────────────────────────────────
                    if (_selMain != null) ...[
                      const _Connector(),
                      _StepBlock(
                        step: 2,
                        label: 'Category',
                        hint: _selMain!.name?.toString(),
                        child: vm.categoryFromMainCategoryListModel == null
                            ? _loader()
                            : Builder(
                                builder: (_) {
                                  // Flatten all categories from response
                                  final allCats =
                                      vm.categoryFromMainCategoryListModel!.data
                                          ?.expand(
                                            (d) =>
                                                d.categories ?? <Categories>[],
                                          )
                                          .toList() ??
                                      [];
                                  return allCats.isEmpty
                                      ? _emptyHint('No categories found')
                                      : _ChipList<Categories>(
                                          items: allCats,
                                          selected: _selCat,
                                          label: (c) =>
                                              c.categoryName?.toString() ?? '',
                                          onTap: _onCatTap,
                                        );
                                },
                              ),
                      ),
                    ],

                    // ── STEP 3: Sub Category ───────────────────────────────
                    if (_selCat != null) ...[
                      const _Connector(),
                      _StepBlock(
                        step: 3,
                        label: 'Sub Category',
                        hint: _selCat!.categoryName?.toString(),
                        child: (_selCat!.subcategories?.isEmpty ?? true)
                            ? _emptyHint('No sub-categories found')
                            : _ChipList<Subcategories>(
                                items: _selCat!.subcategories!,
                                selected: _selSub,
                                label: (s) => s.subcatName?.toString() ?? '',
                                onTap: _onSubTap,
                              ),
                      ),
                    ],

                    // ── STEP 4: Product ────────────────────────────────────
                    if (_selSub != null) ...[
                      const _Connector(),
                      _StepBlock(
                        step: 4,
                        label: 'Product',
                        hint: _selSub!.subcatName?.toString(),
                        child: (_selSub!.products?.isEmpty ?? true)
                            ? _emptyHint('No products found')
                            : _ProductGrid(
                                items: _selSub!.products!,
                                selected: _selProduct,
                                onTap: _onProductTap,
                              ),
                      ),
                    ],

                    // ── STEP 5: Variant + Qty + Add ────────────────────────
                    if (_selProduct != null) ...[
                      const _Connector(),
                      _StepBlock(
                        step: 5,
                        label: 'Variant & Qty',
                        hint: _selProduct!.productName?.toString(),
                        child: _VariantQtyPanel(
                          product: _selProduct!,
                          selVariant: _selVariant,
                          qty: _qty,
                          onVariantTap: _onVariantTap,
                          onQtyChange: _changeQty,
                          onAddToCart: _selVariant != null ? _addToCart : null,
                        ),
                      ),
                    ],

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // RIGHT — Cart
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildRight() {
    return Consumer<UrgentAddOnViewModel>(
      builder: (context, vm, _) => Column(
        children: [
          _panelHeader('🛒  Request Cart  (${_cart.length})', ColorConst.honey),
          Expanded(
            child: _cart.isEmpty
                ? _emptyCart()
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _cart.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _CartTile(
                      item: _cart[i],
                      onRemove: () => _removeCartItem(i),
                      onQtyChange: (d) => _changeCartQty(_cart[i], d),
                    ),
                  ),
          ),
          // ── Summary footer ─────────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              color: ColorConst.white,
              border: Border(top: BorderSide(color: ColorConst.borderColor)),
            ),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
            child: Column(
              children: [
                _summaryRow('Items', '${_cart.length}'),
                // _summaryRow('Subtotal', '₹${_subtotal.toStringAsFixed(0)}'),
                // _summaryRow('Tax (5%)', '₹${_tax.toStringAsFixed(0)}'),
                const Divider(color: ColorConst.borderColor, height: 16),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: vm.addLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: ColorConst.primaryGreen),
                        )
                      : ElevatedButton.icon(
                          onPressed: _cart.isEmpty ? null : _confirmOrder,
                          icon: const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 18,
                          ),
                          label: const Text(
                            'Confirm Order',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _cart.isEmpty
                                ? Colors.grey.shade300
                                : ColorConst.honey,
                            foregroundColor: _cart.isEmpty
                                ? Colors.grey
                                : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: _cart.isEmpty ? 0 : 3,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Small helpers ──────────────────────────────────────────────────────────

  Widget _loader() => const Padding(
    padding: EdgeInsets.symmetric(vertical: 10),
    child: Center(
      child: SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2, color: ColorConst.primaryGreen),
      ),
    ),
  );

  Widget _emptyCart() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Text('🛒', style: TextStyle(fontSize: 48)),
        SizedBox(height: 12),
        Text(
          'Cart is empty',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: ColorConst.textDark,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Select products from the left panel',
          style: TextStyle(color: ColorConst.textGrey, fontSize: 12),
        ),
      ],
    ),
  );

  Widget _summaryRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: ColorConst.textGrey)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: ColorConst.textDark,
          ),
        ),
      ],
    ),
  );
}

class _TopBar extends StatelessWidget {
  final int cartCount;
  const _TopBar({required this.cartCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: ColorConst.primaryGreen,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
           Text(
            'Urgent Add-On',
            style: TextStyle(color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 17,
              letterSpacing: 0.4,),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _StepBlock extends StatelessWidget {
  final int step;
  final String label;
  final String? hint;
  final Widget child;
  const _StepBlock({
    required this.step,
    required this.label,
    this.hint,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorConst.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorConst.borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: const BoxDecoration(
              color: Color(0xFFF7F9FC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(bottom: BorderSide(color: ColorConst.borderColor)),
            ),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: ColorConst.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$step',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: ColorConst.textDark,
                  ),
                ),
                if (hint != null) ...[
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      '· $hint',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: ColorConst.textGrey),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(12), child: child),
        ],
      ),
    );
  }
}

class _Connector extends StatelessWidget {
  const _Connector();
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 22, top: 4, bottom: 4),
    child: Container(width: 2, height: 14, color: ColorConst.borderColor),
  );
}

class _MainCategoryGrid extends StatelessWidget {
  final List<UrgentMainCategoryData> items;
  final UrgentMainCategoryData? selected;
  final ValueChanged<UrgentMainCategoryData> onTap;
  const _MainCategoryGrid({
    required this.items,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 3.4,
      children: items.map((mc) {
        final sel = selected?.id == mc.id;
        return GestureDetector(
          onTap: () => onTap(mc),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: sel ? ColorConst.primaryExtraLightGreen : const Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: sel ? ColorConst.primaryGreen : ColorConst.borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Use Image.network if img is available, else icon
                if (mc.img != null && mc.img.toString().isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      mc.img.toString(),
                      width: 24,
                      height: 24,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.category,
                        size: 20,
                        color: sel ? Colors.white : ColorConst.primaryGreen,
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.category,
                    size: 20,
                    color: sel ? Colors.white : ColorConst.primaryGreen,
                  ),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    mc.name?.toString() ?? '',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: sel ? ColorConst.primaryGreen : ColorConst.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ChipList<T> extends StatelessWidget {
  final List<T> items;
  final T? selected;
  final String Function(T) label;
  final ValueChanged<T> onTap;
  const _ChipList({
    required this.items,
    required this.selected,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: items.map((item) {
        final sel = selected == item;
        return GestureDetector(
          onTap: () => onTap(item),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: sel ? ColorConst.honey : const Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: sel ? ColorConst.honey : ColorConst.borderColor),
            ),
            child: Text(
              label(item),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: sel ? Colors.white : ColorConst.textGrey,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  final List<Products> items;
  final Products? selected;
  final ValueChanged<Products> onTap;
  const _ProductGrid({
    required this.items,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 2.6,
      children: items.map((p) {
        final sel = selected?.productId == p.productId;
        return GestureDetector(
          onTap: () => onTap(p),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: sel ? ColorConst.primaryGreen.withOpacity(0.07) : const Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: sel ? ColorConst.primaryGreen : ColorConst.borderColor,
                width: sel ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                // product image
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child:
                      (p.productImg != null &&
                          p.productImg.toString().isNotEmpty)
                      ? Image.network(
                          p.productImg.toString(),
                          width: 34,
                          height: 34,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _productPlaceholder(sel),
                        )
                      : _productPlaceholder(sel),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        p.productName?.toString() ?? '',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: sel ? ColorConst.primaryGreen : ColorConst.textDark,
                        ),
                      ),
                      if (p.brandName != null)
                        Text(
                          p.brandName.toString(),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 10, color: ColorConst.textGrey),
                        ),
                      Text(
                        '${p.variants?.length ?? 0} variant${(p.variants?.length ?? 0) != 1 ? 's' : ''}',
                        style: const TextStyle(fontSize: 10, color: ColorConst.textGrey),
                      ),
                    ],
                  ),
                ),
                if (sel)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: ColorConst.primaryGreen,
                    size: 16,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _productPlaceholder(bool sel) => Container(
    width: 34,
    height: 34,
    decoration: BoxDecoration(
      color: sel ? ColorConst.primaryGreen.withOpacity(0.15) : ColorConst.bgColor,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Icon(Icons.inventory_2_outlined, size: 18, color: sel ? ColorConst.primaryGreen : ColorConst.textGrey),
  );
}

class _VariantQtyPanel extends StatelessWidget {
  final Products product;
  final Variants? selVariant;
  final int qty;
  final ValueChanged<Variants> onVariantTap;
  final ValueChanged<int> onQtyChange;
  final VoidCallback? onAddToCart;

  const _VariantQtyPanel({
    required this.product,
    required this.selVariant,
    required this.qty,
    required this.onVariantTap,
    required this.onQtyChange,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final variants = product.variants ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Variant chips ──────────────────────────────────────────────────────
        const Text(
          'Variant',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: ColorConst.textGrey,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),

        variants.isEmpty
            ? const Text(
                'No variants available',
                style: TextStyle(color: ColorConst.textGrey, fontSize: 12),
              )
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: variants.map((v) {
                  final sel = selVariant?.variantId == v.variantId;
                  final price =
                      double.tryParse(v.price?.toString() ?? '') ?? 0.0;
                  final dPrice = double.tryParse(
                    v.discountPrice?.toString() ?? '',
                  );
                  return GestureDetector(
                    onTap: () => onVariantTap(v),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: sel ? ColorConst.honey : const Color(0xFFF7F9FC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: sel ? ColorConst.honey : ColorConst.borderColor),
                        boxShadow: sel
                            ? [
                                BoxShadow(
                                  color: ColorConst.honey.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Column(
                        children: [
                          Text(
                            v.variantValue?.toString() ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: sel ? Colors.white : ColorConst.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          // discount price + strikethrough original
                          if (dPrice != null && dPrice < price)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '₹${dPrice.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: sel ? Colors.white : ColorConst.primaryGreen,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '₹${price.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: sel ? Colors.white54 : ColorConst.textGrey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            )
                          else
                            Text(
                              '₹${price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: sel ? Colors.white70 : ColorConst.primaryGreen,
                              ),
                            ),
                          // current stock badge
                          // if (v.currentStock != null) ...[
                          //   const SizedBox(height: 2),
                          //   Text(
                          //     'Stock: ${v.currentStock}',
                          //     style: TextStyle(
                          //       fontSize: 9,
                          //       color: sel ? Colors.white60 : ColorConst.textGrey,
                          //     ),
                          //   ),
                          // ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

        if (selVariant != null) ...[
          const SizedBox(height: 14),
          const Divider(color: ColorConst.borderColor, height: 1),
          const SizedBox(height: 12),

          // ── Qty row ──────────────────────────────────────────────────────────
          Row(
            children: [
              const Text(
                'Qty',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: ColorConst.textGrey,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 12),
              _QtyControl(qty: qty, onChanged: onQtyChange),
              // const Spacer(),
              // Column(
              //   crossAxisAlignment: CrossAxisAlignment.end,
              //   children: [
              //     const Text(
              //       'Subtotal',
              //       style: TextStyle(fontSize: 10, color: ColorConst.textGrey),
              //     ),
              //     Text(
              //       '₹${((double.tryParse(selVariant!.discountPrice?.toString() ?? '') ?? double.tryParse(selVariant!.price?.toString() ?? '') ?? 0.0) * qty).toStringAsFixed(0)}',
              //       style: const TextStyle(
              //         fontWeight: FontWeight.w900,
              //         fontSize: 16,
              //         color: ColorConst.primaryGreen,
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),

          const SizedBox(height: 14),
          //
          // // ── SKU row ──────────────────────────────────────────────────────────
          // if (selVariant!.sku != null)
          //   Padding(
          //     padding: const EdgeInsets.only(bottom: 10),
          //     child: Text(
          //       'SKU: ${selVariant!.sku}',
          //       style: const TextStyle(fontSize: 11, color: ColorConst.textGrey),
          //     ),
          //   ),

          // ── Add to Cart button ────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAddToCart,
              icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
              label: const Text(
                'Add to Cart',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorConst.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _QtyControl extends StatelessWidget {
  final int qty;
  final ValueChanged<int> onChanged;
  const _QtyControl({required this.qty, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: ColorConst.borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn(Icons.remove, () => onChanged(-1)),
          Container(
            width: 38,
            height: 36,
            alignment: Alignment.center,
            color: ColorConst.bgColor,
            child: Text(
              '$qty',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: ColorConst.primaryGreen,
              ),
            ),
          ),
          _btn(Icons.add, () => onChanged(1)),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: SizedBox(
      width: 34,
      height: 36,
      child: Icon(icon, size: 16, color: ColorConst.primaryGreen),
    ),
  );
}

class _CartTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove;
  final ValueChanged<int> onQtyChange;
  const _CartTile({
    required this.item,
    required this.onRemove,
    required this.onQtyChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: ColorConst.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ColorConst.borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── product image ────────────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child:
                (item.product.productImg != null &&
                    item.product.productImg.toString().isNotEmpty)
                ? Image.network(
                    item.product.productImg.toString(),
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imgFallback(),
                  )
                : _imgFallback(),
          ),
          const SizedBox(width: 10),

          // ── details ──────────────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.productName?.toString() ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: ColorConst.textDark,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    _badge(
                      item.variant.variantValue?.toString() ?? '',
                      ColorConst.honey,
                    ),
                    const SizedBox(width: 6),
                    if (item.product.brandName != null)
                      _badge(item.product.brandName.toString(), ColorConst.primaryGreen),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _SmallQty(qty: item.qty, onChanged: onQtyChange),
                    const Spacer(),
                    // Text(
                    //   '₹${item.total.toStringAsFixed(0)}',
                    //   style: const TextStyle(
                    //     fontWeight: FontWeight.w800,
                    //     fontSize: 14,
                    //     color: ColorConst.primaryGreen,
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          ),

          // ── remove ──────────────────────────────────────────────────────────
          GestureDetector(
            onTap: onRemove,
            child: Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Icon(
                Icons.close_rounded,
                size: 16,
                color: Colors.red.shade300,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imgFallback() => Container(
    width: 44,
    height: 44,
    decoration: BoxDecoration(
      color: ColorConst.bgColor,
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Icon(Icons.inventory_2_outlined, size: 22, color: ColorConst.textGrey),
  );

  Widget _badge(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700),
    ),
  );
}

class _SmallQty extends StatelessWidget {
  final int qty;
  final ValueChanged<int> onChanged;
  const _SmallQty({required this.qty, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      decoration: BoxDecoration(
        border: Border.all(color: ColorConst.borderColor),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn(Icons.remove, () => onChanged(-1), Colors.red.shade300),
          Container(
            width: 30,
            height: 26,
            alignment: Alignment.center,
            color: ColorConst.bgColor,
            child: Text(
              '$qty',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: ColorConst.primaryGreen,
              ),
            ),
          ),
          _btn(Icons.add, () => onChanged(1), Colors.green.shade600),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap, Color color) =>
      GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 28,
          height: 26,
          child: Icon(icon, size: 14, color: color),
        ),
      );
}


Widget _panelHeader(String title, Color color) => Container(
  width: double.infinity,
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  color: color.withOpacity(0.06),
  child: Text(
    title,
    style: TextStyle(
      color: color,
      fontWeight: FontWeight.w800,
      fontSize: 13,
      letterSpacing: 0.3,
    ),
  ),
);

Widget _emptyHint(String msg) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 6),
  child: Text(msg, style: const TextStyle(color: ColorConst.textGrey, fontSize: 12)),
);

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
