import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/city_request_history_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/city_stock_view_model.dart';

class CityRequestHistoryScreen extends StatefulWidget {
  const CityRequestHistoryScreen({super.key});

  @override
  State<CityRequestHistoryScreen> createState() =>
      _CityRequestHistoryScreenState();
}

class _CityRequestHistoryScreenState extends State<CityRequestHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cityStockData = Provider.of<CityStockViewModel>(context,listen: false);
      cityStockData.cityRequestHistoryApi(context);
    });
  }

  /// Groups flat list by request id
  List<_RequestGroup> _buildGroups(List<CityRequestHistoryData> raw) {
    final Map<int, _RequestGroup> map = {};
    for (final item in raw) {
      final id = item.id ?? 0;
      if (!map.containsKey(id)) {
        map[id] = _RequestGroup(
          id: id,
          status: item.status ?? 0,
          remarks: item.remarks,
          createdAt: item.createdAt,
          items: [],
        );
      }
      map[id]!.items.add(_RequestItem(
        name: item.name ?? '—',
        quantity: item.quantity ?? 0,
      ));
    }
    // Sort by id descending (latest first)
    final groups = map.values.toList()
      ..sort((a, b) => b.id.compareTo(a.id));
    return groups;
  }

  String _formatDate(String? iso) {
    if (iso == null) return '—';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.bgColor,
      appBar: _buildAppBar(context),
      body: Consumer<CityStockViewModel>(
        builder: (context, vm, _) {
          // ── Loading ──────────────────────────────────────────────────
          if (vm.adminHistoryLoading) {
            return const Center(
              child: CircularProgressIndicator(color: ColorConst.primaryGreen),
            );
          }

          final raw = vm.cityRequestHistoryModel?.data ?? [];

          // ── Empty ────────────────────────────────────────────────────
          if (raw.isEmpty) {
            return _buildEmptyState(context, vm);
          }

          final groups = _buildGroups(raw);

          // ── Summary banner ───────────────────────────────────────────
          final totalRequests = groups.length;
          final pendingCount =
              groups.where((g) => g.status == 0).length;
          final totalItems =
          raw.fold<int>(0, (s, i) => s + int.tryParse(i.quantity?.toString() ?? "0")!);

          return Column(
            children: [
              _buildSummaryBanner(
                  totalRequests, pendingCount, totalItems),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: groups.length,
                  itemBuilder: (_, i) => _RequestCard(
                    group: groups[i],
                    formatDate: _formatDate,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: ColorConst.primaryGreen,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Stock Requests',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          Text('Requests sent to admin',
              style:
              TextStyle(color: Colors.white, fontSize: 11)),
        ],
      ),
      actions: [
        Consumer<CityStockViewModel>(
          builder: (ctx, vm, _) => IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: Colors.white, size: 22),
            onPressed: () => vm.cityRequestHistoryApi(ctx),
            tooltip: 'Refresh',
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ── Summary Banner ─────────────────────────────────────────────────────────

  Widget _buildSummaryBanner(
      int totalRequests, int pendingCount, int totalItems) {
    return Container(
      color: ColorConst.primaryExtraLightGreen,
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 16),
      child: Row(
        children: [
          _bannerStat('Total Requests', '$totalRequests',
              Icons.list_alt_rounded),
          _bannerDivider(),
          _bannerStat(
              'Pending', '$pendingCount', Icons.hourglass_top_rounded),
          _bannerDivider(),
          _bannerStat('Total Units', '$totalItems',
              Icons.inventory_2_outlined),
        ],
      ),
    );
  }

  Widget _bannerStat(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: ColorConst.primaryGreen, size: 18),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: ColorConst.primaryGreen,
                  fontSize: 22,
                  fontWeight: FontWeight.w800)),
          Text(label,
              style: const TextStyle(
                  color: ColorConst.primaryGreen, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _bannerDivider() => Container(
    width: 1,
    height: 40,
    color: Colors.white.withValues(alpha: 0.15),
  );

  // ── Empty state ────────────────────────────────────────────────────────────

  Widget _buildEmptyState(
      BuildContext context, CityStockViewModel vm) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded,
              size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          const Text('No requests found',
              style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text('No stock requests have been sent to admin yet.',
              textAlign: TextAlign.center,
              style:
              TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: () => vm.cityRequestHistoryApi(context),
            icon: const Icon(Icons.refresh_rounded,
                color: ColorConst.primaryGreen, size: 18),
            label: const Text('Retry',
                style: TextStyle(color: ColorConst.primaryGreen)),
          ),
        ],
      ),
    );
  }
}

// ─── Request Card ─────────────────────────────────────────────────────────────

class _RequestCard extends StatefulWidget {
  final _RequestGroup group;
  final String Function(String?) formatDate;

  const _RequestCard({
    required this.group,
    required this.formatDate,
  });

  @override
  State<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<_RequestCard> {
  bool _expanded = true;

  _StatusMeta get _meta => _statusMeta(widget.group.status);

  @override
  Widget build(BuildContext context) {
    final totalQty = widget.group.items
        .fold<int>(0, (s, i) => s + i.quantity);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          // ── Header ─────────────────────────────────────────────────
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: _expanded
                ? const BorderRadius.vertical(top: Radius.circular(16))
                : BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Request ID avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _meta.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '#${widget.group.id}',
                        style: TextStyle(
                            color: _meta.color,
                            fontWeight: FontWeight.w800,
                            fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Request #${widget.group.id}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: Color(0xFF111827)),
                            ),
                            const Spacer(),
                            _StatusChip(meta: _meta),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            _miniStat(
                                Icons.inventory_2_outlined,
                                '${widget.group.items.length} products'),
                            const SizedBox(width: 12),
                            _miniStat(Icons.numbers_rounded,
                                '$totalQty units'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded,
                                size: 11,
                                color: Color(0xFF9CA3AF)),
                            const SizedBox(width: 3),
                            Text(
                              widget.formatDate(widget.group.createdAt),
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF9CA3AF)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Chevron
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF9CA3AF),
                        size: 22),
                  ),
                ],
              ),
            ),
          ),

          // ── Expandable body ────────────────────────────────────────
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildExpandedBody(),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedBody() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: Color(0xFFF3F4F6), height: 1),
          const SizedBox(height: 12),

          // ── Remarks ──────────────────────────────────────────────
          if (widget.group.remarks != null &&
              widget.group.remarks!.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.sticky_note_2_outlined,
                      size: 15, color: Color(0xFFD97706)),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      widget.group.remarks!,
                      style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF92400E),
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ── Product list ──────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: List.generate(widget.group.items.length, (i) {
                final item = widget.group.items[i];
                final isLast = i == widget.group.items.length - 1;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 11),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: ColorConst.primaryExtraLightGreen,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                                Icons.shopping_bag_outlined,
                                size: 15,
                                color: ColorConst.primaryGreen),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Color(0xFF111827)),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: ColorConst.primaryExtraLightGreen,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Qty: ${item.quantity}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: ColorConst.primaryGreen),
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
                          color: Color(0xFFE5E7EB)),
                  ],
                );
              }),
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

// ─── Status helpers ───────────────────────────────────────────────────────────

_StatusMeta _statusMeta(int status) {
  switch (status) {
    case 0:
      return const _StatusMeta(
          'Pending', Color(0xFFD97706), Icons.hourglass_top_rounded);
    case 1:
      return const _StatusMeta(
          'Approved', Color(0xFF059669), Icons.check_circle_outline_rounded);
    case 2:
      return const _StatusMeta(
          'Rejected', Color(0xFFDC2626), Icons.cancel_outlined);
    default:
      return const _StatusMeta(
          'Unknown', Color(0xFF9CA3AF), Icons.help_outline_rounded);
  }
}

class _StatusMeta {
  final String label;
  final Color color;
  final IconData icon;
  const _StatusMeta(this.label, this.color, this.icon);
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
        color: meta.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: meta.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(meta.icon, size: 11, color: meta.color),
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

// ─── Local grouped models (UI only) ──────────────────────────────────────────

class _RequestGroup {
  final int id;
  final int status;
  final String? remarks;
  final String? createdAt;
  final List<_RequestItem> items;

  _RequestGroup({
    required this.id,
    required this.status,
    this.remarks,
    this.createdAt,
    required this.items,
  });
}

class _RequestItem {
  final String name;
  final int quantity;
  const _RequestItem({required this.name, required this.quantity});
}