import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/HubRequestGetDir/hub_get_req_view_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/HubRequestGetDir/hub_req_get_model.dart';

const _kBg = Color(0xFFF4F6F9);
const _kSurf = Colors.white;
const _kBorder = Color(0xFFE0E4EA);
const _kGreen = Color(0xFF2E7D32);
const _kGreenSoft = Color(0xFFE8F5E9);
const _kT1 = Color(0xFF1A1D23);
const _kT2 = Color(0xFF6B7280);
const _kError = Color(0xFFC62828);
const _kErrorSoft = Color(0xFFFFEBEE);
const _kInfo = Color(0xFF1565C0);
const _kInfoSoft = Color(0xFFE3F2FD);
const _kWarn = Color(0xFFE65100);
const _kWarnSoft = Color(0xFFFFF3E0);
const _kAccent = Color(0xFF0F6E56);
const _kAccentSoft = Color(0xFFE1F5EE);


enum _RequestFilter { all, pending, accepted, rejected }


class HubRequestManagementScreen extends StatefulWidget {
  const HubRequestManagementScreen({super.key});

  @override
  State<HubRequestManagementScreen> createState() =>
      _HubRequestManagementScreenState();
}

class _HubRequestManagementScreenState extends State<HubRequestManagementScreen> {


  _RequestFilter _filter = _RequestFilter.all;
  Data? _selectedRequest;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HubReqGetViewModel>().getHubReqGetDataApi(context);
    });
  }

  // ── Status helper — 0: pending | 1: accepted | 2: rejected ──────────────────

  String _statusStr(dynamic status) {
    switch (status?.toString()) {
      case '1':
        return 'accepted';
      case '2':
        return 'rejected';
      default:
        return 'pending'; // 0 or anything else
    }
  }

  List<Data> _allRequests(HubReqGetViewModel vm) =>
      vm.hubRequestListModel?.data ?? [];

  List<Data> _filtered(HubReqGetViewModel vm) {
    final all = _allRequests(vm);
    if (_filter == _RequestFilter.all) return all;
    return all
        .where((r) => _statusStr(r.status) == _filter.name)
        .toList();
  }

  int _pendingCount(HubReqGetViewModel vm) =>
      _allRequests(vm).where((r) => _statusStr(r.status) == 'pending').length;

  int _totalQty(Data req) =>
      (req.products ?? []).fold(
        0,
            (sum, p) =>
        sum +
            (int.tryParse(p.requestedQuantity?.toString() ?? '0') ?? 0),
      );

  int _totalVariants(Data req) =>
      (req.products ?? [])
          .fold(0, (sum, p) => sum + (p.variants?.length ?? 0));

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildAppHeader(),
        Expanded(
          child: Consumer<HubReqGetViewModel>(
            builder: (context, vm, _) {
              if (vm.hubRequestListModel == null) {
                return const Center(
                  child: CircularProgressIndicator(color: _kAccent),
                );
              }
              return _buildSplitLayout(vm);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAppHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: _kSurf,
        border: Border(bottom: BorderSide(color: _kBorder)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _kAccentSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.inbox_rounded, color: _kAccent, size: 20),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hub Request Management',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _kT1,
                ),
              ),
              Text(
                'Review incoming requests — accept or reject them.',
                style: TextStyle(fontSize: 11, color: _kT2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SPLIT LAYOUT
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildSplitLayout(HubReqGetViewModel vm) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 55, child: _buildLeftPanel(vm)),
        Container(width: 1, color: _kBorder),
        Expanded(flex: 45, child: _buildRightPanel(vm)),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LEFT PANEL
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildLeftPanel(HubReqGetViewModel vm) {
    final filtered = _filtered(vm);

    return Column(
      children: [
        // Panel header
        _PanelHeader(
          label: '📋  Incoming Requests',
          color: _kGreen,
          bgColor: _kGreenSoft,
          trailing: '${filtered.length} requests',
        ),
        // Filter bar
        _buildFilterBar(vm),
        // List
        Expanded(
          child: filtered.isEmpty
              ? _EmptyList()
              : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: filtered.length,
            itemBuilder: (_, i) => _buildRequestCard(filtered[i]),
          ),
        ),
      ],
    );
  }

  // ── Filter Bar ─────────────────────────────────────────────────────────────

  Widget _buildFilterBar(HubReqGetViewModel vm) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: _kSurf,
        border: Border(bottom: BorderSide(color: _kBorder)),
      ),
      child: Row(
        children: [
          _buildFilterChip(
            label: 'All',
            filter: _RequestFilter.all,
            count: _allRequests(vm).length,
            countColor: _kAccent,
          ),
          const SizedBox(width: 6),
          _buildFilterChip(
            label: 'Pending',
            filter: _RequestFilter.pending,
            count: _pendingCount(vm),
            countColor: _kWarn,
          ),
          const SizedBox(width: 6),
          _buildFilterChip(label: 'Accepted', filter: _RequestFilter.accepted),
          const SizedBox(width: 6),
          _buildFilterChip(label: 'Rejected', filter: _RequestFilter.rejected),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required _RequestFilter filter,
    int? count,
    Color? countColor,
  }) {
    final isActive = _filter == filter;

    return GestureDetector(
      onTap: () => setState(() => _filter = filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? _kAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? _kAccent : _kBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : _kT2,
              ),
            ),
            if (count != null && count > 0) ...[
              const SizedBox(width: 5),
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white.withValues(alpha: 0.25)
                      : countColor ?? _kAccent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Request Card ────────────────────────────────────────────────────────────

  Widget _buildRequestCard(Data req) {
    final isSelected =
        _selectedRequest?.requestId?.toString() == req.requestId?.toString();
    final statusStr = _statusStr(req.status);

    Color statusColor;
    Color statusBg;
    switch (statusStr) {
      case 'accepted':
        statusColor = _kGreen;
        statusBg = _kGreenSoft;
        break;
      case 'rejected':
        statusColor = _kError;
        statusBg = _kErrorSoft;
        break;
      default:
        statusColor = _kWarn;
        statusBg = _kWarnSoft;
    }

    // Category tags from products
    final categories = (req.products ?? [])
        .map((p) => p.categoryName?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();

    final hubName = req.hubmanager?.name?.toString() ?? 'Unknown Hub';

    return GestureDetector(
      onTap: () => setState(() => _selectedRequest = req),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: _kSurf,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _kAccent : _kBorder,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: _kAccent.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : const [
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        _initials(hubName),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Meta
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hubName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _kT1,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          req.createdAt?.toString() ?? '',
                          style: const TextStyle(fontSize: 10, color: _kT2),
                        ),
                      ],
                    ),
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _capitalize(statusStr),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Tags row
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: Wrap(
                spacing: 5,
                runSpacing: 4,
                children: [
                  ...categories.take(3).map(
                        (cat) => _MiniTag(label: cat),
                  ),
                  _MiniTag(
                    label:
                    '${_totalVariants(req)} variants · qty ${_totalQty(req)}',
                    bgColor: _kInfoSoft,
                    textColor: _kInfo,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // RIGHT PANEL
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildRightPanel(HubReqGetViewModel vm) {
    return Column(
      children: [
        _PanelHeader(
          label: '🔍  Request Details',
          color: _kInfo,
          bgColor: _kInfoSoft,
        ),
        if (_selectedRequest == null)
          const Expanded(child: _EmptyDetail())
        else
          Expanded(child: _buildDetailView(vm, _selectedRequest!)),
      ],
    );
  }

  // ── Detail View ─────────────────────────────────────────────────────────────

  Widget _buildDetailView(HubReqGetViewModel vm, Data req) {
    final statusStr = _statusStr(req.status);
    final hubName = req.hubmanager?.name?.toString() ?? '-';

    Color statusColor;
    switch (statusStr) {
      case 'accepted':
        statusColor = _kGreen;
        break;
      case 'rejected':
        statusColor = _kError;
        break;
      default:
        statusColor = _kWarn;
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info chips
                const _SectionLabel('Request info'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _InfoChip(
                        label: 'Request ID',
                        value: req.requestId?.toString() ?? '-',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _InfoChip(label: 'Hub', value: hubName),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _InfoChip(
                        label: 'Total variants',
                        value: '${_totalVariants(req)}',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _InfoChip(
                        label: 'Total qty',
                        value: '${_totalQty(req)} units',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _InfoChip(
                        label: 'Status',
                        value: _capitalize(statusStr),
                        valueColor: statusColor,
                      ),
                    ),
                  ],
                ),

                // Products
                const SizedBox(height: 14),
                const _SectionLabel('Requested products'),
                const SizedBox(height: 8),
                ...(req.products ?? []).map((p) => _buildProductCard(p)),
              ],
            ),
          ),
        ),
        // Action footer
        _buildActionFooter(vm, req),
      ],
    );
  }

  // ── Product Card ────────────────────────────────────────────────────────────

  Widget _buildProductCard(Products product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _kSurf,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product header
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: Row(
              children: [
                // Image or icon
                ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: (product.productImg != null &&
                      product.productImg.toString().isNotEmpty)
                      ? Image.network(
                    product.productImg.toString(),
                    width: 30,
                    height: 30,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _prodIcon(),
                  )
                      : _prodIcon(),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.productName?.toString() ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _kT1,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Text(
                            product.categoryName?.toString() ?? '',
                            style:
                            const TextStyle(fontSize: 10, color: _kT2),
                          ),
                          if (product.brandName != null) ...[
                            const Text(
                              ' · ',
                              style: TextStyle(fontSize: 10, color: _kT2),
                            ),
                            Text(
                              product.brandName.toString(),
                              style:
                              const TextStyle(fontSize: 10, color: _kT2),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Requested qty badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _kInfoSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Req: ${product.requestedQuantity ?? 0}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _kInfo,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Variant count badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _kGreenSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${product.variants?.length ?? 0} variant${(product.variants?.length ?? 1) != 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _kGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Variant rows
          if (product.variants != null)
            ...product.variants!.map((v) => _buildVariantRow(v)),
        ],
      ),
    );
  }

  Widget _prodIcon() => Container(
    width: 30,
    height: 30,
    decoration: BoxDecoration(
      color: _kAccentSoft,
      borderRadius: BorderRadius.circular(7),
    ),
    child: const Icon(Icons.inventory_2, color: _kAccent, size: 16),
  );

  Widget _buildVariantRow(Variants variant) {
    final stock =
        int.tryParse(variant.currentStock?.toString() ?? '0') ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _kBorder)),
      ),
      child: Row(
        children: [
          // Variant name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  variant.variantValue?.toString() ?? 'Default',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _kT1),
                ),
                if (variant.sku != null)
                  Text(
                    'SKU: ${variant.sku}',
                    style: const TextStyle(fontSize: 9, color: _kT2),
                  ),
              ],
            ),
          ),
          // Price
          if (variant.discountPrice != null) ...[
            Text(
              '₹${variant.discountPrice}',
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _kAccent),
            ),
            const SizedBox(width: 7),
          ],
          // Current stock chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: stock > 0 ? _kGreenSoft : _kErrorSoft,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              'Stock: $stock',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: stock > 0 ? _kGreen : _kError,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ACTION FOOTER
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildActionFooter(HubReqGetViewModel vm, Data req) {
    final statusStr = _statusStr(req.status);
    final isPending = statusStr == 'pending';

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
      decoration: const BoxDecoration(
        color: _kSurf,
        border: Border(top: BorderSide(color: _kBorder)),
        boxShadow: [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: isPending
          ? _buildPendingActions(vm, req)
          : _buildDoneState(statusStr),
    );
  }

  Widget _buildPendingActions(HubReqGetViewModel vm, Data req) {
    return vm.addLoading
        ? const Center(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: CircularProgressIndicator(
            color: _kAccent, strokeWidth: 2),
      ),
    )
        : Row(
      children: [
        // Accept
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => vm.acceptHubRequestApi(
              context,
              req.requestId.toString(),
            ),
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: const Text(
              'Accept Request',
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(width: 10),
        // // Reject
        // Expanded(
        //   child: ElevatedButton.icon(
        //     onPressed: () => _onReject(context, req),
        //     icon: const Icon(Icons.cancel_outlined, size: 18),
        //     label: const Text(
        //       'Reject',
        //       style: TextStyle(
        //           fontSize: 13, fontWeight: FontWeight.w700),
        //     ),
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: _kErrorSoft,
        //       foregroundColor: _kError,
        //       padding: const EdgeInsets.symmetric(vertical: 13),
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(11),
        //         side: BorderSide(
        //             color: _kError.withValues(alpha: 0.3)),
        //       ),
        //       elevation: 0,
        //     ),
        //   ),
        // ),
      ],
    );
  }


  Widget _buildDoneState(String status) {
    final isAccepted = status == 'accepted';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isAccepted ? _kGreenSoft : _kErrorSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isAccepted
              ? _kGreen.withValues(alpha: 0.3)
              : _kError.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isAccepted ? Icons.check_circle : Icons.cancel,
            color: isAccepted ? _kGreen : _kError,
            size: 18,
          ),
          const SizedBox(width: 9),
          Text(
            isAccepted
                ? 'This request has already been accepted.'
                : 'This request has already been rejected.',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isAccepted ? _kGreen : _kError,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════════════════════════

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ════════════════════════════════════════════════════════════════════════════
// REJECT CONFIRM DIALOG
// ════════════════════════════════════════════════════════════════════════════

// class _RejectConfirmDialog extends StatelessWidget {
//   const _RejectConfirmDialog();
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       shape:
//       RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       title: const Row(
//         children: [
//           Icon(Icons.warning_amber_rounded, color: _kError, size: 22),
//           SizedBox(width: 8),
//           Text(
//             'Request Reject karein?',
//             style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
//           ),
//         ],
//       ),
//       content: const Text(
//         'Kya aap sure hain? Reject karne ke baad hub ko dobara request karni padegi.',
//         style: TextStyle(fontSize: 13, color: _kT2, height: 1.5),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context, false),
//           child: const Text('Cancel', style: TextStyle(color: _kT2)),
//         ),
//         ElevatedButton(
//           onPressed: () => Navigator.pop(context, true),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: _kError,
//             foregroundColor: Colors.white,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//             elevation: 0,
//           ),
//           child: const Text('Haan, Reject Karein'),
//         ),
//       ],
//     );
//   }
// }

// ════════════════════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ════════════════════════════════════════════════════════════════════════════

class _PanelHeader extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;
  final String? trailing;

  const _PanelHeader({
    required this.label,
    required this.color,
    required this.bgColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: bgColor,
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 13,
              letterSpacing: 0.2,
            ),
          ),
          if (trailing != null) ...[
            const Spacer(),
            Text(
              trailing!,
              style: const TextStyle(fontSize: 11, color: _kT2),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: _kT2,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoChip({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _kBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: _kT2)),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: valueColor ?? _kT1,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;

  const _MiniTag({
    required this.label,
    this.bgColor = _kAccentSoft,
    this.textColor = _kAccent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

class _EmptyList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, color: _kT2, size: 40),
          SizedBox(height: 10),
          Text(
            'No requests found.',
            style: TextStyle(fontSize: 13, color: _kT2),
          ),
        ],
      ),
    );
  }
}

class _EmptyDetail extends StatelessWidget {
  const _EmptyDetail();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _kInfoSoft,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.mark_email_unread_outlined,
                color: _kInfo,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Please select a request.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _kT1,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Click on a request from the left panel to view details.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: _kT2, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}