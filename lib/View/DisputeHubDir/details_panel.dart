import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/DisputeHubDir/dispute_model.dart';

class DetailPane extends StatefulWidget {
  final DisputeItem? dispute;
  final ValueChanged<DisputeItem> onStatusUpdated;

  const DetailPane({super.key, required this.dispute, required this.onStatusUpdated});

  @override
  State<DetailPane> createState() => _DetailPaneState();
}

class _DetailPaneState extends State<DetailPane> {
  String? _requestType;
  final _noteController = TextEditingController();
  OverlayEntry? _toastEntry;

  final List<String> _requestTypes = [
    'Request replacement stock',
    'Request refund / credit',
    'Flag for investigation',
    'Product recall request',
    'Quality check required',
  ];

  @override
  void didUpdateWidget(covariant DetailPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dispute?.id != widget.dispute?.id) {
      _requestType = null;
      final d = widget.dispute;
      if (d != null) {
        _noteController.text = d.type == DisputeType.defective
            ? 'Product received in defective condition. Please review and arrange replacement or credit.'
            : d.type == DisputeType.missing
            ? 'Units missing from shipment. Please investigate and arrange for resupply.'
            : '';
      }
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _showToast(String message) {
    _toastEntry?.remove();
    _toastEntry = OverlayEntry(
      builder: (_) => Positioned(
        bottom: 30,
        left: 0,
        right: 0,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF185FA5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(message, style: const TextStyle(color: Colors.white, fontSize: 13)),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_toastEntry!);
    Future.delayed(const Duration(seconds: 3), () {
      _toastEntry?.remove();
      _toastEntry = null;
    });
  }

  void _sendToCity() {
    if (_requestType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a request type'), duration: Duration(seconds: 2)),
      );
      return;
    }
    final updated = widget.dispute!.copyWith(status: DisputeStatus.sentToCity);
    widget.onStatusUpdated(updated);
    _showToast('Request sent to city panel for "${widget.dispute!.product}"');
  }

  void _markRejected() {
    final updated = widget.dispute!.copyWith(status: DisputeStatus.rejected);
    widget.onStatusUpdated(updated);
    _showToast('"${widget.dispute!.product}" marked as rejected');
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.dispute;
    if (d == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.dashboard_outlined, size: 40, color: Color(0xFFD3D1C7)),
            SizedBox(height: 10),
            Text('Select a dispute to view details',
                style: TextStyle(fontSize: 13, color: Color(0xFF888780))),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(d),
          const SizedBox(height: 14),
          _buildOverviewCards(d),
          const _Divider(),
          _buildVariantTable(d),
          const _Divider(),
          _buildNoteBox(d),
          const _Divider(),
          _buildRequestForm(d),
        ],
      ),
    );
  }

  Widget _buildHeader(DisputeItem d) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(d.product,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF1A1A1A))),
              const SizedBox(height: 2),
              Text(d.hub, style: const TextStyle(fontSize: 12, color: Color(0xFF888780))),
            ],
          ),
        ),
        _StatusChip(status: d.status),
      ],
    );
  }

  Widget _buildOverviewCards(DisputeItem d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Overview'),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 2.5,
          children: [
            _MetricCard(value: '${d.transferred}', label: 'Units transferred', valueColor: const Color(0xFF1A1A1A)),
            _MetricCard(value: '${d.defective}', label: 'Defective units', valueColor: const Color(0xFFA32D2D)),
            _MetricCard(value: '${d.missing}', label: 'Missing units', valueColor: const Color(0xFF854F0B)),
            _MetricCard(value: '${d.variants.length}', label: 'Variants affected', valueColor: const Color(0xFF185FA5)),
          ],
        ),
      ],
    );
  }

  Widget _buildVariantTable(DisputeItem d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Variant breakdown'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFD3D1C7), width: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(2.5),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1.2),
              4: FlexColumnWidth(1.2),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F3),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                ),
                children: ['Variant', 'Sent', 'Recv', 'Defective', 'Missing']
                    .map((h) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                  child: Text(h,
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF888780))),
                ))
                    .toList(),
              ),
              ...d.variants.asMap().entries.map((entry) {
                final i = entry.key;
                final v = entry.value;
                final isLast = i == d.variants.length - 1;
                return TableRow(
                  decoration: BoxDecoration(
                    border: isLast
                        ? null
                        : const Border(bottom: BorderSide(color: Color(0xFFD3D1C7), width: 0.5)),
                  ),
                  children: [
                    _TableCell(text: v.name),
                    _TableCell(text: '${v.sent}'),
                    _TableCell(text: '${v.received}'),
                    _TableCell(
                      text: v.defective > 0 ? '${v.defective}' : '—',
                      color: v.defective > 0 ? const Color(0xFFA32D2D) : const Color(0xFF888780),
                      dot: v.defective > 0 ? const Color(0xFFE24B4A) : null,
                    ),
                    _TableCell(
                      text: v.missing > 0 ? '${v.missing}' : '—',
                      color: v.missing > 0 ? const Color(0xFF854F0B) : const Color(0xFF888780),
                      dot: v.missing > 0 ? const Color(0xFFEF9F27) : null,
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoteBox(DisputeItem d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Note from hub'),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(d.note,
              style: const TextStyle(fontSize: 12, color: Color(0xFF5F5E5A), height: 1.6)),
        ),
      ],
    );
  }

  Widget _buildRequestForm(DisputeItem d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Send request to city panel'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFD3D1C7), width: 0.5),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text('Select request type',
                        style: TextStyle(fontSize: 12, color: Color(0xFF888780))),
                    value: _requestType,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF1A1A1A)),
                    items: _requestTypes
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) => setState(() => _requestType = v),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                maxLines: 3,
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'Add additional notes for city panel...',
                  hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF888780)),
                  contentPadding: const EdgeInsets.all(10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFD3D1C7), width: 0.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFD3D1C7), width: 0.5),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _markRejected,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFA32D2D),
                        side: const BorderSide(color: Color(0xFFE24B4A), width: 0.5),
                        backgroundColor: const Color(0xFFFCEBEB),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Mark Rejected', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _sendToCity,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF185FA5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: const Text('Send to City Panel', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final DisputeStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    switch (status) {
      case DisputeStatus.sentToCity:
        bg = const Color(0xFFEAF3DE);
        fg = const Color(0xFF3B6D11);
        break;
      case DisputeStatus.pendingReview:
        bg = const Color(0xFFFAEEDA);
        fg = const Color(0xFF854F0B);
        break;
      case DisputeStatus.underReview:
        bg = const Color(0xFFE6F1FB);
        fg = const Color(0xFF185FA5);
        break;
      case DisputeStatus.rejected:
        bg = const Color(0xFFF1EFE8);
        fg = const Color(0xFF5F5E5A);
        break;
      case DisputeStatus.open:
        bg = const Color(0xFFFCEBEB);
        fg = const Color(0xFFA32D2D);
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        _label(status),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: fg),
      ),
    );
  }

  String _label(DisputeStatus s) {
    switch (s) {
      case DisputeStatus.sentToCity:
        return 'Sent to City';
      case DisputeStatus.pendingReview:
        return 'Pending Review';
      case DisputeStatus.underReview:
        return 'Under Review';
      case DisputeStatus.rejected:
        return 'Rejected';
      case DisputeStatus.open:
        return 'Open';
    }
  }
}

class _MetricCard extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;
  const _MetricCard({required this.value, required this.label, required this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: valueColor)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(fontSize: 10, color: Color(0xFF888780))),
        ],
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final Color? color;
  final Color? dot;
  const _TableCell({required this.text, this.color, this.dot});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot != null) ...[
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            ),
          ],
          Text(text,
              style: TextStyle(
                fontSize: 11,
                color: color ?? const Color(0xFF1A1A1A),
                fontWeight: FontWeight.w400,
              )),
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
        fontWeight: FontWeight.w500,
        color: Color(0xFF888780),
        letterSpacing: 0.6,
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 14),
      child: Divider(height: 0.5, thickness: 0.5, color: Color(0xFFD3D1C7)),
    );
  }
}