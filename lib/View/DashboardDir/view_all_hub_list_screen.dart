import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/responsive_sizes.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/dashboard_model.dart';

class ViewAllHubsScreen extends StatefulWidget {
  final List<Hubs> hubs;
  const ViewAllHubsScreen({super.key, required this.hubs});

  @override
  State<ViewAllHubsScreen> createState() => _ViewAllHubsScreenState();
}

class _ViewAllHubsScreenState extends State<ViewAllHubsScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _filterStatus = 'All'; // All / Active / Inactive
  late AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  List<Hubs> get _filtered {
    return widget.hubs.where((h) {
      final matchSearch = _searchQuery.isEmpty ||
          (h.hubName ?? '').toLowerCase().contains(
              _searchQuery.toLowerCase()) ||
          (h.address ?? '').toLowerCase().contains(
              _searchQuery.toLowerCase());
      final matchStatus = _filterStatus == 'All' ||
          (_filterStatus == 'Active' && h.status == 1) ||
          (_filterStatus == 'Inactive' && h.status != 1);
      return matchSearch && matchStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar ───────────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 130,
            backgroundColor: ColorConst.primaryGreen,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${widget.hubs.length} Hubs',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ColorConst.primaryGreen,
                      ColorConst.primaryGreen.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -20,
                      right: -20,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 44, 80, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'All Hubs',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'City-wide hub management overview',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0),
              child: Container(
                height: 20,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F7FA),
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(20)),
                ),
              ),
            ),
          ),

          // ── Search + filter ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Column(
                children: [
                  // Search bar
                  Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 14),
                        const Icon(Icons.search_rounded,
                            size: 18, color: ColorConst.primaryGreen),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            onChanged: (v) =>
                                setState(() => _searchQuery = v),
                            style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF111827)),
                            decoration: const InputDecoration(
                              hintText: 'Search hubs by name or address…',
                              hintStyle: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF9CA3AF)),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          GestureDetector(
                            onTap: () => setState(() {
                              _searchCtrl.clear();
                              _searchQuery = '';
                            }),
                            child: Container(
                              width: 26,
                              height: 26,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: const Icon(Icons.close_rounded,
                                  size: 13, color: Color(0xFF6B7280)),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Status filter chips
                  Row(
                    children: ['All', 'Active', 'Inactive'].map((f) {
                      final isSelected = _filterStatus == f;
                      final color = f == 'Active'
                          ? const Color(0xFF16A34A)
                          : f == 'Inactive'
                          ? const Color(0xFFEF4444)
                          : ColorConst.primaryGreen;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _filterStatus = f),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: isSelected ? color : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? color
                                    : const Color(0xFFE5E7EB),
                              ),
                              boxShadow: isSelected
                                  ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ]
                                  : [],
                            ),
                            child: Text(
                              f,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // ── Count header ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Container(
                    width: 3,
                    height: 16,
                    decoration: BoxDecoration(
                      color: ColorConst.primaryGreen,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Showing ${filtered.length} hubs',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Hub list ───────────────────────────────────────────
          filtered.isEmpty
              ? SliverFillRemaining(child: _buildEmptyState())
              : SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, i) {
                  final hub = filtered[i];
                  final delay = (i * 0.08).clamp(0.0, 0.6);
                  return AnimatedBuilder(
                    animation: _animCtrl,
                    builder: (context, child) {
                      final p = Curves.easeOut.transform(
                          ((_animCtrl.value - delay)
                              .clamp(0.0, 1.0)));
                      return Opacity(
                        opacity: p,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - p)),
                          child: child,
                        ),
                      );
                    },
                    child: isMobile
                        ? _buildMobileCard(hub)
                        : _buildDesktopRow(hub, i),
                  );
                },
                childCount: filtered.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Mobile card ───────────────────────────────────────────────────────────

  Widget _buildMobileCard(Hubs hub) {
    return GestureDetector(
      onTap: () => _showDetails(hub),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                _hubAvatar(hub.hubName ?? ''),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hub.hubName ?? 'N/A',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Color(0xFF111827),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded,
                              size: 11, color: Color(0xFF9CA3AF)),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              hub.address ?? 'N/A',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF9CA3AF)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _statusBadge(hub.status == 1),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade100),
            const SizedBox(height: 8),
            Row(
              children: [
                _mobileStat(hub.deliveryBoys.toString(), 'Riders',
                    Icons.pedal_bike_outlined, const Color(0xFF2563EB)),
                _vDivider(),
                _mobileStat(hub.inProgress.toString(), 'In Progress',
                    Icons.sync_rounded, const Color(0xFFF59E0B)),
                _vDivider(),
                _mobileStat(hub.completedToday.toString(), 'Done',
                    Icons.check_circle_outline_rounded,
                    const Color(0xFF10B981)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Desktop row ───────────────────────────────────────────────────────────

  Widget _buildDesktopRow(Hubs hub, int index) {
    return GestureDetector(
      onTap: () => _showDetails(hub),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: index.isEven ? Colors.white : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  _hubAvatar(hub.hubName ?? ''),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hub.hubName ?? 'N/A',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFF111827),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          hub.address ?? 'N/A',
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF9CA3AF)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
                child: _desktopMetric(hub.deliveryBoys.toString(),
                    const Color(0xFF2563EB))),
            Expanded(
                child: _desktopMetric(hub.inProgress.toString(),
                    const Color(0xFFF59E0B))),
            Expanded(
                child: _desktopMetric(hub.completedToday.toString(),
                    const Color(0xFF10B981))),
            Expanded(child: _statusBadge(hub.status == 1)),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.chevron_right_rounded,
                  color: ColorConst.primaryGreen, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  // ── Details bottom sheet ──────────────────────────────────────────────────

  void _showDetails(Hubs hub) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Row(
              children: [
                _hubAvatar(hub.hubName ?? '', size: 52),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(hub.hubName ?? 'N/A',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827))),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded,
                              size: 12, color: Color(0xFF9CA3AF)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(hub.address ?? 'N/A',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF9CA3AF))),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _statusBadge(hub.status == 1),
              ],
            ),
            const SizedBox(height: 20),
            Divider(color: Colors.grey.shade100),
            const SizedBox(height: 14),
            Row(
              children: [
                _detailStat(hub.deliveryBoys.toString(), 'Delivery Boys',
                    Icons.pedal_bike_outlined, const Color(0xFF2563EB)),
                const SizedBox(width: 10),
                _detailStat(hub.inProgress.toString(), 'In Progress',
                    Icons.sync_rounded, const Color(0xFFF59E0B)),
                const SizedBox(width: 10),
                _detailStat(hub.completedToday.toString(), 'Completed',
                    Icons.check_circle_outline_rounded,
                    const Color(0xFF10B981)),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ColorConst.primaryGreen.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.account_tree_outlined,
                size: 40,
                color:
                ColorConst.primaryGreen.withValues(alpha: 0.4)),
          ),
          const SizedBox(height: 14),
          const Text('No hubs found',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF374151))),
          const SizedBox(height: 6),
          Text('Try adjusting your search or filter',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  // ── Shared micro-widgets ──────────────────────────────────────────────────

  Widget _hubAvatar(String name, {double size = 42}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: ColorConst.primaryGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'H',
          style: TextStyle(
            color: ColorConst.primaryGreen,
            fontWeight: FontWeight.w700,
            fontSize: size * 0.38,
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(bool isActive) => Container(
    padding:
    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: isActive
          ? const Color(0xFFDCFCE7)
          : const Color(0xFFFEE2E2),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? const Color(0xFF16A34A)
                : const Color(0xFFEF4444),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          isActive ? 'Active' : 'Inactive',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isActive
                ? const Color(0xFF16A34A)
                : const Color(0xFFEF4444),
          ),
        ),
      ],
    ),
  );

  Widget _mobileStat(
      String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: color)),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: Color(0xFF9CA3AF))),
        ],
      ),
    );
  }

  Widget _desktopMetric(String value, Color color) => Text(value,
      style: TextStyle(
          fontSize: 15, fontWeight: FontWeight.w700, color: color));

  Widget _detailStat(
      String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 10, color: Color(0xFF9CA3AF))),
          ],
        ),
      ),
    );
  }

  Widget _vDivider() => Container(
    width: 1,
    height: 36,
    color: const Color(0xFFF1F5F9),
    margin: const EdgeInsets.symmetric(horizontal: 8),
  );
}