import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';


// ─── Data Models ────────────────────────────────────────────────────────────

class MainCategory {
  final String id, name, icon;
  const MainCategory(this.id, this.name, this.icon);
}

class Category {
  final String id, name, mainCategoryId;
  const Category(this.id, this.name, this.mainCategoryId);
}

class SubCategory {
  final String id, name, categoryId;
  const SubCategory(this.id, this.name, this.categoryId);
}

class ProductVariant {
  final String id, label, unit;
  final double price;
  const ProductVariant(this.id, this.label, this.unit, this.price);
}

class Product {
  final String id, name, subCategoryId, imageEmoji;
  final List<ProductVariant> variants;
  const Product(this.id, this.name, this.subCategoryId, this.imageEmoji, this.variants);
}

class CartItem {
  final Product product;
  final ProductVariant variant;
  int qty;
  CartItem({required this.product, required this.variant, this.qty = 1});
}

// ─── Static Data ─────────────────────────────────────────────────────────────

const mainCategories = [
  MainCategory('mc1', 'Grocery', '🛒'),
  MainCategory('mc2', 'Electronics', '⚡'),
  MainCategory('mc3', 'Fashion', '👗'),
  MainCategory('mc4', 'Home & Living', '🏠'),
];

const categories = [
  Category('c1', 'Fruits & Vegs', 'mc1'),
  Category('c2', 'Dairy & Eggs', 'mc1'),
  Category('c3', 'Beverages', 'mc1'),
  Category('c4', 'Mobiles', 'mc2'),
  Category('c5', 'Laptops', 'mc2'),
  Category('c6', 'Men\'s Wear', 'mc3'),
  Category('c7', 'Women\'s Wear', 'mc3'),
  Category('c8', 'Furniture', 'mc4'),
  Category('c9', 'Kitchen', 'mc4'),
];

const subCategories = [
  SubCategory('sc1', 'Fresh Fruits', 'c1'),
  SubCategory('sc2', 'Fresh Vegetables', 'c1'),
  SubCategory('sc3', 'Exotic Produce', 'c1'),
  SubCategory('sc4', 'Milk & Curd', 'c2'),
  SubCategory('sc5', 'Cheese & Butter', 'c2'),
  SubCategory('sc6', 'Juices', 'c3'),
  SubCategory('sc7', 'Soft Drinks', 'c3'),
  SubCategory('sc8', 'Android Phones', 'c4'),
  SubCategory('sc9', 'iPhones', 'c4'),
  SubCategory('sc10', 'Gaming Laptops', 'c5'),
  SubCategory('sc11', 'Shirts', 'c6'),
  SubCategory('sc12', 'Ethnic Wear', 'c7'),
  SubCategory('sc13', 'Sofas', 'c8'),
  SubCategory('sc14', 'Cookware', 'c9'),
];

final products = [
  Product('p1', 'Banana', 'sc1', '🍌', [
    const ProductVariant('v1', '250g', 'g', 18),
    const ProductVariant('v2', '500g', 'g', 35),
    const ProductVariant('v3', '1 kg', 'kg', 65),
  ]),
  Product('p2', 'Apple', 'sc1', '🍎', [
    const ProductVariant('v4', '500g', 'g', 80),
    const ProductVariant('v5', '1 kg', 'kg', 150),
  ]),
  Product('p3', 'Mango', 'sc1', '🥭', [
    const ProductVariant('v6', '1 kg', 'kg', 120),
    const ProductVariant('v7', '2 kg', 'kg', 230),
  ]),
  Product('p4', 'Tomato', 'sc2', '🍅', [
    const ProductVariant('v8', '500g', 'g', 25),
    const ProductVariant('v9', '1 kg', 'kg', 45),
  ]),
  Product('p5', 'Spinach', 'sc2', '🥬', [
    const ProductVariant('v10', '200g', 'g', 20),
    const ProductVariant('v11', '500g', 'g', 45),
  ]),
  Product('p6', 'Full Cream Milk', 'sc4', '🥛', [
    const ProductVariant('v12', '500ml', 'ml', 30),
    const ProductVariant('v13', '1 L', 'L', 58),
    const ProductVariant('v14', '2 L', 'L', 110),
  ]),
  Product('p7', 'Curd', 'sc4', '🫙', [
    const ProductVariant('v15', '200g', 'g', 22),
    const ProductVariant('v16', '400g', 'g', 42),
  ]),
  Product('p8', 'Orange Juice', 'sc6', '🍊', [
    const ProductVariant('v17', '1 L', 'L', 90),
    const ProductVariant('v18', '2 L', 'L', 170),
  ]),
];

// ─── Main Screen ─────────────────────────────────────────────────────────────

class ProductAddOnScreen extends StatefulWidget {
  const ProductAddOnScreen({super.key});

  @override
  State<ProductAddOnScreen> createState() => _ProductAddOnScreenState();
}

class _ProductAddOnScreenState extends State<ProductAddOnScreen>
    with TickerProviderStateMixin {
  // Selections
  MainCategory? _selMain;
  Category? _selCat;
  SubCategory? _selSub;
  Product? _selProduct;
  ProductVariant? _selVariant;
  int _qty = 1;

  // Cart
  final List<CartItem> _cart = [];

  // UI
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Category> get _filteredCats =>
      categories.where((c) => c.mainCategoryId == _selMain?.id).toList();

  List<SubCategory> get _filteredSubs =>
      subCategories.where((s) => s.categoryId == _selCat?.id).toList();

  List<Product> get _filteredProducts =>
      products.where((p) => p.subCategoryId == _selSub?.id).toList();

  double get _cartTotal => _cart.fold(
      0, (sum, item) => sum + item.variant.price * item.qty);

  void _addToCart() {
    if (_selProduct == null || _selVariant == null) return;
    final existing = _cart.where((c) =>
    c.product.id == _selProduct!.id &&
        c.variant.id == _selVariant!.id).toList();
    setState(() {
      if (existing.isNotEmpty) {
        existing.first.qty += _qty;
      } else {
        _cart.add(CartItem(product: _selProduct!, variant: _selVariant!, qty: _qty));
      }
      // Reset product selection
      _selProduct = null;
      _selVariant = null;
      _qty = 1;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Added to cart ✓'),
        backgroundColor: const Color(0xFF1A237E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.bgColor,
      body: Column(
        children: [
          _buildTopBar(),
          _buildStepTabs(),
          Expanded(
            child: _tabController.index == 0
                ? _buildSelectionPanel()
                : _buildCartPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      decoration: const BoxDecoration(
        color: ColorConst.primaryGreen
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.location_city, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('City Panel',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3)),
                    Text('Product Add-On Manager',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _tabController.index = 1;
                  });
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha:0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.shopping_cart_outlined,
                          color: Colors.white, size: 22),
                    ),
                    if (_cart.isNotEmpty)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF6B35),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${_cart.length}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepTabs() {
    return Container(
      color: ColorConst.primaryExtraLightGreen,
      child: TabBar(
        controller: _tabController,
        onTap: (i) => setState(() {}),
        indicatorColor: const Color(0xFFFF6B35),
        indicatorWeight: 3,
        labelColor: ColorConst.primaryGreen,
        unselectedLabelColor: ColorConst.primaryGreen,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13,color: ColorConst.primaryGreen),
        tabs: const [
          Tab(icon: Icon(Icons.add_box_outlined, size: 18,color: ColorConst.primaryGreen,), text: 'Add Product'),
          Tab(icon: Icon(Icons.receipt_long_outlined, size: 18,color: ColorConst.primaryGreen,), text: 'Cart'),
        ],
      ),
    );
  }

  // ─── Selection Panel ───────────────────────────────────────────────────────

  Widget _buildSelectionPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            step: '01',
            title: 'Main Category',
            child: _buildMainCategoryGrid(),
          ),
          if (_selMain != null) ...[
            const SizedBox(height: 14),
            _buildSectionCard(
              step: '02',
              title: 'Category',
              child: _buildChipList(
                items: _filteredCats,
                selected: _selCat,
                label: (c) => c.name,
                onTap: (c) => setState(() {
                  _selCat = c;
                  _selSub = null;
                  _selProduct = null;
                  _selVariant = null;
                }),
              ),
            ),
          ],
          if (_selCat != null) ...[
            const SizedBox(height: 14),
            _buildSectionCard(
              step: '03',
              title: 'Sub Category',
              child: _buildChipList(
                items: _filteredSubs,
                selected: _selSub,
                label: (s) => s.name,
                onTap: (s) => setState(() {
                  _selSub = s;
                  _selProduct = null;
                  _selVariant = null;
                }),
              ),
            ),
          ],
          if (_selSub != null) ...[
            const SizedBox(height: 14),
            _buildSectionCard(
              step: '04',
              title: 'Select Product',
              child: _filteredProducts.isEmpty
                  ? const Padding(
                padding: EdgeInsets.all(12),
                child: Text('No products in this subcategory.',
                    style: TextStyle(color: Colors.grey)),
              )
                  : _buildProductList(),
            ),
          ],
          if (_selProduct != null) ...[
            const SizedBox(height: 14),
            _buildSectionCard(
              step: '05',
              title: 'Variant & Quantity',
              child: _buildVariantAndQty(),
            ),
          ],
          if (_selVariant != null) ...[
            const SizedBox(height: 20),
            _buildAddToCartButton(),
          ],
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String step,
    required String title,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha:0.06),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: ColorConst.primaryGreen,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(step,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Text(title,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: ColorConst.primaryGreen)),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          Padding(
            padding: const EdgeInsets.all(14),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildMainCategoryGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 4,
      children: mainCategories.map((mc) {
        final selected = _selMain?.id == mc.id;
        return GestureDetector(
          onTap: () => setState(() {
            _selMain = mc;
            _selCat = null;
            _selSub = null;
            _selProduct = null;
            _selVariant = null;
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: selected
                  ? ColorConst.primaryExtraLightGreen
                  : const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: selected
                      ? ColorConst.primaryGreen
                      : const Color(0xFFE0E0E0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(mc.icon, style: const TextStyle(fontSize: 15)),
                const SizedBox(width: 8),
                Text(
                  mc.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: selected ? ColorConst.primaryGreen : const Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChipList<T>({
    required List<T> items,
    required T? selected,
    required String Function(T) label,
    required void Function(T) onTap,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final isSelected = selected == item;
        return GestureDetector(
          onTap: () => onTap(item),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFFF6B35)
                  : const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFF6B35)
                      : const Color(0xFFE0E0E0)),
            ),
            child: Text(
              label(item),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF555555),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProductList() {
    return Column(
      children: _filteredProducts.map((p) {
        final selected = _selProduct?.id == p.id;
        return GestureDetector(
          onTap: () => setState(() {
            _selProduct = p;
            _selVariant = null;
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: selected
                  ? ColorConst.primaryExtraLightGreen.withValues(alpha:0.07)
                  : const Color(0xFFF8F9FC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: selected
                      ? ColorConst.primaryGreen
                      : const Color(0xFFE8E8E8),
                  width: selected ? 1.5 : 1),
            ),
            child: Row(
              children: [
                Text(p.imageEmoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14)),
                      Text('${p.variants.length} variants available',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                if (selected)
                  const Icon(Icons.check_circle,
                      color: ColorConst.primaryGreen, size: 22),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildVariantAndQty() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Choose Variant',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF444444))),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _selProduct!.variants.map((v) {
            final selected = _selVariant?.id == v.id;
            return GestureDetector(
              onTap: () => setState(() => _selVariant = v),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color:
                  selected ? const Color(0xFFFF6B35) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: selected
                          ? const Color(0xFFFF6B35)
                          : const Color(0xFFDDDDDD)),
                  boxShadow: selected
                      ? [
                    BoxShadow(
                        color: const Color(0xFFFF6B35).withValues(alpha:0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3))
                  ]
                      : [],
                ),
                child: Column(
                  children: [
                    Text(v.label,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: selected ? Colors.white : Colors.black87,
                            fontSize: 13)),
                    Text('₹${v.price.toStringAsFixed(0)}',
                        style: TextStyle(
                            fontSize: 12,
                            color: selected
                                ? Colors.white70
                                : ColorConst.primaryGreen,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (_selVariant != null) ...[
          const SizedBox(height: 18),
          const Text('Quantity',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Color(0xFF444444))),
          const SizedBox(height: 10),
          Row(
            children: [
              _qtyBtn(Icons.remove, () {
                if (_qty > 1) setState(() => _qty--);
              }),
              Container(
                width: 56,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6FA),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Text(
                  '$_qty',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: ColorConst.primaryGreen),
                ),
              ),
              _qtyBtn(Icons.add, () => setState(() => _qty++)),
              const SizedBox(width: 16),
              if (_selVariant != null)
                Text(
                  'Total: ₹${(_selVariant!.price * _qty).toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: ColorConst.primaryGreen),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: ColorConst.primaryGreen,
          borderRadius: BorderRadius.circular(
              icon == Icons.remove ? const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ).topLeft.x : 0),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildAddToCartButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _addToCart,
        icon: const Icon(Icons.add_shopping_cart),
        label: Text(
          'Add to Cart  •  ₹${(_selVariant!.price * _qty).toStringAsFixed(0)}',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorConst.primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 4,
          shadowColor: ColorConst.primaryExtraLightGreen.withValues(alpha:0.5),
        ),
      ),
    );
  }

  // ─── Cart Panel ────────────────────────────────────────────────────────────

  Widget _buildCartPanel() {
    if (_cart.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🛒', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text('Cart is empty',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF444444))),
            const SizedBox(height: 8),
            const Text('Add products from the selection tab',
                style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => setState(() => _tabController.index = 0),
              style: ElevatedButton.styleFrom(
                  backgroundColor:ColorConst.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: const Text('Add Products'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _cart.length,
            itemBuilder: (context, i) => _buildCartTile(_cart[i], i),
          ),
        ),
        _buildCartSummary(),
      ],
    );
  }

  Widget _buildCartTile(CartItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha:0.05),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6FA),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(item.product.imageEmoji,
                  style: const TextStyle(fontSize: 28)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.product.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35).withValues(alpha:0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(item.variant.label,
                        style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFFF6B35),
                            fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                      '₹${item.variant.price.toStringAsFixed(0)} × ${item.qty} = ₹${(item.variant.price * item.qty).toStringAsFixed(0)}',
                      style: const TextStyle(
                          color: ColorConst.primaryGreen,
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
                ],
              ),
            ),
            Column(
              children: [
                Row(
                  children: [
                    _smallQtyBtn(Icons.remove, () {
                      setState(() {
                        if (item.qty > 1) {
                          item.qty--;
                        } else {
                          _cart.removeAt(index);
                        }
                      });
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text('${item.qty}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 16)),
                    ),
                    _smallQtyBtn(Icons.add, () {
                      setState(() => item.qty++);
                    }),
                  ],
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => setState(() => _cart.removeAt(index)),
                  child: const Text('Remove',
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallQtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: ColorConst.primaryExtraLightGreen.withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: ColorConst.primaryGreen),
      ),
    );
  }

  Widget _buildCartSummary() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha:0.1),
              blurRadius: 20,
              offset: const Offset(0, -5)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${_cart.length} item${_cart.length > 1 ? 's' : ''} in cart',
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
              Text('Total: ₹${_cartTotal.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: ColorConst.primaryGreen)),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    title: const Text('Order Requested! 🎉',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    content: Text(
                        '${_cart.length} products worth ₹${_cartTotal.toStringAsFixed(0)} added successfully.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          setState(() => _cart.clear());
                          Navigator.pop(context);
                          _tabController.index = 0;
                        },
                        child: const Text('Done',
                            style: TextStyle(color: ColorConst.primaryGreen)),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Confirm & Place Order',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorConst.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}