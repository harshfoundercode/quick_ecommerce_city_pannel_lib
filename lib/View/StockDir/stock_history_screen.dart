
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/city_hub_history_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/city_stock_view_model.dart';

class CityHubHistoryScreen extends StatefulWidget {
  const CityHubHistoryScreen({super.key});

  @override
  State<CityHubHistoryScreen> createState() => _CityHubHistoryScreenState();
}

class _CityHubHistoryScreenState extends State<CityHubHistoryScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  // Filter state
  String _filterMode = 'all'; // 'all' | 'active' | 'empty'

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<CityStockViewModel>(context, listen: false);
      vm.cityHubHistoryApi(context).then((_) => _fadeCtrl.forward());
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: _buildAppBar(context),
      body: Consumer<CityStockViewModel>(
        builder: (context, vm, _) {
          if (vm.historyLoading) return _buildShimmerLoader();

          final allGroups = vm.hubGroups;
          if (allGroups.isEmpty) return _buildEmptyState(context, vm);

          // Apply filter
          final groups = _filterGroups(allGroups);

          final totalHubs = allGroups.length;
          final activeHubs = allGroups.where((g) => g.hasProducts).length;
          final emptyHubs = totalHubs - activeHubs;
          final totalSent =
          allGroups.fold<int>(0, (s, g) => s + g.totalStockSent);
          final totalInStock = allGroups.fold<int>(
              0, (s, g) => s + g.totalCurrentStock);

          return FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              children: [
                _buildSummarySection(
                    totalHubs, activeHubs, emptyHubs, totalSent, totalInStock),
                _buildFilterBar(allGroups),
                _buildListHeader(groups.length),
                Expanded(
                  child: groups.isEmpty
                      ? _buildFilterEmptyState()
                      : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    itemCount: groups.length,
                    itemBuilder: (_, i) =>
                        _HubCard(group: groups[i], index: i),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<HubGroup> _filterGroups(List<HubGroup> all) {
    switch (_filterMode) {
      case 'active':
        return all.where((g) => g.hasProducts).toList();
      case 'empty':
        return all.where((g) => !g.hasProducts).toList();
      default:
        return all;
    }
  }

  // ── AppBar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: ColorConst.primaryGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.account_tree_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hub Transfer History',
                  style: TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3)),
              Text('City → Hub stock movements',
                  style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 11,
                      fontWeight: FontWeight.w400)),
            ],
          ),
        ],
      ),
      actions: [
        Consumer<CityStockViewModel>(
          builder: (ctx, vm, _) => _AppBarAction(
            icon: Icons.refresh_rounded,
            tooltip: 'Refresh',
            onTap: () {
              _fadeCtrl.reset();
              vm.cityHubHistoryApi(ctx).then((_) => _fadeCtrl.forward());
            },
          ),
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: const Color(0xFFF3F4F6)),
      ),
    );
  }

  // ── Summary Section ───────────────────────────────────────────────────────

  Widget _buildSummarySection(int totalHubs, int activeHubs, int emptyHubs,
      int totalSent, int totalInStock) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  label: 'Total Hubs',
                  value: '$totalHubs',
                  icon: Icons.hub_outlined,
                  iconBg: const Color(0xFFEFF6FF),
                  iconColor: const Color(0xFF2563EB),
                  valueColor: const Color(0xFF111827),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryCard(
                  label: 'Active Hubs',
                  value: '$activeHubs',
                  icon: Icons.check_circle_outline_rounded,
                  iconBg: const Color(0xFFF0FDF4),
                  iconColor: const Color(0xFF16A34A),
                  valueColor: const Color(0xFF16A34A),
                  badge: emptyHubs > 0 ? '$emptyHubs idle' : null,
                  badgeColor: const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  label: 'Units Dispatched',
                  value: '$totalSent',
                  icon: Icons.send_rounded,
                  iconBg: const Color(0xFFFFF7ED),
                  iconColor: const Color(0xFFEA580C),
                  valueColor: const Color(0xFF111827),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryCard(
                  label: 'Currently In Hubs',
                  value: '$totalInStock',
                  icon: Icons.inventory_2_outlined,
                  iconBg: const Color(0xFFF5F3FF),
                  iconColor: const Color(0xFF7C3AED),
                  valueColor: const Color(0xFF111827),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Filter Bar ────────────────────────────────────────────────────────────

  Widget _buildFilterBar(List<HubGroup> all) {
    final active = all.where((g) => g.hasProducts).length;
    final empty = all.length - active;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          _FilterChip(
              label: 'All',
              count: all.length,
              selected: _filterMode == 'all',
              onTap: () => setState(() => _filterMode = 'all')),
          const SizedBox(width: 8),
          _FilterChip(
              label: 'Active',
              count: active,
              selected: _filterMode == 'active',
              color: const Color(0xFF16A34A),
              onTap: () => setState(() => _filterMode = 'active')),
          const SizedBox(width: 8),
          _FilterChip(
              label: 'Empty',
              count: empty,
              selected: _filterMode == 'empty',
              color: const Color(0xFF9CA3AF),
              onTap: () => setState(() => _filterMode = 'empty')),
        ],
      ),
    );
  }

  Widget _buildListHeader(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Text('$count hub${count != 1 ? 's' : ''}',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280))),
          const Spacer(),
          const Icon(Icons.sort_rounded, size: 14, color: Color(0xFF9CA3AF)),
          const SizedBox(width: 4),
          const Text('Hub ID',
              style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
        ],
      ),
    );
  }

  // ── Shimmer Loader ────────────────────────────────────────────────────────

  Widget _buildShimmerLoader() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (_, i) => _ShimmerCard(),
    );
  }

  // ── Empty States ──────────────────────────────────────────────────────────

  Widget _buildEmptyState(BuildContext context, CityStockViewModel vm) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Icon(Icons.history_rounded,
                size: 36, color: Color(0xFFD1D5DB)),
          ),
          const SizedBox(height: 16),
          const Text('No transfer history',
              style: TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 17,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('No stock has been sent to any hub yet.',
              style:
              TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorConst.primaryGreen,
              foregroundColor: Colors.white,
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () => vm.cityHubHistoryApi(context),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Refresh',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.filter_list_off_rounded,
              size: 40, color: Color(0xFFD1D5DB)),
          const SizedBox(height: 12),
          const Text('No hubs match this filter',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => setState(() => _filterMode = 'all'),
            child: const Text('Clear filter',
                style: TextStyle(color: ColorConst.primaryGreen)),
          ),
        ],
      ),
    );
  }
}

// ── Summary Card Widget ───────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final Color valueColor;
  final String? badge;
  final Color? badgeColor;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.valueColor,
    this.badge,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(value,
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: valueColor,
                            letterSpacing: -0.5)),
                    if (badge != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                          (badgeColor ?? Colors.grey).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(badge!,
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: badgeColor ?? Colors.grey)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter Chip ───────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    this.color = const Color(0xFF374151),
  });

  @override
  Widget build(BuildContext context) {
    final activeColor =
    selected ? color : const Color(0xFF6B7280);
    final bg = selected
        ? color.withValues(alpha: 0.08)
        : const Color(0xFFF3F4F6);
    final border = selected
        ? color.withValues(alpha: 0.3)
        : const Color(0xFFE5E7EB);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w500,
                    color: activeColor)),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: selected
                    ? color.withValues(alpha: 0.15)
                    : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('$count',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: selected ? color : const Color(0xFF9CA3AF))),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shimmer Card ──────────────────────────────────────────────────────────────

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
        duration: const Duration(milliseconds: 1100))
      ..repeat();
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
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
      builder: (_, __) {
        final shimmer = LinearGradient(
          colors: [
            const Color(0xFFE5E7EB),
            const Color(0xFFF3F4F6),
            const Color(0xFFE5E7EB),
          ],
          stops: [
            (_anim.value - 0.3).clamp(0.0, 1.0),
            _anim.value.clamp(0.0, 1.0),
            (_anim.value + 0.3).clamp(0.0, 1.0),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _shimmerBox(46, 46, gradient: shimmer, radius: 12),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _shimmerBox(140, 14, gradient: shimmer),
                      const SizedBox(height: 8),
                      _shimmerBox(100, 10, gradient: shimmer),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _shimmerBox(double.infinity, 60, gradient: shimmer, radius: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _shimmerBox(double w, double h,
      {required LinearGradient gradient, double radius = 6}) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ── AppBar Action Button ──────────────────────────────────────────────────────

class _AppBarAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _AppBarAction(
      {required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF374151)),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ── Hub Card ──────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────

class _HubCard extends StatefulWidget {
  final HubGroup group;
  final int index;
  const _HubCard({required this.group, required this.index});

  @override
  State<_HubCard> createState() => _HubCardState();
}

class _HubCardState extends State<_HubCard> {
  bool _expanded = true;

  bool get _hasProducts => widget.group.hasProducts;

  // Stock health ratio: currentStock / totalSent
  double get _stockRatio {
    final sent = widget.group.totalStockSent;
    if (sent == 0) return 0;
    return (widget.group.totalCurrentStock / sent).clamp(0.0, 1.0);
  }

  Color get _healthColor {
    if (_stockRatio > 0.5) return const Color(0xFF16A34A);
    if (_stockRatio > 0.2) return const Color(0xFFCA8A04);
    return const Color(0xFFDC2626);
  }

  String get _healthLabel {
    if (!_hasProducts) return 'No Stock';
    if (_stockRatio > 0.5) return 'Healthy';
    if (_stockRatio > 0.2) return 'Low';
    return 'Critical';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _hasProducts
              ? const Color(0xFFE5E7EB)
              : const Color(0xFFF3F4F6),
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        children: [
          // ── Card Header ──────────────────────────────────────────────
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: _expanded
                ? const BorderRadius.vertical(top: Radius.circular(16))
                : BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Hub Avatar
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: _hasProducts
                              ? const LinearGradient(
                            colors: [
                              ColorConst.primaryGreen,
                              ColorConst.primaryGreen
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                              : null,
                          color: _hasProducts
                              ? null
                              : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'H${widget.group.hubId}',
                              style: TextStyle(
                                  color: _hasProducts
                                      ? Colors.white
                                      : const Color(0xFF9CA3AF),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  letterSpacing: -0.3),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Hub name + meta
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.group.hubName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: Color(0xFF111827),
                                        letterSpacing: -0.2),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _StatusPill(
                                    label: _healthLabel,
                                    color: _healthColor),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                _MiniPill(
                                    icon: Icons.inventory_2_outlined,
                                    label:
                                    '${widget.group.productCount} SKUs'),
                                const SizedBox(width: 8),
                                _MiniPill(
                                    icon: Icons.send_rounded,
                                    label: '${widget.group.totalStockSent} sent'),
                                const SizedBox(width: 8),
                                _MiniPill(
                                    icon: Icons.warehouse_outlined,
                                    label:
                                    '${widget.group.totalCurrentStock} in hub'),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 6),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 220),
                        child: const Icon(Icons.keyboard_arrow_down_rounded,
                            color: Color(0xFFD1D5DB), size: 22),
                      ),
                    ],
                  ),

                  // ── Stock Health Bar ─────────────────────────────────
                  if (_hasProducts) ...[
                    const SizedBox(height: 12),
                    _StockHealthBar(
                        ratio: _stockRatio, color: _healthColor),
                  ],
                ],
              ),
            ),
          ),

          // ── Expandable Product List ──────────────────────────────────
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildProductList(),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    if (!_hasProducts) {
      return Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: const Color(0xFFE5E7EB), style: BorderStyle.solid),
        ),
        child: const Column(
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 32, color: Color(0xFFD1D5DB)),
            SizedBox(height: 8),
            Text('No stock assigned',
                style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
            SizedBox(height: 4),
            Text('This hub has not received any products yet.',
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(
        children: [
          Divider(
              color: const Color(0xFFF3F4F6), height: 1, thickness: 1),
          const SizedBox(height: 10),
          // Column header
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Row(
              children: const [
                Expanded(
                    child: Text('PRODUCT / VARIANT',
                        style: _columnHeaderStyle)),
                SizedBox(width: 8),
                SizedBox(
                    width: 70,
                    child: Text('IN HUB',
                        style: _columnHeaderStyle,
                        textAlign: TextAlign.center)),
                SizedBox(width: 8),
                SizedBox(
                    width: 70,
                    child: Text('DISPATCHED',
                        style: _columnHeaderStyle,
                        textAlign: TextAlign.center)),
              ],
            ),
          ),
          ...widget.group.byProduct.entries.map(
                (entry) => _ProductGroup(
              productName: entry.key,
              variants: entry.value,
            ),
          ),
        ],
      ),
    );
  }
}

const _columnHeaderStyle = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w700,
    color: Color(0xFF9CA3AF),
    letterSpacing: 0.8);

// ── Stock Health Bar ──────────────────────────────────────────────────────────

class _StockHealthBar extends StatelessWidget {
  final double ratio;
  final Color color;
  const _StockHealthBar({required this.ratio, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Stock health',
                style: const TextStyle(
                    fontSize: 10, color: Color(0xFF9CA3AF))),
            Text('${(ratio * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            backgroundColor: const Color(0xFFF3F4F6),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 5,
          ),
        ),
      ],
    );
  }
}

// ── Product Group ─────────────────────────────────────────────────────────────

class _ProductGroup extends StatelessWidget {
  final String productName;
  final List<CityHubHistoryData> variants;

  const _ProductGroup(
      {required this.productName, required this.variants});

  int get _totalInHub =>
      variants.fold<int>(0, (s, v) => s + (v.hubCurrentStock ?? 0));
  int get _totalSent =>
      variants.fold<int>(0, (s, v) => s + v.totalSent);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product header row
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.shopping_bag_outlined,
                      size: 13, color: Color(0xFF2563EB)),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    productName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF1E3A5F),
                        letterSpacing: -0.2),
                  ),
                ),
                // Aggregate totals
                _ProductTotalsRow(
                    totalInHub: _totalInHub, totalSent: _totalSent),
              ],
            ),
          ),

          if (variants.length > 1) ...[
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            ...variants.map((v) => _VariantRow(item: v)),
          ] else ...[
            // Single variant — merged look
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            _VariantRow(item: variants.first),
          ],
        ],
      ),
    );
  }
}

class _ProductTotalsRow extends StatelessWidget {
  final int totalInHub;
  final int totalSent;
  const _ProductTotalsRow(
      {required this.totalInHub, required this.totalSent});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _dot(totalInHub == 0
            ? const Color(0xFFDC2626)
            : const Color(0xFF16A34A)),
        const SizedBox(width: 4),
        Text('$totalInHub',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: totalInHub == 0
                    ? const Color(0xFFDC2626)
                    : const Color(0xFF16A34A))),
        const SizedBox(width: 10),
        const Icon(Icons.send_rounded,
            size: 11, color: Color(0xFF6B7280)),
        const SizedBox(width: 3),
        Text('$totalSent',
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF374151))),
      ],
    );
  }

  Widget _dot(Color c) => Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle));
}

// ── Variant Row ───────────────────────────────────────────────────────────────

class _VariantRow extends StatelessWidget {
  final CityHubHistoryData item;
  const _VariantRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final stock = item.hubCurrentStock ?? 0;
    final sent = item.totalSent;
    final isOutOfStock = stock == 0;
    final stockColor =
    isOutOfStock ? const Color(0xFFDC2626) : const Color(0xFF059669);
    // Sell-through %
    final sellThrough =
    sent > 0 ? ((sent - stock) / sent * 100).clamp(0, 100).toInt() : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      child: Row(
        children: [
          // Variant tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE9FE),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              item.variant ?? 'Default',
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5B21B6)),
            ),
          ),
          const SizedBox(width: 8),

          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // In Hub stock
                SizedBox(
                  width: 70,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('$stock',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: stockColor,
                                  letterSpacing: -0.5)),
                          if (isOutOfStock) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('OUT',
                                  style: TextStyle(
                                      fontSize: 8,
                                      color: Color(0xFFDC2626),
                                      fontWeight: FontWeight.w800)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 1),
                      Text('in hub',
                          style: const TextStyle(
                              fontSize: 9, color: Color(0xFF9CA3AF))),
                    ],
                  ),
                ),

                // Sell-through indicator
                Expanded(
                  child: Column(
                    children: [
                      Text('$sellThrough%',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280))),
                      const SizedBox(height: 3),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: sellThrough / 100,
                          backgroundColor: const Color(0xFFF3F4F6),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            sellThrough > 70
                                ? const Color(0xFF16A34A)
                                : sellThrough > 40
                                ? const Color(0xFFCA8A04)
                                : const Color(0xFF9CA3AF),
                          ),
                          minHeight: 4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text('sold',
                          style: TextStyle(
                              fontSize: 9, color: Color(0xFF9CA3AF))),
                    ],
                  ),
                ),

                // Total dispatched
                SizedBox(
                  width: 70,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send_rounded,
                              size: 10, color: Color(0xFF6B7280)),
                          const SizedBox(width: 3),
                          Text('$sent',
                              style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF374151),
                                  letterSpacing: -0.5)),
                        ],
                      ),
                      const SizedBox(height: 1),
                      const Text('dispatched',
                          style: TextStyle(
                              fontSize: 9, color: Color(0xFF9CA3AF))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status Pill ───────────────────────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 5,
              height: 5,
              decoration:
              BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: 0.2)),
        ],
      ),
    );
  }
}

// ── Mini Pill ─────────────────────────────────────────────────────────────────

class _MiniPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MiniPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 3),
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}