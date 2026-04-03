import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/CityStocksRedefinedDir/common_widgets.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/CityStocksRedefinedDir/demo_data.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/CityStocksRedefinedDir/models.dart';


// ─────────────────────────────────────────────
//  INCOMING STOCK SCREEN
// ─────────────────────────────────────────────
class IncomingStockScreen extends StatefulWidget {
  const IncomingStockScreen({super.key});

  @override
  State<IncomingStockScreen> createState() => _IncomingStockScreenState();
}

class _IncomingStockScreenState extends State<IncomingStockScreen> {
  ShipmentStatus? _filterStatus;

  List<IncomingShipment> get _filtered {
    if (_filterStatus == null) return demoShipments;
    return demoShipments.where((s) => s.status == _filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Info Banner ──
        _buildInfoBanner(),
        const SizedBox(height: 14),

        // ── Filter tabs ──
        _buildFilterTabs(),
        const SizedBox(height: 14),

        // ── Shipment List ──
        Expanded(
          child: _filtered.isEmpty
              ? const _EmptyShipments()
              : ListView.separated(
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _ShipmentCard(
                    shipment: _filtered[i],
                    onUpdated: () => setState(() {}),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildInfoBanner() {
    final arrivedCount = demoShipments.where((s) => s.status == ShipmentStatus.arrived).length;
    if (arrivedCount == 0) return const SizedBox();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColorConst.criticalYellowLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_rounded, size: 18, color: ColorConst.criticalYellowLightText),
          const SizedBox(width: 10),
          Expanded(
            child: Text('$arrivedCount shipment${arrivedCount > 1 ? 's' : ''} arrived and awaiting confirmation. Please verify received quantities.',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  color: ColorConst.criticalYellowLightText)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    final tabs = [
      (null, 'All'),
      (ShipmentStatus.inTransit, 'In Transit'),
      (ShipmentStatus.arrived, 'Arrived'),
      (ShipmentStatus.confirmed, 'Confirmed'),
    ];
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final (status, label) = tabs[i];
          final sel = _filterStatus == status;
          return GestureDetector(
            onTap: () => setState(() => _filterStatus = status),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: sel ? ColorConst.primaryGreen : ColorConst.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: sel ? ColorConst.primaryGreen : ColorConst.borderColor),
              ),
              child: Text(label,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                    color: sel ? Colors.white : ColorConst.textSecondary)),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Shipment Card
// ─────────────────────────────────────────────
class _ShipmentCard extends StatefulWidget {
  final IncomingShipment shipment;
  final VoidCallback onUpdated;
  const _ShipmentCard({required this.shipment, required this.onUpdated});

  @override
  State<_ShipmentCard> createState() => _ShipmentCardState();
}

class _ShipmentCardState extends State<_ShipmentCard> {
  bool _expanded = false;
  bool _confirming = false;
  final _noteCtrl = TextEditingController();

  IncomingShipment get sh => widget.shipment;

  int get totalDamaged => sh.items.fold(0, (s, i) => s + (i.damagedQty ?? 0));
  int get totalMissing => sh.items.fold(0, (s, i) => s + (i.missingQty ?? 0));
  int get totalExpected => sh.items.fold(0, (s, i) => s + i.expectedQty);
  int get totalReceived => sh.items.fold(0, (s, i) => s + (i.receivedQty ?? 0));
  bool get hasIssues => totalDamaged > 0 || totalMissing > 0;
  bool get isConfirmable => sh.status != ShipmentStatus.confirmed;

  String _formatDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  void _confirm() async {
    setState(() => _confirming = true);
    await Future.delayed(const Duration(milliseconds: 700));
    sh.status = ShipmentStatus.confirmed;
    sh.note = _noteCtrl.text.trim();
    if (mounted) {
      setState(() => _confirming = false);
      widget.onUpdated();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(hasIssues
            ? '${sh.id} confirmed with issues reported'
            : '${sh.id} confirmed successfully!',
            style: const TextStyle(fontWeight: FontWeight.w700)),
        ]),
        backgroundColor: hasIssues ? ColorConst.warning : ColorConst.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorConst.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: sh.status == ShipmentStatus.arrived
              ? const Color(0xFFFDE68A) : ColorConst.borderColor,
          width: sh.status == ShipmentStatus.arrived ? 1.5 : 1,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          // ── Top Row ──
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
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: _shipmentIconBg(),
                          borderRadius: BorderRadius.circular(11)),
                        child: Icon(_shipmentIcon(), size: 20, color: _shipmentIconColor()),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(sh.id,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: ColorConst.kTextHead)),
                          const SizedBox(height: 3),
                          Row(children: [
                            const Icon(Icons.assignment_outlined, size: 12, color: ColorConst.textSecondary),
                            const SizedBox(width: 3),
                            Text('Req: ${sh.requestId}',
                              style: const TextStyle(fontSize: 11, color: ColorConst.textSecondary)),
                            const SizedBox(width: 10),
                            const Icon(Icons.calendar_today_outlined, size: 11, color: ColorConst.textSecondary),
                            const SizedBox(width: 3),
                            Text(_formatDate(sh.dispatchDate),
                              style: const TextStyle(fontSize: 11, color: ColorConst.textSecondary)),
                          ]),
                        ]),
                      ),
                      ShipmentStatusPill(status: sh.status),
                      const SizedBox(width: 6),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(Icons.keyboard_arrow_down_rounded,
                            size: 20, color: ColorConst.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Mini summary row
                  Row(children: [
                    _InfoPill(icon: Icons.inventory_2_outlined,
                        text: '${sh.items.length} items', color: ColorConst.textSecondary),
                    const SizedBox(width: 8),
                    _InfoPill(icon: Icons.numbers_rounded,
                        text: '$totalExpected units expected', color: ColorConst.textSecondary),
                    if (sh.status == ShipmentStatus.confirmed && hasIssues) ...[
                      const SizedBox(width: 8),
                      _InfoPill(icon: Icons.warning_rounded,
                          text: '$totalDamaged dmg · $totalMissing miss',
                          color: ColorConst.warning),
                    ],
                  ]),
                ],
              ),
            ),
          ),

          // ── Expanded Confirm Body ──
          if (_expanded) ...[
            const Divider(height: 1, color: ColorConst.borderColor),
            Container(
              color: ColorConst.containerGrey2,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Column Headers
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(children: const [
                      Expanded(flex: 3, child: _CH('PRODUCT / VARIANT')),
                      Expanded(child: _CH('EXPECTED')),
                      Expanded(child: _CH('RECEIVED')),
                      Expanded(child: _CH('DAMAGED')),
                      Expanded(child: _CH('MISSING')),
                    ]),
                  ),
                  const Divider(height: 1, color: ColorConst.borderColor),

                  // Item rows
                  ...sh.items.asMap().entries.map((e) => _ConfirmRow(
                    item: e.value,
                    enabled: isConfirmable,
                    onChanged: () => setState(() {}),
                  )),

                  const SizedBox(height: 12),

                  // Issue summary bar
                  if (totalDamaged > 0 || totalMissing > 0)
                    _buildIssueSummary(),

                  // Note field (only if not confirmed)
                  if (isConfirmable) ...[
                    const SizedBox(height: 12),
                    const Text('Remarks / Issues (optional)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: ColorConst.textSecondary)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _noteCtrl,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 12, color: ColorConst.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Describe any damage, packaging issues...',
                        hintStyle: const TextStyle(fontSize: 12, color: ColorConst.textSecondary),
                        filled: true, fillColor: ColorConst.cardColor,
                        contentPadding: const EdgeInsets.all(12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(9),
                          borderSide: const BorderSide(color: ColorConst.borderColor)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(9),
                          borderSide: const BorderSide(color: ColorConst.borderColor)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(9),
                          borderSide: const BorderSide(color: ColorConst.primaryLightGreen, width: 1.5)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Material(
                            color: ColorConst.primaryGreen,
                            borderRadius: BorderRadius.circular(11),
                            child: InkWell(
                              onTap: _confirming ? null : _confirm,
                              borderRadius: BorderRadius.circular(11),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: _confirming
                                    ? const Center(child: SizedBox(width: 20, height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)))
                                    : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                        Icon(
                                          hasIssues ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
                                          size: 17, color: Colors.white),
                                        const SizedBox(width: 7),
                                        Text(
                                          hasIssues ? 'Confirm with Issues' : 'Confirm Receipt',
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
                                      ]),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Confirmed note
                  if (!isConfirmable && sh.note != null && sh.note!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ColorConst.primaryExtraLightGreen,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: const Color(0xFFBBF7D0))),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle_outline_rounded, size: 14, color: ColorConst.primaryGreen),
                          const SizedBox(width: 6),
                          Expanded(child: Text(sh.note!,
                            style: const TextStyle(fontSize: 12, color: ColorConst.primaryGreen,
                                fontStyle: FontStyle.italic))),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIssueSummary() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorConst.criticalRedLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.report_problem_rounded, size: 16, color: ColorConst.criticalRed),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              [
                if (totalDamaged > 0) '$totalDamaged unit${totalDamaged > 1 ? 's' : ''} damaged',
                if (totalMissing > 0) '$totalMissing unit${totalMissing > 1 ? 's' : ''} missing',
              ].join(' · '),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: ColorConst.criticalRed),
            ),
          ),
          const Text('Will be reported to admin',
            style: TextStyle(fontSize: 10, color: ColorConst.criticalRed)),
        ],
      ),
    );
  }

  Color _shipmentIconBg() {
    switch (sh.status) {
      case ShipmentStatus.inTransit: return ColorConst.criticalBlueLight;
      case ShipmentStatus.arrived: return ColorConst.criticalYellowLight;
      case ShipmentStatus.confirmed: return ColorConst.primaryExtraLightGreen;
      default: return ColorConst.containerGrey;
    }
  }

  Color _shipmentIconColor() {
    switch (sh.status) {
      case ShipmentStatus.inTransit: return ColorConst.criticalBlue;
      case ShipmentStatus.arrived: return ColorConst.criticalYellowLightText;
      case ShipmentStatus.confirmed: return ColorConst.primaryGreen;
      default: return ColorConst.textSecondary;
    }
  }

  IconData _shipmentIcon() {
    switch (sh.status) {
      case ShipmentStatus.inTransit: return Icons.local_shipping_rounded;
      case ShipmentStatus.arrived: return Icons.move_to_inbox_rounded;
      case ShipmentStatus.confirmed: return Icons.inventory_rounded;
      default: return Icons.pending_rounded;
    }
  }
}

// ─────────────────────────────────────────────
//  Confirm Row (per item)
// ─────────────────────────────────────────────
class _ConfirmRow extends StatelessWidget {
  final ShipmentItem item;
  final bool enabled;
  final VoidCallback onChanged;
  const _ConfirmRow({required this.item, required this.enabled, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: ColorConst.borderColor))),
      child: Row(
        children: [
          Expanded(flex: 3, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.productName,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: ColorConst.kTextHead)),
              Container(
                margin: const EdgeInsets.only(top: 3),
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: ColorConst.containerGrey, borderRadius: BorderRadius.circular(5)),
                child: Text(item.variantLabel,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: ColorConst.textSecondary)),
              ),
            ],
          )),
          Expanded(child: Center(
            child: Text('${item.expectedQty}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: ColorConst.textSecondary)),
          )),
          Expanded(child: _NumInput(
            value: item.receivedQty,
            placeholder: '${item.expectedQty}',
            enabled: enabled,
            borderColor: ColorConst.borderColor,
            textColor: ColorConst.kTextHead,
            onChanged: (v) { item.receivedQty = v; onChanged(); },
          )),
          Expanded(child: _NumInput(
            value: item.damagedQty,
            placeholder: '0',
            enabled: enabled,
            borderColor: const Color(0xFFFCA5A5),
            bgColor: const Color(0xFFFFF1F2),
            textColor: ColorConst.criticalRed,
            onChanged: (v) { item.damagedQty = v; onChanged(); },
          )),
          Expanded(child: _NumInput(
            value: item.missingQty,
            placeholder: '0',
            enabled: enabled,
            borderColor: const Color(0xFFFDE68A),
            bgColor: ColorConst.criticalYellowLight,
            textColor: ColorConst.criticalYellowLightText,
            onChanged: (v) { item.missingQty = v; onChanged(); },
          )),
        ],
      ),
    );
  }
}

class _NumInput extends StatefulWidget {
  final int? value;
  final String placeholder;
  final bool enabled;
  final Color borderColor;
  final Color? bgColor;
  final Color textColor;
  final ValueChanged<int?> onChanged;
  const _NumInput({
    this.value, required this.placeholder, required this.enabled,
    required this.borderColor, this.bgColor, required this.textColor,
    required this.onChanged,
  });

  @override
  State<_NumInput> createState() => _NumInputState();
}

class _NumInputState extends State<_NumInput> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value != null ? '${widget.value}' : '');
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: TextField(
        controller: _ctrl,
        enabled: widget.enabled,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: widget.textColor),
        decoration: InputDecoration(
          hintText: widget.placeholder,
          hintStyle: TextStyle(fontSize: 12, color: widget.textColor.withValues(alpha: .4)),
          filled: true,
          fillColor: widget.bgColor ?? ColorConst.cardColor,
          contentPadding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: widget.borderColor)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: widget.borderColor)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: widget.borderColor, width: 1.5)),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: widget.borderColor.withValues(alpha: .4))),
        ),
        onChanged: (v) => widget.onChanged(int.tryParse(v)),
      ),
    );
  }
}

class _CH extends StatelessWidget {
  final String text;
  const _CH(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text,
      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800,
          color: ColorConst.textSecondary, letterSpacing: 0.5));
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _InfoPill({required this.icon, required this.text, required this.color});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 11, color: color),
      const SizedBox(width: 3),
      Text(text, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    ]);
  }
}

class _EmptyShipments extends StatelessWidget {
  const _EmptyShipments();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            color: ColorConst.criticalBlueLight, borderRadius: BorderRadius.circular(18)),
          child: const Icon(Icons.local_shipping_rounded, size: 30, color: ColorConst.criticalBlue),
        ),
        const SizedBox(height: 16),
        const Text('No Incoming Shipments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: ColorConst.kTextHead)),
        const SizedBox(height: 6),
        const Text('Shipments will appear here once dispatched',
          style: TextStyle(fontSize: 12, color: ColorConst.textSecondary)),
      ]),
    );
  }
}
