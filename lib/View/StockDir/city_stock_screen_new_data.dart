import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/city_stock_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/admin_city_stocks_list_view_model.dart';


class CityStockScreen extends StatefulWidget {
  const CityStockScreen({super.key});

  @override
  State<CityStockScreen> createState() => _CityStockScreenState();
}

class _CityStockScreenState extends State<CityStockScreen>
    with TickerProviderStateMixin {

  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  // Stagger animation
  late AnimationController _staggerCtrl;
  late List<Animation<double>>  _fades;
  late List<Animation<Offset>>  _slides;
  static const _maxAnim = 12;

  // AppBar collapse
  bool _scrolledPast = false;

  @override
  void initState() {
    super.initState();

    _staggerCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 350 + _maxAnim * 55),
    );
    _fades  = _buildFades();
    _slides = _buildSlides();

    _scrollCtrl.addListener(() {
      final past = _scrollCtrl.offset > 80;
      if (past != _scrolledPast) setState(() => _scrolledPast = past);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<AdminStockListRecieveViewModel>().fetchCityStock(context);
      if (mounted) _staggerCtrl.forward();
    });
  }

  List<Animation<double>> _buildFades() => List.generate(_maxAnim, (i) {
    final t0 = (i * 0.08).clamp(0.0, 0.85);
    final t1 = (t0 + 0.26).clamp(0.0, 1.0);
    return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _staggerCtrl,
            curve: Interval(t0, t1, curve: Curves.easeOut)));
  });

  List<Animation<Offset>> _buildSlides() => List.generate(_maxAnim, (i) {
    final t0 = (i * 0.08).clamp(0.0, 0.85);
    final t1 = (t0 + 0.30).clamp(0.0, 1.0);
    return Tween<Offset>(
      begin: const Offset(0, 0.18), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _staggerCtrl,
        curve: Interval(t0, t1, curve: Curves.easeOutCubic)));
  });

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    _staggerCtrl.dispose();
    super.dispose();
  }

  Widget _animated(int i, Widget child) {
    final idx = i.clamp(0, _maxAnim - 1);
    return FadeTransition(
      opacity: _fades[idx],
      child: SlideTransition(position: _slides[idx], child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.bgColor,
      body: Consumer<AdminStockListRecieveViewModel>(
        builder: (context, vm, _) {
          return Column(
            children: [
              _buildAppBar(vm),
              if (vm.isLoading)
                Expanded(child: _buildShimmer())
              else
                Expanded(
                  child: RefreshIndicator(
                    color: ColorConst.green,
                    onRefresh: () async {
                      _staggerCtrl.reset();
                      await vm.fetchCityStock(context);
                      _staggerCtrl.forward();
                    },
                    child: CustomScrollView(
                      controller: _scrollCtrl,
                      physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics()),
                      slivers: [
                        // Stat cards
                        SliverToBoxAdapter(
                          child: _animated(0, _buildStatsRow(vm)),
                        ),

                        // Search bar
                        SliverToBoxAdapter(
                          child: _animated(1, _buildSearchBar(vm)),
                        ),

                        // Stock filter chips
                        SliverToBoxAdapter(
                          child: _animated(2, _buildStockFilterRow(vm)),
                        ),

                        // Category filter chips
                        SliverToBoxAdapter(
                          child: _animated(3, _buildCategoryFilterRow(vm)),
                        ),

                        // Result count
                        SliverToBoxAdapter(
                          child: _animated(
                            4,
                            _buildResultCount(vm),
                          ),
                        ),

                        // Product list
                        vm.filteredProducts.isEmpty
                            ? SliverToBoxAdapter(
                            child: _buildEmptyState(vm))
                            : SliverList(
                          delegate: SliverChildBuilderDelegate(
                                (_, i) => _animated(
                              (i + 5).clamp(0, _maxAnim - 1),
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  16, 0, 16,
                                  i == vm.filteredProducts.length - 1
                                      ? 32
                                      : 10,
                                ),
                                child: _ProductCard(
                                    data: vm.filteredProducts[i]),
                              ),
                            ),
                            childCount: vm.filteredProducts.length,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────────────────────────

  Widget _buildAppBar(AdminStockListRecieveViewModel vm) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      color: ColorConst.white,
      padding: EdgeInsets.fromLTRB(16, top + 8, 16, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'City Stock',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: ColorConst.inkDark,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  '${vm.totalProducts} products',
                  style: const TextStyle(
                    fontSize: 11,
                    color: ColorConst.inkLight,
                  ),
                ),
              ],
            ),
          ),
          // Refresh
          GestureDetector(
            onTap: () async {
              HapticFeedback.selectionClick();
              _staggerCtrl.reset();
              await vm.fetchCityStock(context);
              _staggerCtrl.forward();
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color:ColorConst.greenPale,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ColorConst.stroke),
              ),
              child: const Icon(Icons.refresh_rounded,
                  size: 18, color: ColorConst.green),
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats Row ─────────────────────────────────────────────────────────────

  Widget _buildStatsRow(AdminStockListRecieveViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          _StatCard(
            label: 'Total Units',
            value: '${vm.totalUnits}',
            icon: Icons.inventory_2_outlined,
            color: ColorConst.green,
            bg: ColorConst.greenPale,
          ),
          const SizedBox(width: 8),
          _StatCard(
            label: 'Low Stock',
            value: '${vm.lowStockCount}',
            icon: Icons.warning_amber_rounded,
            color: ColorConst.honey,
            bg: ColorConst.honeyBg,
          ),
          const SizedBox(width: 8),
          _StatCard(
            label: 'Out of Stock',
            value: '${vm.outOfStockCount}',
            icon: Icons.remove_shopping_cart_outlined,
            color: ColorConst.danger,
            bg: ColorConst.dangerBg,
          ),
        ],
      ),
    );
  }

  // ── Search Bar ────────────────────────────────────────────────────────────

  Widget _buildSearchBar(AdminStockListRecieveViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: ColorConst.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ColorConst.stroke),
          boxShadow: const [
            BoxShadow(
                color: Color(0x08000000),
                blurRadius: 8,
                offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            const Icon(Icons.search_rounded, size: 18, color: ColorConst.inkLight),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) {
                  vm.setSearch(v);
                  setState(() {});
                },
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ColorConst.inkDark,
                ),
                decoration: const InputDecoration(
                  hintText: 'Search products, brands, categories...',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: ColorConst.inkLight,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                cursorColor: ColorConst.green,
              ),
            ),
            if (_searchCtrl.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchCtrl.clear();
                  vm.setSearch('');
                  setState(() {});
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: ColorConst.inkLight.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded,
                        size: 12, color: _inkMid),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Stock Filter Chips ────────────────────────────────────────────────────

  Widget _buildStockFilterRow(AdminStockListRecieveViewModel vm) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        children: StockFilter.values.map((f) {
          final sel = vm.stockFilter == f;
          Color chipColor;
          Color chipBg;
          switch (f) {
            case StockFilter.inStock:
              chipColor = ColorConst.green; chipBg = ColorConst.greenPale; break;
            case StockFilter.lowStock:
              chipColor =ColorConst.honey; chipBg = ColorConst.honeyBg; break;
            case StockFilter.outOfStock:
              chipColor = ColorConst.danger; chipBg = ColorConst.dangerBg; break;
            default:
              chipColor = ColorConst.inkMid; chipBg = ColorConst.creamDeep; break;
          }

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              vm.setStockFilter(f);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: sel ? chipColor : ColorConst.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: sel ? chipColor : ColorConst.stroke,
                  width: sel ? 1.5 : 1,
                ),
              ),
              child: Text(
                f.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: sel ? ColorConst.white : _inkMid,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Category Filter Chips ─────────────────────────────────────────────────

  Widget _buildCategoryFilterRow(AdminStockListRecieveViewModel vm) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        children: vm.categoryFilters.map((cat) {
          final sel = vm.selectedCategory == cat;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              vm.setCategory(cat);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: sel ? ColorConst.greenPale : ColorConst.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: sel ? ColorConst.green : ColorConst.stroke,
                  width: sel ? 1.5 : 1,
                ),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: sel ? ColorConst.green : _inkMid,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Result count + clear ──────────────────────────────────────────────────

  Widget _buildResultCount(AdminStockListRecieveViewModel vm) {
    final isFiltered = vm.searchQuery.isNotEmpty ||
        vm.selectedCategory != 'All' ||
        vm.stockFilter != StockFilter.all;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        children: [
          Text(
            '${vm.filteredProducts.length} products',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: ColorConst.inkLight,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          if (isFiltered)
            GestureDetector(
              onTap: () {
                _searchCtrl.clear();
                vm.clearFilters();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: ColorConst.terraLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.close_rounded, size: 12, color: ColorConst.terra),
                    SizedBox(width: 4),
                    Text(
                      'Clear filters',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: ColorConst.terra,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────────────────────

  Widget _buildEmptyState(AdminStockListRecieveViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: ColorConst.greenPale,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.inventory_2_outlined,
                size: 32, color: ColorConst.green),
          ),
          const SizedBox(height: 16),
          const Text(
            'No products found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: ColorConst.inkDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try adjusting your search or filters',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: ColorConst.inkLight),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              _searchCtrl.clear();
              vm.clearFilters();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: ColorConst.greenPale,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: ColorConst.stroke),
              ),
              child: const Text(
                'Clear all filters',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: ColorConst.green,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Shimmer loading ───────────────────────────────────────────────────────

  Widget _buildShimmer() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => _ShimmerCard(),
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bg;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: color,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Product Card ─────────────────────────────────────────────────────────────

class _ProductCard extends StatefulWidget {
  final CityStockData data;
  const _ProductCard({required this.data});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _expandCtrl;
  late Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _expandCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _expandAnim = CurvedAnimation(
        parent: _expandCtrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _expandCtrl.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    HapticFeedback.selectionClick();
    setState(() => _expanded = !_expanded);
    _expanded ? _expandCtrl.forward() : _expandCtrl.reverse();
  }

  // Stock badge config
  _StockBadgeConfig _stockConfig(int total) {
    if (total == 0) {
      return _StockBadgeConfig(
          label: 'Out of Stock',
          color: ColorConst.danger,
          bg: ColorConst.dangerBg,
          icon: Icons.remove_shopping_cart_outlined);
    } else if (total <= 10) {
      return _StockBadgeConfig(
          label: 'Low Stock',
          color: ColorConst.honey,
          bg: ColorConst.honeyBg,
          icon: Icons.warning_amber_rounded);
    } else {
      return _StockBadgeConfig(
          label: 'In Stock',
          color: ColorConst.green,
          bg: ColorConst.greenPale,
          icon: Icons.check_circle_outline_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final total = (d.totalStock ?? 0) as int;
    final cfg = _stockConfig(total);
    final variants = d.variants ?? [];

    return Container(
      decoration: BoxDecoration(
        color: ColorConst.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ColorConst.stroke),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Main row ────────────────────────────────────────────────
          GestureDetector(
            onTap: _toggleExpand,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: d.productImg?.toString() ?? '',
                      width: 68,
                      height: 68,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        width: 68,
                        height: 68,
                        color: ColorConst.greenPale,
                        child: const Icon(Icons.image_outlined,
                            color: ColorConst.inkLight, size: 24),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: ColorConst.greenPale,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.inventory_2_outlined,
                            color: ColorConst.inkLight, size: 24),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product name
                        Text(
                          d.productName?.toString() ?? '—',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: ColorConst.inkDark,
                            letterSpacing: -0.2,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        // Brand + category
                        Row(
                          children: [
                            if (d.brandName != null) ...[
                              _InfoPill(text: "Brand: ${d.brandName.toString()}"),
                              const SizedBox(width: 5),
                            ],
                            if (d.categoryName != null)
                              _InfoPill(
                                text: "Category: ${d.categoryName.toString()}",
                                isCategory: true,
                              ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Total stock + badge
                        Row(
                          children: [
                            // Total stock number
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: cfg.bg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(cfg.icon,
                                      size: 12, color: cfg.color),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$total units',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: cfg.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 7),
                            // Status badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: cfg.bg,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color:
                                    cfg.color.withOpacity(0.25)),
                              ),
                              child: Text(
                                cfg.label,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: cfg.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 6),

                  // Expand chevron
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 280),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: ColorConst.creamDeep,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: _inkMid),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Meta footer ─────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: ColorConst.cream,
              border: const Border(
                top: BorderSide(color: ColorConst.stroke, width: 0.8),
              ),
            ),
            child: Row(
              children: [
                _MetaChip(
                    icon: Icons.category_outlined,
                    text: "Subcategory: ${d.subcategoryName?.toString() ?? '—'}"),
                const SizedBox(width: 10),
                _MetaChip(
                    icon: Icons.layers_outlined,
                    text: '${variants.length} variant${variants.length == 1 ? '' : 's'}'),
                const Spacer(),
                if (d.sku != null)
                  Text(
                    'SKU: ${d.sku}',
                    style: const TextStyle(
                        fontSize: 10, color: ColorConst.inkLight),
                  ),
              ],
            ),
          ),

          // ── Variant table (expandable) ───────────────────────────────
          SizeTransition(
            sizeFactor: _expandAnim,
            axisAlignment: -1,
            child: variants.isEmpty
                ? const SizedBox.shrink()
                : _VariantTable(variants: variants),
          ),
        ],
      ),
    );
  }
}

class _StockBadgeConfig {
  final String label;
  final Color color;
  final Color bg;
  final IconData icon;
  const _StockBadgeConfig(
      {required this.label,
        required this.color,
        required this.bg,
        required this.icon});
}

// ─── Info Pill ────────────────────────────────────────────────────────────────

class _InfoPill extends StatelessWidget {
  final String text;
  final bool isCategory;

  const _InfoPill({required this.text, this.isCategory = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isCategory ? ColorConst.creamDeep : ColorConst.greenSoft,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isCategory ? _inkMid : ColorConst.green,
        ),
      ),
    );
  }
}

// ─── Meta Chip ────────────────────────────────────────────────────────────────

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MetaChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color:ColorConst.inkLight),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 11, color: _inkMid),
        ),
      ],
    );
  }
}

// ─── Variant Table ────────────────────────────────────────────────────────────

class _VariantTable extends StatelessWidget {
  final List<Variants> variants;
  const _VariantTable({required this.variants});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: ColorConst.stroke, width: 0.8)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            color: ColorConst.creamDeep,
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 8),
            child: Row(
              children: const [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Variant',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: ColorConst.inkLight,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Price',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: ColorConst.inkLight,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'MRP',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: ColorConst.inkLight,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Stock',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: ColorConst.inkLight,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Rows
          ...variants.asMap().entries.map((entry) {
            final i = entry.key;
            final v = entry.value;
            final stock  = (v.stock ?? 0) as int;
            final isLast = i == variants.length - 1;
            final outOf  = stock == 0;
            final low    = stock > 0 && stock <= 10;

            final price    = v.discountPrice ?? v.price;
            final mrp      = v.price;
            final hasDisc  = v.discountPrice != null &&
                v.price != null &&
                v.discountPrice != v.price;

            return Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: outOf
                    ? ColorConst.dangerBg.withOpacity(0.4)
                    : low
                    ? ColorConst.honeyBg.withOpacity(0.4)
                    : ColorConst.white,
                border: isLast
                    ? null
                    : const Border(
                    bottom:
                    BorderSide(color: ColorConst.stroke, width: 0.8)),
              ),
              child: Row(
                children: [
                  // Variant value
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: outOf
                                ? ColorConst.danger
                                : low
                                ? ColorConst.honey
                                : ColorConst.green,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Flexible(
                          child: Text(
                            v.value?.toString() ?? '—',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: ColorConst.inkDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Discounted price
                  Expanded(
                    flex: 2,
                    child: Text(
                      price != null ? '₹$price' : '—',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: ColorConst.green,
                      ),
                    ),
                  ),

                  // MRP (strikethrough if discount exists)
                  Expanded(
                    flex: 2,
                    child: Text(
                      mrp != null ? '₹$mrp' : '—',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: hasDisc ? ColorConst.inkLight : _inkMid,
                        fontWeight: FontWeight.w500,
                        decoration: hasDisc
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                  ),

                  // Stock qty
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '$stock',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: outOf
                                ? ColorConst.danger
                                : low
                                ? ColorConst.honey
                                : ColorConst.inkDark,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(width: 3),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Shimmer Card ─────────────────────────────────────────────────────────────

class _ShimmerCard extends StatefulWidget {
  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        height: 110,
        decoration: BoxDecoration(
          color: ColorConst.white.withOpacity(_anim.value + 0.3),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ColorConst.stroke),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: ColorConst.creamDeep.withOpacity(_anim.value),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: ColorConst.creamDeep.withOpacity(_anim.value),
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 10,
                    width: 120,
                    decoration: BoxDecoration(
                      color: ColorConst.creamDeep.withOpacity(_anim.value * 0.6),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 24,
                    width: 90,
                    decoration: BoxDecoration(
                      color: ColorConst.greenPale.withOpacity(_anim.value),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Palette extras needed ─────────────────────────────────────────────────────
const _inkMid = Color(0xFF5C5E4E);