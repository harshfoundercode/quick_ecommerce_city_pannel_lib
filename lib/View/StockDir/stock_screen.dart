// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ConstDir/customTextfield.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ConstDir/tost_msg/custom_snackbar.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ModelDir/city_stock_model.dart';
// import 'package:quick_ecommerce_city_panel_redefined/View/StockDir/bulk_transfer_to_hub.dart';
// import 'package:quick_ecommerce_city_panel_redefined/View/StockDir/transfer_stock_to_hub.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/all_hub_list_view_model.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/city_stock_view_model.dart';
//
// class CityStockScreen extends StatefulWidget {
//   const CityStockScreen({super.key});
//
//   @override
//   State<CityStockScreen> createState() => _CityStockScreenState();
// }
//
// class _CityStockScreenState extends State<CityStockScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = '';
//   String? _selectedCategory;
//   String? _selectedMainCategory;
//   String? _selectedSubCategory;
//   bool _showLowStockOnly = false;
//   bool _showOutOfStockOnly = false;
//   String _sortBy = 'name'; // name, stock, received
//   bool _sortAscending = true;
//   final ScrollController _scrollController = ScrollController();
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final stockProvider = Provider.of<CityStockViewModel>(
//         context,
//         listen: false,
//       );
//       stockProvider.getCityStockDataApi(context);
//     });
//   }
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ColorConst.bgColor,
//       appBar: _buildAppBar(),
//       body: Consumer<CityStockViewModel>(
//         builder: (context, vm, _) {
//           if (vm.cityStockModel == null) {
//             return const Center(
//               child: CircularProgressIndicator(color: ColorConst.primaryGreen),
//             );
//           }
//
//           final allItems = vm.cityStockModel!.data ?? [];
//
//           // Extract unique categories
//           final categories = allItems
//               .map((e) => e.category ?? '')
//               .where((c) => c.isNotEmpty)
//               .toSet()
//               .toList();
//
//           final mainCategories = allItems
//               .map((e) => e.mainCategory ?? '')
//               .where((c) => c.isNotEmpty)
//               .toSet()
//               .toList();
//
//           final subCategories = allItems
//               .map((e) => e.subCategory ?? '')
//               .where((c) => c.isNotEmpty)
//               .toSet()
//               .toList();
//
//           // Apply filters
//           var filtered = allItems.where((item) {
//             final matchSearch = _searchQuery.isEmpty ||
//                 (item.productName?.toLowerCase().contains(
//                   _searchQuery.toLowerCase(),
//                 ) ??
//                     false);
//             final matchCategory = _selectedCategory == null ||
//                 item.category == _selectedCategory;
//             final matchMainCategory = _selectedMainCategory == null ||
//                 item.mainCategory == _selectedMainCategory;
//             final matchSubCategory = _selectedSubCategory == null ||
//                 item.subCategory == _selectedSubCategory;
//             final matchLowStock = !_showLowStockOnly ||
//                 (item.currentStock ?? 0) < 10;
//             final matchOutOfStock = !_showOutOfStockOnly ||
//                 (item.currentStock ?? 0) == 0;
//
//             return matchSearch && matchCategory && matchMainCategory &&
//                 matchSubCategory && matchLowStock && matchOutOfStock;
//           }).toList();
//
//           // Apply sorting
//           _applySorting(filtered);
//
//           // Group by main_category > category > sub_category
//           final Map<String, Map<String, Map<String, List<CityStockData>>>> grouped = {};
//           for (var item in filtered) {
//             final main = item.mainCategory ?? 'Other';
//             final cat = item.category ?? 'Other';
//             final sub = item.subCategory ?? 'Other';
//             grouped.putIfAbsent(main, () => {});
//             grouped[main]!.putIfAbsent(cat, () => {});
//             grouped[main]![cat]!.putIfAbsent(sub, () => []);
//             grouped[main]![cat]![sub]!.add(item);
//           }
//
//           return Column(
//             children: [
//               _buildSearchAndFilter(categories, mainCategories, subCategories),
//               _buildAdvancedFilters(),
//               _buildSummaryRow(allItems, filtered),
//               _buildBulkRequestBar(vm, allItems),
//               Expanded(
//                 child: filtered.isEmpty
//                     ? _buildEmptyState()
//                     : ListView.builder(
//                   controller: _scrollController,
//                   padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
//                   itemCount: grouped.length,
//                   itemBuilder: (context, index) {
//                     final mainEntry = grouped.entries.elementAt(index);
//                     return _buildMainCategorySection(
//                       mainEntry.key.toString(),
//                       mainEntry.value,
//                       vm,
//                     );
//                   },
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   void _applySorting(List<CityStockData> items) {
//     switch (_sortBy) {
//       case 'name':
//         items.sort((a, b) => _sortAscending
//             ? (a.productName ?? '').compareTo(b.productName ?? '')
//             : (b.productName ?? '').compareTo(a.productName ?? ''));
//         break;
//       case 'stock':
//         items.sort((a, b) => _sortAscending
//             ? (a.currentStock ?? 0).compareTo(b.currentStock ?? 0)
//             : (b.currentStock ?? 0).compareTo(a.currentStock ?? 0));
//         break;
//       case 'received':
//         items.sort((a, b) => _sortAscending
//             ? (int.tryParse(a.totalReceived ?? '0') ?? 0)
//             .compareTo(int.tryParse(b.totalReceived ?? '0') ?? 0)
//             : (int.tryParse(b.totalReceived ?? '0') ?? 0)
//             .compareTo(int.tryParse(a.totalReceived ?? '0') ?? 0));
//         break;
//     }
//   }
//
//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       backgroundColor: ColorConst.primaryGreen,
//       elevation: 0,
//       toolbarHeight: Sizes.screenHeight * 0.12,
//       automaticallyImplyLeading: false,
//       title: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'City Stock',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 20,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//           SizedBox(height: Sizes.screenHeight * 0.01),
//           Text(
//             'Inventory Management',
//             style: TextStyle(color: ColorConst.white, fontSize: 15),
//           ),
//         ],
//       ),
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.download_rounded, color: Colors.white),
//           onPressed: () => _exportStockData(context),
//           tooltip: 'Export Data',
//         ),
//         Consumer<CityStockViewModel>(
//           builder: (context, vm, _) => IconButton(
//             icon: const Icon(Icons.refresh_rounded, color: Colors.white),
//             onPressed: () => vm.getCityStockDataApi(context),
//             tooltip: 'Refresh',
//           ),
//         ),
//         const SizedBox(width: 8),
//       ],
//     );
//   }
//
//   Widget _buildSearchAndFilter(List<dynamic> categories, List<dynamic> mainCategories, List<dynamic> subCategories) {
//     return Container(
//       color: ColorConst.primaryExtraLightGreen,
//       padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: Container(
//                   height: 42,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: TextField(
//                     controller: _searchController,
//                     onChanged: (v) => setState(() => _searchQuery = v),
//                     style: const TextStyle(color: ColorConst.primaryGreen, fontSize: 14),
//                     decoration: const InputDecoration(
//                       hintText: 'Search products...',
//                       hintStyle: TextStyle(color: ColorConst.primaryGreen, fontSize: 14),
//                       prefixIcon: Icon(
//                         Icons.search_rounded,
//                         color: ColorConst.primaryGreen,
//                         size: 20,
//                       ),
//                       border: InputBorder.none,
//                       contentPadding: EdgeInsets.symmetric(vertical: 11),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Container(
//                 height: 42,
//                 width: 42,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: IconButton(
//                   icon: const Icon(Icons.filter_list_rounded, color: ColorConst.primaryGreen),
//                   onPressed: () => _showFilterBottomSheet(categories, mainCategories, subCategories),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           if (_selectedCategory != null || _selectedMainCategory != null ||
//               _selectedSubCategory != null || _showLowStockOnly || _showOutOfStockOnly)
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: [
//                   if (_selectedCategory != null)
//                     _buildFilterChip('Category: $_selectedCategory', () {
//                       setState(() => _selectedCategory = null);
//                     }),
//                   if (_selectedMainCategory != null)
//                     _buildFilterChip('Main: $_selectedMainCategory', () {
//                       setState(() => _selectedMainCategory = null);
//                     }),
//                   if (_selectedSubCategory != null)
//                     _buildFilterChip('Sub: $_selectedSubCategory', () {
//                       setState(() => _selectedSubCategory = null);
//                     }),
//                   if (_showLowStockOnly)
//                     _buildFilterChip('Low Stock Only', () {
//                       setState(() => _showLowStockOnly = false);
//                     }),
//                   if (_showOutOfStockOnly)
//                     _buildFilterChip('Out of Stock', () {
//                       setState(() => _showOutOfStockOnly = false);
//                     }),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFilterChip(String label, VoidCallback onDeleted) {
//     return Container(
//       margin: const EdgeInsets.only(right: 8),
//       child: Chip(
//         label: Text(label, style: const TextStyle(fontSize: 12)),
//         backgroundColor: ColorConst.primaryGreen.withValues(alpha: 0.1),
//         deleteIcon: const Icon(Icons.close, size: 16),
//         onDeleted: onDeleted,
//         visualDensity: VisualDensity.compact,
//       ),
//     );
//   }
//
//   Widget _buildAdvancedFilters() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.grey.shade200),
//             ),
//             child: Row(
//               children: [
//                 const Icon(Icons.sort_rounded, size: 16, color: ColorConst.primaryGreen),
//                 const SizedBox(width: 4),
//                 DropdownButton<String>(
//                   value: _sortBy,
//                   underline: const SizedBox(),
//                   dropdownColor: Colors.white,
//                   items: const [
//                     DropdownMenuItem(value: 'name', child: Text('Name')),
//                     DropdownMenuItem(value: 'stock', child: Text('Stock')),
//                     DropdownMenuItem(value: 'received', child: Text('Received')),
//                   ],
//                   onChanged: (value) {
//                     setState(() {
//                       _sortBy = value!;
//                     });
//                   },
//                 ),
//                 IconButton(
//                   icon: Icon(
//                     _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
//                     size: 16,
//                   ),
//                   onPressed: () => setState(() => _sortAscending = !_sortAscending),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: [
//                   FilterChip(
//                     label: const Text('Low Stock'),
//                     selected: _showLowStockOnly,
//                     onSelected: (selected) => setState(() => _showLowStockOnly = selected),
//                     backgroundColor: Colors.white,
//                     selectedColor: ColorConst.primaryGreen.withValues(alpha: 0.1),
//                   ),
//                   const SizedBox(width: 8),
//                   FilterChip(
//                     label: const Text('Out of Stock'),
//                     selected: _showOutOfStockOnly,
//                     onSelected: (selected) => setState(() => _showOutOfStockOnly = selected),
//                     backgroundColor: Colors.white,
//                     selectedColor: Colors.red.withValues(alpha: 0.1),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSummaryRow(List<CityStockData> allItems, List<CityStockData> filteredItems) {
//     final totalProducts = filteredItems.length;
//     final totalAllProducts = allItems.length;
//     final lowStock = allItems.where((i) => (i.currentStock ?? 0) < 10).length;
//     final outOfStock = allItems.where((i) => (i.currentStock ?? 0) == 0).length;
//
//     final totalStock = allItems.fold<int>(
//       0,
//           (s, i) => s + (int.tryParse(i.currentStock?.toString() ?? '0') ?? 0),
//     );
//
//     final totalValue = allItems.fold<double>(
//       0,
//           (sum, i) => sum + ((i.currentStock ?? 0) * (10)), // price hoga 10 ki jagah
//     );
//
//     return Container(
//       margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               _buildSummaryCard(
//                 'Products',
//                 '$totalProducts',
//                 Icons.inventory_2_outlined,
//                 const Color(0xFF2563EB),
//                 subtitle: 'Total: $totalAllProducts',
//               ),
//               const SizedBox(width: 10),
//               _buildSummaryCard(
//                 'Total Stock',
//                 totalStock.toString(),
//                 Icons.stacked_bar_chart_rounded,
//                 const Color(0xFF059669),
//                 subtitle: 'Units',
//               ),
//               const SizedBox(width: 10),
//               _buildSummaryCard(
//                 'Stock Value',
//                 '₹${(totalValue).toStringAsFixed(0)}',
//                 Icons.currency_rupee_rounded,
//                 const Color(0xFFF59E0B),
//                 subtitle: 'Estimated',
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               _buildSummaryCard(
//                 'Low Stock',
//                 '$lowStock',
//                 Icons.warning_amber_rounded,
//                 const Color(0xFFDC2626),
//                 subtitle: 'Below 10 units',
//               ),
//               const SizedBox(width: 10),
//               _buildSummaryCard(
//                 'Out of Stock',
//                 '$outOfStock',
//                 Icons.cancel_rounded,
//                 const Color(0xFFEF4444),
//                 subtitle: 'Zero stock',
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSummaryCard(
//       String label,
//       String value,
//       IconData icon,
//       Color color, {
//         String? subtitle,
//       }) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withValues(alpha: 0.05),
//               blurRadius: 6,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(7),
//               decoration: BoxDecoration(
//                 color: color.withValues(alpha: 0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Icon(icon, color: color, size: 18),
//             ),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     value,
//                     style: TextStyle(
//                       color: color,
//                       fontWeight: FontWeight.w700,
//                       fontSize: 16,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   Text(
//                     label,
//                     style: const TextStyle(
//                       color: Color(0xFF6B7280),
//                       fontSize: 10,
//                     ),
//                   ),
//                   if (subtitle != null)
//                     Text(
//                       subtitle,
//                       style: const TextStyle(
//                         color: Color(0xFF9CA3AF),
//                         fontSize: 8,
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBulkRequestBar(CityStockViewModel vm, List<CityStockData> allItems) {
//     if (vm.selectedProductIds.isEmpty) {
//       return const SizedBox();
//     }
//
//     final selectedProducts = allItems.where((item) =>
//         vm.selectedProductIds.contains(item.productid)
//     ).toList();
//
//     // final totalQty = selectedProducts.fold<int>(
//     //     0,
//     //         (sum, item) => sum + int.parse(vm.requestQuantities[item.productid] ?? 1)
//     // );
//
//     return Container(
//       padding: const EdgeInsets.all(12),
//       color: Colors.white,
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: ElevatedButton.icon(
//                   onPressed: vm.cityRequestLoading
//                       ? null
//                       : () {
//                     vm.bulkRequestStock(
//                       context,
//                       "Bulk stock request",
//                     );
//                   },
//                   icon: vm.cityRequestLoading
//                       ? const SizedBox(
//                     width: 16,
//                     height: 16,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       color: Colors.white,
//                     ),
//                   )
//                       : const Icon(Icons.send, color: Colors.white),
//                   label: Text(
//                     vm.cityRequestLoading
//                         ? "Requesting..."
//                         : "Request (${vm.selectedProductIds.length} items)",
//                     style: const TextStyle(color: Colors.white),
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: ColorConst.primaryGreen,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               OutlinedButton.icon(
//                 onPressed: () => vm.clearSelection(),
//                 icon: const Icon(Icons.clear_rounded, size: 18),
//                 label: const Text('Clear'),
//                 style: OutlinedButton.styleFrom(
//                   foregroundColor: Colors.red,
//                 ),
//               ),
//             ],
//           ),
//           if (selectedProducts.isNotEmpty) ...[
//             const SizedBox(height: 8),
//             // SingleChildScrollView(
//             //   scrollDirection: Axis.horizontal,
//             //   child: Row(
//             //     children: selectedProducts.map((product) {
//             //       final qty = vm.requestQuantities[product.productid] ?? 1;
//             //       return Container(
//             //         margin: const EdgeInsets.only(right: 8),
//             //         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             //         decoration: BoxDecoration(
//             //           color: ColorConst.primaryGreen.withValues(alpha: 0.1),
//             //           borderRadius: BorderRadius.circular(12),
//             //         ),
//             //         child: Text(
//             //           '${product.productName}: $qty',
//             //           style: const TextStyle(fontSize: 11),
//             //         ),
//             //       );
//             //     }).toList(),
//             //   ),
//             // ),
//           ],
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMainCategorySection(
//       String mainCategory,
//       Map<String, Map<String, List<CityStockData>>> categoryMap,
//       CityStockViewModel vm,
//       ) {
//     // Calculate category summary
//     int totalItems = 0;
//     int totalStock = 0;
//     categoryMap.forEach((cat, subMap) {
//       subMap.forEach((sub, items) {
//         totalItems += items.length;
//         totalStock += items.fold<int>(0, (sum, item) => sum + (int.tryParse(item.currentStock?.toString() ?? '0') ?? 0));
//       });
//     });
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(top: 16, bottom: 8),
//           child: Row(
//             children: [
//               Container(
//                 width: 4,
//                 height: 20,
//                 decoration: BoxDecoration(
//                   color: ColorConst.primaryGreen,
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 mainCategory,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w700,
//                   color: ColorConst.primaryGreen,
//                 ),
//               ),
//               const Spacer(),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade100,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   '$totalItems items | $totalStock units',
//                   style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         ...categoryMap.entries.map((catEntry) {
//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(left: 12, top: 6, bottom: 6),
//                 child: Row(
//                   children: [
//                     Text(
//                       catEntry.key,
//                       style: const TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xFF374151),
//                       ),
//                     ),
//                     const Spacer(),
//                     Text(
//                       '${catEntry.value.values.fold<int>(0, (sum, items) => sum + items.length)} items',
//                       style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
//                     ),
//                   ],
//                 ),
//               ),
//               ...catEntry.value.entries.map((subEntry) {
//                 return Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.only(
//                         left: 24,
//                         top: 4,
//                         bottom: 4,
//                       ),
//                       child: Row(
//                         children: [
//                           const Icon(
//                             Icons.subdirectory_arrow_right_rounded,
//                             size: 14,
//                             color: Color(0xFF9CA3AF),
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             subEntry.key,
//                             style: const TextStyle(
//                               fontSize: 12,
//                               color: Color(0xFF9CA3AF),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     ...subEntry.value.map((item) => _buildStockCard(item, vm)),
//                   ],
//                 );
//               }),
//             ],
//           );
//         }),
//       ],
//     );
//   }
//
//   Widget _buildStockCard(CityStockData item, CityStockViewModel vm) {
//     final current = item.currentStock ?? 0;
//     final received = int.tryParse(item.totalReceived ?? '0') ?? 0;
//     final sold = received - current;
//     final double progress = received > 0
//         ? (current / received).clamp(0.0, 1.0)
//         : 0.0;
//     final isLow = current < 10 && current > 0;
//     final isOutOfStock = current == 0;
//     final stockColor = isOutOfStock
//         ? const Color(0xFFEF4444)
//         : isLow
//         ? const Color(0xFFDC2626)
//         : current < 20
//         ? const Color(0xFFD97706)
//         : ColorConst.primaryGreen;
//
//     final isSelected = vm.selectedProductIds.contains(item.productid);
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: isLow || isOutOfStock
//             ? Border.all(color: stockColor.withValues(alpha: 0.3))
//             : null,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(14),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Checkbox(
//                   value: isSelected,
//                   checkColor: ColorConst.white,
//                   activeColor: ColorConst.primaryGreen,
//                   onChanged: (item.productid != null)
//                       ? (_) => vm.toggleSelection(item.productid!)
//                       : null,
//                 ),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         item.productName ?? '',
//                         style: const TextStyle(
//                           fontWeight: FontWeight.w600,
//                           fontSize: 15,
//                         ),
//                       ),
//                       if (item.variantName != null && item.variantName != 'Default')
//                         Text(
//                           item.variantName!,
//                           style: const TextStyle(
//                             fontSize: 11,
//                             color: Color(0xFF6B7280),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//                 if (isOutOfStock)
//                   _buildStatusBadge('Out of Stock', const Color(0xFFEF4444))
//                 else if (isLow)
//                   _buildStatusBadge('Low Stock', const Color(0xFFDC2626)),
//               ],
//             ),
//
//             const SizedBox(height: 8),
//
//             if (isSelected)
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: ColorConst.primaryGreen.withValues(alpha: 0.05),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   children: [
//                     const Text(
//                       "Request Quantity: ",
//                       style: TextStyle(fontSize: 13),
//                     ),
//                     Expanded(
//                       child: CustomTextField(
//                         width: 80,
//                         height: 35,
//                         keyboardType: TextInputType.number,
//                         fillColor: Colors.white,
//                         maxLength: 3,
//                         filled: true,
//                         onChanged: (val) {
//                           final qty = int.tryParse(val) ?? 1;
//                           vm.updateQty(item.productid!, qty);
//                         },
//                         hintText: "1",
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//             const SizedBox(height: 10),
//
//             Row(
//               children: [
//                 _buildStockStat('Current', '$current', stockColor, Icons.inventory_rounded),
//                 const SizedBox(width: 16),
//                 _buildStockStat('Received', '$received', const Color(0xFF059669), Icons.download_rounded),
//                 const SizedBox(width: 16),
//                 _buildStockStat('Sold', '$sold', const Color(0xFFDC2626), Icons.shopping_cart_rounded),
//               ],
//             ),
//             const SizedBox(height: 10),
//
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       'Stock Level',
//                       style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
//                     ),
//                     Text(
//                       '${(progress * 100).toStringAsFixed(0)}%',
//                       style: TextStyle(
//                         fontSize: 11,
//                         fontWeight: FontWeight.w600,
//                         color: stockColor,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 5),
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(4),
//                   child: LinearProgressIndicator(
//                     value: progress,
//                     backgroundColor: const Color(0xFFF3F4F6),
//                     valueColor: AlwaysStoppedAnimation<Color>(stockColor),
//                     minHeight: 6,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//
//             Row(
//               children: [
//                 Expanded(
//                   child: Tooltip(
//                     message: 'Transfer stock to hub',
//                     child: _buildActionButton(
//                       label: 'Transfer',
//                       icon: Icons.swap_horiz_rounded,
//                       color: ColorConst.primaryGreen,
//                       // onTap: () => _showTransferDialog(context, item, vm),
//                       onTap: () {
//                         Navigator.push(context, MaterialPageRoute(
//                           builder: (_) => TransferStockScreen(
//                             allItems: vm.cityStockModel!.data!,
//                             preSelected: item, // optional
//                           ),
//                         ));
//                       }
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Tooltip(
//                     message: 'Bulk transfer',
//                     child: _buildActionButton(
//                       label: 'Request',
//                       icon: Icons.add_shopping_cart_rounded,
//                       color: const Color(0xFF059669),
//                       // onTap: () => _showUpdateStockDialog(context, item, vm),
//                       onTap: () {
//                         Navigator.push(context, MaterialPageRoute(
//     builder: (_) => BulkTransferScreen(allItems: vm.cityStockModel!.data!),
//   ));
//                       },
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Tooltip(
//                     message: 'View product details',
//                     child: _buildActionButton(
//                       label: 'Details',
//                       icon: Icons.info_outline_rounded,
//                       color: const Color(0xFF6B7280),
//                       onTap: () => _showProductDetailsDialog(context, item),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildStatusBadge(String text, Color color) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//       decoration: BoxDecoration(
//         color: color.withValues(alpha: 0.1),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(
//           fontSize: 11,
//           color: color,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildStockStat(String label, String value, Color color, IconData icon) {
//     return Expanded(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(icon, size: 12, color: color),
//               const SizedBox(width: 4),
//               Text(
//                 label,
//                 style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
//               ),
//             ],
//           ),
//           const SizedBox(height: 2),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w700,
//               color: color,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildActionButton({
//     required String label,
//     required IconData icon,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(8),
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 8),
//         decoration: BoxDecoration(
//           color: color.withValues(alpha: 0.08),
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: color.withValues(alpha: 0.25)),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 14, color: color),
//             const SizedBox(width: 5),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 11,
//                 fontWeight: FontWeight.w600,
//                 color: color,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.inventory_2_outlined,
//             size: 60,
//             color: Colors.grey.shade300,
//           ),
//           const SizedBox(height: 12),
//           const Text(
//             'No products found',
//             style: TextStyle(color: Color(0xFF6B7280), fontSize: 16),
//           ),
//           const SizedBox(height: 8),
//           TextButton(
//             onPressed: () {
//               setState(() {
//                 _searchQuery = '';
//                 _selectedCategory = null;
//                 _selectedMainCategory = null;
//                 _selectedSubCategory = null;
//                 _showLowStockOnly = false;
//                 _showOutOfStockOnly = false;
//               });
//             },
//             child: const Text('Clear Filters'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showFilterBottomSheet(List<dynamic> categories, List<dynamic> mainCategories, List<dynamic> subCategories) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setStateSheet) {
//             return Container(
//               padding: EdgeInsets.only(
//                 bottom: MediaQuery.of(context).viewInsets.bottom,
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const SizedBox(height: 12),
//                   Container(
//                     width: 40,
//                     height: 4,
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade300,
//                       borderRadius: BorderRadius.circular(2),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   const Text(
//                     'Filter Products',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//                   ),
//                   const SizedBox(height: 20),
//                   Expanded(
//                     child: SingleChildScrollView(
//                       padding: const EdgeInsets.symmetric(horizontal: 20),
//                       child: Column(
//                         children: [
//                           _buildFilterOption(
//                             'Main Category',
//                             mainCategories,
//                             _selectedMainCategory,
//                                 (value) => setState(() => _selectedMainCategory = value),
//                           ),
//                           const SizedBox(height: 16),
//                           _buildFilterOption(
//                             'Category',
//                             categories,
//                             _selectedCategory,
//                                 (value) => setState(() => _selectedCategory = value),
//                           ),
//                           const SizedBox(height: 16),
//                           _buildFilterOption(
//                             'Sub Category',
//                             subCategories,
//                             _selectedSubCategory,
//                                 (value) => setState(() => _selectedSubCategory = value),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: TextButton(
//                           onPressed: () {
//                             setState(() {
//                               _selectedMainCategory = null;
//                               _selectedCategory = null;
//                               _selectedSubCategory = null;
//                             });
//                             Navigator.pop(context);
//                           },
//                           child: const Text('Clear All'),
//                         ),
//                       ),
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: () {
//                             setState(() {});
//                             Navigator.pop(context);
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: ColorConst.primaryGreen,
//                           ),
//                           child: const Text('Apply Filters'),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   Widget _buildFilterOption(
//       String title,
//       List<dynamic> options,
//       String? selectedValue,
//       Function(String?) onChanged,
//       ) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
//         ),
//         const SizedBox(height: 8),
//         Wrap(
//           spacing: 8,
//           runSpacing: 8,
//           children: [
//             FilterChip(
//               label: const Text('All'),
//               selected: selectedValue == null,
//               onSelected: (_) => onChanged(null),
//             ),
//             ...options.map((option) {
//               return FilterChip(
//                 label: Text(option),
//                 selected: selectedValue == option,
//                 onSelected: (_) => onChanged(option),
//               );
//             }),
//           ],
//         ),
//       ],
//     );
//   }
//
//   void _showProductDetailsDialog(BuildContext context, CityStockData item) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text(item.productName ?? 'Product Details'),
//           content: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 _detailRow('Product ID', item.productid?.toString() ?? 'N/A'),
//                 _detailRow('Variant', item.variantName ?? 'Default'),
//                 _detailRow('Category', item.category ?? 'N/A'),
//                 _detailRow('Main Category', item.mainCategory ?? 'N/A'),
//                 _detailRow('Sub Category', item.subCategory ?? 'N/A'),
//                 const Divider(),
//                 _detailRow('Current Stock', item.currentStock?.toString() ?? '0'),
//                 _detailRow('Total Received', item.totalReceived ?? '0'),
//                 _detailRow('Price', '₹${10}'),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Close'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Widget _detailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 100,
//             child: Text(
//               label,
//               style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
//             ),
//           ),
//           Expanded(
//             child: Text(value, style: const TextStyle(fontSize: 13)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _exportStockData(BuildContext context) {
//     CustomSnackBar.show(
//       context,
//       message: "Export feature coming soon",
//       type: SnackBarType.info,
//     );
//   }
//
//   void _showTransferDialog(
//       BuildContext context,
//       CityStockData item,
//       CityStockViewModel vm,
//       ) {
//     final qtyController = TextEditingController();
//
//     String? selectedHubId;
//
//     final hubVM = Provider.of<AllHubViewModel>(context, listen: false);
//     hubVM.getHubListDataApi(context);
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             final hubVM = Provider.of<AllHubViewModel>(context);
//
//             return _BottomSheetWrapper(
//               title: 'Transfer Stock',
//               subtitle: item.productName ?? '',
//               icon: Icons.swap_horiz_rounded,
//               iconColor: ColorConst.primaryGreen,
//               child: Column(
//                 children: [
//                   _dialogInfoRow(
//                     'Available Stock',
//                     '${item.currentStock ?? 0}',
//                   ),
//
//                   const SizedBox(height: 16),
//
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey.shade300),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: DropdownButtonHideUnderline(
//                       child: DropdownButton<String>(
//                         value: selectedHubId,
//                         hint: const Text(
//                           "Select Destination Hub",
//                           style: TextStyle(fontSize: 14),
//                         ),
//                         isExpanded: true,
//                         dropdownColor: Colors.white,
//                         items: (hubVM.hubListModel?.data?.hubs ?? [])
//                             .map<DropdownMenuItem<String>>((hub) {
//                           return DropdownMenuItem<String>(
//                             value: hub.hubId.toString(),
//                             child: Text(
//                               hub.hubName ?? "N/a",
//                               style: const TextStyle(fontSize: 16, color: Colors.black),
//                             ),
//                           );
//                         })
//                             .toList(),
//                         onChanged: (value) {
//                           setState(() {
//                             selectedHubId = value;
//                           });
//                         },
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(height: 12),
//
//                   _buildDialogField(
//                     controller: qtyController,
//                     label: 'Quantity to Transfer',
//                     hint: 'Enter quantity',
//                     icon: Icons.numbers_rounded,
//                     keyboardType: TextInputType.number,
//                   ),
//
//                   const SizedBox(height: 20),
//
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton.icon(
//                       onPressed: () {
//                         if (selectedHubId == null) {
//                           CustomSnackBar.show(
//                             context,
//                             message: "Please select a hub",
//                             type: SnackBarType.error,
//                           );
//                           return;
//                         }
//
//                         if (qtyController.text.isEmpty) {
//                           CustomSnackBar.show(
//                             context,
//                             message: "Enter quantity",
//                             type: SnackBarType.error,
//                           );
//                           return;
//                         }
//
//                         final qty = int.tryParse(qtyController.text);
//                         if (qty == null || qty <= 0) {
//                           CustomSnackBar.show(
//                             context,
//                             message: 'Enter valid quantity',
//                             type: SnackBarType.error,
//                           );
//                           return;
//                         }
//
//                         if (qty > (item.currentStock ?? 0)) {
//                           CustomSnackBar.show(
//                             context,
//                             message: 'Insufficient stock',
//                             type: SnackBarType.error,
//                           );
//                           return;
//                         }
//
//                         final items = [
//                           {
//                             "productid": item.productid,
//                             "variantid": item.variantid ?? 0,
//                             "qty": qty,
//                           },
//                         ];
//
//                         vm.cityTransferToHubApi(
//                           context,
//                           selectedHubId!,
//                           "Transfer from city",
//                           items,
//                         );
//                       },
//                       icon: const Icon(Icons.send_rounded, size: 18),
//                       label: const Text('Confirm Transfer'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: ColorConst.primaryGreen,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   void _showUpdateStockDialog(
//       BuildContext context,
//       CityStockData item,
//       CityStockViewModel vm,
//       ) {
//     final stockController = TextEditingController();
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) {
//         return _BottomSheetWrapper(
//           title: 'Request Stock',
//           subtitle: item.productName ?? '',
//           icon: Icons.inventory_2_outlined,
//           iconColor: ColorConst.primaryGreen,
//           child: Consumer<CityStockViewModel>(
//             builder: (context, vm, _) {
//               return Column(
//                 children: [
//                   _dialogInfoRow(
//                     'Current Stock',
//                     '${item.currentStock ?? 0}',
//                   ),
//                   const SizedBox(height: 16),
//
//                   _buildDialogField(
//                     controller: stockController,
//                     label: 'Request Quantity',
//                     hint: 'Enter quantity',
//                     icon: Icons.numbers_rounded,
//                     keyboardType: TextInputType.number,
//                   ),
//
//                   const SizedBox(height: 20),
//
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton.icon(
//                       onPressed: vm.cityRequestLoading
//                           ? null
//                           : () {
//                         final qty = int.tryParse(stockController.text);
//
//                         if (qty == null || qty <= 0) {
//                           CustomSnackBar.show(
//                             context,
//                             message: "Enter valid quantity",
//                             type: SnackBarType.error,
//                           );
//                           return;
//                         }
//
//                         final items = [
//                           {
//                             "productid": item.productid,
//                             "qty": qty,
//                           }
//                         ];
//
//                         vm.cityRequestApi(
//                           context,
//                           "Stock request from city panel",
//                           items,
//                         );
//                       },
//                       icon: vm.cityRequestLoading
//                           ? const SizedBox(
//                         width: 16,
//                         height: 16,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           color: Colors.white,
//                         ),
//                       )
//                           : const Icon(Icons.send_rounded, size: 18),
//                       label: Text(
//                         vm.cityRequestLoading
//                             ? 'Requesting...'
//                             : 'Request Stock',
//                       ),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: ColorConst.primaryGreen,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _dialogInfoRow(String label, String value) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF9FAFB),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
//           ),
//           Text(
//             value,
//             style: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w700,
//               color: Color(0xFF111827),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDialogField({
//     required TextEditingController controller,
//     required String label,
//     required String hint,
//     required IconData icon,
//     TextInputType keyboardType = TextInputType.text,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w600,
//             color: Color(0xFF374151),
//           ),
//         ),
//         const SizedBox(height: 6),
//         TextField(
//           controller: controller,
//           keyboardType: keyboardType,
//           decoration: InputDecoration(
//             hintText: hint,
//             hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
//             prefixIcon: Icon(icon, size: 18, color: const Color(0xFF6B7280)),
//             filled: true,
//             fillColor: const Color(0xFFF9FAFB),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//               borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//               borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//               borderSide: const BorderSide(
//                 color: Color(0xFF2563EB),
//                 width: 1.5,
//               ),
//             ),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 14,
//               vertical: 12,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class _BottomSheetWrapper extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final IconData icon;
//   final Color iconColor;
//   final Widget child;
//
//   const _BottomSheetWrapper({
//     required this.title,
//     required this.subtitle,
//     required this.icon,
//     required this.iconColor,
//     required this.child,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Padding(
//         padding: EdgeInsets.only(
//           left: 20,
//           right: 20,
//           top: 20,
//           bottom: MediaQuery.of(context).viewInsets.bottom + 20,
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: Container(
//                 width: 40,
//                 height: 4,
//                 margin: const EdgeInsets.only(bottom: 20),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFE5E7EB),
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//             ),
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: iconColor.withValues(alpha: 0.1),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Icon(icon, color: iconColor, size: 22),
//                 ),
//                 const SizedBox(width: 12),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: const TextStyle(
//                         fontSize: 17,
//                         fontWeight: FontWeight.w700,
//                         color: Color(0xFF111827),
//                       ),
//                     ),
//                     Text(
//                       subtitle,
//                       style: const TextStyle(
//                         fontSize: 12,
//                         color: Color(0xFF6B7280),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             const Divider(color: Color(0xFFF3F4F6)),
//             const SizedBox(height: 16),
//             child,
//           ],
//         ),
//       ),
//     );
//   }
// }