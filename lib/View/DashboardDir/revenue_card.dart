import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/dialog_box.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/dashboard_model.dart';

class RevenueCard extends StatefulWidget {
  final List<Hubs>? dashboardHubData;
  final Summary dashboardSummaryData;

  const RevenueCard({
    super.key,
    required this.dashboardHubData,
    required this.dashboardSummaryData,
  });

  @override
  State<RevenueCard> createState() => _RevenueCardState();
}

class _RevenueCardState extends State<RevenueCard>
    with SingleTickerProviderStateMixin {

  late AnimationController _barCtrl;
  late Animation<double>   _barAnim;

  @override
  void initState() {
    super.initState();
    _barCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _barAnim = CurvedAnimation(
        parent: _barCtrl, curve: Curves.easeOutCubic);
    _barCtrl.forward();
  }

  @override
  void dispose() {
    _barCtrl.dispose();
    super.dispose();
  }

  // ── helpers ───────────────────────────────────────────────────────────────

  double _revenue(Hubs h) =>
      double.tryParse(h.revenue ?? '0') ?? 0.0;

  String _formatRevenue(double v) {
    if (v >= 100000) return '₹${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000)   return '₹${(v / 1000).toStringAsFixed(1)}K';
    return '₹${v.toStringAsFixed(0)}';
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final hubs        = widget.dashboardHubData ?? [];
    final displayList = hubs.length > 4 ? hubs.take(4).toList() : hubs;
    final totalRev    = double.tryParse(
        widget.dashboardSummaryData.revenue ?? '0') ?? 0.0;
    final maxRevenue  = hubs.isEmpty
        ? 1.0
        : hubs
        .map(_revenue)
        .reduce((a, b) => a > b ? a : b)
        .clamp(1.0, double.infinity);

    // top hub
    Hubs? topHub;
    if (hubs.isNotEmpty) {
      topHub = hubs.reduce(
              (a, b) => _revenue(a) > _revenue(b) ? a : b);
    }

    return _CardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Header ──────────────────────────────────────────────
          Row(children: [
            // Icon badge
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: ColorConst.primaryGreen,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: ColorConst.primaryLightGreen.withValues(alpha:0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.bar_chart_rounded,
                  size: 16, color: Colors.white),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Revenue Analytics',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: ColorConst.textBlack,
                            letterSpacing: 0.2)),
                    Text('Weekly earning performance',
                        style: TextStyle(
                            fontSize: 11, color: ColorConst.textBlack)),
                  ]),
            ),
            // View all
            if (hubs.length > 4)
              GestureDetector(
                onTap: () => _showAllHubsDrawer(
                    context, hubs, maxRevenue),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: ColorConst.primaryExtraLightGreen,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: ColorConst.primaryExtraLightGreen),
                  ),
                  child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('View All',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: ColorConst.black)),
                      ]),
                ),
              ),
          ]),

          const SizedBox(height: 14),

          // ── Total revenue ────────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total Revenue',
                  style: TextStyle(
                      fontSize: 11,
                      color: ColorConst.textBlack,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 3),
              Text(
                _formatRevenue(totalRev),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: ColorConst.textBlack,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Top hub highlight ────────────────────────────────────
          if (topHub != null)
            _TopHubBanner(
              hub: topHub,
              revenue: _revenue(topHub),
              formatRevenue: _formatRevenue,
            ),

          const SizedBox(height: 14),

          // ── Bar chart ────────────────────────────────────────────
          const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Hub Performance',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: ColorConst.textSecondary)),
                Text('This week',
                    style: TextStyle(
                        fontSize: 8, color: ColorConst.textBlack)),
              ]),

          const SizedBox(height: 10),

          Expanded(
            child: AnimatedBuilder(
              animation: _barAnim,
              builder: (_, ii) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(
                    displayList.length,
                        (i) {
                      final hub      = displayList[i];
                      final rev      = _revenue(hub);
                      final isTopHub = topHub != null &&
                          hub.hubId == topHub.hubId;
                      final maxH = Sizes.screenHeight * 0.065;
                      final barH = maxRevenue == 0
                          ? 8.0
                          : (rev / maxRevenue) *
                          maxH *
                          _barAnim.value;

                      return _HubBar(
                        hub: hub,
                        revenue: rev,
                        barHeight: barH.clamp(8.0, maxH),
                        isTop: isTopHub,
                        formatRevenue: _formatRevenue,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ── Legend ───────────────────────────────────────────────
          Row(children: [
            _LegendDot(color: ColorConst.primaryLightGreen, label: 'Revenue'),
            const SizedBox(width: 14),
            _LegendDot(color: ColorConst.criticalYellowLight, label: 'Top Hub'),
            const SizedBox(width: 14),
            _LegendDot(color: Color(0xFFE5E7EB), label: 'No revenue'),
          ]),
        ],
      ),
    );
  }

  // ── All hubs drawer ───────────────────────────────────────────────────────

  void _showAllHubsDrawer(
      BuildContext context, List<Hubs> hubs, double maxRevenue) {
    openRightDrawer(
      context,
      Material(
        color: Colors.white,
        child: Container(
          width: Sizes.screenWidth * 0.42,
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            // Header
            Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ColorConst.primaryExtraLightGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.hub_rounded,
                    size: 16, color: ColorConst.primaryGreen),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text('All Hubs Revenue',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: ColorConst.textBlack)),
                      Text('Performance overview',
                          style: TextStyle(
                              fontSize: 11,
                              color: ColorConst.textBlack)),
                    ]),
              ),
            ]),

            const SizedBox(height: 16),
            const Divider(color: ColorConst.borderColor),
            const SizedBox(height: 8),

            // Hub list with bars
            Expanded(
              child: ListView.separated(
                itemCount: hubs.length,
                separatorBuilder: (_, ii) =>
                const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final hub = hubs[i];
                  final rev = double.tryParse(
                      hub.revenue ?? '0') ?? 0.0;
                  final progress = maxRevenue == 0
                      ? 0.0
                      : (rev / maxRevenue).clamp(0.0, 1.0);
                  final isTop = hubs
                      .map((h) =>
                  double.tryParse(h.revenue ?? '0') ?? 0.0)
                      .reduce((a, b) => a > b ? a : b) ==
                      rev;

                  return _DrawerHubRow(
                    hub: hub,
                    revenue: rev,
                    progress: progress,
                    isTop: isTop,
                    formatRevenue: (v) {
                      if (v >= 100000) {
                        return '₹${(v / 100000).toStringAsFixed(1)}L';
                      }
                      if (v >= 1000) {
                        return '₹${(v / 1000).toStringAsFixed(1)}K';
                      }
                      return '₹${v.toStringAsFixed(0)}';
                    },
                  );
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─── Hub bar (chart column) ───────────────────────────────────────────────────

class _HubBar extends StatelessWidget {
  final Hubs hub;
  final double revenue;
  final double barHeight;
  final bool isTop;
  final String Function(double) formatRevenue;

  const _HubBar({
    required this.hub,
    required this.revenue,
    required this.barHeight,
    required this.isTop,
    required this.formatRevenue,
  });

  @override
  Widget build(BuildContext context) {
    final hasRev = revenue > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Revenue label
          Text(
            formatRevenue(revenue),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isTop ? ColorConst.primaryLightGreen : ColorConst.textSecondary,
            ),
          ),

          const SizedBox(height: 5),

          // Bar
          Container(
            width: isTop ? 22 : 16,
            height: barHeight,
            decoration: BoxDecoration(
              gradient: hasRev
                  ? LinearGradient(
                colors: isTop
                    ? [ColorConst.primaryGreen, ColorConst.primaryGreen]
                    : [ColorConst.primaryLightGreen, ColorConst.primaryLightGreen],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              )
                  : null,
              color: hasRev ? null : Colors.grey.shade200,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8)),
              boxShadow: isTop && hasRev
                  ? [BoxShadow(
                color: ColorConst.primaryLightGreen.withValues(alpha:0.35),
                blurRadius: 8,
                offset: const Offset(0, -2),
              )]
                  : [],
            ),
          ),

          // Crown for top hub

          const SizedBox(height: 4),

          // Hub name
          SizedBox(
            width: 52,
            child: Text(
              hub.hubName ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                fontWeight:
                isTop ? FontWeight.w700 : FontWeight.w500,
                color: isTop ? ColorConst.primaryLightGreen : ColorConst.textBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Top hub banner ───────────────────────────────────────────────────────────

class _TopHubBanner extends StatelessWidget {
  final Hubs hub;
  final double revenue;
  final String Function(double) formatRevenue;

  const _TopHubBanner({
    required this.hub,
    required this.revenue,
    required this.formatRevenue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: ColorConst.primaryGreen,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: ColorConst.primaryLightGreen.withValues(alpha:0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(children: [
        // Crown icon
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha:0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.workspace_premium_rounded,
              size: 16, color: ColorConst.white),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Top Performing Hub',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.4)),
                const SizedBox(height: 2),
                Text(
                  hub.hubName ?? '—',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ]),
        ),
        // Revenue only
        Text(
          formatRevenue(revenue),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ]),
    );
  }
}

// ─── Drawer hub row ───────────────────────────────────────────────────────────

class _DrawerHubRow extends StatelessWidget {
  final Hubs hub;
  final double revenue;
  final double progress;
  final bool isTop;
  final String Function(double) formatRevenue;

  const _DrawerHubRow({
    required this.hub,
    required this.revenue,
    required this.progress,
    required this.isTop,
    required this.formatRevenue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: isTop ? ColorConst.primaryExtraLightGreen : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTop ? ColorConst.primaryExtraLightGreen : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              if (isTop)
                const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: Icon(Icons.workspace_premium_rounded,
                      size: 14, color: ColorConst.criticalYellow),
                ),
              Expanded(
                child: Text(
                  hub.hubName ?? '—',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isTop ? ColorConst.black : ColorConst.textSecondary,
                  ),
                ),
              ),
              Text(
                formatRevenue(revenue),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isTop ? ColorConst.black : ColorConst.textSecondary,
                ),
              ),
            ]),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                backgroundColor: const Color(0xFFE5E7EB),
                valueColor: AlwaysStoppedAnimation<Color>(
                    isTop ? ColorConst.primaryExtraLightGreen : ColorConst.primaryLightGreen),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${(progress * 100).toStringAsFixed(0)}% of top revenue',
              style: const TextStyle(fontSize: 9, color: ColorConst.textBlack),
            ),
          ]),
    );
  }
}

// ─── Legend dot ───────────────────────────────────────────────────────────────

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 8, height: 8,
        decoration: BoxDecoration(
            color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 4),
      Text(label,
          style: const TextStyle(
              fontSize: 10, color: ColorConst.textBlack)),
    ]);
  }
}

// ─── Card wrapper ─────────────────────────────────────────────────────────────

class _CardWrapper extends StatelessWidget {
  final Widget child;
  const _CardWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Sizes.screenHeight * 0.52,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
