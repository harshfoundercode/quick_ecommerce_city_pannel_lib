import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/HubRequestGetDir/hub_req_get_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/HubRequestGetDir/hub_request_get_viewmodel.dart';


// ════════════════════════════════════════════════════════════════════════════
// THEME CONSTANTS  (matches your ColorConst palette)
// ════════════════════════════════════════════════════════════════════════════

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

// ════════════════════════════════════════════════════════════════════════════
// SCREEN
// ════════════════════════════════════════════════════════════════════════════

class HubRequestManagementScreen extends StatefulWidget {
  const HubRequestManagementScreen({super.key});

  @override
  State<HubRequestManagementScreen> createState() =>
      _HubRequestManagementScreenState();
}

class _HubRequestManagementScreenState
    extends State<HubRequestManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HubRequestProvider>().fetchHubRequests(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AppHeader(),
        Expanded(
          child: Consumer<HubRequestProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: _kAccent),
                );
              }
              if (provider.error != null) {
                return _ErrorState(
                  message: provider.error!,
                  onRetry: () => provider.fetchHubRequests(context),
                );
              }
              return _SplitLayout();
            },
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// APP HEADER
// ════════════════════════════════════════════════════════════════════════════

class _AppHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                'Incoming requests review karein — accept ya reject karein',
                style: TextStyle(fontSize: 11, color: _kT2),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// SPLIT LAYOUT
// ════════════════════════════════════════════════════════════════════════════

class _SplitLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // LEFT 55%
        const Expanded(flex: 55, child: _LeftPanel()),
        // Divider
        Container(width: 1, color: _kBorder),
        // RIGHT 45%
        const Expanded(flex: 45, child: _RightPanel()),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// LEFT PANEL
// ════════════════════════════════════════════════════════════════════════════

class _LeftPanel extends StatelessWidget {
  const _LeftPanel();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HubRequestProvider>();
    final filtered = provider.filteredRequests;

    return Column(
      children: [
        // Panel header
        _PanelHeader(
          label: '📋  Incoming Requests',
          color: _kGreen,
          bgColor: _kGreenSoft,
          trailing: '${filtered.length} requests',
        ),
        // Filter tabs
        _FilterBar(),
        // List
        Expanded(
          child: filtered.isEmpty
              ? _EmptyList()
              : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: filtered.length,
            itemBuilder: (_, i) => _RequestCard(request: filtered[i]),
          ),
        ),
      ],
    );
  }
}

// ── Filter Bar ──────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HubRequestProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: _kSurf,
        border: Border(bottom: BorderSide(color: _kBorder)),
      ),
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            filter: RequestFilter.all,
            count: provider.allRequests.length,
            countColor: _kAccent,
          ),
          const SizedBox(width: 6),
          _FilterChip(
            label: 'Pending',
            filter: RequestFilter.pending,
            count: provider.pendingCount,
            countColor: _kWarn,
          ),
          const SizedBox(width: 6),
          _FilterChip(label: 'Accepted', filter: RequestFilter.accepted),
          const SizedBox(width: 6),
          _FilterChip(label: 'Rejected', filter: RequestFilter.rejected),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final RequestFilter filter;
  final int? count;
  final Color? countColor;

  const _FilterChip({
    required this.label,
    required this.filter,
    this.count,
    this.countColor,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HubRequestProvider>();
    final isActive = provider.filter == filter;

    return GestureDetector(
      onTap: () => provider.setFilter(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? _kAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? _kAccent : _kBorder,
          ),
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
            if (count != null && count! > 0) ...[
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
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: isActive ? Colors.white : Colors.white,
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
}

// ── Request Card ────────────────────────────────────────────────────────────

class _RequestCard extends StatelessWidget {
  final HubRequest request;

  const _RequestCard({required this.request});

  Color get _statusColor {
    switch (request.status) {
      case 'accepted':
        return _kGreen;
      case 'rejected':
        return _kError;
      default:
        return _kWarn;
    }
  }

  Color get _statusBg {
    switch (request.status) {
      case 'accepted':
        return _kGreenSoft;
      case 'rejected':
        return _kErrorSoft;
      default:
        return _kWarnSoft;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HubRequestProvider>();
    final isSelected =
        provider.selectedRequest?.requestId?.toString() ==
            request.requestId?.toString();

    final categories = request.products
        ?.map((p) => p.subCategory ?? p.mainCategory ?? '')
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList() ??
        [];

    return GestureDetector(
      onTap: () => provider.selectRequest(request),
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
                      color: _statusBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        _initials(request.hubName ?? 'HB'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _statusColor,
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
                          request.hubName ?? 'Unknown Hub',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _kT1,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${request.cityName ?? ''} · ${request.createdAt ?? ''}',
                          style: const TextStyle(fontSize: 10, color: _kT2),
                        ),
                      ],
                    ),
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _statusBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _capitalize(request.status ?? 'pending'),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _statusColor,
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
                    '${request.totalVariants} variants · qty ${request.totalQty}',
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
            'Koi request nahi mili',
            style: TextStyle(fontSize: 13, color: _kT2),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// RIGHT PANEL
// ════════════════════════════════════════════════════════════════════════════

class _RightPanel extends StatelessWidget {
  const _RightPanel();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HubRequestProvider>();
    final req = provider.selectedRequest;

    return Column(
      children: [
        _PanelHeader(
          label: '🔍  Request Details',
          color: _kInfo,
          bgColor: _kInfoSoft,
        ),
        if (req == null)
          const Expanded(child: _EmptyDetail())
        else
          Expanded(child: _DetailView(request: req)),
      ],
    );
  }
}

// ── Empty detail ────────────────────────────────────────────────────────────

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
              'Koi request select karein',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _kT1,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Left panel se kisi request par\nclick karein to details dekhein',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: _kT2, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Detail View ─────────────────────────────────────────────────────────────

class _DetailView extends StatelessWidget {
  final HubRequest request;

  const _DetailView({required this.request});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info chips
                _SectionLabel('Request info'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _InfoChip(
                        label: 'Request ID',
                        value: request.requestId?.toString() ?? '-',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _InfoChip(
                        label: 'Hub',
                        value: request.hubName ?? '-',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _InfoChip(
                        label: 'Total variants',
                        value: '${request.totalVariants}',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _InfoChip(
                        label: 'Total qty',
                        value: '${request.totalQty} units',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _InfoChip(
                        label: 'Status',
                        value: _capitalize(request.status ?? 'pending'),
                        valueColor: _statusColor(request.status),
                      ),
                    ),
                  ],
                ),

                // Note
                if (request.note != null && request.note!.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _SectionLabel('Note'),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _kBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _kBorder),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.note_alt_outlined,
                          size: 14,
                          color: _kT2,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            request.note!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: _kT1,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Products
                const SizedBox(height: 14),
                _SectionLabel('Requested products'),
                const SizedBox(height: 8),
                ...(request.products ?? []).map(
                      (p) => _ProductCard(product: p),
                ),
              ],
            ),
          ),
        ),
        // Action footer
        _ActionFooter(request: request),
      ],
    );
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'accepted':
        return _kGreen;
      case 'rejected':
        return _kError;
      default:
        return _kWarn;
    }
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ── Product Card ────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final RequestProduct product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
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
                      product.productImg!.isNotEmpty)
                      ? Image.network(
                    product.productImg!,
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
                        product.productName ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _kT1,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${product.mainCategory ?? ''} › ${product.subCategory ?? ''}',
                        style: const TextStyle(fontSize: 10, color: _kT2),
                      ),
                    ],
                  ),
                ),
                // Variant count badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
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
            ...product.variants!.map((v) => _VariantRow(variant: v)),
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
}

class _VariantRow extends StatelessWidget {
  final RequestVariant variant;

  const _VariantRow({required this.variant});

  @override
  Widget build(BuildContext context) {
    final isLow = variant.isLowStock;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        border: const Border(top: BorderSide(color: _kBorder)),
        color: isLow ? _kErrorSoft.withValues(alpha: 0.4) : Colors.transparent,
      ),
      child: Row(
        children: [
          // Variant name
          Expanded(
            child: Text(
              variant.variantName ?? 'Default',
              style: const TextStyle(fontSize: 11, color: _kT1),
            ),
          ),
          // Stock chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: isLow ? _kWarnSoft : _kGreenSoft,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              'Stock: ${variant.availableStock ?? 0}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isLow ? _kWarn : _kGreen,
              ),
            ),
          ),
          const SizedBox(width: 7),
          // Qty badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: isLow
                  ? _kError.withValues(alpha: 0.1)
                  : _kAccentSoft,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '×${variant.qty ?? 0}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: isLow ? _kError : _kAccent,
              ),
            ),
          ),
          if (isLow) ...[
            const SizedBox(width: 5),
            const Icon(
              Icons.warning_amber_rounded,
              size: 13,
              color: _kWarn,
            ),
          ],
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// ACTION FOOTER — Accept / Reject
// ════════════════════════════════════════════════════════════════════════════

class _ActionFooter extends StatelessWidget {
  final HubRequest request;

  const _ActionFooter({required this.request});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HubRequestProvider>();
    final isPending = request.status == 'pending';

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
          ? _PendingActions(request: request, provider: provider)
          : _DoneState(status: request.status ?? 'pending'),
    );
  }
}

class _PendingActions extends StatelessWidget {
  final HubRequest request;
  final HubRequestProvider provider;

  const _PendingActions({
    required this.request,
    required this.provider,
  });

  Future<void> _onAccept(BuildContext context) async {
    final success = await provider.acceptRequest(
      context,
      request.requestId,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Request accept kar li gayi ✓' : 'Kuch galat hua, retry karein',
          ),
          backgroundColor: success ? _kGreen : _kError,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _onReject(BuildContext context) async {
    // Optional: show a reject reason bottom sheet
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const _RejectConfirmDialog(),
    );
    if (confirmed != true) return;

    // final success = await provider.rejectRequest(
    //   context,
    //   request.requestId,
    // );
    // if (context.mounted) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text(
    //         success ? 'Request reject kar di gayi' : 'Kuch galat hua, retry karein',
    //       ),
    //       backgroundColor: success ? _kError : _kWarn,
    //       behavior: SnackBarBehavior.floating,
    //       shape: RoundedRectangleBorder(
    //         borderRadius: BorderRadius.circular(10),
    //       ),
    //     ),
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    return provider.isActionLoading
        ? const Center(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: CircularProgressIndicator(color: _kAccent, strokeWidth: 2),
      ),
    )
        : Row(
      children: [
        // Accept
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _onAccept(context),
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: const Text(
              'Accept Request',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
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
        // Reject
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _onReject(context),
            icon: const Icon(Icons.cancel_outlined, size: 18),
            label: const Text(
              'Reject',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kErrorSoft,
              foregroundColor: _kError,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
                side: BorderSide(
                  color: _kError.withValues(alpha: 0.3),
                ),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _DoneState extends StatelessWidget {
  final String status;

  const _DoneState({required this.status});

  @override
  Widget build(BuildContext context) {
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
                ? 'Yeh request accept ki ja chuki hai'
                : 'Yeh request reject ki ja chuki hai',
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
}

// ════════════════════════════════════════════════════════════════════════════
// REJECT CONFIRM DIALOG
// ════════════════════════════════════════════════════════════════════════════

class _RejectConfirmDialog extends StatelessWidget {
  const _RejectConfirmDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: _kError, size: 22),
          SizedBox(width: 8),
          Text(
            'Request Reject karein?',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ],
      ),
      content: const Text(
        'Kya aap sure hain? Reject karne ke baad hub ko dobara request karni padegi.',
        style: TextStyle(fontSize: 13, color: _kT2, height: 1.5),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel', style: TextStyle(color: _kT2)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: _kError,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
          child: const Text('Haan, Reject Karein'),
        ),
      ],
    );
  }
}

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
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: _kT2),
          ),
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

// ════════════════════════════════════════════════════════════════════════════
// ERROR STATE
// ════════════════════════════════════════════════════════════════════════════

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: _kError, size: 40),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(fontSize: 13, color: _kT2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}