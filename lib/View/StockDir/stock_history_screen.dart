import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/city_hub_history_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/city_stock_view_model.dart';


class CityHubHistoryScreen extends StatefulWidget {
  const CityHubHistoryScreen({super.key});

  @override
  State<CityHubHistoryScreen> createState() => _CityHubHistoryScreenState();
}

class _CityHubHistoryScreenState extends State<CityHubHistoryScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'all'; // 'all' | 'active' | 'inactive'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CityStockViewModel>().cityHubHistoryApi(context);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<CityHubHistoryData> _filtered(List<CityHubHistoryData> raw) {
    return raw.where((p) {
      final q = _searchQuery.toLowerCase();
      final matchSearch = q.isEmpty ||
          (p.productName?.toString().toLowerCase().contains(q) ?? false) ||
          (p.sku?.toString().toLowerCase().contains(q) ?? false) ||
          (p.brandName?.toString().toLowerCase().contains(q) ?? false) ||
          (p.transfers ?? []).any(
                (t) => t.hubName?.toString().toLowerCase().contains(q) ?? false,
          );
      final matchStatus = _statusFilter == 'all' || (p.status?.toString().toLowerCase() == _statusFilter);
      return matchSearch && matchStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(),
            _buildSearchAndFilter(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: ColorConst.white,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: ColorConst.greenPale,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ColorConst.stroke),
            ),
            child: const Icon(
              Icons.store_rounded,
              color: ColorConst.primaryGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hub Transfer History',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ColorConst.textPrimary,
                  ),
                ),
                Text(
                  'Track all product transfers',
                  style: TextStyle(
                    fontSize: 12,
                    color: ColorConst.textGrey,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              context.read<CityStockViewModel>().cityHubHistoryApi(context);
            },
            icon: const Icon(Icons.refresh_rounded,
                color: ColorConst.primaryGreen, size: 22),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      color: ColorConst.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        children: [
          const Divider(height: 1, color: ColorConst.borderColor),
          const SizedBox(height: 12),
          // Search bar
          Container(
            height: 42,
            decoration: BoxDecoration(
              color: ColorConst.bgColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ColorConst.borderColor),
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(
                fontSize: 14,
                color: ColorConst.textPrimary,
              ),
              decoration: const InputDecoration(
                hintText: 'Search product, hub, or SKU...',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: ColorConst.textGrey1,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: ColorConst.textGrey,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Filter chips
          Row(
            children: [
              _filterChip('All', 'all'),
              const SizedBox(width: 8),
              _filterChip('Active', 'active'),
              const SizedBox(width: 8),
              _filterChip('Inactive', 'inactive'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final isActive = _statusFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _statusFilter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? ColorConst.primaryGreen : ColorConst.containerGrey,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? ColorConst.primaryGreen : ColorConst.borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isActive ? ColorConst.white : ColorConst.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<CityStockViewModel>(
      builder: (context, vm, _) {
        if (vm.historyLoading) {
          return const Center(
            child: CircularProgressIndicator(color: ColorConst.primaryGreen),
          );
        }

        final raw = vm.cityHubHistoryModel?.data ?? [];
        if (raw.isEmpty) {
          return _buildEmptyState('No transfer history found');
        }

        final items = _filtered(raw);
        if (items.isEmpty) {
          return _buildEmptyState('No results match your search');
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          itemCount: items.length,
          itemBuilder: (_, i) => _ProductTransferCard(item: items[i]),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: ColorConst.greenPale,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: ColorConst.primaryGreen,
              size: 34,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 15,
              color: ColorConst.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pull down to refresh',
            style: TextStyle(fontSize: 13, color: ColorConst.textGrey1),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PRODUCT TRANSFER CARD
// ─────────────────────────────────────────────
class _ProductTransferCard extends StatelessWidget {
  final CityHubHistoryData item;
  const _ProductTransferCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final transfers = item.transfers ?? [];
    final isActive = item.status?.toString().toLowerCase() == 'active';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: ColorConst.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColorConst.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product header
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Product image / placeholder
                _ProductAvatar(
                  imgUrl: item.productImg?.toString(),
                  categoryName: item.categoryName?.toString() ?? '',
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName?.toString() ?? '—',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ColorConst.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (item.sku != null)
                            _SkuBadge(sku: item.sku.toString()),
                          if (item.sku != null) const SizedBox(width: 6),
                          if (item.brandName != null)
                            Flexible(
                              child: Text(
                                item.brandName.toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: ColorConst.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (item.mainCategoryName != null)
                            Text(
                              item.mainCategoryName.toString(),
                              style: const TextStyle(
                                fontSize: 11,
                                color: ColorConst.textGrey1,
                              ),
                            ),
                          if (item.categoryName != null) ...[
                            const Text(
                              ' › ',
                              style: TextStyle(
                                fontSize: 11,
                                color: ColorConst.textGrey1,
                              ),
                            ),
                            Text(
                              item.categoryName.toString(),
                              style: const TextStyle(
                                fontSize: 11,
                                color: ColorConst.textGrey1,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Status indicator
                _StatusDot(isActive: isActive),
              ],
            ),
          ),

          // Summary stat row
          _TransferSummaryRow(transfers: transfers),

          // Divider
          const Divider(height: 1, color: ColorConst.borderColor),

          // Transfers section
          if (transfers.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
              child: Row(
                children: [
                  const Icon(Icons.swap_horiz_rounded,
                      size: 14, color: ColorConst.textGrey1),
                  const SizedBox(width: 4),
                  Text(
                    'TRANSFERS (${transfers.length})',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: ColorConst.textGrey1,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

          ...transfers.map((t) => _TransferTile(transfer: t)),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PRODUCT AVATAR
// ─────────────────────────────────────────────
class _ProductAvatar extends StatelessWidget {
  final String? imgUrl;
  final String categoryName;
  const _ProductAvatar({this.imgUrl, required this.categoryName});

  IconData _categoryIcon() {
    final c = categoryName.toLowerCase();
    if (c.contains('grain') || c.contains('rice')) return Icons.grain;
    if (c.contains('oil')) return Icons.opacity;
    if (c.contains('spice') || c.contains('powder')) return Icons.local_florist;
    if (c.contains('dairy')) return Icons.egg_alt;
    if (c.contains('fruit') || c.contains('veg')) return Icons.eco;
    return Icons.inventory_2_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: ColorConst.greenPale,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ColorConst.stroke),
      ),
      child: imgUrl != null
          ? ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          imgUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(
            _categoryIcon(),
            color: ColorConst.primaryGreen,
            size: 22,
          ),
        ),
      )
          : Icon(_categoryIcon(), color: ColorConst.primaryGreen, size: 22),
    );
  }
}

// ─────────────────────────────────────────────
// SKU BADGE
// ─────────────────────────────────────────────
class _SkuBadge extends StatelessWidget {
  final String sku;
  const _SkuBadge({required this.sku});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: ColorConst.containerGrey,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: ColorConst.borderColor),
      ),
      child: Text(
        sku,
        style: const TextStyle(
          fontSize: 11,
          color: ColorConst.textSecondary,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STATUS DOT
// ─────────────────────────────────────────────
class _StatusDot extends StatelessWidget {
  final bool isActive;
  const _StatusDot({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: isActive ? ColorConst.success : ColorConst.error,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          isActive ? 'Active' : 'Inactive',
          style: TextStyle(
            fontSize: 10,
            color: isActive ? ColorConst.success : ColorConst.error,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// TRANSFER SUMMARY ROW
// ─────────────────────────────────────────────
class _TransferSummaryRow extends StatelessWidget {
  final List<Transfers> transfers;
  const _TransferSummaryRow({required this.transfers});

  @override
  Widget build(BuildContext context) {
    int totalSent = 0, totalReceived = 0, totalMissing = 0, totalStock = 0;
    for (final t in transfers) {
      for (final v in t.variants ?? []) {
        totalSent += (v.sentQty ?? 0) as int;
        totalReceived += (v.receivedQty ?? 0) as int;
        totalMissing += (v.missingQty ?? 0) as int;
        totalStock += (v.currentStock ?? 0) as int;
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: Row(
        children: [
          _SummaryStatBox(
              label: 'Sent', value: '$totalSent', color: ColorConst.info),
          const SizedBox(width: 8),
          _SummaryStatBox(
              label: 'Received',
              value: '$totalReceived',
              color: ColorConst.success),
          const SizedBox(width: 8),
          _SummaryStatBox(
              label: 'Missing',
              value: '$totalMissing',
              color: totalMissing > 0 ? ColorConst.error : ColorConst.textGrey1),
          const SizedBox(width: 8),
          _SummaryStatBox(
              label: 'Stock',
              value: '$totalStock',
              color: ColorConst.primaryGreen),
        ],
      ),
    );
  }
}

class _SummaryStatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SummaryStatBox(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 10, color: ColorConst.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TRANSFER TILE (expandable)
// ─────────────────────────────────────────────
class _TransferTile extends StatefulWidget {
  final Transfers transfer;
  const _TransferTile({required this.transfer});

  @override
  State<_TransferTile> createState() => _TransferTileState();
}

class _TransferTileState extends State<_TransferTile>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _animCtrl;
  late Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _expandAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      _expanded ? _animCtrl.forward() : _animCtrl.reverse();
    });
  }

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'received':
        return ColorConst.success;
      case 'pending':
        return ColorConst.warning;
      case 'partial':
        return ColorConst.info;
      default:
        return ColorConst.textGrey1;
    }
  }

  Color _statusBgColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'received':
        return ColorConst.greenSoft;
      case 'pending':
        return ColorConst.honeyBg;
      case 'partial':
        return ColorConst.criticalBlueLight;
      default:
        return ColorConst.containerGrey;
    }
  }

  String _formatDate(String? iso) {
    if (iso == null) return '—';
    try {
      final dt = DateTime.parse(iso);
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${dt.day} ${months[dt.month]} ${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.transfer;
    final variants = t.variants ?? [];
    final statusColor = _statusColor(t.status?.toString());
    final statusBg = _statusBgColor(t.status?.toString());
    final statusLabel =
    (t.status?.toString() ?? '').toUpperCase();

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
      decoration: BoxDecoration(
        border: Border.all(color: ColorConst.stroke),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          // Header row
          InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: ColorConst.containerGrey2,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: ColorConst.greenPale,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.warehouse_outlined,
                      size: 16,
                      color: ColorConst.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.hubName?.toString() ?? '—',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: ColorConst.textPrimary,
                          ),
                        ),
                        Text(
                          _formatDate(t.createdAt?.toString()),
                          style: const TextStyle(
                            fontSize: 11,
                            color: ColorConst.textGrey1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status badge
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _expanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: ColorConst.textGrey1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expandable variants table
          SizeTransition(
            sizeFactor: _expandAnim,
            child: Column(
              children: [
                const SizedBox(height: 2),
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: ColorConst.borderColor),
                    ),
                  ),
                  child: _VariantsTable(variants: variants),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// VARIANTS TABLE
// ─────────────────────────────────────────────
class _VariantsTable extends StatelessWidget {
  final List<Variants> variants;
  const _VariantsTable({required this.variants});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          color: ColorConst.containerGrey,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            children: const [
              _ColHeader(text: 'Variant', flex: 2),
              _ColHeader(text: 'Price', flex: 2, align: TextAlign.right),
              _ColHeader(text: 'Sent', flex: 1, align: TextAlign.right),
              _ColHeader(text: 'Rcvd', flex: 1, align: TextAlign.right),
              _ColHeader(text: 'Miss', flex: 1, align: TextAlign.right),
              _ColHeader(text: 'Stock', flex: 1, align: TextAlign.right),
            ],
          ),
        ),
        ...variants.asMap().entries.map((e) {
          final v = e.value;
          final isLast = e.key == variants.length - 1;
          final hasMissing = (v.missingQty ?? 0) > 0;
          final isFullyReceived =
              (v.receivedQty ?? 0) > 0 &&
                  (v.receivedQty ?? 0) >= (v.sentQty ?? 0);
          final hasDispute = (v.disputeQty ?? 0) > 0;

          return Container(
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : const Border(
                bottom:
                BorderSide(color: ColorConst.borderColor, width: 0.5),
              ),
              color: hasDispute
                  ? ColorConst.dangerBg.withOpacity(0.5)
                  : Colors.transparent,
            ),
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Variant chip
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: ColorConst.greenPale,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      v.value?.toString() ?? '—',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: ColorConst.primaryGreen,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                // Price
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${v.discountPrice ?? v.price ?? 0}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ColorConst.textPrimary,
                        ),
                      ),
                      if (v.discountPrice != null &&
                          v.price != null &&
                          v.discountPrice != v.price)
                        Text(
                          '₹${v.price}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: ColorConst.textGrey1,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),
                ),
                // Sent
                Expanded(
                  flex: 1,
                  child: Text(
                    '${v.sentQty ?? 0}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 12,
                      color: ColorConst.info,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Received
                Expanded(
                  flex: 1,
                  child: Text(
                    '${v.receivedQty ?? 0}',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 12,
                      color: isFullyReceived
                          ? ColorConst.success
                          : (v.receivedQty ?? 0) > 0
                          ? ColorConst.warning
                          : ColorConst.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Missing
                Expanded(
                  flex: 1,
                  child: Text(
                    '${v.missingQty ?? 0}',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 12,
                      color: hasMissing
                          ? ColorConst.error
                          : ColorConst.textSecondary,
                      fontWeight: hasMissing ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ),
                // Stock
                Expanded(
                  flex: 1,
                  child: Text(
                    '${v.currentStock ?? 0}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 12,
                      color: ColorConst.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),

        // Dispute notice (if any)
        if (variants.any((v) => (v.disputeQty ?? 0) > 0))
          Container(
            margin: const EdgeInsets.fromLTRB(10, 4, 10, 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: ColorConst.dangerBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: ColorConst.danger.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    size: 15, color: ColorConst.danger),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Some variants have disputed quantities. Please review.',
                    style: TextStyle(
                      fontSize: 11,
                      color: ColorConst.danger,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ColHeader extends StatelessWidget {
  final String text;
  final int flex;
  final TextAlign align;
  const _ColHeader({
    required this.text,
    this.flex = 1,
    this.align = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: align,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: ColorConst.textGrey1,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}