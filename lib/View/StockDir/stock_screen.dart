import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/tost_msg/custom_snackbar.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/city_stock_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/all_hub_list_view_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/city_stock_view_model.dart';

class CityStockScreen extends StatefulWidget {
  const CityStockScreen({super.key});

  @override
  State<CityStockScreen> createState() => _CityStockScreenState();
}

class _CityStockScreenState extends State<CityStockScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final stockProvider = Provider.of<CityStockViewModel>(context,listen: false);
      stockProvider.getCityStockDataApi(context);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.bgColor,
      appBar: _buildAppBar(),
      body: Consumer<CityStockViewModel>(
        builder: (context, vm, _) {
          if (vm.cityStockModel == null) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2563EB)),
            );
          }

          final allItems = vm.cityStockModel!.data ?? [];
          final categories = allItems
              .map((e) => e.category ?? '')
              .toSet()
              .toList();

          final filtered = allItems.where((item) {
            final matchSearch = _searchQuery.isEmpty ||
                (item.productName
                    ?.toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ??
                    false);
            final matchCategory = _selectedCategory == null ||
                item.category == _selectedCategory;
            return matchSearch && matchCategory;
          }).toList();

          // Group by main_category > category > sub_category
          final Map<String, Map<String, Map<String, List<CityStockData>>>> grouped = {};
          for (var item in filtered) {
            final main = item.mainCategory ?? 'Other';
            final cat = item.category ?? 'Other';
            final sub = item.subCategory ?? 'Other';
            grouped.putIfAbsent(main, () => {});
            grouped[main]!.putIfAbsent(cat, () => {});
            grouped[main]![cat]!.putIfAbsent(sub, () => []);
            grouped[main]![cat]![sub]!.add(item);
          }

          return Column(
            children: [
              _buildSearchAndFilter(categories),
              _buildSummaryRow(allItems),
              Expanded(
                child: filtered.isEmpty
                    ? _buildEmptyState()
                    : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: grouped.entries.map((mainEntry) {
                    return _buildMainCategorySection(
                        mainEntry.key.toString(), mainEntry.value, vm);
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: ColorConst.primaryGreen,
      elevation: 0,
      toolbarHeight: Sizes.screenHeight*0.12,
      automaticallyImplyLeading: false,
      title:  Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('City Stock',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700)),
          SizedBox(height: Sizes.screenHeight*0.01),
          Text('Inventory Management',
              style: TextStyle(color: ColorConst.white, fontSize: 15)),
        ],
      ),
      actions: [
        Consumer<CityStockViewModel>(
          builder: (context, vm, _) => IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () => vm.getCityStockDataApi(context),
            tooltip: 'Refresh',
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchAndFilter(List<dynamic> categories) {
    return Container(
      color: ColorConst.primaryLightGreen,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: TextStyle(color: Colors.white, fontSize: 14),
                  prefixIcon:
                  Icon(Icons.search_rounded, color: Colors.white, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 11),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: _selectedCategory,
                dropdownColor: const Color(0xFF1E3A5F),
                hint: const Text('Category',
                    style:
                    TextStyle(color: Color(0xFF93C5FD), fontSize: 13)),
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF93C5FD)),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All',
                        style: TextStyle(color: Colors.white, fontSize: 13)),
                  ),
                  ...categories.map((c) => DropdownMenuItem<String?>(
                    value: c,
                    child: Text(c,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 13)),
                  )),
                ],
                onChanged: (v) => setState(() => _selectedCategory = v),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(List<CityStockData> items) {
    final totalProducts = items.length;
    final lowStock = items.where((i) => (i.currentStock ?? 0) < 10).length;
    final totalStock = items.fold<int>(
      0,
          (sum, i) => sum + int.tryParse(i.currentStock?.toString() ?? "0")!,
    );
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          _buildSummaryCard('Products', '$totalProducts',
              Icons.inventory_2_outlined, const Color(0xFF2563EB)),
          const SizedBox(width: 10),
          _buildSummaryCard('Total Stock', totalStock.toString(),
              Icons.stacked_bar_chart_rounded, const Color(0xFF059669)),
          const SizedBox(width: 10),
          _buildSummaryCard('Low Stock', '$lowStock',
              Icons.warning_amber_rounded, const Color(0xFFDC2626)),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha:0.05),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 18)),
                Text(label,
                    style: const TextStyle(
                        color: Color(0xFF6B7280), fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCategorySection(
      String mainCategory,
      Map<String, Map<String, List<CityStockData>>> categoryMap,
      CityStockViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                    color: ColorConst.primaryGreen,
                    borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 8),
              Text(mainCategory,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: ColorConst.primaryGreen)),
            ],
          ),
        ),
        ...categoryMap.entries.map((catEntry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 6, bottom: 6),
                child: Text(catEntry.key,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151))),
              ),
              ...catEntry.value.entries.map((subEntry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                      const EdgeInsets.only(left: 24, top: 4, bottom: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.subdirectory_arrow_right_rounded,
                              size: 14, color: Color(0xFF9CA3AF)),
                          const SizedBox(width: 4),
                          Text(subEntry.key,
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF9CA3AF))),
                        ],
                      ),
                    ),
                    ...subEntry.value
                        .map((item) => _buildStockCard(item, vm))
                        ,
                  ],
                );
              }),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildStockCard(CityStockData item, CityStockViewModel vm) {
    final current = item.currentStock ?? 0;
    final received = int.tryParse(item.totalReceived ?? '0') ?? 0;
    final sold = received - current;
    final double progress =
    received > 0 ? (current / received).clamp(0.0, 1.0) : 0.0;
    final isLow = current < 10;
    final stockColor = isLow
        ? const Color(0xFFDC2626)
        : current < 20
        ? const Color(0xFFD97706)
        : ColorConst.primaryGreen;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: isLow
            ? Border.all(color: const Color(0xFFDC2626).withValues(alpha:0.3))
            : null,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha:0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product name + low stock badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.productName ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Color(0xFF111827)),
                  ),
                ),
                if (item.variantName != null && item.variantName != 'Default')
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(item.variantName!,
                        style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.w500)),
                  ),
                if (isLow) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Low Stock',
                        style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFFDC2626),
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),

            // Stock numbers
            Row(
              children: [
                _buildStockStat(
                    'Current', '$current', stockColor),
                const SizedBox(width: 16),
                _buildStockStat(
                    'Received', '$received', const Color(0xFF374151)),
                const SizedBox(width: 16),
                _buildStockStat(
                    'Sold', '$sold', const Color(0xFF6B7280)),
              ],
            ),
            const SizedBox(height: 10),

            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Stock Level',
                        style: TextStyle(
                            fontSize: 11, color: Color(0xFF6B7280))),
                    Text('${(progress * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: stockColor)),
                  ],
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: const Color(0xFFF3F4F6),
                    valueColor: AlwaysStoppedAnimation<Color>(stockColor),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    label: 'Transfer',
                    icon: Icons.swap_horiz_rounded,
                    color: ColorConst.primaryGreen,
                    onTap: () => _showTransferDialog(context, item, vm),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    label: 'Update Stock',
                    icon: Icons.edit_rounded,
                    color: const Color(0xFF059669),
                    onTap: () => _showUpdateStockDialog(context, item, vm),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
            const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: color)),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha:0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha:0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          const Text('No products found',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 16)),
        ],
      ),
    );
  }

  // ─── Dialogs ────────────────────────────────────────────────────────────────

  void _showTransferDialog(
      BuildContext context, CityStockData item, CityStockViewModel vm) {

    final qtyController = TextEditingController();

    String? selectedHubId;

    /// 🔥 Call hub list API before opening bottom sheet
    final hubVM = Provider.of<AllHubViewModel>(context, listen: false);
    hubVM.getHubListDataApi(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            final hubVM = Provider.of<AllHubViewModel>(context);

            return _BottomSheetWrapper(
              title: 'Transfer Stock',
              subtitle: item.productName ?? '',
              icon: Icons.swap_horiz_rounded,
              iconColor: ColorConst.primaryGreen,
              child: Column(
                children: [
                  _dialogInfoRow(
                      'Available Stock', '${item.currentStock ?? 0}'),

                  const SizedBox(height: 16),

                  /// 🔽 HUB DROPDOWN (replacing city field)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedHubId,
                        hint: const Text("Select Destination Hub",style: TextStyle(fontSize: 14),),
                        isExpanded: true,
                        dropdownColor: Colors.white,
                        /// ✅ Handle loading safely
                        items: (hubVM.hubListModel?.data?.hubs ?? []).map<DropdownMenuItem<String>>((hub) {
                          return DropdownMenuItem<String>(
                            value: hub.hubId.toString(),
                            child: Text(hub.hubName ?? "",style: TextStyle(fontSize: 16),),
                          );
                        }).toList(),

                        onChanged: (value) {
                          setState(() {
                            selectedHubId = value;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// 🔢 Quantity Field
                  _buildDialogField(
                    controller: qtyController,
                    label: 'Quantity to Transfer',
                    hint: 'Enter quantity',
                    icon: Icons.numbers_rounded,
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 20),

                  /// 🚀 Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                        onPressed: () {
                          if (selectedHubId == null) {
                            CustomSnackBar.show(context,message: "Please select a hub", type: SnackBarType.error);
                          }

                          if (qtyController.text.isEmpty) {
                            CustomSnackBar.show(context,message:"Enter quantity", type: SnackBarType.error);
                          }

                          final qty = int.tryParse(qtyController.text);
                          if (qty == null || qty <= 0) {
                            CustomSnackBar.show(context,message:'Enter valid quantity', type: SnackBarType.error);
                          }
                          final items = [
                            {
                              "productid": item.productid,
                              "variantid": item.variantid ?? 0,
                              "qty": qty,
                            }
                          ];

                          vm.cityTransferToHubApi(
                            context,
                            selectedHubId!,
                            "Transfer from city",
                            items,
                          );
                        },
                      icon: const Icon(Icons.send_rounded, size: 18),
                      label: const Text('Confirm Transfer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorConst.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showUpdateStockDialog(
      BuildContext context, CityStockData item, CityStockViewModel vm) {
    final stockController =
    TextEditingController(text: '${item.currentStock ?? 0}');
    final receivedController =
    TextEditingController(text: item.totalReceived ?? '0');
    String updateType = 'add';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => _BottomSheetWrapper(
          title: 'Update Stock',
          subtitle: item.productName ?? '',
          icon: Icons.edit_rounded,
          iconColor: ColorConst.primaryGreen,
          child: Column(
            children: [
              _dialogInfoRow('Current Stock', '${item.currentStock ?? 0}'),
              const SizedBox(height: 16),

              // Update type toggle
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    _toggleOption('Add Stock', 'add', updateType,
                            (v) => setModalState(() => updateType = v),
                    ColorConst.primaryGreen),
                    _toggleOption('Remove Stock', 'remove', updateType,
                            (v) => setModalState(() => updateType = v),
                        const Color(0xFFDC2626)),
                    _toggleOption('Set Exact', 'set', updateType,
                            (v) => setModalState(() => updateType = v),
                        const Color(0xFF7C3AED)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              _buildDialogField(
                controller: stockController,
                label: updateType == 'set' ? 'New Stock Value' : 'Quantity',
                hint: 'Enter value',
                icon: Icons.inventory_2_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              _buildDialogField(
                controller: receivedController,
                label: 'Total Received',
                hint: 'Enter total received',
                icon: Icons.move_to_inbox_rounded,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: call update stock API
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Stock updated for ${item.productName}'),
                        backgroundColor: const Color(0xFF059669),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Save Changes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorConst.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _dialogInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF6B7280))),
          Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827))),
        ],
      ),
    );
  }

  Widget _buildDialogField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151))),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
            const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            prefixIcon: Icon(icon, size: 18, color: const Color(0xFF6B7280)),
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
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
            ),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _toggleOption(
      String label,
      String value,
      String selected,
      Function(String) onChanged,
      Color activeColor,
      ) {
    final isSelected = selected == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF6B7280),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Reusable Bottom Sheet Wrapper ──────────────────────────────────────────

class _BottomSheetWrapper extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const _BottomSheetWrapper({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827))),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF6B7280))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: Color(0xFFF3F4F6)),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}