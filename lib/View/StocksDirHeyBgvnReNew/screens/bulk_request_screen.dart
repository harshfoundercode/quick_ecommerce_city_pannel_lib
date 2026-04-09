import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import '../providers/stock_provider.dart';
import '../models/models.dart';
import '../widgets/app_header.dart';

class BulkRequestScreen extends StatefulWidget {
  const BulkRequestScreen({super.key});
  @override
  State<BulkRequestScreen> createState() => _BulkRequestScreenState();
}

class _BulkRequestScreenState extends State<BulkRequestScreen> {
  // Per-variant qty controllers — keyed by variantId
  final Map<String, TextEditingController> _qtyCtrl = {};
  final TextEditingController _noteCtrl = TextEditingController();
  TransferType _transferType = TransferType.adminRequest;

  static const List<String> _hubs = [
    'Delhi Hub', 'Mumbai Hub', 'Bangalore Hub', 'Hyderabad Hub', 'Chennai Hub',
  ];
  String? _selectedHub;

  @override
  void dispose() {
    for (var c in _qtyCtrl.values) c.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  TextEditingController _ctrl(String variantId) =>
      _qtyCtrl[variantId] ??= TextEditingController(text: '0');

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StockProvider>();
    // Always read from provider.selectedProducts — these are ALL selected products,
    // even if filtered out in overview screen.
    final selected = provider.selectedProducts;

    return Column(
      children: [
        const AppHeader(title: 'Stock Transfer', subtitle: 'Admin request ya Hub transfer'),
        if (selected.isEmpty)
          _emptyState()
        else
          Expanded(
            child: Column(
              children: [
                _selectionBar(context, provider, selected),
                _typeToggle(),
                if (_transferType == TransferType.hubTransfer) _hubDropdown(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: selected.length,
                    itemBuilder: (_, i) => _productCard(selected[i]),
                  ),
                ),
                _submitSection(context, provider, selected),
              ],
            ),
          ),
      ],
    );
  }

  // ── Empty ──────────────────────────────────────────────────────────
  Widget _emptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(color: ColorConst.greenPale, borderRadius: BorderRadius.circular(18)),
              child: const Icon(Icons.swap_horiz, color: ColorConst.primaryGreen, size: 32),
            ),
            const SizedBox(height: 18),
            const Text('Koi product select nahi hai',
                style: TextStyle(color: ColorConst.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text(
              'Stock Overview mein products select karein\nphir yahan transfer request banayein',
              textAlign: TextAlign.center,
              style: TextStyle(color: ColorConst.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // ── Selection bar ──────────────────────────────────────────────────
  Widget _selectionBar(BuildContext ctx, StockProvider provider, List<Product> sel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: ColorConst.greenSoft,
        border: Border(bottom: BorderSide(color: ColorConst.stroke)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: ColorConst.primaryGreen, size: 16),
          const SizedBox(width: 7),
          Text('${sel.length} product(s) selected',
              style: const TextStyle(color: ColorConst.primaryGreen, fontWeight: FontWeight.w600, fontSize: 13)),
          const Spacer(),
          TextButton.icon(
            onPressed: () { _qtyCtrl.clear(); provider.clearSelection(); },
            icon: const Icon(Icons.close, size: 14),
            label: const Text('Clear All'),
            style: TextButton.styleFrom(
                foregroundColor: ColorConst.error,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
          ),
        ],
      ),
    );
  }

  // ── Transfer type toggle ───────────────────────────────────────────
  Widget _typeToggle() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: ColorConst.containerGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorConst.borderColor),
      ),
      child: Row(
        children: [
          _toggleBtn('Admin Request', Icons.admin_panel_settings_outlined, TransferType.adminRequest),
          _toggleBtn('Hub Transfer',  Icons.hub_outlined,                  TransferType.hubTransfer),
        ],
      ),
    );
  }

  Widget _toggleBtn(String label, IconData icon, TransferType type) {
    final active = _transferType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() { _transferType = type; _selectedHub = null; }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? ColorConst.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: active ? [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 6, offset: const Offset(0, 2))] : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: active ? ColorConst.primaryGreen : ColorConst.textGrey),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontSize: 13, fontWeight: active ? FontWeight.w700 : FontWeight.w400, color: active ? ColorConst.primaryGreen : ColorConst.textGrey)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Hub dropdown ───────────────────────────────────────────────────
  Widget _hubDropdown() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: ColorConst.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorConst.borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedHub,
          hint: const Text('Hub select karein...', style: TextStyle(color: ColorConst.textGrey, fontSize: 13)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: ColorConst.textGrey),
          style: const TextStyle(color: ColorConst.textPrimary, fontSize: 14),
          items: _hubs.map((h) => DropdownMenuItem(
            value: h,
            child: Row(children: [
              const Icon(Icons.hub_outlined, size: 15, color: ColorConst.primaryGreen),
              const SizedBox(width: 8),
              Text(h),
            ]),
          )).toList(),
          onChanged: (v) => setState(() => _selectedHub = v),
        ),
      ),
    );
  }

  // ── Product card ───────────────────────────────────────────────────
  Widget _productCard(Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: ColorConst.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColorConst.borderColor),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(color: ColorConst.greenPale, borderRadius: BorderRadius.circular(9)),
                  child: const Icon(Icons.inventory_2, color: ColorConst.primaryGreen, size: 17),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(product.name,
                    style: const TextStyle(color: ColorConst.textPrimary, fontSize: 14, fontWeight: FontWeight.w700))),
              ],
            ),
          ),
          Divider(height: 1, color: ColorConst.borderColor),
          // Variants
          ...product.variants.map((v) => _variantRow(product, v)),
        ],
      ),
    );
  }

  Widget _variantRow(Product product, ProductVariant variant) {
    final ctrl = _ctrl(variant.id);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(variant.name, style: const TextStyle(color: ColorConst.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
                Text('SKU: ${variant.sku}', style: const TextStyle(color: ColorConst.textGrey, fontSize: 11)),
                const SizedBox(height: 3),
                _stockBadge(variant),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Stepper
          Container(
            decoration: BoxDecoration(
              color: ColorConst.containerGrey,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ColorConst.borderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _stepBtn(Icons.remove, () {
                  final v = int.tryParse(ctrl.text) ?? 0;
                  if (v > 0) setState(() => ctrl.text = '${v - 1}');
                }),
                SizedBox(
                  width: 44,
                  child: TextField(
                    controller: ctrl,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: ColorConst.textPrimary, fontWeight: FontWeight.w700, fontSize: 14),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                _stepBtn(Icons.add, () {
                  final v = int.tryParse(ctrl.text) ?? 0;
                  setState(() => ctrl.text = '${v + 1}');
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30, height: 30,
        decoration: BoxDecoration(color: ColorConst.greenSoft, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: ColorConst.primaryGreen, size: 15),
      ),
    );
  }

  Widget _stockBadge(ProductVariant v) {
    Color c; String label;
    if (v.availableStock <= 0)       { c = ColorConst.error;   label = 'Out of Stock'; }
    else if (v.availableStock <= 10) { c = ColorConst.warning; label = 'Low: ${v.availableStock}'; }
    else                             { c = ColorConst.success; label = 'Avail: ${v.availableStock}'; }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: c.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: c.withOpacity(0.3))),
      child: Text(label, style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }

  // ── Submit section ─────────────────────────────────────────────────
  Widget _submitSection(BuildContext context, StockProvider provider, List<Product> selected) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColorConst.white,
        border: Border(top: BorderSide(color: ColorConst.borderColor)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: Column(
        children: [
          TextField(
            controller: _noteCtrl,
            style: const TextStyle(color: ColorConst.textPrimary, fontSize: 13),
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Note add karein (optional)...',
              hintStyle: const TextStyle(color: ColorConst.textGrey, fontSize: 13),
              filled: true,
              fillColor: ColorConst.containerGrey,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              prefixIcon: const Icon(Icons.note_alt_outlined, color: ColorConst.textGrey, size: 18),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _submit(context, provider, selected),
              icon: Icon(_transferType == TransferType.hubTransfer ? Icons.hub : Icons.send, size: 18),
              label: Text(
                _transferType == TransferType.hubTransfer
                    ? 'Transfer to ${_selectedHub ?? "Hub"}'
                    : 'Send Admin Request',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _transferType == TransferType.hubTransfer
                    ? ColorConst.info
                    : ColorConst.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submit(BuildContext context, StockProvider provider, List<Product> selected) {
    if (_transferType == TransferType.hubTransfer && _selectedHub == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Pehle hub select karein!'), backgroundColor: ColorConst.warning));
      return;
    }

    final items = <StockRequestItem>[];
    for (final p in selected) {
      for (final v in p.variants) {
        final qty = int.tryParse(_qtyCtrl[v.id]?.text ?? '0') ?? 0;
        if (qty > 0) {
          items.add(StockRequestItem(
            productId: p.id, productName: p.name,
            variantId: v.id, variantName: v.name,
            quantityRequested: qty,
          ));
        }
      }
    }

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Kisi bhi variant mein quantity 0 hai!'), backgroundColor: ColorConst.warning));
      return;
    }

    // Save which hub before we clear
    final hubName = _selectedHub;

    provider.submitBulkRequest(
        items: items, note: _noteCtrl.text.trim(),
        transferType: _transferType, hubName: hubName);

    // Now clear selection from provider
    provider.clearSelection();

    // Reset local state
    _noteCtrl.clear();
    for (var c in _qtyCtrl.values) c.text = '0';
    setState(() { _selectedHub = null; });

    final msg = _transferType == TransferType.hubTransfer
        ? '✓ ${items.length} items $hubName ko transfer kiye!'
        : '✓ ${items.length} items ka admin request submit hua!';
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: ColorConst.success));
  }
}
