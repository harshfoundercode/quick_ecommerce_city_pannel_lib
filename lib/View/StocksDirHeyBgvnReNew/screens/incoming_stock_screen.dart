import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import '../providers/stock_provider.dart';
import '../models/models.dart';
import '../widgets/app_header.dart';

class IncomingStockScreen extends StatelessWidget {
  const IncomingStockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shipments = context.watch<StockProvider>().incomingStocks;
    return Column(
      children: [
        const AppHeader(
            title: 'Incoming Stock', subtitle: 'Check your incomming stocks'),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: shipments.length,
            itemBuilder: (_, i) => _ShipmentCard(shipment: shipments[i]),
          ),
        ),
      ],
    );
  }
}

// ─── Shipment Card ────────────────────────────────────────────────────────────
class _ShipmentCard extends StatelessWidget {
  final IncomingStock shipment;
  const _ShipmentCard({required this.shipment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: ColorConst.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColorConst.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                const Icon(Icons.local_shipping_outlined,
                    color: ColorConst.primaryGreen, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(shipment.supplierName,
                      style: const TextStyle(
                          color: ColorConst.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                ),
                Text(_dateLabel(shipment.expectedDate),
                    style: const TextStyle(
                        color: ColorConst.textGrey, fontSize: 12)),
              ],
            ),
          ),
          const Divider(height: 1, color: ColorConst.borderColor),
          ...shipment.items.map((item) => _ItemRow(
            item: item,
            shipmentId: shipment.id,
          )),
        ],
      ),
    );
  }

  String _dateLabel(DateTime dt) {
    final diff = dt.difference(DateTime.now()).inDays;
    if (diff < 0) return '${diff.abs()}d overdue';
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    return '$diff days';
  }
}

// ─── Item Row ─────────────────────────────────────────────────────────────────
class _ItemRow extends StatefulWidget {
  final IncomingStockItem item;
  final String shipmentId;
  const _ItemRow({required this.item, required this.shipmentId});

  @override
  State<_ItemRow> createState() => _ItemRowState();
}

class _ItemRowState extends State<_ItemRow> {
  bool _open = false;

  // ── Multi-select: Good is exclusive; Defective + Missing can coexist ──
  bool _isGood = false;
  bool _isDefective = false;
  bool _isMissing = false;

  late TextEditingController _rcvCtrl;
  late TextEditingController _missingCtrl;
  late TextEditingController _defectiveCtrl;
  final List<String> _photos = [];

  @override
  void initState() {
    super.initState();
    _rcvCtrl = TextEditingController(text: '${widget.item.expectedQty}');
    _missingCtrl = TextEditingController();
    _defectiveCtrl = TextEditingController();

    if (widget.item.itemStatus != ItemStatus.pending) {
      _rcvCtrl.text = '${widget.item.receivedQty}';
      _missingCtrl.text = '${widget.item.computedMissing}';
      _photos.addAll(widget.item.defectivePhotos);
      switch (widget.item.itemStatus) {
        case ItemStatus.accepted:
          _isGood = true;
          break;
        case ItemStatus.defective:
          _isDefective = true;
          break;
        case ItemStatus.missing:
          _isMissing = true;
          break;
        default:
          break;
      }
    }
  }

  @override
  void dispose() {
    _rcvCtrl.dispose();
    _missingCtrl.dispose();
    _defectiveCtrl.dispose();
    super.dispose();
  }

  bool get _anythingSelected => _isGood || _isDefective || _isMissing;
  bool get _isSaved => widget.item.itemStatus != ItemStatus.pending;

  Color get _dotColor {
    if (!_isSaved) return ColorConst.textGrey1;
    if (_isMissing && _isDefective) return ColorConst.warning;
    if (_isMissing) return ColorConst.danger;
    if (_isDefective) return ColorConst.warning;
    if (_isGood) return ColorConst.success;
    return ColorConst.textGrey1;
  }

  Widget? _multiTag() {
    final active = [
      if (_isGood) 'Good',
      if (_isDefective) 'Defective',
      if (_isMissing) 'Missing',
    ];
    if (active.length <= 1) return null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: ColorConst.honeyBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: ColorConst.warning.withValues(alpha: 0.4)),
      ),
      child: Text(
        active.join(' + '),
        style: const TextStyle(
            color: ColorConst.warning,
            fontSize: 10,
            fontWeight: FontWeight.w700),
      ),
    );
  }

  void _save() {
    final rcv = int.tryParse(_rcvCtrl.text) ?? widget.item.expectedQty;
    final missing = int.tryParse(_missingCtrl.text) ?? 0;
    final defective = int.tryParse(_defectiveCtrl.text) ?? 0;

    ItemStatus status = ItemStatus.pending;
    if (_isGood && !_isDefective && !_isMissing) status = ItemStatus.accepted;
    if (_isDefective) status = ItemStatus.defective;
    if (_isMissing && !_isDefective) status = ItemStatus.missing;

    context.read<StockProvider>().updateIncomingItem(
      incomingId: widget.shipmentId,
      itemId: widget.item.id,
      receivedQty: rcv,
      defectiveQty: defective,
      missingQty: missing,
      status: status,
      note: '',
    );
    setState(() => _open = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Saved!'),
      backgroundColor: ColorConst.success,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Collapsed row ─────────────────────────────────────────────
        InkWell(
          onTap: () => setState(() => _open = !_open),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 10, top: 2),
                  decoration:
                  BoxDecoration(shape: BoxShape.circle, color: _dotColor),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.item.productName,
                          style: const TextStyle(
                              color: ColorConst.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                      Text(widget.item.variantName,
                          style: const TextStyle(
                              color: ColorConst.textGrey, fontSize: 11)),
                    ],
                  ),
                ),
                if (_multiTag() != null) ...[
                  _multiTag()!,
                  const SizedBox(width: 6),
                ],
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: ColorConst.info.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('Req: ${widget.item.expectedQty}',
                      style: const TextStyle(
                          color: ColorConst.info,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 6),
                Icon(_open ? Icons.expand_less : Icons.expand_more,
                    color: ColorConst.textGrey, size: 18),
              ],
            ),
          ),
        ),

        // ── Expanded form ──────────────────────────────────────────────
        if (_open)
          Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColorConst.containerGrey2,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ColorConst.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Received qty ──────────────────────────────────────
                Row(
                  children: [
                    const Text('Mili kitni:',
                        style: TextStyle(
                            color: ColorConst.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    const Spacer(),
                    _qtyBtn(Icons.remove, () {
                      final v = int.tryParse(_rcvCtrl.text) ?? 0;
                      if (v > 0) setState(() => _rcvCtrl.text = '${v - 1}');
                    }),
                    const SizedBox(width: 6),
                    SizedBox(
                      width: 56,
                      child: TextField(
                        controller: _rcvCtrl,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        style: const TextStyle(
                            color: ColorConst.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700),
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding:
                          const EdgeInsets.symmetric(vertical: 8),
                          filled: true,
                          fillColor: ColorConst.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                  color: ColorConst.borderColor)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                  color: ColorConst.borderColor)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                  color: ColorConst.primaryGreen, width: 1.5)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _qtyBtn(Icons.add, () {
                      final v = int.tryParse(_rcvCtrl.text) ?? 0;
                      setState(() => _rcvCtrl.text = '${v + 1}');
                    }),
                    const SizedBox(width: 8),
                    Text('/ ${widget.item.expectedQty}',
                        style: const TextStyle(
                            color: ColorConst.textGrey, fontSize: 12)),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: ColorConst.borderColor),
                const SizedBox(height: 12),

                // ── Condition — MULTI SELECT ─────────────────────────
                Row(
                  children: [
                    const Text('Condition:',
                        style: TextStyle(
                            color: ColorConst.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: ColorConst.primaryExtraLightGreen,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text(
                        'Multiple select kar sakte ho',
                        style: TextStyle(
                            color: ColorConst.primaryGreen,
                            fontSize: 10,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(children: [
                  _condCheckBtn(
                    selected: _isGood,
                    label: '✓ Sab sahi',
                    color: ColorConst.success,
                    bg: ColorConst.greenPale,
                    onTap: () => setState(() {
                      _isGood = !_isGood;
                      // Good is exclusive
                      if (_isGood) {
                        _isDefective = false;
                        _isMissing = false;
                      }
                    }),
                  ),
                  const SizedBox(width: 6),
                  _condCheckBtn(
                    selected: _isDefective,
                    label: '! Defective',
                    color: ColorConst.warning,
                    bg: ColorConst.honeyBg,
                    onTap: () => setState(() {
                      _isDefective = !_isDefective;
                      if (_isDefective) _isGood = false;
                    }),
                  ),
                  const SizedBox(width: 6),
                  _condCheckBtn(
                    selected: _isMissing,
                    label: '? Missing',
                    color: ColorConst.danger,
                    bg: ColorConst.dangerBg,
                    onTap: () => setState(() {
                      _isMissing = !_isMissing;
                      if (_isMissing) _isGood = false;
                    }),
                  ),
                ]),

                // ── Both selected info banner ─────────────────────────
                if (_isDefective && _isMissing) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: ColorConst.honeyBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: ColorConst.warning.withValues(alpha:0.4)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 14, color: ColorConst.warning),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Defective + Missing dono mark hai. Dono ki qty alag fill karein.',
                            style: TextStyle(
                                color: ColorConst.warning,
                                fontSize: 11,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // ── Defective section ─────────────────────────────────
                if (_isDefective) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: ColorConst.borderColor),
                  const SizedBox(height: 10),
                  _sectionHeader(Icons.warning_amber_rounded, 'Defective',
                      ColorConst.warning),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Defective kitne:',
                          style: TextStyle(
                              color: ColorConst.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                      const Spacer(),
                      _qtyBtn(Icons.remove, () {
                        final v = int.tryParse(_defectiveCtrl.text) ?? 0;
                        if (v > 0) {
                          setState(() => _defectiveCtrl.text = '${v - 1}');
                        }
                      }),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 56,
                        child: TextField(
                          controller: _defectiveCtrl,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          style: const TextStyle(
                              color: ColorConst.warning,
                              fontSize: 15,
                              fontWeight: FontWeight.w700),
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding:
                            const EdgeInsets.symmetric(vertical: 8),
                            filled: true,
                            fillColor: ColorConst.honeyBg,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color:
                                    ColorConst.warning.withValues(alpha:0.4))),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color:
                                    ColorConst.warning.withValues(alpha:0.4))),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: ColorConst.warning, width: 1.5)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      _qtyBtn(Icons.add, () {
                        final v = int.tryParse(_defectiveCtrl.text) ?? 0;
                        setState(() => _defectiveCtrl.text = '${v + 1}');
                      }),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Photos
                  Row(children: [
                    const Text('Defective photos:',
                        style: TextStyle(
                            color: ColorConst.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        // TODO: replace with image_picker
                        setState(() =>
                            _photos.add('photo_${_photos.length + 1}.jpg'));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: ColorConst.honeyBg,
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(
                              color: ColorConst.warning.withValues(alpha:0.4)),
                        ),
                        child: const Row(children: [
                          Icon(Icons.add_a_photo_outlined,
                              color: ColorConst.warning, size: 13),
                          SizedBox(width: 4),
                          Text('Add Photo',
                              style: TextStyle(
                                  color: ColorConst.warning,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  if (_photos.isEmpty)
                    Text('Koi photo nahi',
                        style: TextStyle(
                            color: ColorConst.textGrey, fontSize: 11))
                  else
                    SizedBox(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _photos.length,
                        itemBuilder: (_, i) => Container(
                          width: 60,
                          height: 60,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: ColorConst.honeyBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: ColorConst.warning.withValues(alpha:0.4)),
                          ),
                          child: Center(
                            child: Text('${i + 1}',
                                style: const TextStyle(
                                    color: ColorConst.warning,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ),
                    ),
                ],

                // ── Missing section ───────────────────────────────────
                if (_isMissing) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: ColorConst.borderColor),
                  const SizedBox(height: 10),
                  _sectionHeader(
                      Icons.help_outline_rounded, 'Missing', ColorConst.danger),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Total ${widget.item.expectedQty} mein se kitne missing:',
                          style: const TextStyle(
                              color: ColorConst.danger,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _qtyBtn(Icons.remove, () {
                        final v = int.tryParse(_missingCtrl.text) ?? 0;
                        if (v > 0) {
                          setState(() => _missingCtrl.text = '${v - 1}');
                        }
                      }),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 56,
                        child: TextField(
                          controller: _missingCtrl,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          style: const TextStyle(
                              color: ColorConst.danger,
                              fontSize: 15,
                              fontWeight: FontWeight.w700),
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding:
                            const EdgeInsets.symmetric(vertical: 8),
                            filled: true,
                            fillColor: ColorConst.dangerBg,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: ColorConst.danger.withValues(alpha:0.3))),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: ColorConst.danger.withValues(alpha:0.3))),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: ColorConst.danger, width: 1.5)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      _qtyBtn(Icons.add, () {
                        final v = int.tryParse(_missingCtrl.text) ?? 0;
                        setState(() => _missingCtrl.text = '${v + 1}');
                      }),
                    ],
                  ),
                ],

                // ── Summary row (only when both selected) ─────────────
                if (_isDefective && _isMissing) ...[
                  const SizedBox(height: 12),
                  _qtySummaryRow(),
                ],

                // ── Save ──────────────────────────────────────────────
                if (_anythingSelected) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorConst.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: const Text('Save',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14)),
                    ),
                  ),
                ],
              ],
            ),
          ),

        const Divider(height: 1, color: ColorConst.borderColor),
      ],
    );
  }

  Widget _sectionHeader(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 5),
        Text(label,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w700)),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: color.withValues(alpha:0.25), height: 1)),
      ],
    );
  }

  Widget _qtySummaryRow() {
    final expected = widget.item.expectedQty;
    final defective = int.tryParse(_defectiveCtrl.text) ?? 0;
    final missing = int.tryParse(_missingCtrl.text) ?? 0;
    final received = int.tryParse(_rcvCtrl.text) ?? expected;
    final goodQty = (received - defective).clamp(0, received);
    final total = defective + missing;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: ColorConst.containerGrey,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ColorConst.borderColor),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.summarize_outlined,
                  size: 13, color: ColorConst.textGrey1),
              SizedBox(width: 5),
              Text('Summary',
                  style: TextStyle(
                      color: ColorConst.textGrey1,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _summaryChip('Expected', '$expected', ColorConst.info,
                  ColorConst.criticalBlueLight),
              const SizedBox(width: 5),
              _summaryChip('Received', '$received', ColorConst.success,
                  ColorConst.greenSoft),
              const SizedBox(width: 5),
              _summaryChip(
                  'Good', '$goodQty', ColorConst.primaryGreen, ColorConst.greenPale),
              const SizedBox(width: 5),
              _summaryChip('Defective', '$defective', ColorConst.warning,
                  ColorConst.honeyBg),
              const SizedBox(width: 5),
              _summaryChip(
                  'Missing', '$missing', ColorConst.danger, ColorConst.dangerBg),
            ],
          ),
          if (total > expected) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: ColorConst.dangerBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Defective ($defective) + Missing ($missing) = $total, expected ($expected) se zyada!',
                style: const TextStyle(
                    color: ColorConst.danger,
                    fontSize: 11,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _summaryChip(String label, String value, Color color, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    color: ColorConst.textGrey1, fontSize: 9)),
          ],
        ),
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: ColorConst.containerGrey,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ColorConst.borderColor),
      ),
      child: Icon(icon, size: 16, color: ColorConst.textPrimary),
    ),
  );

  Widget _condCheckBtn({
    required bool selected,
    required String label,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: selected ? bg : ColorConst.white,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
                color: selected ? color : ColorConst.borderColor,
                width: selected ? 1.5 : 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated checkbox
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: selected ? color : ColorConst.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                      color: selected ? color : ColorConst.borderColor,
                      width: 1.5),
                ),
                child: selected
                    ? const Icon(Icons.check, size: 10, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 5),
              Text(label,
                  style: TextStyle(
                      color: selected ? color : ColorConst.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}