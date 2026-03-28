import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/city_stock_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/StockDir/product_sheet.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/all_hub_list_view_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/city_stock_view_model.dart';


class TransferStockScreen extends StatefulWidget {
  final List<CityStockData> allItems;
  final CityStockData?      preSelected;

  const TransferStockScreen({
    super.key,
    required this.allItems,
    this.preSelected,
  });

  @override
  State<TransferStockScreen> createState() => _TransferStockScreenState();
}

class _TransferStockScreenState extends State<TransferStockScreen> {
  final _qtyCtrl     = TextEditingController();
  final _remarksCtrl = TextEditingController();

  CityStockData? _product;
  String?        _hubId;
  String?        _hubName;

  @override
  void initState() {
    super.initState();
    _product = widget.preSelected;
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        context.read<AllHubViewModel>().getHubListDataApi(context));
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _remarksCtrl.dispose();
    super.dispose();
  }

  int    get _stock      => _product?.stock ?? 0;
  int    get _qty        => int.tryParse(_qtyCtrl.text) ?? 0;
  bool   get _qtyValid   => _qty > 0 && _qty <= _stock;
  double get _progress   => _stock > 0 ? (_qty / _stock).clamp(0.0, 1.0) : 0.0;
  bool   get _canConfirm => _product != null && _stock > 0 && _hubId != null && _qtyValid;

  Color _stockColor(int s) {
    if (s == 0) return const Color(0xFFEF4444);
    if (s < 10) return const Color(0xFFDC2626);
    if (s < 20) return const Color(0xFFD97706);
    return ColorConst.primaryGreen;
  }

  Future<void> _pickProduct() async {
    final picked = await ProductPickerSheet.show(
      context,
      items:    widget.allItems,
      selected: _product,
    );
    if (picked != null) {
      setState(() {
        _product = picked;
        _qtyCtrl.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: ColorConst.primaryGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Transfer Stock', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          Text('City → Hub', style: TextStyle(color: Colors.white70, fontSize: 11)),
        ]),
      ),
      body: Consumer2<CityStockViewModel, AllHubViewModel>(
        builder: (context, vm, hubVm, _) => Column(children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              children: [
                // ── 1. Product dropdown ──────────────────────────
                _label('Select Product', Icons.inventory_2_outlined),
                const SizedBox(height: 8),
                _buildProductTrigger(),
                const SizedBox(height: 16),

                // ── 2. Stock info (after selection) ──────────────
                if (_product != null) ...[
                  _buildStockInfoCard(),
                  const SizedBox(height: 16),
                ],

                // ── 3. Hub ────────────────────────────────────────
                _label('Destination Hub', Icons.hub_outlined),
                const SizedBox(height: 8),
                _buildHubDropdown(hubVm),
                const SizedBox(height: 16),

                // ── 4. Quantity (only if product has stock) ───────
                if (_product != null && _stock > 0) ...[
                  _label('Transfer Quantity', Icons.numbers_rounded),
                  const SizedBox(height: 8),
                  _buildQtyCard(),
                  const SizedBox(height: 16),
                ],

                // ── 5. Remarks ────────────────────────────────────
                _label('Remarks (Optional)', Icons.notes_rounded),
                const SizedBox(height: 8),
                _buildRemarksField(),
                const SizedBox(height: 16),

                // ── 6. Summary ────────────────────────────────────
                if (_canConfirm) _buildSummary(),
              ],
            ),
          ),
          _buildConfirmBar(vm),
        ]),
      ),
    );
  }

  // ── Product dropdown trigger ───────────────────────────────────────────────

  Widget _buildProductTrigger() {
    final p     = _product;
    final stock = p?.stock ?? 0;
    final color = p != null ? _stockColor(stock) : Colors.grey;

    return GestureDetector(
      onTap: _pickProduct,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: p != null ? ColorConst.primaryGreen.withOpacity(0.4) : const Color(0xFFE5E7EB),
            width: p != null ? 1.5 : 1,
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: (p != null ? ColorConst.primaryGreen : Colors.grey.shade400).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(p != null ? Icons.inventory_2_rounded : Icons.add_box_outlined,
                size: 18, color: p != null ? ColorConst.primaryGreen : Colors.grey.shade400),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: p == null
                ? const Text('Tap to choose a product',
                style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)))
                : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.product?.name ?? '',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
              const SizedBox(height: 3),
              Row(children: [
                Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 5),
                Text(stock == 0 ? 'Out of stock' : '$stock units available',
                    style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
                if (p.variant?.name != null && p.variant?.name != 'Default') ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(color: const Color(0xFF2563EB).withOpacity(0.08), borderRadius: BorderRadius.circular(5)),
                    child: Text(p.variant?.name, style: const TextStyle(fontSize: 9, color: Color(0xFF2563EB), fontWeight: FontWeight.w700)),
                  ),
                ],
              ]),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(p == null ? 'Select' : 'Change',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: Color(0xFF374151)),
            ]),
          ),
        ]),
      ),
    );
  }

  // ── Stock info card ────────────────────────────────────────────────────────

  Widget _buildStockInfoCard() {
    final p        = _product!;
    final stock    = p.stock ?? 0;
    final received = int.tryParse(p.totalReceived ?? '0') ?? 0;
    final sold     = received - stock;
    final color    = _stockColor(stock);
    final isOut    = stock == 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(children: [
        Row(children: [
          Expanded(child: _stat('Available', '$stock', color)),
          Container(width: 1, height: 32, color: const Color(0xFFF3F4F6)),
          Expanded(child: _stat('Received', '$received', const Color(0xFF059669))),
          Container(width: 1, height: 32, color: const Color(0xFFF3F4F6)),
          Expanded(child: _stat('Sold', '$sold', const Color(0xFF6B7280))),
        ]),
        if (isOut) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(10)),
            child: const Row(children: [
              Icon(Icons.warning_amber_rounded, size: 14, color: Color(0xFFDC2626)),
              SizedBox(width: 6),
              Expanded(child: Text('This product is out of stock — cannot be transferred.',
                  style: TextStyle(fontSize: 11, color: Color(0xFFDC2626)))),
            ]),
          ),
        ] else ...[
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Stock Level', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
            Text(received > 0 ? '${((stock / received) * 100).toStringAsFixed(0)}%' : '—',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
          ]),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: received > 0 ? (stock / received).clamp(0.0, 1.0) : 0,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ]),
    );
  }

  // ── Hub dropdown ───────────────────────────────────────────────────────────

  Widget _buildHubDropdown(AllHubViewModel hubVm) {
    final hubs = hubVm.hubListModel?.data?.hubs ?? [];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _hubId != null ? ColorConst.primaryGreen : const Color(0xFFE5E7EB),
          width: _hubId != null ? 1.5 : 1,
        ),
      ),
      child: hubs.isEmpty
          ? const Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: ColorConst.primaryGreen)))
          : DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _hubId,
          isExpanded: true,
          dropdownColor: Colors.white,
          hint: Row(children: [
            Icon(Icons.hub_outlined, size: 16, color: Colors.grey.shade400),
            const SizedBox(width: 8),
            const Text('Choose a hub', style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
          ]),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF6B7280)),
          items: hubs.map<DropdownMenuItem<String>>((h) => DropdownMenuItem<String>(
            value: h.hubId.toString(),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: ColorConst.primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.store_outlined, size: 14, color: ColorConst.primaryGreen),
              ),
              const SizedBox(width: 10),
              Text(h.hubName ?? 'Hub', style: const TextStyle(fontSize: 14, color: Color(0xFF111827))),
            ]),
          )).toList(),
          onChanged: (v) => setState(() {
            _hubId   = v;
            _hubName = hubs.firstWhere((h) => h.hubId.toString() == v).hubName;
          }),
        ),
      ),
    );
  }

  // ── Quantity card ──────────────────────────────────────────────────────────

  Widget _buildQtyCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(children: [
        Row(children: [
          _qtyBtn(Icons.remove_rounded, () {
            if (_qty > 1) { _qtyCtrl.text = '${_qty - 1}'; setState(() {}); }
          }),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _qtyCtrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(fontSize: 22, color: Colors.grey.shade300),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _qtyBtn(Icons.add_rounded, () {
            if (_qty < _stock) { _qtyCtrl.text = '${_qty + 1}'; setState(() {}); }
          }),
        ]),
        const SizedBox(height: 12),
        // Quick chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            const Text('Quick: ', style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
            ...[10, 25, 50, 100].map((q) {
              final ok = q <= _stock;
              return GestureDetector(
                onTap: ok ? () { _qtyCtrl.text = '$q'; setState(() {}); } : null,
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: ok ? ColorConst.primaryGreen.withOpacity(0.08) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: ok ? ColorConst.primaryGreen.withOpacity(0.3) : Colors.grey.shade200),
                  ),
                  child: Text('$q', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                      color: ok ? ColorConst.primaryGreen : Colors.grey.shade300)),
                ),
              );
            }),
            GestureDetector(
              onTap: () { _qtyCtrl.text = '$_stock'; setState(() {}); },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A5F).withOpacity(0.07),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF1E3A5F).withOpacity(0.2)),
                ),
                child: const Text('Max', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1E3A5F))),
              ),
            ),
          ]),
        ),
        if (_qty > 0) ...[
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Transferring $_qty of $_stock units', style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
            Text('${(_progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                    color: _qtyValid ? ColorConst.primaryGreen : Colors.red)),
          ]),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: AlwaysStoppedAnimation<Color>(_qtyValid ? ColorConst.primaryGreen : Colors.red),
              minHeight: 6,
            ),
          ),
          if (_qty > _stock)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(children: [
                const Icon(Icons.error_outline_rounded, size: 13, color: Colors.red),
                const SizedBox(width: 4),
                Text('Max available: $_stock units', style: const TextStyle(fontSize: 11, color: Colors.red)),
              ]),
            ),
        ],
      ]),
    );
  }

  // ── Remarks ────────────────────────────────────────────────────────────────

  Widget _buildRemarksField() => TextField(
    controller: _remarksCtrl,
    maxLines: 2,
    style: const TextStyle(fontSize: 13),
    decoration: InputDecoration(
      hintText: 'e.g. Urgent transfer for weekend demand…',
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      prefixIcon: const Padding(
        padding: EdgeInsets.only(left: 14, right: 10, top: 14),
        child: Icon(Icons.notes_rounded, size: 17, color: Color(0xFF6B7280)),
      ),
      prefixIconConstraints: const BoxConstraints(),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: ColorConst.primaryGreen, width: 1.5)),
      contentPadding: const EdgeInsets.all(14),
    ),
  );

  // ── Transfer summary ───────────────────────────────────────────────────────

  Widget _buildSummary() {
    final remaining = _stock - _qty;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColorConst.primaryGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorConst.primaryGreen.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.summarize_outlined, size: 13, color: ColorConst.primaryGreen),
          const SizedBox(width: 6),
          const Text('Transfer Summary', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: ColorConst.primaryGreen)),
        ]),
        const SizedBox(height: 10),
        _summRow('Product', _product?.product?.name ?? '—'),
        _summRow('To Hub', _hubName ?? '—'),
        _summRow('Sending', '$_qty units'),
        _summRow('Remaining', '$remaining units', color: remaining < 10 ? const Color(0xFFDC2626) : null),
      ]),
    );
  }

  Widget _summRow(String l, String v, {Color? color}) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(l, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
      Text(v, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color ?? const Color(0xFF111827))),
    ]),
  );

  // ── Confirm bar ────────────────────────────────────────────────────────────

  Widget _buildConfirmBar(CityStockViewModel vm) => Container(
    padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
    ),
    child: SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: (_canConfirm && !vm.transferLoading) ? () {
          vm.cityTransferToHubApi(context, _hubId!,
            _remarksCtrl.text.trim().isEmpty ? 'Transfer from city panel' : _remarksCtrl.text.trim(),
            [{'productid': _product!.productid, 'variantid': _product!.variantid ?? 0, 'qty': _qty}],
          );
        } : null,
        icon: vm.transferLoading
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.send_rounded, size: 18, color: Colors.white),
        label: Text(vm.transferLoading ? 'Transferring…' : 'Confirm Transfer',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: _canConfirm ? ColorConst.primaryGreen : Colors.grey.shade300,
          disabledBackgroundColor: Colors.grey.shade300,
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    ),
  );

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _label(String t, IconData icon) => Row(children: [
    Icon(icon, size: 15, color: ColorConst.primaryGreen),
    const SizedBox(width: 7),
    Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
  ]);

  Widget _stat(String l, String v, Color c) => Column(children: [
    Text(v, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: c)),
    Text(l, style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
  ]);

  Widget _qtyBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 44, height: 44,
      decoration: BoxDecoration(
        color: ColorConst.primaryGreen.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ColorConst.primaryGreen.withOpacity(0.3)),
      ),
      child: Icon(icon, color: ColorConst.primaryGreen, size: 20),
    ),
  );
}