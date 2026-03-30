import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/tost_msg/custom_snackbar.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/city_stock_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/city_stock_view_model.dart';

class RequestStockToAdminScreen extends StatefulWidget {
  const RequestStockToAdminScreen({
    super.key,
  });

  @override
  State<RequestStockToAdminScreen> createState() => _RequestStockToAdminScreenState();
}

class _RequestStockToAdminScreenState extends State<RequestStockToAdminScreen> {
  // Each entry: { product, qty, note }
  final List<_RequestEntry> _entries = [];
  final TextEditingController _remarkController = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      final stockProducts = Provider.of<CityStockViewModel>(context,listen: false);
      stockProducts.getCityStockDataApi(context);
    });
    // if (widget.preSelected != null) {
    //   _entries.add(_RequestEntry(selectedProduct: widget.preSelected!));
    // } else {
    //   _entries.add(_RequestEntry());
    // }
  }

  @override
  void dispose() {
    _remarkController.dispose();
    for (final e in _entries) {
      e.dispose();
    }
    super.dispose();
  }

  void _addEntry() {
    setState(() {
      _entries.add(_RequestEntry());
    });
  }

  void _removeEntry(int index) {
    if (_entries.length == 1) {
      CustomSnackBar.show(
        context,
        message: "At least one product is required",
        type: SnackBarType.error,
      );
      return;
    }
    setState(() {
      _entries[index].dispose();
      _entries.removeAt(index);
    });
  }

  Future<void> _submitRequest(CityStockViewModel vm) async {
    // Validate all entries
    for (int i = 0; i < _entries.length; i++) {
      final entry = _entries[i];
      if (entry.selectedProduct == null) {
        CustomSnackBar.show(
          context,
          message: "Select a product for entry ${i + 1}",
          type: SnackBarType.error,
        );
        return;
      }
      final qty = int.tryParse(entry.qtyController.text);
      if (qty == null || qty <= 0) {
        CustomSnackBar.show(
          context,
          message: "Enter valid quantity for entry ${i + 1}",
          type: SnackBarType.error,
        );
        return;
      }
    }

    final items = _entries.map((e) {
      return {
        "productid": e.selectedProduct!.productid,
        "qty": int.tryParse(e.qtyController.text) ?? 1,
      };
    }).toList();

    final remark = _remarkController.text.isNotEmpty
        ? _remarkController.text
        : "Stock request from city panel";

    await vm.cityRequestApi(context, remark, items);
  }

  // Returns products not already selected in other entries (except current)
  List<CityStockData> _availableProducts(int currentIndex) {
    final stockProducts = Provider.of<CityStockViewModel>(context,listen: false);
    final selectedIds = _entries
        .asMap()
        .entries
        .where((e) => e.key != currentIndex && e.value.selectedProduct != null)
        .map((e) => e.value.selectedProduct!.productid)
        .toSet();

    return stockProducts.cityStockModel!.data!.where((p) => !selectedIds.contains(p.productid))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: Consumer<CityStockViewModel>(
        builder: (context, vm, _) {
          return Column(
            children: [
              // Header summary strip
              _buildHeaderStrip(),

              // Scrollable content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  children: [
                    // Remark field
                    _buildRemarkField(),
                    const SizedBox(height: 16),

                    // Section header
                    Row(
                      children: [
                        const Text(
                          'Products to Request',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_entries.length} item${_entries.length > 1 ? 's' : ''}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Product entries
                    ...List.generate(_entries.length, (index) {
                      return _buildProductEntry(index, vm);
                    }),

                    const SizedBox(height: 12),

                    // Add more button
                    _buildAddMoreButton(),
                  ],
                ),
              ),
            ],
          );
        },
      ),

      // Bottom submit bar
      bottomNavigationBar: Consumer<CityStockViewModel>(
        builder: (context, vm, _) => _buildSubmitBar(vm),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: ColorConst.primaryGreen,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Request Stock',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'Request products from warehouse',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStrip() {
    final totalQty = _entries.fold<int>(
      0,
          (sum, e) => sum + (int.tryParse(e.qtyController.text) ?? 0),
    );
    final validEntries = _entries.where((e) => e.selectedProduct != null).length;

    return Container(
      color: ColorConst.primaryGreen,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          _buildStripStat(Icons.inventory_2_outlined, '$validEntries', 'Products'),
          _buildStripDivider(),
          _buildStripStat(Icons.numbers_rounded, '$totalQty', 'Total Units'),
          _buildStripDivider(),
          _buildStripStat(
            Icons.check_circle_outline_rounded,
            _entries.every((e) =>
            e.selectedProduct != null &&
                (int.tryParse(e.qtyController.text) ?? 0) > 0)
                ? 'Ready'
                : 'Pending',
            'Status',
          ),
        ],
      ),
    );
  }

  Widget _buildStripStat(IconData icon, String value, String label) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              Text(
                label,
                style: const TextStyle(color: Colors.white60, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStripDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.white24,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildRemarkField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _remarkController,
        maxLines: 2,
        style: const TextStyle(fontSize: 14, color: Color(0xFF1F2937)),
        decoration: InputDecoration(
          hintText: 'Add a remark (optional)...',
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Icon(Icons.notes_rounded, color: ColorConst.primaryGreen, size: 20),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildProductEntry(int index, CityStockViewModel vm) {
    final entry = _entries[index];
    final available = _availableProducts(index);
    final product = entry.selectedProduct;

    final isLow = product != null && (product.stock ?? 0) < 10;
    final isOut = product != null && (product.stock ?? 0) == 0;

    Color borderColor = Colors.transparent;
    if (isOut) borderColor = const Color(0xFFEF4444);
    else if (isLow) borderColor = const Color(0xFFF59E0B);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Entry header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: ColorConst.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Item ${index + 1}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: ColorConst.primaryGreen,
                    ),
                  ),
                ),
                const Spacer(),
                if (_entries.length > 1)
                  GestureDetector(
                    onTap: () => _removeEntry(index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Product Dropdown
            const Text(
              'Select Product',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 6),
            _buildProductDropdown(index, available, entry),

            // Product info chips (shown when selected)
            if (product != null) ...[
              const SizedBox(height: 10),
              _buildProductInfoChips(product),
            ],

            const SizedBox(height: 12),

            // Quantity input
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Request Quantity',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 6),
                      _buildQtyField(entry),
                    ],
                  ),
                ),
                if (product != null) ...[
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Stock',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 46,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isOut
                              ? const Color(0xFFFEE2E2)
                              : isLow
                              ? const Color(0xFFFEF3C7)
                              : const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '${product.stock ?? 0}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isOut
                                  ? const Color(0xFFEF4444)
                                  : isLow
                                  ? const Color(0xFFF59E0B)
                                  : const Color(0xFF059669),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),

            // Stock warning
            if (isOut || isLow) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isOut
                      ? const Color(0xFFFEE2E2)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      isOut
                          ? Icons.cancel_outlined
                          : Icons.warning_amber_rounded,
                      size: 14,
                      color: isOut
                          ? const Color(0xFFEF4444)
                          : const Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOut
                          ? 'Out of stock — urgent request needed'
                          : 'Low stock — consider requesting more',
                      style: TextStyle(
                        fontSize: 11,
                        color: isOut
                            ? const Color(0xFFEF4444)
                            : const Color(0xFFD97706),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProductDropdown(
      int index,
      List<CityStockData> available,
      _RequestEntry entry,
      ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFFF9FAFB),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: entry.selectedProduct?.productid,
          hint: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Search & select product...',
              style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
            ),
          ),
          isExpanded: true,
          dropdownColor: Colors.white,
          icon: const Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(Icons.keyboard_arrow_down_rounded,
                color: ColorConst.primaryGreen),
          ),
          items: available.map((product) {
            final stockColor = (product.stock ?? 0) == 0
                ? const Color(0xFFEF4444)
                : (product.stock ?? 0) < 10
                ? const Color(0xFFF59E0B)
                : ColorConst.primaryGreen;

            return DropdownMenuItem<int>(
              value: product.productid,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  children: [
                    // Stock indicator dot
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: stockColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            product.product?.name ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              if (product.variant?.name != null &&
                                  product.variant?.name != 'Default')
                                Text(
                                  '${product.variant?.name} · ',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              Text(
                                product.category?.categoryName ?? '',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: stockColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${product.stock ?? 0}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: stockColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          onChanged: (productId) {
            setState(() {
              entry.selectedProduct = available.firstWhere(
                    (p) => p.productid == productId,
              );
            });
          },
        ),
      ),
    );
  }

  Widget _buildProductInfoChips(CityStockData product) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (product.category?.mainCategoryName != null)
            _infoChip(Icons.category_outlined, product.category?.mainCategoryName,
                const Color(0xFF6366F1)),
          if (product.category != null)
            _infoChip(Icons.label_outline_rounded, product.category?.mainCategoryName,
                const Color(0xFF0891B2)),
          if (product.category?.subcategoryName != null)
            _infoChip(
                Icons.subdirectory_arrow_right_rounded,
                product.category?.subcategoryName,
                const Color(0xFF059669)),
          if (product.variant!.name != null &&
              product.variant!.name != 'Default')
            _infoChip(Icons.tune_rounded, product.variant!.name,
                const Color(0xFFF59E0B)),
          _infoChip(Icons.download_rounded,
              'Received: ${product.totalReceived ?? "0"}',
              const Color(0xFF8B5CF6)),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyField(_RequestEntry entry) {
    return TextField(
      controller: entry.qtyController,
      keyboardType: TextInputType.number,
      onChanged: (_) => setState(() {}),
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1F2937),
      ),
      decoration: InputDecoration(
        hintText: '0',
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
        prefixIcon: const Icon(
          Icons.add_shopping_cart_rounded,
          color: ColorConst.primaryGreen,
          size: 18,
        ),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
          const BorderSide(color: ColorConst.primaryGreen, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildAddMoreButton() {
    return GestureDetector(
      onTap: _addEntry,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ColorConst.primaryGreen.withValues(alpha: 0.4),
            style: BorderStyle.solid,
            width: 1.5,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline_rounded,
                color: ColorConst.primaryGreen, size: 20),
            SizedBox(width: 8),
            Text(
              'Add Another Product',
              style: TextStyle(
                color: ColorConst.primaryGreen,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitBar(CityStockViewModel vm) {
    final readyCount =
        _entries.where((e) => e.selectedProduct != null).length;
    final totalQty = _entries.fold<int>(
        0, (sum, e) => sum + (int.tryParse(e.qtyController.text) ?? 0));

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Summary row
          Row(
            children: [
              _submitStat('Products', '$readyCount', const Color(0xFF2563EB)),
              const SizedBox(width: 8),
              _submitStat('Total Units', '$totalQty', ColorConst.primaryGreen),
            ],
          ),
          const SizedBox(height: 10),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: vm.cityRequestLoading
                  ? null
                  : () => _submitRequest(vm),
              icon: vm.cityRequestLoading
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
              label: Text(
                vm.cityRequestLoading
                    ? 'Submitting Request...'
                    : 'Submit Stock Request ($readyCount items)',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorConst.primaryGreen,
                disabledBackgroundColor:
                ColorConst.primaryGreen.withValues(alpha: 0.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _submitStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helper class ────────────────────────────────────────────────────────────

class _RequestEntry {
  CityStockData? selectedProduct;
  final TextEditingController qtyController = TextEditingController();
  _RequestEntry({this.selectedProduct,});

  void dispose() {
    qtyController.dispose();
  }
}