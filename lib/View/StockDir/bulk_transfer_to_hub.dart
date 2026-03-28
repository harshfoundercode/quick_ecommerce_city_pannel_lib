import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/city_stock_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/all_hub_list_view_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/city_stock_view_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/tost_msg/custom_snackbar.dart';

// ─────────────────────────────────────────────────────────────────────────────
// USAGE:
//   Navigator.push(context, MaterialPageRoute(
//     builder: (_) => BulkTransferScreen(allItems: vm.cityStockModel!.data!),
//   ));
// ─────────────────────────────────────────────────────────────────────────────

class BulkTransferScreen extends StatefulWidget {
  final List<CityStockData> allItems;
  const BulkTransferScreen({super.key, required this.allItems});

  @override
  State<BulkTransferScreen> createState() => _BulkTransferScreenState();
}

class _BulkTransferScreenState extends State<BulkTransferScreen> {
  // Hub
  String? _hubId;
  String? _hubName;

  // Remarks
  final _remarksCtrl = TextEditingController();

  // Product picker state
  String _searchQuery = '';
  final _searchCtrl   = TextEditingController();
  bool _pickerOpen    = false; // shows/hides the dropdown list

  // productid → qty
  final Map<int, int> _selectedQty = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        context.read<AllHubViewModel>().getHubListDataApi(context));
  }

  @override
  void dispose() {
    _remarksCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Color _stockColor(int s) {
    if (s == 0) return const Color(0xFFEF4444);
    if (s < 10) return const Color(0xFFDC2626);
    if (s < 20) return const Color(0xFFD97706);
    return ColorConst.primaryGreen;
  }

  List<CityStockData> get _filteredItems => _searchQuery.isEmpty
      ? widget.allItems
      : widget.allItems
      .where((i) => (i.product?.name ?? '').toLowerCase().contains(_searchQuery.toLowerCase()))
      .toList();

  bool get _hasSelections   => _selectedQty.isNotEmpty;
  int  get _totalUnits      => _selectedQty.values.fold(0, (s, q) => s + q);
  bool get _canConfirm      => _hubId != null && _hasSelections;

  void _toggle(CityStockData item) {
    final id = item.productid as int?;
    if (id == null || (item.stock ?? 0) == 0) return;
    setState(() {
      if (_selectedQty.containsKey(id)) _selectedQty.remove(id);
      else _selectedQty[id] = 1;
    });
  }

  void _setQty(int id, int qty) => setState(() => _selectedQty[id] = qty);

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: _buildAppBar(),
      body: Consumer2<CityStockViewModel, AllHubViewModel>(
        builder: (context, vm, hubVm, _) => GestureDetector(
          // Close picker when tapping outside
          onTap: () { if (_pickerOpen) setState(() => _pickerOpen = false); },
          behavior: HitTestBehavior.translucent,
          child: Column(children: [
            // ── Hub + remarks ──────────────────────────────────────
            _buildTopPanel(hubVm),

            // ── Product search dropdown ────────────────────────────
            _buildProductSearchSection(),

            // ── Selection strip ────────────────────────────────────
            if (_hasSelections) _buildSelectionStrip(),

            // ── Selected product list ──────────────────────────────
            if (_hasSelections)
              Expanded(child: _buildSelectedList())
            else
              Expanded(child: _buildEmptySelection()),

            // ── Confirm bar ────────────────────────────────────────
            _buildConfirmBar(vm),
          ]),
        ),
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() => AppBar(
    backgroundColor: ColorConst.primaryGreen,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
      onPressed: () => Navigator.pop(context),
    ),
    title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Bulk Transfer', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
      Text('Select products & quantities', style: TextStyle(color: Colors.white70, fontSize: 11)),
    ]),
    actions: [
      if (_hasSelections)
        TextButton(
          onPressed: () => setState(() => _selectedQty.clear()),
          child: const Text('Clear All', style: TextStyle(color: Colors.white70, fontSize: 12)),
        ),
    ],
  );

  // ── Hub + remarks panel ────────────────────────────────────────────────────

  Widget _buildTopPanel(AllHubViewModel hubVm) {
    final hubs = hubVm.hubListModel?.data?.hubs ?? [];
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      color: Colors.white,
      child: Column(children: [
        // Hub dropdown
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hubId != null ? ColorConst.primaryGreen : const Color(0xFFE5E7EB),
              width: _hubId != null ? 1.5 : 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _hubId,
              isExpanded: true,
              dropdownColor: Colors.white,
              hint: Row(children: [
                Icon(Icons.hub_outlined, size: 16, color: Colors.grey.shade400),
                const SizedBox(width: 8),
                const Text('Select destination hub', style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
              ]),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF6B7280)),
              items: hubs.map<DropdownMenuItem<String>>((h) => DropdownMenuItem<String>(
                value: h.hubId.toString(),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: ColorConst.primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(7)),
                    child: const Icon(Icons.store_outlined, size: 13, color: ColorConst.primaryGreen),
                  ),
                  const SizedBox(width: 10),
                  Text(h.hubName ?? 'Hub', style: const TextStyle(fontSize: 13, color: Color(0xFF111827))),
                ]),
              )).toList(),
              onChanged: (v) => setState(() {
                _hubId   = v;
                _hubName = hubs.firstWhere((h) => h.hubId.toString() == v).hubName;
              }),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Remarks
        TextField(
          controller: _remarksCtrl,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Remarks (optional)',
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
            prefixIcon: const Icon(Icons.notes_rounded, size: 16, color: Color(0xFF6B7280)),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: ColorConst.primaryGreen, width: 1.5)),
          ),
        ),
      ]),
    );
  }

  // ── Product search dropdown ────────────────────────────────────────────────

  Widget _buildProductSearchSection() {
    final filtered = _filteredItems;
    return Container(
      color: const Color(0xFFF4F6FA),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Search bar trigger
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: Row(children: [
            const Icon(Icons.inventory_2_outlined, size: 14, color: ColorConst.primaryGreen),
            const SizedBox(width: 6),
            const Text('Add Products', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: GestureDetector(
            onTap: () => setState(() => _pickerOpen = !_pickerOpen),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _pickerOpen ? ColorConst.primaryGreen : const Color(0xFFE5E7EB),
                  width: _pickerOpen ? 1.5 : 1,
                ),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: Row(children: [
                const SizedBox(width: 12),
                const Icon(Icons.search_rounded, size: 18, color: ColorConst.primaryGreen),
                const SizedBox(width: 10),
                Expanded(
                  child: _pickerOpen
                      ? TextField(
                    controller: _searchCtrl,
                    autofocus: true,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'Search products to add…',
                      hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                      border: InputBorder.none, isDense: true,
                    ),
                  )
                      : Text(
                    _hasSelections
                        ? 'Add more products…'
                        : 'Search & select products to transfer',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () { _searchCtrl.clear(); setState(() => _searchQuery = ''); },
                    child: const Padding(padding: EdgeInsets.only(right: 12),
                        child: Icon(Icons.close_rounded, size: 15, color: Color(0xFF9CA3AF))),
                  ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                      _pickerOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      size: 18, color: const Color(0xFF6B7280)),
                ),
              ]),
            ),
          ),
        ),

        // Dropdown list
        if (_pickerOpen)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 4))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // Legend header
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
                  child: Row(children: [
                    Text('${filtered.length} products', style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                    const Spacer(),
                    _dot(ColorConst.primaryGreen, 'In stock'),
                    const SizedBox(width: 8),
                    _dot(const Color(0xFFDC2626), 'Low'),
                    const SizedBox(width: 8),
                    _dot(const Color(0xFFEF4444), 'Out'),
                  ]),
                ),
                const Divider(height: 1, color: Color(0xFFF3F4F6)),
                Flexible(
                  child: filtered.isEmpty
                      ? const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No products found', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)))
                      : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    shrinkWrap: true,
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, indent: 14, endIndent: 14, color: Color(0xFFF3F4F6)),
                    itemBuilder: (_, i) {
                      final item  = filtered[i];
                      final id    = item.productid as int?;
                      final stock = item.stock ?? 0;
                      final isOut = stock == 0;
                      final isSel = id != null && _selectedQty.containsKey(id);
                      final color = _stockColor(stock);

                      return InkWell(
                        onTap: () {
                          _toggle(item);
                          if (isOut) {
                            CustomSnackBar.show(context,
                                message: '${item.product?.name} is out of stock',
                                type: SnackBarType.error);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          child: Row(children: [
                            Container(width: 8, height: 8,
                                decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(item.product?.name ?? '',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                                      color: isOut ? const Color(0xFF9CA3AF) : const Color(0xFF111827))),
                              Row(children: [
                                Text(isOut ? 'Out of stock' : '$stock units',
                                    style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
                                if (item.category != null) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(5)),
                                    child: Text(item.category?.categoryName!, style: const TextStyle(fontSize: 9, color: Color(0xFF6B7280))),
                                  ),
                                ],
                              ]),
                            ])),
                            if (isSel)
                              const Icon(Icons.check_circle_rounded, color: ColorConst.primaryGreen, size: 20)
                            else if (isOut)
                              const Icon(Icons.lock_outline_rounded, color: Color(0xFFD1D5DB), size: 16)
                            else
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: ColorConst.primaryGreen.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.add_rounded, color: ColorConst.primaryGreen, size: 14),
                              ),
                          ]),
                        ),
                      );
                    },
                  ),
                ),
              ]),
            ),
          ),
        const SizedBox(height: 8),
      ]),
    );
  }

  // ── Selection strip ────────────────────────────────────────────────────────

  Widget _buildSelectionStrip() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    color: ColorConst.primaryGreen.withOpacity(0.06),
    child: Row(children: [
      Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(color: ColorConst.primaryGreen.withOpacity(0.15), shape: BoxShape.circle),
        child: const Icon(Icons.check_rounded, size: 12, color: ColorConst.primaryGreen),
      ),
      const SizedBox(width: 8),
      Text('${_selectedQty.length} products  •  $_totalUnits units',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ColorConst.primaryGreen)),
      const Spacer(),
      GestureDetector(
        onTap: () => setState(() => _selectedQty.clear()),
        child: const Text('Clear', style: TextStyle(fontSize: 11, color: Color(0xFFDC2626), fontWeight: FontWeight.w600)),
      ),
    ]),
  );

  // ── Selected product list (qty steppers) ───────────────────────────────────

  Widget _buildSelectedList() {
    final selected = widget.allItems
        .where((i) => i.productid != null && _selectedQty.containsKey(i.productid as int))
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      itemCount: selected.length,
      itemBuilder: (_, i) {
        final item  = selected[i];
        final id    = item.productid as int;
        final stock = item.stock ?? 0;
        final qty   = _selectedQty[id] ?? 1;
        final color = _stockColor(stock);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: ColorConst.primaryGreen.withOpacity(0.25)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Row(children: [
            // Remove button
            GestureDetector(
              onTap: () => setState(() => _selectedQty.remove(id)),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(6)),
                child: Icon(Icons.close_rounded, size: 13, color: Colors.red.shade400),
              ),
            ),
            const SizedBox(width: 10),

            // Product info
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.product?.name ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              Row(children: [
                Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text('$stock available', style: TextStyle(fontSize: 10, color: color)),
              ]),
            ])),
            const SizedBox(width: 10),

            // Qty stepper
            Row(mainAxisSize: MainAxisSize.min, children: [
              _stepBtn(Icons.remove_rounded, qty <= 1 ? null : () => _setQty(id, qty - 1)),
              Container(width: 38, alignment: Alignment.center,
                  child: Text('$qty', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: ColorConst.primaryGreen))),
              _stepBtn(Icons.add_rounded, qty >= stock ? null : () => _setQty(id, qty + 1)),
            ]),
          ]),
        );
      },
    );
  }

  // ── Empty selection state ──────────────────────────────────────────────────

  Widget _buildEmptySelection() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.add_shopping_cart_rounded, size: 52, color: Colors.grey.shade300),
      const SizedBox(height: 12),
      const Text('No products selected yet', style: TextStyle(color: Color(0xFF6B7280), fontSize: 15, fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      const Text('Search above and tap products to add them', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
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
    child: Row(children: [
      Expanded(child: _hasSelections
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${_selectedQty.length} products  •  $_totalUnits units',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
        Text('→ ${_hubName ?? 'Select hub'}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
      ])
          : const Text('Select products above', style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)))),
      const SizedBox(width: 12),
      SizedBox(
        height: 48,
        child: ElevatedButton.icon(
          onPressed: (_canConfirm && !vm.transferLoading) ? () {
            final items = _selectedQty.entries.map((e) {
              final product = widget.allItems.firstWhere((i) => i.productid == e.key);
              return {'productid': e.key, 'variantid': product.variantid ?? 0, 'qty': e.value};
            }).toList();
            vm.cityTransferToHubApi(context, _hubId!,
                _remarksCtrl.text.trim().isEmpty ? 'Bulk transfer from city panel' : _remarksCtrl.text.trim(),
                items);
          } : null,
          icon: vm.transferLoading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.send_rounded, size: 16, color: Colors.white),
          label: Text(vm.transferLoading ? 'Sending…' : 'Transfer Now',
              style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: _canConfirm ? ColorConst.primaryGreen : Colors.grey.shade300,
            disabledBackgroundColor: Colors.grey.shade300,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    ]),
  );

  // ── Tiny helpers ───────────────────────────────────────────────────────────

  Widget _stepBtn(IconData icon, VoidCallback? onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 28, height: 28,
      decoration: BoxDecoration(
        color: onTap != null ? ColorConst.primaryGreen.withOpacity(0.08) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: onTap != null ? ColorConst.primaryGreen.withOpacity(0.3) : Colors.grey.shade200),
      ),
      child: Icon(icon, size: 14, color: onTap != null ? ColorConst.primaryGreen : Colors.grey.shade300),
    ),
  );

  Widget _dot(Color c, String l) => Row(children: [
    Container(width: 7, height: 7, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
    const SizedBox(width: 4),
    Text(l, style: const TextStyle(fontSize: 9, color: Color(0xFF9CA3AF))),
  ]);
}