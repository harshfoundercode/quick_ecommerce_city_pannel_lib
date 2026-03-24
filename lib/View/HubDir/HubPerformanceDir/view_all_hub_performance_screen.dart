import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/app_button.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/tost_msg/custom_snackbar.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/dialog_box.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/hub_performance_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/HubDir/HubPerformanceDir/ViewAllOrderHubDir/view_all_order_specific_hub.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/hub_performance_view_model.dart';

class ViewAllHubPerformanceScreen extends StatefulWidget {
  final List<Hubs> hub;
  const ViewAllHubPerformanceScreen({super.key, required this.hub});

  @override
  State<ViewAllHubPerformanceScreen> createState() =>
      _ViewAllHubPerformanceScreenState();
}

class _ViewAllHubPerformanceScreenState
    extends State<ViewAllHubPerformanceScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Hubs> get _filteredHubs {
    if (_searchQuery.isEmpty) return widget.hub;
    return widget.hub
        .where((h) =>
        (h.hubName ?? '')
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  /// Derives a status from the hub's success rate
  _HubStatus _getStatus(Hubs hub) {
    final rate = hub.successRate ?? 0;
    if (rate >= 85) return _HubStatus.excellent;
    if (rate >= 60) return _HubStatus.good;
    if (rate >= 30) return _HubStatus.average;
    return _HubStatus.poor;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredHubs;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildSummaryRow(),
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: filtered.length,
              itemBuilder: (_, i) => _HubPerformanceCard(
                hub: filtered[i],
                status: _getStatus(filtered[i]),
                onViewOrders: () => openRightDrawer(
                  context,
                  ViewAllOrderSpecificHub(
                      hubName: filtered[i].hubName ?? '', hubId: filtered[i].hubId.toString(),),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: ColorConst.primaryGreen,
      elevation: 0,
      toolbarHeight: Sizes.screenHeight*0.1,
      leading: AppBackBtn(),
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hub Performance',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          Text('All hubs overview',
              style: TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
      actions: [
        Consumer<HubPerformanceViewModel>(
          builder: (ctx, vm, _) => IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: Colors.white, size: 22),
            tooltip: 'Refresh',
            onPressed: () {
              vm.getHubPerformanceDataApi(ctx);
              CustomSnackBar.show(ctx,
                  message: 'Refreshing data...',
                  type: SnackBarType.success);
            },
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ── Search bar ──────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      color: ColorConst.primaryLightGreen,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 14),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: const InputDecoration(
            hintText: 'Search hub by name...',
            hintStyle: TextStyle(color: Colors.white60, fontSize: 14),
            prefixIcon:
            Icon(Icons.search_rounded, color: Colors.white60, size: 20),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 11),
          ),
        ),
      ),
    );
  }

  // ── Summary strip ───────────────────────────────────────────────────────

  Widget _buildSummaryRow() {
    final hubs = widget.hub;
    final total = hubs.length;
    final avgRate = total == 0
        ? 0.0
        : hubs.fold<double>(0, (s, h) => s + (h.successRate ?? 0)) / total;

    final totalOrders =
    hubs.fold<int>(0, (s, h) => s + (int.tryParse(h.totalOrders.toString()) ?? 0));

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          _summaryTile('Total Hubs', '$total',
              Icons.hub_outlined, ColorConst.primaryGreen),
          const SizedBox(width: 10),
          _summaryTile('Avg. Success',
              '${avgRate.toStringAsFixed(1)}%',
              Icons.percent_rounded, const Color(0xFF2563EB)),
          const SizedBox(width: 10),
          _summaryTile('Total Orders', '$totalOrders',
              Icons.shopping_cart_outlined, const Color(0xFF7C3AED)),
        ],
      ),
    );
  }

  Widget _summaryTile(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha:0.04),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: color)),
                  Text(label,
                      style: const TextStyle(
                          fontSize: 10, color: Color(0xFF6B7280))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty state ─────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded,
              size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text('No hubs found for "$_searchQuery"',
              style: const TextStyle(
                  color: Color(0xFF6B7280), fontSize: 15)),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
            child: const Text('Clear search'),
          ),
        ],
      ),
    );
  }
}

// ─── Status enum ─────────────────────────────────────────────────────────────

enum _HubStatus { excellent, good, average, poor }

extension _HubStatusX on _HubStatus {
  String get label {
    switch (this) {
      case _HubStatus.excellent:
        return 'Excellent';
      case _HubStatus.good:
        return 'Good';
      case _HubStatus.average:
        return 'Average';
      case _HubStatus.poor:
        return 'Poor';
    }
  }

  Color get color {
    switch (this) {
      case _HubStatus.excellent:
        return const Color(0xFF059669);
      case _HubStatus.good:
        return const Color(0xFF2563EB);
      case _HubStatus.average:
        return const Color(0xFFD97706);
      case _HubStatus.poor:
        return const Color(0xFFDC2626);
    }
  }

  IconData get icon {
    switch (this) {
      case _HubStatus.excellent:
        return Icons.trending_up_rounded;
      case _HubStatus.good:
        return Icons.check_circle_outline_rounded;
      case _HubStatus.average:
        return Icons.remove_circle_outline_rounded;
      case _HubStatus.poor:
        return Icons.warning_amber_rounded;
    }
  }
}

// ─── Hub Performance Card ─────────────────────────────────────────────────────

class _HubPerformanceCard extends StatelessWidget {
  final Hubs hub;
  final _HubStatus status;
  final VoidCallback onViewOrders;

  const _HubPerformanceCard({
    required this.hub,
    required this.status,
    required this.onViewOrders,
  });

  @override
  Widget build(BuildContext context) {
    final successRate = (hub.successRate ?? 0).toDouble();
    final progress = (successRate / 100).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha:0.04),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        children: [
          // ── Card header ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hub icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color:
                    ColorConst.primaryGreen.withValues(alpha:0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.account_tree_outlined,
                      size: 20, color: ColorConst.primaryGreen),
                ),
                const SizedBox(width: 12),

                // Hub name + ID
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hub.hubName ?? 'Unknown Hub',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Color(0xFF111827)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ID: HUB${(hub.hubName ?? '').hashCode.abs() % 1000}',
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF9CA3AF)),
                      ),
                    ],
                  ),
                ),

                // Status chip
                _StatusChip(status: status),
              ],
            ),
          ),

          // ── Stats grid ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                _statCell(
                  label: 'Total Orders',
                  value: '${hub.totalOrders ?? 0}',
                  icon: Icons.shopping_cart_outlined,
                  color: const Color(0xFF2563EB),
                ),
                _verticalDivider(),
                _statCell(
                  label: 'Avg. Delivery',
                  value: '${hub.avgDeliveryTime ?? 0} min',
                  icon: Icons.access_time_rounded,
                  color: const Color(0xFF7C3AED),
                ),
                _verticalDivider(),
                _statCell(
                  label: 'Active Boys',
                  value: '${hub.activeBoys ?? 0}',
                  icon: Icons.pedal_bike_rounded,
                  color: const Color(0xFFD97706),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Success rate bar ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Success Rate',
                        style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w500)),
                    Text(
                      '${successRate.toStringAsFixed(1)}%',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: status.color),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor:
                    status.color.withValues(alpha:0.12),
                    valueColor:
                    AlwaysStoppedAnimation<Color>(status.color),
                    minHeight: 7,
                  ),
                ),
              ],
            ),
          ),

          // ── Footer ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onViewOrders,
                icon: Icon(Icons.visibility_outlined,
                    size: 16, color: ColorConst.primaryGreen),
                label: Text('View Orders',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ColorConst.primaryGreen)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  side: BorderSide(
                      color: ColorConst.primaryGreen.withValues(alpha:0.4)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCell({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 10, color: Color(0xFF9CA3AF))),
          ],
        ),
      ),
    );
  }

  Widget _verticalDivider() => Container(
    width: 1,
    height: 44,
    color: const Color(0xFFF3F4F6),
  );
}

// ─── Status Chip ─────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final _HubStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: status.color.withValues(alpha:0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 12, color: status.color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: status.color),
          ),
        ],
      ),
    );
  }
}