import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/city_hub_history_model.dart'
    show CityHubHistoryData, Transfers, Variants;
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/city_request_history_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/city_stock_view_model.dart';
import '../widgets/app_header.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchCtrl = TextEditingController();

  // Admin tab filters
  String _adminStatus = 'All';
  final List<String> _adminStatuses = [
    'All',
    'Pending',
    'Approved',
    'Rejected',
    'Fulfilled',
  ];

  // Hub tab filters
  String _hubStatus = 'All';
  final List<String> _hubStatuses = [
    'All',
    'Pending',
    'Received',
    'Disputed',
    'In Transit',
  ];

  String _sortBy = 'Newest';
  final List<String> _sortOptions = [
    'Newest',
    'Oldest',
    'Quantity: High',
    'Quantity: Low',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    final vm = context.read<CityStockViewModel>();
    vm.cityRequestHistoryApi(context);
    vm.cityHubHistoryApi(context);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppHeader(
          title: 'History',
          subtitle: 'Track all your requests and transfers',
          actions: [
            IconButton(
              onPressed: () {
                final vm = context.read<CityStockViewModel>();
                vm.cityRequestHistoryApi(context);
                vm.cityHubHistoryApi(context);
              },
              icon: Icon(Icons.refresh),
            ),
          ],
        ),
        Expanded(
          child: Column(
            children: [
              _buildTabBar(),
              _buildSearchAndFilters(),
              _buildStatusPills(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _AdminHistoryTab(
                      searchQuery: _searchCtrl.text,
                      selectedStatus: _adminStatus,
                      sortBy: _sortBy,
                    ),
                    _HubHistoryTab(
                      searchQuery: _searchCtrl.text,
                      selectedStatus: _hubStatus,
                      sortBy: _sortBy,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Segmented tab bar ─────────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: ColorConst.containerGrey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _tabSegment(0, 'Admin Requests'),
          _tabSegment(1, 'Hub Transfers'),
        ],
      ),
    );
  }

  Widget _tabSegment(int index, String label) {
    final isActive = _tabController.index == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabController.animateTo(index)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isActive ? ColorConst.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isActive ? Border.all(color: ColorConst.borderColor) : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? ColorConst.textPrimary : ColorConst.textGrey,
            ),
          ),
        ),
      ),
    );
  }

  // ── Search + sort row ─────────────────────────────────────────────
  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: [
          // Search
          Expanded(
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: ColorConst.white,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: ColorConst.borderColor),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(
                  color: ColorConst.textPrimary,
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  hintText: 'Search by name, ID...',
                  hintStyle: const TextStyle(
                    color: ColorConst.textGrey,
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: ColorConst.textGrey,
                    size: 17,
                  ),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: ColorConst.textGrey,
                            size: 15,
                          ),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Sort dropdown
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: ColorConst.white,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: ColorConst.borderColor),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _sortBy,
                icon: const Icon(
                  Icons.unfold_more,
                  color: ColorConst.textGrey,
                  size: 16,
                ),
                style: const TextStyle(
                  color: ColorConst.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                items: _sortOptions
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _sortBy = v!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Status pills row ──────────────────────────────────────────────
  Widget _buildStatusPills() {
    final isAdmin = _tabController.index == 0;
    final statuses = isAdmin ? _adminStatuses : _hubStatuses;
    final current = isAdmin ? _adminStatus : _hubStatus;

    return Container(
      height: 36,
      margin: const EdgeInsets.only(top: 10),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: statuses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final s = statuses[i];
          final active = current == s;
          final color = _pillColor(s);

          return GestureDetector(
            onTap: () => setState(() {
              if (isAdmin)
                _adminStatus = s;
              else
                _hubStatus = s;
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: active ? color.withOpacity(0.12) : ColorConst.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: active ? color : ColorConst.borderColor,
                  width: active ? 1.5 : 1,
                ),
              ),
              child: Text(
                s,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: active ? color : ColorConst.textGrey,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _pillColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return ColorConst.warning;
      case 'approved':
      case 'received':
        return ColorConst.success;
      case 'rejected':
      case 'disputed':
        return ColorConst.danger;
      case 'fulfilled':
      case 'in transit':
        return ColorConst.info;
      default:
        return ColorConst.primaryGreen;
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Admin History Tab
// ══════════════════════════════════════════════════════════════════════════════
class _AdminHistoryTab extends StatelessWidget {
  final String searchQuery;
  final String selectedStatus;
  final String sortBy;

  const _AdminHistoryTab({
    required this.searchQuery,
    required this.selectedStatus,
    required this.sortBy,
  });

  List<CityRequestHistoryData> _filterAndSort(
    List<CityRequestHistoryData> list,
  ) {
    var result = list.where((item) {
      final q = searchQuery.toLowerCase();
      final matchSearch =
          q.isEmpty ||
          '${item.id}'.toLowerCase().contains(q) ||
          '${item.name}'.toLowerCase().contains(q);
      final matchStatus =
          selectedStatus == 'All' ||
          '${item.status}'.toLowerCase() == selectedStatus.toLowerCase();
      return matchSearch && matchStatus;
    }).toList();

    result.sort((a, b) {
      switch (sortBy) {
        case 'Oldest':
          return _dt('${a.createdAt}').compareTo(_dt('${b.createdAt}'));
        case 'Quantity: High':
          return (int.tryParse('${b.quantity}') ?? 0).compareTo(
            int.tryParse('${a.quantity}') ?? 0,
          );
        case 'Quantity: Low':
          return (int.tryParse('${a.quantity}') ?? 0).compareTo(
            int.tryParse('${b.quantity}') ?? 0,
          );
        default:
          return _dt('${b.createdAt}').compareTo(_dt('${a.createdAt}'));
      }
    });
    return result;
  }

  DateTime _dt(String s) {
    try {
      return DateTime.parse(s);
    } catch (_) {
      return DateTime(2000);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CityStockViewModel>();

    if (vm.adminHistoryLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: ColorConst.primaryGreen,
          backgroundColor: ColorConst.white,
        ),
      );
    }

    final list = _filterAndSort(vm.cityRequestHistoryModel?.data ?? []);

    if (list.isEmpty) return _emptyState('No requests found');

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: list.length,
      itemBuilder: (_, i) => _RequestCard(item: list[i]),
    );
  }

  Widget _emptyState(String msg) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.inbox_outlined,
          size: 52,
          color: ColorConst.textGrey.withOpacity(0.3),
        ),
        const SizedBox(height: 12),
        Text(
          msg,
          style: const TextStyle(color: ColorConst.textSecondary, fontSize: 14),
        ),
      ],
    ),
  );
}

// ── Request Card ──────────────────────────────────────────────────────────────
class _RequestCard extends StatelessWidget {
  final CityRequestHistoryData item;
  const _RequestCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final status = '${item.status}';
    final color = _statusColor(status);
    final iconBg = color.withOpacity(0.1);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: ColorConst.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorConst.borderColor),
      ),
      child: Column(
        children: [
          // ── Main row ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.description_outlined,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),

                // Meta
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.name}',
                        style: const TextStyle(
                          color: ColorConst.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ID: #${item.id}',
                        style: const TextStyle(
                          color: ColorConst.textGrey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status badge
                _StatusBadge(status: status),
              ],
            ),
          ),

          // ── Footer ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(12, 7, 12, 7),
            decoration: BoxDecoration(
              color: ColorConst.containerGrey2,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
              border: Border(top: BorderSide(color: ColorConst.borderColor)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time_outlined,
                  size: 12,
                  color: ColorConst.textGrey,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate('${item.createdAt}'),
                  style: const TextStyle(
                    color: ColorConst.textGrey,
                    fontSize: 11,
                  ),
                ),
                if (item.remarks != null && '${item.remarks}'.isNotEmpty) ...[
                  const SizedBox(width: 10),
                  const Text(
                    '·',
                    style: TextStyle(color: ColorConst.textGrey, fontSize: 11),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${item.remarks}',
                      style: const TextStyle(
                        color: ColorConst.textGrey,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ] else
                  const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: ColorConst.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Qty: ${item.quantity}',
                    style: const TextStyle(
                      color: ColorConst.info,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'pending':
        return ColorConst.warning;
      case 'approved':
        return ColorConst.success;
      case 'rejected':
        return ColorConst.danger;
      case 'fulfilled':
        return ColorConst.info;
      default:
        return ColorConst.textGrey;
    }
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return raw;
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Hub History Tab
// ══════════════════════════════════════════════════════════════════════════════
class _HubHistoryTab extends StatelessWidget {
  final String searchQuery;
  final String selectedStatus;
  final String sortBy;

  const _HubHistoryTab({
    required this.searchQuery,
    required this.selectedStatus,
    required this.sortBy,
  });

  List<CityHubHistoryData> _filterAndSort(List<CityHubHistoryData> list) {
    var result = list.where((p) {
      final q = searchQuery.toLowerCase();
      final matchSearch =
          q.isEmpty ||
          '${p.productName}'.toLowerCase().contains(q) ||
          '${p.sku}'.toLowerCase().contains(q) ||
          '${p.brandName}'.toLowerCase().contains(q);
      final matchStatus =
          selectedStatus == 'All' ||
          p.transfers?.any(
                (t) =>
                    '${t.status}'.toLowerCase() == selectedStatus.toLowerCase(),
              ) ==
              true;
      return matchSearch && matchStatus;
    }).toList();

    result.sort((a, b) {
      final aDate = _latestDate(a) ?? DateTime(2000);
      final bDate = _latestDate(b) ?? DateTime(2000);
      return sortBy == 'Oldest'
          ? aDate.compareTo(bDate)
          : bDate.compareTo(aDate);
    });
    return result;
  }

  DateTime? _latestDate(CityHubHistoryData p) {
    if (p.transfers == null || p.transfers!.isEmpty) return null;
    return p.transfers!
        .map((t) {
          try {
            return DateTime.parse('${t.createdAt}');
          } catch (_) {
            return null;
          }
        })
        .whereType<DateTime>()
        .reduce((a, b) => a.isAfter(b) ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CityStockViewModel>();

    if (vm.historyLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: ColorConst.primaryGreen,
          backgroundColor: ColorConst.white,
        ),
      );
    }

    final list = _filterAndSort(vm.cityHubHistoryModel?.data ?? []);

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 52,
              color: ColorConst.textGrey.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            const Text(
              'No transfers found',
              style: TextStyle(color: ColorConst.textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: list.length,
      itemBuilder: (_, i) =>
          _HubCard(product: list[i], statusFilter: selectedStatus.toString()),
    );
  }
}

// ── Hub Card ──────────────────────────────────────────────────────────────────
class _HubCard extends StatefulWidget {
  final CityHubHistoryData product;
  final String statusFilter;
  const _HubCard({required this.product, required this.statusFilter});

  @override
  State<_HubCard> createState() => _HubCardState();
}

class _HubCardState extends State<_HubCard> {
  bool _expanded = false;

  List<Transfers> get _transfers {
    if (widget.statusFilter == 'All') return widget.product.transfers ?? [];
    return widget.product.transfers
            ?.where(
              (t) =>
                  '${t.status}'.toLowerCase() ==
                  widget.statusFilter.toLowerCase(),
            )
            .toList() ??
        [];
  }

  // CORRECTED: Fixed the _totalSent getter
  int get _totalSent {
    return _transfers.fold(0, (sum, transfer) {
      final variantsSum =
          transfer.variants?.fold<int>(0, (vSum, variant) {
            // Safely parse sentQty to int
            final qty = variant.sentQty;
            if (qty == null) return vSum;
            final parsedQty = qty is int
                ? qty
                : int.tryParse(qty.toString()) ?? 0;
            return vSum + parsedQty;
          }) ??
          0;
      return sum + variantsSum;
    });
  }

  @override
  Widget build(BuildContext context) {
    final transfers = _transfers;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: ColorConst.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorConst.borderColor),
      ),
      child: Column(
        children: [
          // ── Header row ───────────────────────────────────────────
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Product image / icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: ColorConst.primaryGreen.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child:
                        widget.product.productImg != null &&
                            '${widget.product.productImg}'.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              '${widget.product.productImg}',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.inventory_2_outlined,
                                color: ColorConst.primaryGreen,
                                size: 20,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.inventory_2_outlined,
                            color: ColorConst.primaryGreen,
                            size: 20,
                          ),
                  ),
                  const SizedBox(width: 10),

                  // Name + SKU
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.product.productName}',
                          style: const TextStyle(
                            color: ColorConst.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              'SKU: ${widget.product.sku}',
                              style: const TextStyle(
                                color: ColorConst.textGrey,
                                fontSize: 11,
                              ),
                            ),
                            if (widget.product.brandName != null) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: ColorConst.info.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${widget.product.brandName}',
                                  style: const TextStyle(
                                    color: ColorConst.info,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Hub count + chevron
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: ColorConst.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${transfers.length} hub${transfers.length != 1 ? 's' : ''}',
                          style: const TextStyle(
                            color: ColorConst.info,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 180),
                        child: const Icon(
                          Icons.keyboard_arrow_down,
                          color: ColorConst.textGrey,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded transfer rows ───────────────────────────────
          if (_expanded && transfers.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: ColorConst.containerGrey2,
                border: Border(top: BorderSide(color: ColorConst.borderColor)),
              ),
              child: Column(
                children: transfers
                    .map((t) => _TransferRow(transfer: t))
                    .toList(),
              ),
            ),

          // ── Footer ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(12, 7, 12, 7),
            decoration: BoxDecoration(
              color: ColorConst.containerGrey2,
              borderRadius: BorderRadius.vertical(
                bottom: const Radius.circular(12),
                top: _expanded ? Radius.zero : Radius.zero,
              ),
              border: Border(top: BorderSide(color: ColorConst.borderColor)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time_outlined,
                  size: 12,
                  color: ColorConst.textGrey,
                ),
                const SizedBox(width: 4),
                Text(
                  '${transfers.length} transfer(s)',
                  style: const TextStyle(
                    color: ColorConst.textGrey,
                    fontSize: 11,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: ColorConst.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$_totalSent total sent',
                    style: const TextStyle(
                      color: ColorConst.info,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
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

// ── Transfer Row ──────────────────────────────────────────────────────────────
class _TransferRow extends StatelessWidget {
  final Transfers transfer;
  const _TransferRow({required this.transfer});

  @override
  Widget build(BuildContext context) {
    final status = '${transfer.status}';
    final variants = transfer.variants ?? [];

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: ColorConst.borderColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hub name + status
          Row(
            children: [
              const Icon(Icons.hub_outlined, size: 13, color: ColorConst.info),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  '${transfer.hubName}',
                  style: const TextStyle(
                    color: ColorConst.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _StatusBadge(status: status),
            ],
          ),
          const SizedBox(height: 8),

          // Variants
          ...variants.map(
            (v) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                children: [
                  const SizedBox(width: 18),
                  Expanded(
                    child: Text(
                      '${v.value}',
                      style: const TextStyle(
                        color: ColorConst.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  _QtyChip(
                    label: 'Sent',
                    value: v.sentQty,
                    color: ColorConst.info,
                  ),
                  const SizedBox(width: 5),
                  _QtyChip(
                    label: 'Rec',
                    value: v.receivedQty,
                    color: ColorConst.success,
                  ),
                  if (v.missingQty != null && (v.missingQty ?? 0) > 0) ...[
                    const SizedBox(width: 5),
                    _QtyChip(
                      label: 'Miss',
                      value: v.missingQty,
                      color: ColorConst.danger,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Shared widgets
// ══════════════════════════════════════════════════════════════════════════════
class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _color(status);
    final bg = color.withOpacity(0.1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Color _color(String s) {
    switch (s.toLowerCase()) {
      case 'pending':
        return ColorConst.warning;
      case 'approved':
      case 'received':
        return ColorConst.success;
      case 'rejected':
      case 'disputed':
        return ColorConst.danger;
      case 'fulfilled':
      case 'in_transit':
        return ColorConst.info;
      default:
        return ColorConst.textGrey;
    }
  }
}

class _QtyChip extends StatelessWidget {
  final String label;
  final dynamic value;
  final Color color;
  const _QtyChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Safely convert value to string for display
    final displayValue = value?.toString() ?? '0';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            displayValue,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(color: color.withOpacity(0.7), fontSize: 9),
          ),
        ],
      ),
    );
  }
}
