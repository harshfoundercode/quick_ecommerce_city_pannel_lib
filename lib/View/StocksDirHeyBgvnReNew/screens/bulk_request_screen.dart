import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/tost_msg/custom_snackbar.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/StocksDirHeyBgvnReNew/models/main_catsubcat_all_data_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/StocksDirHeyBgvnReNew/models/transfer_stock_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/StocksDirHeyBgvnReNew/providers/stock_provider_new.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/all_hub_list_view_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/city_stock_view_model.dart';
import '../widgets/app_header.dart';

// ════════════════════════════════════════════════════════════════════════════
// THEME CONSTANTS  (matches your ColorConst palette)
// ════════════════════════════════════════════════════════════════════════════

const _kBg = Color(0xFFF4F6F9);
const _kSurf = Colors.white;
const _kBorder = ColorConst.borderColor;
const _kGreen = ColorConst.primaryGreen;
const _kGreenSoft = ColorConst.greenSoft;
const _kT1 = ColorConst.textPrimary;
const _kT2 = ColorConst.textGrey;
const _kError = ColorConst.error;
const _kInfo = ColorConst.info;
const _kWarn = ColorConst.warning;

// ════════════════════════════════════════════════════════════════════════════
// SCREEN
// ════════════════════════════════════════════════════════════════════════════

class BulkRequestScreen extends StatefulWidget {
  const BulkRequestScreen({super.key});

  @override
  State<BulkRequestScreen> createState() => _BulkRequestScreenState();
}

class _BulkRequestScreenState extends State<BulkRequestScreen> {
  // Per-variant qty controllers — keyed by variantId (UNCHANGED)
  final Map<String, TextEditingController> _qtyCtrl = {};
  final TextEditingController _noteCtrl = TextEditingController();
  TransferType _transferType = TransferType.adminRequest;
  String? _selectedHub;

  // Per-variant validation errors — keyed by variantId (NEW)
  final Map<String, String?> _variantErrors = {};

  @override
  void dispose() {
    for (var c in _qtyCtrl.values) {
      c.dispose();
    }
    _noteCtrl.dispose();
    super.dispose();
  }

  TextEditingController _ctrl(String variantId) =>
      _qtyCtrl[variantId] ??= TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // UNCHANGED — same as original
      final allHubViewModel = Provider.of<AllHubViewModel>(
        context,
        listen: false,
      );
      allHubViewModel.getHubListDataApi(context);
    });
  }

  // ── Helper ─────────────────────────────────────────────────────────────────
  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // ── Real-time stock validation (NEW) ───────────────────────────────────────
  void _validateVariant(Variants variant, String input) {
    final key = variant.variantId.toString();
    final entered = int.tryParse(input) ?? 0;
    final available = _parseInt(variant.stock);

    setState(() {
      if (_transferType == TransferType.hubTransfer && entered > available) {
        _variantErrors[key] = 'Max $available available in stock';
      } else {
        _variantErrors.remove(key);
      }
    });
  }

  // ── Check if any variant has error ────────────────────────────────────────
  bool get _hasStockError => _variantErrors.values.any((e) => e != null);

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StockProvider>();
    final selected = provider.selectedProducts;

    return Column(
      children: [
        const AppHeader(
          title: 'Stock Transfer',
          subtitle: 'Admin request ya Hub transfer',
        ),
        Expanded(
          child: selected.isEmpty
              ? _emptyState()
              : _splitLayout(context, provider, selected),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SPLIT LAYOUT  — Left: products+qty | Right: config+submit
  // ══════════════════════════════════════════════════════════════════════════

  Widget _splitLayout(
    BuildContext context,
    StockProvider provider,
    List<Products> selected,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── LEFT PANEL (55%) ────────────────────────────────────────────────
        Expanded(
          flex: 55,
          child: Column(
            children: [
              _leftHeader(provider, selected),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: selected.length,
                  itemBuilder: (_, i) => _productCard(selected[i]),
                ),
              ),
            ],
          ),
        ),

        // ── DIVIDER ─────────────────────────────────────────────────────────
        Container(width: 1, color: _kBorder),

        // ── RIGHT PANEL (45%) ───────────────────────────────────────────────
        Expanded(flex: 45, child: _rightPanel(context, provider, selected)),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LEFT — header bar
  // ══════════════════════════════════════════════════════════════════════════

  Widget _leftHeader(StockProvider provider, List<Products> selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: _kGreenSoft,
        border: Border(bottom: BorderSide(color: _kBorder)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: _kGreen, size: 16),
          const SizedBox(width: 7),
          Text(
            '${selected.length} product${selected.length > 1 ? 's' : ''} selected',
            style: const TextStyle(
              color: _kGreen,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () {
              _qtyCtrl.clear();
              _variantErrors.clear();
              provider.clearProductSelection();
            },
            icon: const Icon(Icons.close, size: 14),
            label: const Text('Clear All'),
            style: TextButton.styleFrom(
              foregroundColor: _kError,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LEFT — product card  (UNCHANGED API logic, new layout)
  // ══════════════════════════════════════════════════════════════════════════

  Widget _productCard(Products product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _kSurf,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // product header
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              children: [
                // image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      (product.img != null && product.img.toString().isNotEmpty)
                      ? Image.network(
                          product.img.toString(),
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _productIcon(),
                        )
                      : _productIcon(),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name?.toString() ?? 'Unnamed',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: _kT1,
                        ),
                      ),
                      if (product.sku != null)
                        Text(
                          'SKU: ${product.sku}',
                          style: const TextStyle(fontSize: 10, color: _kT2),
                        ),
                    ],
                  ),
                ),
                // variant count badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _kGreenSoft,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${product.variants?.length ?? 0} variant${(product.variants?.length ?? 1) != 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: _kGreen,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _kBorder),
          // variant rows
          if (product.variants != null)
            ...product.variants!.map((v) => _variantRow(product, v)),
        ],
      ),
    );
  }

  Widget _productIcon() => Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      color: _kGreenSoft,
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Icon(Icons.inventory_2, color: _kGreen, size: 18),
  );

  Widget _variantRow(Products product, Variants variant) {
    final ctrl = _ctrl(variant.variantId.toString());
    final stock = _parseInt(variant.stock);
    final errKey = variant.variantId.toString();
    final hasErr = _variantErrors[errKey] != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: hasErr ? _kError.withValues(alpha: 0.04) : _kBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasErr ? _kError.withValues(alpha: 0.4) : _kBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // variant info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      variant.value?.toString() ?? 'Default',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _kT1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // stock chip
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: stock > 0
                                ? _kGreen.withValues(alpha: 0.1)
                                : _kError.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Stock: $stock',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: stock > 0 ? _kGreen : _kError,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // ── Stepper  (UNCHANGED logic) ────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: _kSurf,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: hasErr ? _kError.withValues(alpha: 0.5) : _kBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _stepBtn(Icons.remove, () {
                      final v = int.tryParse(ctrl.text) ?? 0;
                      if (v > 0) {
                        ctrl.text = '${v - 1}';
                        _validateVariant(variant, ctrl.text);
                      }
                    }),
                    SizedBox(
                      width: 44,
                      child: TextField(
                        controller: ctrl,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: hasErr ? _kError : _kT1,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (val) => _validateVariant(variant, val),
                      ),
                    ),
                    _stepBtn(Icons.add, () {
                      final v = int.tryParse(ctrl.text) ?? 0;
                      ctrl.text = '${v + 1}';
                      _validateVariant(variant, ctrl.text);
                    }),
                  ],
                ),
              ),
            ],
          ),
          // inline error message
          if (hasErr) ...[
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 13,
                  color: _kError,
                ),
                const SizedBox(width: 4),
                Text(
                  _variantErrors[errKey]!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: _kError,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: _kGreenSoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: _kGreen, size: 15),
    ),
  );

  // ══════════════════════════════════════════════════════════════════════════
  // RIGHT PANEL — transfer config + note + submit
  // ══════════════════════════════════════════════════════════════════════════

  Widget _rightPanel(
    BuildContext context,
    StockProvider provider,
    List<Products> selected,
  ) {
    return Column(
      children: [
        // ── Header ────────────────────────────────────────────────────────────
        _panelHeader('⚙️  Transfer Config', _kInfo),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Transfer type toggle ─────────────────────────────────────────
                _sectionLabel('Transfer Type'),
                const SizedBox(height: 8),
                _typeToggle(),

                // ── Hub dropdown (only for hub transfer) ─────────────────────────
                if (_transferType == TransferType.hubTransfer) ...[
                  const SizedBox(height: 14),
                  _sectionLabel('Select Hub'),
                  const SizedBox(height: 8),
                  _hubDropdown(),
                ],

                // ── Stock error summary ──────────────────────────────────────────
                if (_hasStockError &&
                    _transferType == TransferType.hubTransfer) ...[
                  const SizedBox(height: 14),
                  _stockErrorBanner(),
                ],

                const SizedBox(height: 14),

                // ── Note field ───────────────────────────────────────────────────
                _sectionLabel('Note (optional)'),
                const SizedBox(height: 8),
                TextField(
                  controller: _noteCtrl,
                  style: const TextStyle(color: _kT1, fontSize: 13),
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Note add karein...',
                    hintStyle: const TextStyle(color: _kT2, fontSize: 13),
                    filled: true,
                    fillColor: _kBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(
                      Icons.note_alt_outlined,
                      color: _kT2,
                      size: 18,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Summary card ─────────────────────────────────────────────────
                _summaryCard(selected),
              ],
            ),
          ),
        ),

        // ── Submit button (pinned at bottom) ─────────────────────────────────
        _submitFooter(context, provider, selected),
      ],
    );
  }

  // ── Section label ──────────────────────────────────────────────────────────
  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: _kT2,
      letterSpacing: 0.5,
    ),
  );

  // ── Panel header bar ───────────────────────────────────────────────────────
  Widget _panelHeader(String title, Color color) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    color: color.withValues(alpha: 0.07),
    child: Text(
      title,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.w800,
        fontSize: 13,
        letterSpacing: 0.3,
      ),
    ),
  );

  // ── Transfer type toggle (same logic, new styling) ─────────────────────────
  Widget _typeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _kBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        children: [
          _toggleBtn(
            'Admin Request',
            Icons.admin_panel_settings_outlined,
            TransferType.adminRequest,
          ),
          _toggleBtn(
            'Hub Transfer',
            Icons.hub_outlined,
            TransferType.hubTransfer,
          ),
        ],
      ),
    );
  }

  Widget _toggleBtn(String label, IconData icon, TransferType type) {
    final active = _transferType == type;
    final activeColor = type == TransferType.hubTransfer ? _kInfo : _kGreen;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _transferType = type;
          _selectedHub = null;
          // Clear stock errors when switching away from hub transfer
          _variantErrors.clear();
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? _kSurf : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.07),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: active ? activeColor : _kT2),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                  color: active ? activeColor : _kT2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Hub dropdown (UNCHANGED API logic) ────────────────────────────────────
  Widget _hubDropdown() {
    return Consumer<AllHubViewModel>(
      builder: (context, hubVM, _) {
        final hubs = hubVM.hubListModel?.data?.hubs ?? [];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: _kSurf,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _kBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedHub,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: _kT2),
              style: const TextStyle(color: _kT1, fontSize: 14),
              hint: hubVM.isLoading
                  ? const Text(
                      'Loading hubs...',
                      style: TextStyle(color: _kT2, fontSize: 13),
                    )
                  : const Text(
                      'Hub select karein...',
                      style: TextStyle(color: _kT2, fontSize: 13),
                    ),
              items: hubs.map<DropdownMenuItem<String>>((hub) {
                return DropdownMenuItem<String>(
                  value: hub.hubId.toString(),
                  child: Row(
                    children: [
                      const Icon(Icons.hub_outlined, size: 15, color: _kInfo),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          hub.hubName?.toString() ?? 'Unnamed Hub',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedHub = val),
            ),
          ),
        );
      },
    );
  }

  // ── Stock error banner (NEW) ───────────────────────────────────────────────
  Widget _stockErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kError.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kError.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: _kError, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stock limit exceeded',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: _kError,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${_variantErrors.values.where((e) => e != null).length} variant(s) have quantity greater than available stock.',
                  style: TextStyle(
                    fontSize: 11,
                    color: _kError.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Summary card (NEW — shows items with qty > 0) ─────────────────────────
  Widget _summaryCard(List<Products> selected) {
    final lines = <_SummaryLine>[];
    for (final p in selected) {
      for (final v in p.variants ?? []) {
        final qty = int.tryParse(_ctrl(v.variantId.toString()).text) ?? 0;
        if (qty > 0) {
          lines.add(
            _SummaryLine(
              name: '${p.name} · ${v.value}',
              qty: qty,
              hasError: _variantErrors[v.variantId.toString()] != null,
            ),
          );
        }
      }
    }

    if (lines.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: _kSurf,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: const BoxDecoration(
              color: _kBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(bottom: BorderSide(color: _kBorder)),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_outlined, size: 15, color: _kT2),
                const SizedBox(width: 6),
                const Text(
                  'Order Summary',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: _kT1,
                  ),
                ),
                const Spacer(),
                Text(
                  '${lines.length} item${lines.length > 1 ? 's' : ''}',
                  style: const TextStyle(fontSize: 11, color: _kT2),
                ),
              ],
            ),
          ),
          // items
          ...lines.map(
            (l) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              child: Row(
                children: [
                  Icon(
                    l.hasError
                        ? Icons.warning_amber_rounded
                        : Icons.check_circle_outline,
                    size: 13,
                    color: l.hasError ? _kError : _kGreen,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      l.name,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: l.hasError ? _kError : _kT1,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: l.hasError
                          ? _kError.withValues(alpha: 0.1)
                          : _kGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '×${l.qty}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: l.hasError ? _kError : _kGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SUBMIT FOOTER (pinned)
  // ══════════════════════════════════════════════════════════════════════════

  Widget _submitFooter(
    BuildContext context,
    StockProvider provider,
    List<Products> selected,
  ) {
    // Button is disabled when:
    // 1. Hub transfer selected but no hub chosen
    // 2. Any variant has stock validation error
    final bool isHubMissing =
        _transferType == TransferType.hubTransfer && _selectedHub == null;
    final bool isDisabled = isHubMissing || _hasStockError;

    String tooltip = '';
    if (isHubMissing) tooltip = 'Pehle hub select karein';
    if (_hasStockError) tooltip = 'Kuch variants mein stock limit exceed hai';

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
      child: Column(
        children: [
          // disabled reason hint
          if (isDisabled) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: _kWarn.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _kWarn.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 14, color: _kWarn),
                  const SizedBox(width: 7),
                  Flexible(
                    child: Text(
                      tooltip,
                      style: const TextStyle(
                        fontSize: 11,
                        color: _kWarn,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isDisabled
                  ? null
                  : () => _submit(context, provider, selected),
              icon: Icon(
                _transferType == TransferType.hubTransfer
                    ? Icons.hub
                    : Icons.send,
                size: 18,
              ),
              label: Text(
                _transferType == TransferType.hubTransfer
                    ? 'Transfer to Hub'
                    : 'Send Admin Request',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDisabled
                    ? Colors.grey.shade300
                    : (_transferType == TransferType.hubTransfer
                          ? _kInfo
                          : _kGreen),
                foregroundColor: isDisabled ? Colors.grey : Colors.white,
                disabledBackgroundColor: Colors.grey.shade200,
                disabledForegroundColor: Colors.grey.shade400,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: isDisabled ? 0 : 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SUBMIT — COMPLETELY UNCHANGED from original
  // ══════════════════════════════════════════════════════════════════════════

  void _submit(
    BuildContext context,
    StockProvider provider,
    List<Products> selected,
  ) async {
    final cityRequest = Provider.of<CityStockViewModel>(context, listen: false);

    // validation for hub (UNCHANGED)
    if (_transferType == TransferType.hubTransfer && _selectedHub == null) {
      CustomSnackBar.show(
        context,
        message: 'Select your hub first!',
        type: SnackBarType.warning,
      );
      return;
    }

    final items = <StockRequestItem>[];
    final adminApiItems = <Map<String, dynamic>>[];
    final hubApiItems = <Map<String, dynamic>>[];

    for (final p in selected) {
      for (final v in p.variants ?? []) {
        final qty = int.tryParse(_ctrl(v.variantId.toString()).text) ?? 0;

        if (qty > 0) {
          items.add(
            StockRequestItem(
              productId: p.productId.toString(),
              productName: p.name?.toString() ?? 'Unknown',
              variantId: v.variantId.toString(),
              variantName: v.value?.toString() ?? 'Default',
              quantityRequested: qty,
            ),
          );
          adminApiItems.add({"productid": p.productId, "qty": qty});
          hubApiItems.add({
            "productid": p.productId,
            "variantid": v.variantId,
            "qty": qty,
          });
        }
      }
    }

    if (items.isEmpty) {
      CustomSnackBar.show(
        context,
        message: 'Check your variant quantity!',
        type: SnackBarType.warning,
      );
      return;
    }

    // ADMIN REQUEST — UNCHANGED
    if (_transferType == TransferType.adminRequest) {
      await cityRequest.cityRequestApi(
        context,
        _noteCtrl.text.trim(),
        adminApiItems,
      );
      provider.clearProductSelection();
      _noteCtrl.clear();
      for (var c in _qtyCtrl.values) {
        c.text = '0';
      }
      return;
    }

    // HUB TRANSFER — stock validation (UNCHANGED double-check at submit time)
    if (_transferType == TransferType.hubTransfer) {
      for (final p in selected) {
        for (final v in p.variants ?? []) {
          final enteredQty =
              int.tryParse(_ctrl(v.variantId.toString()).text) ?? 0;
          final availableStock = _parseInt(v.stock);
          if (enteredQty > availableStock) {
            CustomSnackBar.show(
              context,
              message:
                  '${p.name} (${v.value}) ka quantity stock se zyada nahi ho sakta.\nAvailable: $availableStock',
              type: SnackBarType.error,
            );
            return;
          }
        }
      }

      await cityRequest.cityTransferToHubBulkApi(
        context,
        _selectedHub.toString(),
        _noteCtrl.text.trim(),
        hubApiItems,
      );
      provider.clearProductSelection();
      _noteCtrl.clear();
      for (var c in _qtyCtrl.values) {
        c.text = '0';
      }
      setState(() => _selectedHub = null);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // EMPTY STATE  (UNCHANGED)
  // ══════════════════════════════════════════════════════════════════════════

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _kSurf,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _kGreen.withValues(alpha: 0.15),
                      _kGreen.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: _kGreen,
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'No products selected',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _kT1,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Go to Stock Overview, select products,\nand then create a transfer request here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _kT2, fontSize: 13.5, height: 1.5),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryLine {
  final String name;
  final int qty;
  final bool hasError;
  const _SummaryLine({
    required this.name,
    required this.qty,
    required this.hasError,
  });
}
