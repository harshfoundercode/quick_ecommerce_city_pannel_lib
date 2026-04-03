import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/CityStocksRedefinedDir/common_widgets.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/CityStocksRedefinedDir/demo_data.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/CityStocksRedefinedDir/models.dart';

// ─────────────────────────────────────────────
//  MY REQUESTS SCREEN
// ─────────────────────────────────────────────
class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  RequestStatus? _filterStatus;

  List<StockRequest> get _filtered {
    if (_filterStatus == null) return demoRequests;
    return demoRequests.where((r) => r.status == _filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Summary chips ──
        _buildSummaryRow(),
        const SizedBox(height: 16),

        // ── Filter Tabs ──
        _buildFilterTabs(),
        const SizedBox(height: 14),

        // ── List ──
        Expanded(
          child: _filtered.isEmpty
              ? const _EmptyRequests()
              : ListView.separated(
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _RequestCard(
                    request: _filtered[i],
                    onRefresh: () => setState(() {}),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow() {
    final counts = {
      RequestStatus.pending: demoRequests.where((r) => r.status == RequestStatus.pending).length,
      RequestStatus.approved: demoRequests.where((r) => r.status == RequestStatus.approved).length,
      RequestStatus.rejected: demoRequests.where((r) => r.status == RequestStatus.rejected).length,
      RequestStatus.partial: demoRequests.where((r) => r.status == RequestStatus.partial).length,
    };
    return Row(
      children: [
        _SummaryChip(count: counts[RequestStatus.pending]!, label: 'Pending',
            color: ColorConst.criticalYellowLightText, bg: ColorConst.criticalYellowLight),
        const SizedBox(width: 8),
        _SummaryChip(count: counts[RequestStatus.approved]!, label: 'Approved',
            color: const Color(0xFF166534), bg: ColorConst.primaryExtraLightGreen),
        const SizedBox(width: 8),
        _SummaryChip(count: counts[RequestStatus.partial]!, label: 'Partial',
            color: ColorConst.criticalBlue, bg: ColorConst.criticalBlueLight),
        const SizedBox(width: 8),
        _SummaryChip(count: counts[RequestStatus.rejected]!, label: 'Rejected',
            color: ColorConst.criticalRed, bg: ColorConst.criticalRedLight),
      ],
    );
  }

  Widget _buildFilterTabs() {
    final tabs = [
      (null, 'All', demoRequests.length),
      (RequestStatus.pending, 'Pending', demoRequests.where((r) => r.status == RequestStatus.pending).length),
      (RequestStatus.approved, 'Approved', demoRequests.where((r) => r.status == RequestStatus.approved).length),
      (RequestStatus.partial, 'Partial', demoRequests.where((r) => r.status == RequestStatus.partial).length),
      (RequestStatus.rejected, 'Rejected', demoRequests.where((r) => r.status == RequestStatus.rejected).length),
    ];
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final (status, label, count) = tabs[i];
          final sel = _filterStatus == status;
          return GestureDetector(
            onTap: () => setState(() => _filterStatus = status),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: sel ? ColorConst.primaryGreen : ColorConst.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: sel ? ColorConst.primaryGreen : ColorConst.borderColor),
              ),
              child: Row(
                children: [
                  Text(label,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                        color: sel ? Colors.white : ColorConst.textSecondary)),
                  const SizedBox(width: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: sel ? Colors.white.withValues(alpha: .25) : ColorConst.containerGrey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('$count',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                          color: sel ? Colors.white : ColorConst.textSecondary)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Request Card
// ─────────────────────────────────────────────
class _RequestCard extends StatefulWidget {
  final StockRequest request;
  final VoidCallback onRefresh;
  const _RequestCard({required this.request, required this.onRefresh});

  @override
  State<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<_RequestCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    return Container(
      decoration: BoxDecoration(
        color: ColorConst.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColorConst.borderColor),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          // ── Header ──
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(14),
              bottom: _expanded ? Radius.zero : const Radius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    children: [
                      // ID + Date
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Text(r.id,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: ColorConst.kTextHead)),
                            const SizedBox(width: 8),
                            PriorityBadge(priority: r.priority),
                          ]),
                          const SizedBox(height: 4),
                          Text(_formatDate(r.date),
                            style: const TextStyle(fontSize: 11, color: ColorConst.textSecondary)),
                        ]),
                      ),
                      RequestStatusPill(status: r.status),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(Icons.keyboard_arrow_down_rounded,
                            size: 20, color: ColorConst.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Item chips preview
                  Wrap(
                    spacing: 6, runSpacing: 6,
                    children: r.items.take(_expanded ? r.items.length : 3).map((item) =>
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: ColorConst.containerGrey2,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: ColorConst.borderColor),
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 12, color: ColorConst.textPrimary),
                            children: [
                              TextSpan(text: item.name),
                              const TextSpan(text: '  '),
                              TextSpan(text: '×${item.qty}',
                                style: const TextStyle(fontWeight: FontWeight.w800, color: ColorConst.primaryGreen)),
                            ],
                          ),
                        ),
                      ),
                    ).toList()
                      ..addAll(!_expanded && r.items.length > 3 ? [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: ColorConst.containerGrey,
                            borderRadius: BorderRadius.circular(8)),
                          child: Text('+${r.items.length - 3} more',
                            style: const TextStyle(fontSize: 12, color: ColorConst.textSecondary, fontWeight: FontWeight.w600)),
                        )
                      ] : []),
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded body ──
          if (_expanded) ...[
            const Divider(height: 1, color: ColorConst.borderColor),
            Container(
              color: ColorConst.containerGrey2,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (r.note.isNotEmpty) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.notes_rounded, size: 14, color: ColorConst.textSecondary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(r.note,
                            style: const TextStyle(fontSize: 12, color: ColorConst.textSecondary,
                                fontStyle: FontStyle.italic)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(color: ColorConst.borderColor),
                    const SizedBox(height: 10),
                  ],
                  // Full items table
                  const _TableHead(),
                  ...r.items.map((item) => _TableRow(item: item)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

class _TableHead extends StatelessWidget {
  const _TableHead();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: const [
          Expanded(flex: 3, child: _TH('PRODUCT')),
          Expanded(child: _TH('QTY', align: TextAlign.center)),
        ],
      ),
    );
  }
}

class _TH extends StatelessWidget {
  final String text;
  final TextAlign align;
  const _TH(this.text, {this.align = TextAlign.left});
  @override
  Widget build(BuildContext context) {
    return Text(text, textAlign: align,
      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800,
          color: ColorConst.textSecondary, letterSpacing: 0.6));
  }
}

class _TableRow extends StatelessWidget {
  final RequestItem item;
  const _TableRow({required this.item});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: ColorConst.borderColor))),
      child: Row(
        children: [
          Expanded(flex: 3,
            child: Text(item.name,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ColorConst.textPrimary))),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: ColorConst.primaryExtraLightGreen,
                  borderRadius: BorderRadius.circular(7)),
                child: Text('${item.qty}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: ColorConst.primaryGreen)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final int count;
  final String label;
  final Color color, bg;
  const _SummaryChip({required this.count, required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: .2)),
        ),
        child: Column(
          children: [
            Text('$count', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}

class _EmptyRequests extends StatelessWidget {
  const _EmptyRequests();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            color: ColorConst.primaryExtraLightGreen, borderRadius: BorderRadius.circular(18)),
          child: const Icon(Icons.pending_actions_rounded, size: 30, color: ColorConst.primaryGreen),
        ),
        const SizedBox(height: 16),
        const Text('No Requests Yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: ColorConst.kTextHead)),
        const SizedBox(height: 6),
        const Text('Go to Inventory to raise a restock request',
          style: TextStyle(fontSize: 12, color: ColorConst.textSecondary)),
      ]),
    );
  }
}
