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

class _CityHubHistoryScreenState extends State<CityHubHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cityHubHistory = Provider.of<CityStockViewModel>(context,listen: false);
      cityHubHistory.cityHubHistoryApi(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.bgColor,
      appBar: _buildAppBar(context),
      body: Consumer<CityStockViewModel>(
        builder: (context, vm, _) {
          // ── Loading state ──────────────────────────────────────────
          if (vm.historyLoading) {
            return const Center(
              child: CircularProgressIndicator(color: ColorConst.primaryGreen),
            );
          }

          // ── Empty / null state ─────────────────────────────────────
          final groups = vm.hubGroups;
          if (groups.isEmpty) {
            return _buildEmptyState(context, vm);
          }

          // ── Summary stats ──────────────────────────────────────────
          final totalHubs = groups.length;
          final activeHubs = groups.where((g) => g.hasProducts).length;
          final totalSent =
          groups.fold<int>(0, (s, g) => s + g.totalStockSent);

          return Column(
            children: [
              _buildSummaryBanner(totalHubs, activeHubs, totalSent),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: groups.length,
                  itemBuilder: (_, i) => _HubCard(group: groups[i]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: ColorConst.primaryGreen,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hub Transfer History',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          Text('City → Hub stock movements',
              style: TextStyle(color: Colors.white, fontSize: 11)),
        ],
      ),
      actions: [
        Consumer<CityStockViewModel>(
          builder: (ctx, vm, _) => IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () => vm.cityHubHistoryApi(ctx),
            tooltip: 'Refresh',
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ── Summary Banner ────────────────────────────────────────────────────────

  Widget _buildSummaryBanner(int totalHubs, int activeHubs, int totalSent) {
    return Container(
      color: ColorConst.primaryExtraLightGreen,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
      child: Row(
        children: [
          _bannerStat('Total Hubs', '$totalHubs', Icons.hub_outlined),
          _bannerDivider(),
          _bannerStat('Active', '$activeHubs',
              Icons.check_circle_outline_rounded),
          _bannerDivider(),
          _bannerStat('Units Sent', '$totalSent', Icons.send_rounded),
        ],
      ),
    );
  }

  Widget _bannerStat(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: ColorConst.primaryGreen, size: 18),
          SizedBox(height: Sizes.screenHeight*0.01),
          Text(value,
              style: const TextStyle(
                  color: ColorConst.primaryGreen,
                  fontSize: 22,
                  fontWeight: FontWeight.w800)),
          Text(label,
              style:
              const TextStyle(color: ColorConst.primaryGreen, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _bannerDivider() => Container(
    width: 1,
    height: 42,
    color: Colors.white.withValues(alpha: 0.15),
  );


  Widget _buildEmptyState(BuildContext context, CityStockViewModel vm) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          const Text('No history found',
              style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text('No transfers have been made yet.',
              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: () => vm.cityHubHistoryApi(context),
            icon: const Icon(Icons.refresh_rounded,
                color: ColorConst.primaryGreen, size: 18),
            label: const Text('Retry',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}


class _HubCard extends StatefulWidget {
  final HubGroup group;
  const _HubCard({required this.group});

  @override
  State<_HubCard> createState() => _HubCardState();
}

class _HubCardState extends State<_HubCard> {
  bool _expanded = true;

  Color get _statusColor =>
      widget.group.hasProducts
          ? ColorConst.primaryGreen
          : const Color(0xFF9CA3AF);

  String get _statusLabel =>
      widget.group.hasProducts ? 'Active' : 'No Stock';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha:0.05),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: _expanded
                ? const BorderRadius.vertical(top: Radius.circular(16))
                : BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Hub ID avatar
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: ColorConst.primaryLightGreen.withValues(alpha:0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'H${widget.group.hubId}',
                        style: const TextStyle(
                            color: ColorConst.primaryGreen,
                            fontWeight: FontWeight.w800,
                            fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Hub name + stats
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
                                    color: Color(0xFF111827)),
                              ),
                            ),
                            _StatusChip(
                                label: _statusLabel,
                                color: _statusColor),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            _miniStat(Icons.inventory_2_outlined,
                                '${widget.group.productCount} products'),
                            const SizedBox(width: 12),
                            _miniStat(Icons.send_rounded,
                                '${widget.group.totalStockSent.toString()} sent'),
                            const SizedBox(width: 12),
                            _miniStat(Icons.warehouse_outlined,
                                '${widget.group.totalCurrentStock.toString()} in stock'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Chevron
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF9CA3AF), size: 22),
                  ),
                ],
              ),
            ),
          ),

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
    if (!widget.group.hasProducts) {
      return Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: const Column(
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 36, color: Color(0xFFD1D5DB)),
            SizedBox(height: 8),
            Text('No stock assigned yet',
                style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
            SizedBox(height: 4),
            Text('This hub has not received any products.',
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(
        children: [
          const Divider(color: Color(0xFFF3F4F6), height: 1),
          const SizedBox(height: 10),
          // Each product name group
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

  Widget _miniStat(IconData icon, String label) => Row(
    children: [
      Icon(icon, size: 12, color: const Color(0xFF6B7280)),
      const SizedBox(width: 3),
      Text(label,
          style: const TextStyle(
              fontSize: 11, color: Color(0xFF6B7280))),
    ],
  );
}


class _ProductGroup extends StatelessWidget {
  final String productName;
  final List<CityHubHistoryData> variants;

  const _ProductGroup(
      {required this.productName, required this.variants});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product name header
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.shopping_bag_outlined,
                      size: 14, color: Color(0xFF2563EB)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    productName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF1E3A5F)),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          // One row per variant
          ...variants.map((v) => _VariantRow(item: v)),
        ],
      ),
    );
  }
}


class _VariantRow extends StatelessWidget {
  final CityHubHistoryData item;
  const _VariantRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final stock = item.hubCurrentStock ?? 0;
    final sent = item.totalSent;
    final isOutOfStock = stock == 0;
    final stockColor = isOutOfStock
        ? const Color(0xFFDC2626)
        : const Color(0xFF059669);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          // Variant tag
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              item.variant ?? 'Default',
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151)),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // In Hub stock
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('In Hub',
                        style: TextStyle(
                            fontSize: 10, color: Color(0xFF9CA3AF))),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text('$stock',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: stockColor)),
                        if (isOutOfStock) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('Out',
                                style: TextStyle(
                                    fontSize: 9,
                                    color: Color(0xFFDC2626),
                                    fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),

                // Divider
                Container(
                    width: 1,
                    height: 28,
                    color: const Color(0xFFE5E7EB)),

                // Total sent
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Total Sent',
                        style: TextStyle(
                            fontSize: 10, color: Color(0xFF9CA3AF))),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.send_rounded,
                            size: 11, color: Color(0xFF6B7280)),
                        const SizedBox(width: 3),
                        Text('$sent',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF374151))),
                      ],
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


class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha:0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 6,
              height: 6,
              decoration:
              BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }
}