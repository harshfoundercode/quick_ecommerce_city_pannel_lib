import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/hub_details_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/all_hub_list_view_model.dart';

class ViewHubDetails extends StatefulWidget {
  final String hubId;
  final String? hubName;

  const ViewHubDetails({
    super.key,
    required this.hubId,
    required this.hubName,
  });

  @override
  State<ViewHubDetails> createState() => _ViewHubDetailsState();
}

class _ViewHubDetailsState extends State<ViewHubDetails> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<AllHubViewModel>()
          .getHubDetailsDataApi(context, widget.hubId);
    });
  }

  String _formatDate(dynamic iso) {
    if (iso == null) return '—';
    try {
      final dt = DateTime.parse(iso.toString()).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return iso.toString();
    }
  }

  // status int → label + color
  _StatusMeta _disruptionStatus(dynamic status) {
    switch (status?.toString()) {
      case '0':
        return const _StatusMeta('Placed', Color(0xFF2563EB));
      case '1':
        return const _StatusMeta('Confirmed', Color(0xFF7C3AED));
      case '2':
        return const _StatusMeta('Picked', Color(0xFFD97706));
      case '3':
        return const _StatusMeta('Out for Delivery', Color(0xFF0891B2));
      case '4':
        return const _StatusMeta('Completed', Color(0xFF059669));
      case '5':
        return const _StatusMeta('Cancelled', Color(0xFFDC2626));
      default:
        return const _StatusMeta('Unknown', Color(0xFF9CA3AF));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.bgColor,
      appBar: _buildAppBar(),
      body: Consumer<AllHubViewModel>(
        builder: (context, vm, _) {
          if (vm.hubDetailsModel == null) {
            return const Center(
              child: CircularProgressIndicator(
                  color: ColorConst.primaryGreen),
            );
          }

          final d = vm.hubDetailsModel!.data;
          final hub = d?.hub;
          final perf = d?.performance;
          final drivers = d?.drivers;
          final topBoys = d?.topDeliveryBoys ?? [];
          final disruptions = d?.recentDisruptions ?? [];

          return RefreshIndicator(
            color: ColorConst.primaryGreen,
            onRefresh: () =>
                vm.getHubDetailsDataApi(context, widget.hubId),
            child: ListView(
              padding:
              const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                // ── Hub info card ────────────────────────────────
                _buildHubInfoCard(hub),
                const SizedBox(height: 14),

                // ── Performance grid ─────────────────────────────
                _sectionTitle(
                    'Performance', Icons.bar_chart_rounded),
                const SizedBox(height: 8),
                _buildPerformanceGrid(perf),
                const SizedBox(height: 14),

                // ── Driver stats ─────────────────────────────────
                _sectionTitle(
                    'Delivery Team', Icons.people_outline_rounded),
                const SizedBox(height: 8),
                _buildDriverStats(drivers),
                const SizedBox(height: 14),

                // ── Top delivery boys ────────────────────────────
                if (topBoys.isNotEmpty) ...[
                  _sectionTitle('Top Delivery Boys',
                      Icons.emoji_events_outlined),
                  const SizedBox(height: 8),
                  _buildTopBoysList(topBoys),
                  const SizedBox(height: 14),
                ],

                // ── Recent disruptions ───────────────────────────
                if (disruptions.isNotEmpty) ...[
                  _sectionTitle('Recent Disruptions',
                      Icons.warning_amber_rounded),
                  const SizedBox(height: 8),
                  _buildDisruptionsList(disruptions),
                ],

                if (topBoys.isEmpty && disruptions.isEmpty)
                  _buildNoDataNote(),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: ColorConst.primaryGreen,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.hubName ?? 'Hub Details',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700),
          ),
          const Text('Full hub overview',
              style:
              TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
      actions: [
        Consumer<AllHubViewModel>(
          builder: (ctx, vm, _) => IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: Colors.white, size: 22),
            onPressed: () =>
                vm.getHubDetailsDataApi(ctx, widget.hubId),
            tooltip: 'Refresh',
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ── Hub info card ──────────────────────────────────────────────────────────

  Widget _buildHubInfoCard(Hub? hub) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _card(),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color:
                  ColorConst.primaryGreen.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.store_outlined,
                    color: ColorConst.primaryGreen, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hub?.hubName?.toString() ?? '—',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                          color: Color(0xFF111827)),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.location_city_outlined,
                            size: 12,
                            color: Color(0xFF9CA3AF)),
                        const SizedBox(width: 4),
                        Text(
                          hub?.cityName?.toString() ?? '—',
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 12),
          _detailRow(Icons.location_on_outlined, 'Address',
              hub?.address?.toString() ?? '—'),
          const SizedBox(height: 8),
          _detailRow(Icons.person_outline_rounded, 'Manager',
              hub?.managerName?.toString() ?? '—'),
          const SizedBox(height: 8),
          _detailRow(Icons.phone_outlined, 'Contact',
              hub?.managerPhone?.toString() ?? '—'),
        ],
      ),
    );
  }

  // ── Performance grid ───────────────────────────────────────────────────────

  Widget _buildPerformanceGrid(Performance? perf) {
    final successRate =
        double.tryParse(perf?.successRate?.toString() ?? '0') ??
            0.0;
    final cancelRate =
        double.tryParse(
            perf?.cancellationRate?.toString() ?? '0') ??
            0.0;

    return Column(
      children: [
        // Row 1 — 3 stat tiles
        Row(
          children: [
            _statTile(
              label: 'Total Orders',
              value: '${perf?.totalOrders ?? 0}',
              icon: Icons.list_alt_rounded,
              color: const Color(0xFF2563EB),
            ),
            const SizedBox(width: 10),
            _statTile(
              label: 'Completed',
              value: '${perf?.completedDeliveries ?? 0}',
              icon: Icons.done_all_rounded,
              color: const Color(0xFF059669),
            ),
            const SizedBox(width: 10),
            _statTile(
              label: 'Cancelled',
              value: '${perf?.cancelledOrders ?? 0}',
              icon: Icons.cancel_outlined,
              color: const Color(0xFFDC2626),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Row 2 — success rate bar + avg delivery
        Row(
          children: [
            // Success rate bar
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: _card(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Success Rate',
                            style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w500)),
                        Text(
                          '${successRate.toStringAsFixed(1)}%',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: _rateColor(successRate)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value:
                        (successRate / 100).clamp(0.0, 1.0),
                        backgroundColor:
                        _rateColor(successRate)
                            .withValues(alpha:0.12),
                        valueColor: AlwaysStoppedAnimation<Color>(
                            _rateColor(successRate)),
                        minHeight: 7,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Cancellation: ',
                            style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF9CA3AF))),
                        Text(
                          '${cancelRate.toStringAsFixed(1)}%',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFDC2626)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Avg delivery time
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: _card(),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C3AED)
                            .withValues(alpha:0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                          Icons.access_time_rounded,
                          color: Color(0xFF7C3AED),
                          size: 20),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${perf?.avgDeliveryTime ?? 0}',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF7C3AED)),
                    ),
                    const Text('min avg',
                        style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF9CA3AF))),
                    const Text('Delivery Time',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF6B7280))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Driver stats ───────────────────────────────────────────────────────────

  Widget _buildDriverStats(Drivers? drivers) {
    final total = drivers?.totalDeliveryBoys ?? 0;
    final active = drivers?.activeBoys ?? 0;
    final inactive =
        (int.tryParse(total.toString()) ?? 0) -
            (int.tryParse(active.toString()) ?? 0);
    final activeRatio = (int.tryParse(total.toString()) ?? 0) > 0
        ? (int.tryParse(active.toString()) ?? 0) /
        (int.tryParse(total.toString()) ?? 1)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _card(),
      child: Column(
        children: [
          Row(
            children: [
              _driverTile('Total Boys', '$total',
                  Icons.group_outlined, const Color(0xFF2563EB)),
              const SizedBox(width: 10),
              _driverTile('Active', '$active',
                  Icons.check_circle_outline_rounded,
                  const Color(0xFF059669)),
              const SizedBox(width: 10),
              _driverTile('Inactive', '$inactive',
                  Icons.pause_circle_outline_rounded,
                  const Color(0xFF9CA3AF)),
            ],
          ),
          const SizedBox(height: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Active Ratio',
                      style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280))),
                  Text(
                    '${(activeRatio * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF059669)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: activeRatio.clamp(0.0, 1.0),
                  backgroundColor:
                  const Color(0xFF059669).withValues(alpha:0.12),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF059669)),
                  minHeight: 7,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _driverTile(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha:0.07),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 5),
            Text(value,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: color)),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 10, color: Color(0xFF6B7280))),
          ],
        ),
      ),
    );
  }

  // ── Top delivery boys ──────────────────────────────────────────────────────

  Widget _buildTopBoysList(List<TopDeliveryBoys> boys) {
    return Container(
      decoration: _card(),
      child: Column(
        children: List.generate(boys.length, (i) {
          final boy = boys[i];
          final isLast = i == boys.length - 1;
          final rank = i + 1;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    // Rank badge
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _rankColor(rank).withValues(alpha:0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '#$rank',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: _rankColor(rank)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Avatar initials
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: ColorConst.primaryGreen
                          .withValues(alpha:0.12),
                      child: Text(
                        _initials(boy.name?.toString() ?? '?'),
                        style: TextStyle(
                            color: ColorConst.primaryGreen,
                            fontWeight: FontWeight.w700,
                            fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Name + phone
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            boy.name?.toString() ?? '—',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF111827)),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.phone_outlined,
                                  size: 11,
                                  color: Color(0xFF9CA3AF)),
                              const SizedBox(width: 3),
                              Text(
                                boy.phone?.toString() ?? '—',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF6B7280)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Deliveries count
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: ColorConst.primaryGreen
                            .withValues(alpha:0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${boy.totalDeliveries ?? 0}',
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: ColorConst.primaryGreen),
                          ),
                          const Text('deliveries',
                              style: TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFF6B7280))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(
                    height: 1,
                    indent: 14,
                    endIndent: 14,
                    color: Color(0xFFF3F4F6)),
            ],
          );
        }),
      ),
    );
  }

  // ── Recent disruptions ─────────────────────────────────────────────────────

  Widget _buildDisruptionsList(List<RecentDisruptions> list) {
    return Container(
      decoration: _card(),
      child: Column(
        children: List.generate(list.length, (i) {
          final item = list[i];
          final isLast = i == list.length - 1;
          final meta = _disruptionStatus(item.status);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: meta.color.withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.warning_amber_rounded,
                          size: 16, color: meta.color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.orderNo?.toString() ?? '—',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: Color(0xFF111827)),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(
                                  Icons.access_time_rounded,
                                  size: 11,
                                  color: Color(0xFF9CA3AF)),
                              const SizedBox(width: 3),
                              Text(
                                _formatDate(item.createdAt),
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF9CA3AF)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _StatusChip(meta: meta),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(
                    height: 1,
                    indent: 14,
                    endIndent: 14,
                    color: Color(0xFFF3F4F6)),
            ],
          );
        }),
      ),
    );
  }

  // ── No data note ───────────────────────────────────────────────────────────

  Widget _buildNoDataNote() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(20),
      decoration: _card(),
      child: const Column(
        children: [
          Icon(Icons.info_outline_rounded,
              size: 36, color: Color(0xFFD1D5DB)),
          SizedBox(height: 8),
          Text('No additional data available',
              style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
        ],
      ),
    );
  }

  // ── Shared helpers ─────────────────────────────────────────────────────────

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: ColorConst.primaryGreen),
        const SizedBox(width: 7),
        Text(title,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E3A5F))),
      ],
    );
  }

  Widget _statTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 12),
        decoration: _card(),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 5),
            Text(value,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: color)),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 10, color: Color(0xFF9CA3AF))),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 8),
        Text('$label: ',
            style: const TextStyle(
                fontSize: 12, color: Color(0xFF6B7280))),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827))),
        ),
      ],
    );
  }

  BoxDecoration _card() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: Colors.grey.shade100),
    boxShadow: [
      BoxShadow(
          color: Colors.black.withValues(alpha:0.04),
          blurRadius: 8,
          offset: const Offset(0, 2)),
    ],
  );

  Color _rateColor(double rate) {
    if (rate >= 80) return const Color(0xFF059669);
    if (rate >= 50) return const Color(0xFFD97706);
    return const Color(0xFFDC2626);
  }

  Color _rankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFD97706); // gold
      case 2:
        return const Color(0xFF6B7280); // silver
      case 3:
        return const Color(0xFFB45309); // bronze
      default:
        return const Color(0xFF2563EB);
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}

// ─── Status chip ──────────────────────────────────────────────────────────────

class _StatusMeta {
  final String label;
  final Color color;
  const _StatusMeta(this.label, this.color);
}

class _StatusChip extends StatelessWidget {
  final _StatusMeta meta;
  const _StatusChip({required this.meta});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: meta.color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: meta.color.withValues(alpha:0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                  color: meta.color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(meta.label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: meta.color)),
        ],
      ),
    );
  }
}