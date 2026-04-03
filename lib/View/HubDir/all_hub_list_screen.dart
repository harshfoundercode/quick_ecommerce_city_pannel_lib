import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/responsive_sizes.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/dialog_box.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/header_widget.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/hub_list_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/HubDir/SpecificHubPerformanceDir/view_hub_details.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/HubDir/edit_hub_details.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/HubDir/view_all_hub_list_screen.dart' show AllHubListFullScreen;
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/all_hub_list_view_model.dart';

class AllHubScreen extends StatefulWidget {
  const AllHubScreen({super.key});

  @override
  State<AllHubScreen> createState() => _AllHubScreenState();
}

class _AllHubScreenState extends State<AllHubScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  String _searchQuery = '';
  int _filterStatus = -1; // -1 = all, 1 = active, 0 = inactive

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<AllHubViewModel>(context, listen: false);
      vm.getHubListDataApi(context).then((_) => _fadeCtrl.forward());
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  List<Hubs> _filteredHubs(List<Hubs> hubs) {
    return hubs.where((h) {
      final matchSearch = _searchQuery.isEmpty ||
          (h.hubName ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (h.address ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (h.managerName ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
      final matchStatus =
          _filterStatus == -1 || h.status == _filterStatus;
      return matchSearch && matchStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final mobile = Responsive.isMobile(context);

    return Consumer<AllHubViewModel>(
      builder: (context, vm, child) {
        final allHubs = vm.hubListModel?.data?.hubs ?? [];
        final filtered = _filteredHubs(allHubs);
        final showLimited = filtered.length >= 4;
        final displayList = showLimited ? filtered.take(4).toList() : filtered;

        return FadeTransition(
          opacity: _fadeAnim,
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(
              horizontal: Sizes.screenWidth * (mobile ? 0.04 : 0.01),
            ),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomWidgets.pageHeader(
                    title: "Hub Management",
                    subtitle:
                    "Manage and monitor all delivery hubs across the city",
                  ),
                  CustomWidgets.verticalSpace(0.03),

                  // ── Stats ──────────────────────────────────────────
                  _buildStatsSection(vm, mobile),
                  CustomWidgets.verticalSpace(0.025),

                  // ── Search + Filter bar ────────────────────────────
                  _buildSearchAndFilter(allHubs),
                  CustomWidgets.verticalSpace(0.02),

                  // ── Hub list ───────────────────────────────────────
                  _buildHubSection(vm, mobile, filtered, displayList, allHubs),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Stats Section ─────────────────────────────────────────────────────────

  Widget _buildStatsSection(AllHubViewModel vm, bool mobile) {
    final summary = vm.hubListModel?.data?.summary;
    final total = summary?.totalHubs ?? 0;
    final active = summary?.activeHubs ?? 0;
    final inactive = int.parse(total.toString()) - int.parse(active.toString());

    final stats = [
      _StatData(
        title: 'Total Hubs',
        value: '$total',
        icon: Icons.hub_outlined,
        iconBg: const Color(0xFFEFF6FF),
        iconColor: const Color(0xFF2563EB),
        valueColor: const Color(0xFF111827),
      ),
      _StatData(
        title: 'Active Hubs',
        value: '$active',
        icon: Icons.check_circle_outline_rounded,
        iconBg: const Color(0xFFF0FDF4),
        iconColor: const Color(0xFF16A34A),
        valueColor: const Color(0xFF16A34A),
        badge: inactive > 0 ? '$inactive offline' : null,
        badgeColor: const Color(0xFF9CA3AF),
      ),
      _StatData(
        title: 'Delivery Boys',
        value: summary?.totalDeliveryBoys?.toString() ?? '0',
        icon: Icons.pedal_bike_outlined,
        iconBg: const Color(0xFFFFF7ED),
        iconColor: const Color(0xFFEA580C),
        valueColor: const Color(0xFF111827),
      ),
      _StatData(
        title: 'Active Orders',
        value: summary?.totalActiveOrders?.toString() ?? '0',
        icon: Icons.receipt_long_outlined,
        iconBg: const Color(0xFFF5F3FF),
        iconColor: const Color(0xFF7C3AED),
        valueColor: const Color(0xFF111827),
      ),
    ];

    if (mobile) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _StatCard(data: stats[0])),
              const SizedBox(width: 10),
              Expanded(child: _StatCard(data: stats[1])),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _StatCard(data: stats[2])),
              const SizedBox(width: 10),
              Expanded(child: _StatCard(data: stats[3])),
            ],
          ),
        ],
      );
    }

    return Row(
      children: stats
          .map((s) => Expanded(
        child: Padding(
          padding: EdgeInsets.only(
              right: s == stats.last ? 0 : 10),
          child: _StatCard(data: s),
        ),
      ))
          .toList(),
    );
  }

  // ── Search + Filter ───────────────────────────────────────────────────────

  Widget _buildSearchAndFilter(List<Hubs> allHubs) {
    final active = allHubs.where((h) => h.status == 1).length;
    final inactive = allHubs.length - active;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search field
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(fontSize: 13, color: Color(0xFF111827)),
              decoration: const InputDecoration(
                hintText: 'Search by hub name, address or manager…',
                hintStyle:
                TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                prefixIcon: Icon(Icons.search_rounded,
                    size: 18, color: Color(0xFF9CA3AF)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Filter chips row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _HubFilterChip(
                  label: 'All',
                  count: allHubs.length,
                  selected: _filterStatus == -1,
                  onTap: () => setState(() => _filterStatus = -1),
                ),
                const SizedBox(width: 8),
                _HubFilterChip(
                  label: 'Active',
                  count: active,
                  color: const Color(0xFF16A34A),
                  selected: _filterStatus == 1,
                  onTap: () => setState(() => _filterStatus = 1),
                ),
                const SizedBox(width: 8),
                _HubFilterChip(
                  label: 'Inactive',
                  count: inactive,
                  color: const Color(0xFF9CA3AF),
                  selected: _filterStatus == 0,
                  onTap: () => setState(() => _filterStatus = 0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Hub List Section ──────────────────────────────────────────────────────

  Widget _buildHubSection(AllHubViewModel vm, bool mobile, List<Hubs> filtered, List<Hubs> displayList, List<Hubs> allHubs) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                const Text('All Hubs',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                        letterSpacing: -0.2)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('${filtered.length}',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6B7280))),
                ),
              ],
            ),
          ),

          if (filtered.isEmpty)
            _buildNoResultsState()
          else ...[
            if (!mobile) ...[
              _buildTableHeader(),
              const Divider(height: 1, color: Color(0xFFF3F4F6)),
            ],
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayList.length,
              padding: EdgeInsets.zero,
              separatorBuilder: (_, __) =>
              const Divider(height: 1, color: Color(0xFFF3F4F6)),
              itemBuilder: (context, index) {
                final hub = displayList[index];
                return mobile
                    ? _HubMobileCard(
                  hub: hub,
                  onView: () => openRightDrawer(
                      context,
                      ViewHubDetails(
                          hubName: hub.hubName,
                          hubId: hub.hubId.toString())),
                  onEdit: () => openRightDrawer(
                      context,
                      EditCityDrawer(hubId: hub.hubId.toString())),
                )
                    : _HubDesktopRow(
                  hub: hub,
                  onView: () => openRightDrawer(
                      context,
                      ViewHubDetails(
                          hubName: hub.hubName,
                          hubId: hub.hubId.toString())),
                  onEdit: () => openRightDrawer(
                      context,
                      EditCityDrawer(hubId: hub.hubId.toString())),
                );
              },
            ),
            if (filtered.length > 4)
              _buildViewAllButton(filtered, allHubs),
          ],
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    const style = TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: Color(0xFF9CA3AF),
        letterSpacing: 0.8);
    return Container(
      color: const Color(0xFFFAFAFA),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: const [
          Expanded(flex: 3, child: Text('HUB DETAILS', style: style)),
          Expanded(flex: 2, child: Text('MANAGER', style: style)),
          Expanded(child: Text('WORKFORCE', style: style)),
          Expanded(child: Text('ORDERS', style: style)),
          Expanded(child: Text('STATUS', style: style)),
          SizedBox(width: 80, child: Text('ACTIONS', style: style, textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.search_off_rounded,
                size: 36, color: Color(0xFFD1D5DB)),
            const SizedBox(height: 10),
            const Text('No hubs found',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280))),
            const SizedBox(height: 4),
            const Text('Try adjusting your search or filter',
                style: TextStyle(
                    fontSize: 12, color: Color(0xFF9CA3AF))),
            const SizedBox(height: 14),
            TextButton(
              onPressed: () =>
                  setState(() {
                    _searchQuery = '';
                    _filterStatus = -1;
                  }),
              child: const Text('Clear filters',
                  style: TextStyle(color: ColorConst.primaryGreen)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewAllButton(List<Hubs> filtered, List<Hubs> allHubs) {
    return Column(
      children: [
        const Divider(height: 1, color: Color(0xFFF3F4F6)),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Showing 4 of ${filtered.length}  ·  ',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF9CA3AF))),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AllHubListFullScreen(hubs: allHubs),
                  ),
                ),
                child: const Text('View All Hubs →',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ColorConst.primaryGreen)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────────────────────

class _StatData {
  final String title;
  final String value;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final Color valueColor;
  final String? badge;
  final Color? badgeColor;

  const _StatData({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.valueColor,
    this.badge,
    this.badgeColor,
  });
}

class _StatCard extends StatelessWidget {
  final _StatData data;
  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: data.iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: data.iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.title,
                    style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(data.value,
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: data.valueColor,
                            letterSpacing: -0.5)),
                    if (data.badge != null) ...[
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: (data.badgeColor ?? Colors.grey)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(data.badge!,
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: data.badgeColor ?? Colors.grey)),
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

class _HubFilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _HubFilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    this.color = const Color(0xFF374151),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.08)
              : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected
                  ? color.withValues(alpha: 0.35)
                  : const Color(0xFFE5E7EB)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected ? color : const Color(0xFF6B7280))),
            const SizedBox(width: 5),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
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

// ── Mobile Hub Card ───────────────────────────────────────────────────────────

class _HubMobileCard extends StatelessWidget {
  final Hubs hub;
  final VoidCallback onView;
  final VoidCallback onEdit;

  const _HubMobileCard({
    required this.hub,
    required this.onView,
    required this.onEdit,
  });

  bool get _isActive => hub.status == 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isActive
              ? const Color(0xFF16A34A).withValues(alpha: 0.15)
              : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          // Accent top bar
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: _isActive
                  ? const Color(0xFF16A34A).withValues(alpha: 0.5)
                  : const Color(0xFFE5E7EB),
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hub info + status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hub avatar
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: _isActive
                            ? const LinearGradient(
                          colors: [
                            Color(0xFF16A34A),
                            Color(0xFF15803D)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                            : null,
                        color: _isActive ? null : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.hub_outlined,
                          color:
                          _isActive ? Colors.white : const Color(0xFF9CA3AF),
                          size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  hub.hubName ?? '—',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: Color(0xFF111827),
                                      letterSpacing: -0.2),
                                ),
                              ),
                              _StatusPill(isActive: _isActive),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 11, color: Color(0xFF9CA3AF)),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  hub.address ?? '—',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF6B7280)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text('Hub #${hub.hubId}',
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF9CA3AF),
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF3F4F6)),
                const SizedBox(height: 12),

                // Manager row
                _ManagerRow(hub: hub),

                const SizedBox(height: 10),

                // Metrics row
                Row(
                  children: [
                    Expanded(
                        child: _MetricTile(
                          icon: Icons.pedal_bike_outlined,
                          value: '${hub.deliveryBoys ?? 0}',
                          label: 'Delivery Boys',
                          iconColor: const Color(0xFFEA580C),
                          iconBg: const Color(0xFFFFF7ED),
                        )),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _MetricTile(
                          icon: Icons.receipt_long_outlined,
                          value: '${hub.activeOrders ?? 0}',
                          label: 'Active Orders',
                          iconColor: const Color(0xFF7C3AED),
                          iconBg: const Color(0xFFF5F3FF),
                        )),
                  ],
                ),

                const SizedBox(height: 12),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        label: 'View Details',
                        icon: Icons.visibility_outlined,
                        onTap: onView,
                        primary: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ActionButton(
                        label: 'Edit Hub',
                        icon: Icons.edit_outlined,
                        onTap: onEdit,
                        primary: false,
                      ),
                    ),
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

class _HubDesktopRow extends StatelessWidget {
  final Hubs hub;
  final VoidCallback onView;
  final VoidCallback onEdit;

  const _HubDesktopRow({
    required this.hub,
    required this.onView,
    required this.onEdit,
  });

  bool get _isActive => hub.status == 1;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          SizedBox(
            width: Sizes.screenWidth*0.272,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hub.hubName.toUpperCase() ?? "-",
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: ColorConst.textBlack)),
                SizedBox(height: Sizes.screenHeight*0.001),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 10, color: ColorConst.textGrey),
                    SizedBox(width: Sizes.screenWidth*0.002),
                    Text(hub.address ?? '—',
                        style: const TextStyle(
                            fontSize: 11,
                            color: ColorConst.textGrey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            width: Sizes.screenWidth*0.17,
              child: _ManagerCell(hub: hub)),
          SizedBox(width: Sizes.screenWidth*0.014),
          SizedBox(
            width: Sizes.screenWidth*0.045,
            child: Center(
              child: Text('${hub.deliveryBoys ?? 0}',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151))),
            ),
          ),
          SizedBox(width: Sizes.screenWidth*0.04),
          // Orders
          SizedBox(
            width: Sizes.screenWidth*0.035,
            child: Center(
              child: Text('${hub.activeOrders ?? 0}',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151))),
            ),
          ),
          SizedBox(width: Sizes.screenWidth*0.044),
          // Status
          SizedBox(
              width: Sizes.screenWidth*0.06,
              child: _StatusPill(isActive: _isActive)),
          Spacer(),
          // Actions
          SizedBox(
            width: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _IconBtn(
                    icon: Icons.visibility_outlined,
                    color: const Color(0xFF2563EB),
                    onTap: onView),
                const SizedBox(width: 8),
                _IconBtn(
                    icon: Icons.edit_outlined,
                    color: const Color(0xFF6B7280),
                    onTap: onEdit),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool isActive;
  const _StatusPill({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final color =
    isActive ? const Color(0xFF16A34A) : const Color(0xFF9CA3AF);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                  color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ],
      ),
    );
  }
}

class _ManagerRow extends StatelessWidget {
  final Hubs hub;
  const _ManagerRow({required this.hub});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.person_outline_rounded,
              size: 15, color: Color(0xFF2563EB)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(hub.managerName ?? '—',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827))),
              if (hub.managerPhone != null)
                Text(hub.managerPhone!,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF9CA3AF))),
            ],
          ),
        ),
      ],
    );
  }
}

class _ManagerCell extends StatelessWidget {
  final Hubs hub;
  const _ManagerCell({required this.hub});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(hub.managerName ?? '—',
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        if (hub.managerPhone != null)
          Text(hub.managerPhone!,
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFF9CA3AF))),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;
  final Color iconBg;

  const _MetricTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 14, color: iconColor),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                      letterSpacing: -0.3)),
              Text(label,
                  style: const TextStyle(
                      fontSize: 10, color: Color(0xFF9CA3AF))),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool primary;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: primary
              ? ColorConst.primaryGreen
              : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(10),
          border: primary
              ? null
              : Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 14,
                color: primary
                    ? Colors.white
                    : const Color(0xFF374151)),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: primary
                        ? Colors.white
                        : const Color(0xFF374151))),
          ],
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _IconBtn(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 15, color: color),
      ),
    );
  }
}