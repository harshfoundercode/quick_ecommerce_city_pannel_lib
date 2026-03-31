// import 'package:flutter/material.dart';
// import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
// import 'package:provider/provider.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ModelDir/city_stock_model.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/city_stock_view_model.dart';
//
// class CityStockListScreen extends StatefulWidget {
//   const CityStockListScreen({super.key});
//
//   @override
//   State<CityStockListScreen> createState() => _CityStockListScreenState();
// }
//
// class _CityStockListScreenState extends State<CityStockListScreen>
//     with SingleTickerProviderStateMixin {
//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = '';
//   String _selectedFilter = 'All';
//   late AnimationController _headerAnimCtrl;
//   late Animation<double> _headerFade;
//
//   final List<String> _filterOptions = [
//     'All',
//     'In Stock',
//     'Low Stock',
//     'Out of Stock',
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _headerAnimCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );
//     _headerFade = CurvedAnimation(
//       parent: _headerAnimCtrl,
//       curve: Curves.easeOut,
//     );
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadData();
//       _headerAnimCtrl.forward();
//     });
//   }
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     _headerAnimCtrl.dispose();
//     super.dispose();
//   }
//
//   Future<void> _loadData() async {
//     await Provider.of<CityStockViewModel>(context, listen: false)
//         .getCityStockDataApi(context);
//   }
//
//   List<CityStockData> _getFilteredStocks(List<CityStockData>? stocks) {
//     if (stocks == null) return [];
//     return stocks.where((stock) {
//       final matchesSearch = _searchQuery.isEmpty ||
//           (stock.product?.name?.toLowerCase().contains(
//               _searchQuery.toLowerCase()) ??
//               false) ||
//           (stock.category?.categoryName?.toLowerCase().contains(
//               _searchQuery.toLowerCase()) ??
//               false);
//
//       bool matchesFilter = true;
//       final s = stock.stock ?? 0;
//       switch (_selectedFilter) {
//         case 'Low Stock':
//           matchesFilter = s > 0 && s <= 10;
//           break;
//         case 'Out of Stock':
//           matchesFilter = s == 0;
//           break;
//         case 'In Stock':
//           matchesFilter = s > 10;
//           break;
//         default:
//           matchesFilter = true;
//       }
//       return matchesSearch && matchesFilter;
//     }).toList();
//   }
//
//   // ── Color helpers ────────────────────────────────────────────────────────
//
//   Color _stockColor(int stock) {
//     if (stock == 0) return const Color(0xFFEF4444);
//     if (stock <= 10) return const Color(0xFFF59E0B);
//     return const Color(0xFF10B981);
//   }
//
//   String _stockLabel(int stock) {
//     if (stock == 0) return 'Out of Stock';
//     if (stock <= 10) return 'Low Stock';
//     return 'In Stock';
//   }
//
//   IconData _stockIcon(int stock) {
//     if (stock == 0) return Icons.cancel_outlined;
//     if (stock <= 10) return Icons.warning_amber_rounded;
//     return Icons.check_circle_outline_rounded;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7FA),
//       body: Consumer<CityStockViewModel>(
//         builder: (context, vm, _) {
//           final allStocks = vm.cityStockModel?.data ?? [];
//           final filtered = _getFilteredStocks(allStocks);
//
//           return CustomScrollView(
//             slivers: [
//               // ── SliverAppBar ─────────────────────────────────────
//               SliverAppBar(
//                 pinned: true,
//                 expandedHeight: 120,
//                 backgroundColor: ColorConst.primaryGreen,
//                 automaticallyImplyLeading: false,
//                 actions: [
//                   IconButton(
//                     icon: const Icon(Icons.refresh_rounded,
//                         color: Colors.white),
//                     onPressed: _loadData,
//                     tooltip: 'Refresh',
//                   ),
//                   const SizedBox(width: 4),
//                 ],
//                 flexibleSpace: FlexibleSpaceBar(
//                   background: _buildAppBarBg(allStocks),
//                 ),
//                 bottom: PreferredSize(
//                   preferredSize: const Size.fromHeight(0),
//                   child: Container(
//                     height: 20,
//                     decoration: const BoxDecoration(
//                       color: Color(0xFFF5F7FA),
//                       borderRadius: BorderRadius.vertical(
//                           top: Radius.circular(20)),
//                     ),
//                   ),
//                 ),
//               ),
//
//               // ── Search + Filters ──────────────────────────────────
//               SliverToBoxAdapter(
//                 child: _buildSearchAndFilter(),
//               ),
//
//               // ── Summary cards ─────────────────────────────────────
//               if (allStocks.isNotEmpty)
//                 SliverToBoxAdapter(
//                   child: _buildSummaryCards(allStocks),
//                 ),
//
//               // ── List header ───────────────────────────────────────
//               SliverToBoxAdapter(
//                 child: _buildListHeader(filtered.length),
//               ),
//
//               // ── Loading ───────────────────────────────────────────
//               if (vm.cityStockModel == null)
//                 const SliverFillRemaining(
//                   child: Center(
//                     child: CircularProgressIndicator(
//                         color: ColorConst.primaryGreen, strokeWidth: 2),
//                   ),
//                 )
//               // ── Empty ─────────────────────────────────────────────
//               else if (filtered.isEmpty)
//                 SliverFillRemaining(child: _buildEmptyState())
//               // ── List ──────────────────────────────────────────────
//               else
//                 SliverPadding(
//                   padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
//                   sliver: SliverList(
//                     delegate: SliverChildBuilderDelegate(
//                           (context, index) {
//                         return AnimationConfiguration.staggeredList(
//                           position: index,
//                           duration: const Duration(milliseconds: 350),
//                           child: SlideAnimation(
//                             verticalOffset: 30.0,
//                             child: FadeInAnimation(
//                               child: _buildStockCard(filtered[index]),
//                             ),
//                           ),
//                         );
//                       },
//                       childCount: filtered.length,
//                     ),
//                   ),
//                 ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   // ── AppBar background ─────────────────────────────────────────────────────
//
//   Widget _buildAppBarBg(List<CityStockData> stocks) {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             ColorConst.primaryGreen,
//             ColorConst.primaryGreen.withValues(alpha: 0.8),
//           ],
//         ),
//       ),
//       child: Stack(
//         children: [
//           Positioned(
//             top: -20,
//             right: -20,
//             child: Container(
//               width: 140,
//               height: 140,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.white.withValues(alpha: 0.06),
//               ),
//             ),
//           ),
//           SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(20, 12, 60, 0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   FadeTransition(
//                     opacity: _headerFade,
//                     child: const Text(
//                       'City Stock',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 22,
//                         fontWeight: FontWeight.w800,
//                         letterSpacing: -0.3,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   FadeTransition(
//                     opacity: _headerFade,
//                     child: Text(
//                       '${stocks.length} products in inventory',
//                       style: TextStyle(
//                         color: Colors.white.withValues(alpha: 0.75),
//                         fontSize: 12,
//                       ),
//                     ),
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
//   // ── Search + Filter ───────────────────────────────────────────────────────
//
//   Widget _buildSearchAndFilter() {
//     return Container(
//       color: const Color(0xFFF5F7FA),
//       padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
//       child: Column(
//         children: [
//           // Search field
//           Container(
//             height: 46,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(13),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withValues(alpha: 0.05),
//                   blurRadius: 10,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Row(
//               children: [
//                 const SizedBox(width: 14),
//                 const Icon(Icons.search_rounded,
//                     size: 18, color: ColorConst.primaryGreen),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: TextField(
//                     controller: _searchController,
//                     onChanged: (v) => setState(() => _searchQuery = v),
//                     style: const TextStyle(
//                         fontSize: 13,
//                         color: Color(0xFF1F2937),
//                         fontWeight: FontWeight.w500),
//                     decoration: const InputDecoration(
//                       hintText: 'Search products, categories…',
//                       hintStyle: TextStyle(
//                           fontSize: 13, color: Color(0xFF9CA3AF)),
//                       border: InputBorder.none,
//                       isDense: true,
//                     ),
//                   ),
//                 ),
//                 if (_searchQuery.isNotEmpty)
//                   GestureDetector(
//                     onTap: () => setState(() {
//                       _searchController.clear();
//                       _searchQuery = '';
//                     }),
//                     child: Container(
//                       width: 26,
//                       height: 26,
//                       margin: const EdgeInsets.only(right: 10),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFF1F5F9),
//                         borderRadius: BorderRadius.circular(7),
//                       ),
//                       child: const Icon(Icons.close_rounded,
//                           size: 13, color: Color(0xFF6B7280)),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 10),
//
//           // Filter chips
//           SizedBox(
//             height: 34,
//             child: ListView.separated(
//               scrollDirection: Axis.horizontal,
//               itemCount: _filterOptions.length,
//               separatorBuilder: (_, __) => const SizedBox(width: 8),
//               itemBuilder: (_, i) {
//                 final f = _filterOptions[i];
//                 final isSelected = _selectedFilter == f;
//                 final chipColor = f == 'Out of Stock'
//                     ? const Color(0xFFEF4444)
//                     : f == 'Low Stock'
//                     ? const Color(0xFFF59E0B)
//                     : f == 'In Stock'
//                     ? const Color(0xFF10B981)
//                     : ColorConst.primaryGreen;
//                 return GestureDetector(
//                   onTap: () => setState(() => _selectedFilter = f),
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 200),
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 14, vertical: 7),
//                     decoration: BoxDecoration(
//                       color: isSelected
//                           ? chipColor
//                           : Colors.white,
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(
//                         color: isSelected
//                             ? chipColor
//                             : const Color(0xFFE5E7EB),
//                       ),
//                       boxShadow: isSelected
//                           ? [
//                         BoxShadow(
//                           color: chipColor.withValues(alpha: 0.3),
//                           blurRadius: 8,
//                           offset: const Offset(0, 2),
//                         )
//                       ]
//                           : [],
//                     ),
//                     child: Text(
//                       f,
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                         color: isSelected
//                             ? Colors.white
//                             : const Color(0xFF6B7280),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── Summary cards ─────────────────────────────────────────────────────────
//
//   Widget _buildSummaryCards(List<CityStockData> stocks) {
//     final total = stocks.length;
//     final totalUnits = stocks.fold<int>(
//         0,
//             (s, i) =>
//         s + (int.tryParse(i.stock?.toString() ?? '0') ?? 0));
//     final low = stocks.where((s) {
//       final v = s.stock ?? 0;
//       return v > 0 && v <= 10;
//     }).length;
//     final out = stocks.where((s) => (s.stock ?? 0) == 0).length;
//
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
//       child: Row(
//         children: [
//           _SummaryCard(
//             label: 'Products',
//             value: '$total',
//             icon: Icons.inventory_2_outlined,
//             color: const Color(0xFF2563EB),
//           ),
//           const SizedBox(width: 8),
//           _SummaryCard(
//             label: 'Total Units',
//             value: '$totalUnits',
//             icon: Icons.stacked_bar_chart_rounded,
//             color: const Color(0xFF10B981),
//           ),
//           const SizedBox(width: 8),
//           _SummaryCard(
//             label: 'Low',
//             value: '$low',
//             icon: Icons.warning_amber_rounded,
//             color: const Color(0xFFF59E0B),
//           ),
//           const SizedBox(width: 8),
//           _SummaryCard(
//             label: 'Out',
//             value: '$out',
//             icon: Icons.cancel_outlined,
//             color: const Color(0xFFEF4444),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── List header ───────────────────────────────────────────────────────────
//
//   Widget _buildListHeader(int count) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
//       child: Row(
//         children: [
//           Container(
//             width: 3,
//             height: 16,
//             decoration: BoxDecoration(
//               color: ColorConst.primaryGreen,
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//           const SizedBox(width: 8),
//           const Text(
//             'Stock Items',
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w700,
//               color: Color(0xFF1F2937),
//             ),
//           ),
//           const Spacer(),
//           Container(
//             padding:
//             const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//             decoration: BoxDecoration(
//               color: ColorConst.primaryGreen.withValues(alpha: 0.1),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Text(
//               '$count items',
//               style: const TextStyle(
//                 fontSize: 11,
//                 fontWeight: FontWeight.w600,
//                 color: ColorConst.primaryGreen,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── Stock Card ────────────────────────────────────────────────────────────
//
//   Widget _buildStockCard(CityStockData stock) {
//     final current = stock.stock ?? 0;
//     final received = int.tryParse(stock.totalReceived ?? '0') ?? 0;
//     final progress =
//     received > 0 ? (current / received).clamp(0.0, 1.0) : 0.0;
//     final color = _stockColor(current);
//     final isOut = current == 0;
//     final isLow = current > 0 && current <= 10;
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: (isOut || isLow)
//             ? Border.all(color: color.withValues(alpha: 0.25), width: 1.5)
//             : null,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(16),
//         onTap: () => _showStockDetails(context, stock),
//         child: Padding(
//           padding: const EdgeInsets.all(14),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // ── Row 1: image + info ───────────────────────────
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Image
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(12),
//                     child: stock.product?.img != null
//                         ? Image.network(
//                       "https://cdn.grofers.com/cdn-cgi/image/f=auto,fit=scale-down,q=70,metadata=none,w=720/da/cms-assets/cms/product/802ad355-91a5-4984-a0c3-06cdb59c3c31.png",
//                       width: 72,
//                       height: 72,
//                       fit: BoxFit.cover,
//                       errorBuilder: (_, __, ___) =>
//                           _imagePlaceholder(),
//                     )
//                         : _imagePlaceholder(),
//                   ),
//                   const SizedBox(width: 12),
//
//                   // Details
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Name + status badge
//                         Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 stock.product?.name ?? 'Unknown Product',
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w700,
//                                   color: Color(0xFF111827),
//                                 ),
//                                 maxLines: 2,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             // Status badge
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 8, vertical: 3),
//                               decoration: BoxDecoration(
//                                 color: color.withValues(alpha: 0.1),
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Icon(_stockIcon(current),
//                                       size: 10, color: color),
//                                   const SizedBox(width: 3),
//                                   Text(
//                                     _stockLabel(current),
//                                     style: TextStyle(
//                                       fontSize: 10,
//                                       fontWeight: FontWeight.w700,
//                                       color: color,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 6),
//
//                         // Chips row
//                         Wrap(
//                           spacing: 5,
//                           runSpacing: 4,
//                           children: [
//                             if (stock.category != null)
//                               _Chip(
//                                 label: stock.category?.categoryName!,
//                                 color: const Color(0xFF2563EB),
//                               ),
//                             if (stock.category?.subcategoryName != null)
//                               _Chip(
//                                 label: stock.category?.subcategoryName,
//                                 color: const Color(0xFF7C3AED),
//                               ),
//                             if (stock.variant?.name != null &&
//                                 stock.variant?.name != 'Default')
//                               _Chip(
//                                 label: stock.variant?.name!,
//                                 color: const Color(0xFF0891B2),
//                               ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//
//               const SizedBox(height: 12),
//               Divider(color: Colors.grey.shade100),
//               const SizedBox(height: 8),
//
//               // ── Row 2: stats ──────────────────────────────────
//               Row(
//                 children: [
//                   _StatCell(
//                     label: 'Current',
//                     value: '$current',
//                     color: color,
//                     icon: Icons.inventory_rounded,
//                   ),
//                   _vDivider(),
//                   _StatCell(
//                     label: 'Received',
//                     value: '$received',
//                     color: const Color(0xFF10B981),
//                     icon: Icons.download_rounded,
//                   ),
//
//                 ],
//               ),
//
//               const SizedBox(height: 10),
//
//               // ── Progress bar ──────────────────────────────────
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'Stock Level',
//                         style: TextStyle(
//                           fontSize: 10,
//                           color: Colors.grey.shade500,
//                         ),
//                       ),
//                       Text(
//                         '${(progress * 100).toStringAsFixed(0)}%',
//                         style: TextStyle(
//                           fontSize: 10,
//                           fontWeight: FontWeight.w700,
//                           color: color,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 5),
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(4),
//                     child: LinearProgressIndicator(
//                       value: progress,
//                       backgroundColor: const Color(0xFFF3F4F6),
//                       valueColor: AlwaysStoppedAnimation<Color>(color),
//                       minHeight: 5,
//                     ),
//                   ),
//                 ],
//               ),
//
//               // ── Warning banner ────────────────────────────────
//               if (isOut || isLow) ...[
//                 const SizedBox(height: 8),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 10, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: color.withValues(alpha: 0.06),
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(
//                         color: color.withValues(alpha: 0.2)),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(
//                         isOut
//                             ? Icons.cancel_outlined
//                             : Icons.warning_amber_rounded,
//                         size: 13,
//                         color: color,
//                       ),
//                       const SizedBox(width: 6),
//                       Text(
//                         isOut
//                             ? 'Out of stock — reorder immediately'
//                             : 'Low stock — consider restocking',
//                         style: TextStyle(
//                           fontSize: 11,
//                           color: color,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//
//               const SizedBox(height: 10),
//
//               // ── Detail button ─────────────────────────────────
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   GestureDetector(
//                     onTap: () => _showStockDetails(context, stock),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 14, vertical: 7),
//                       decoration: BoxDecoration(
//                         color: ColorConst.primaryGreen
//                             .withValues(alpha: 0.07),
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(
//                           color: ColorConst.primaryGreen
//                               .withValues(alpha: 0.2),
//                         ),
//                       ),
//                       child: const Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(Icons.info_outline_rounded,
//                               size: 13, color: ColorConst.primaryGreen),
//                           SizedBox(width: 5),
//                           Text(
//                             'View Details',
//                             style: TextStyle(
//                               fontSize: 11,
//                               fontWeight: FontWeight.w600,
//                               color: ColorConst.primaryGreen,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _imagePlaceholder() {
//     return Container(
//       width: 72,
//       height: 72,
//       decoration: BoxDecoration(
//         color: const Color(0xFFF3F4F6),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: const Icon(Icons.image_not_supported_rounded,
//           color: Color(0xFF9CA3AF), size: 28),
//     );
//   }
//
//   Widget _vDivider() {
//     return Container(
//       width: 1,
//       height: 32,
//       color: const Color(0xFFF3F4F6),
//       margin: const EdgeInsets.symmetric(horizontal: 12),
//     );
//   }
//
//   // ── Empty state ───────────────────────────────────────────────────────────
//
//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: ColorConst.primaryGreen.withValues(alpha: 0.06),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(Icons.inventory_2_outlined,
//                 size: 52, color: ColorConst.primaryGreen.withValues(alpha: 0.4)),
//           ),
//           const SizedBox(height: 16),
//           const Text(
//             'No products found',
//             style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w700,
//                 color: Color(0xFF374151)),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             'Try adjusting your search or filter',
//             style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
//           ),
//           const SizedBox(height: 16),
//           TextButton.icon(
//             onPressed: () => setState(() {
//               _searchController.clear();
//               _searchQuery = '';
//               _selectedFilter = 'All';
//             }),
//             icon: const Icon(Icons.refresh_rounded, size: 16),
//             label: const Text('Clear Filters'),
//             style: TextButton.styleFrom(
//                 foregroundColor: ColorConst.primaryGreen),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── Details bottom sheet ──────────────────────────────────────────────────
//
//   void _showStockDetails(BuildContext context, CityStockData stock) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => DraggableScrollableSheet(
//         initialChildSize: 0.88,
//         minChildSize: 0.5,
//         maxChildSize: 0.95,
//         expand: false,
//         builder: (context, scrollController) => _StockDetailsSheet(
//           stock: stock,
//           scrollController: scrollController,
//         ),
//       ),
//     );
//   }
// }
//
// // ── Summary Card ──────────────────────────────────────────────────────────────
//
// class _SummaryCard extends StatelessWidget {
//   final String label;
//   final String value;
//   final IconData icon;
//   final Color color;
//
//   const _SummaryCard({
//     required this.label,
//     required this.value,
//     required this.icon,
//     required this.color,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(14),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withValues(alpha: 0.04),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(7),
//               decoration: BoxDecoration(
//                 color: color.withValues(alpha: 0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(icon, size: 15, color: color),
//             ),
//             const SizedBox(height: 6),
//             Text(
//               value,
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w800,
//                 color: color,
//               ),
//             ),
//             Text(
//               label,
//               style: const TextStyle(
//                   fontSize: 9,
//                   color: Color(0xFF9CA3AF),
//                   fontWeight: FontWeight.w500),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ── Chip ──────────────────────────────────────────────────────────────────────
//
// class _Chip extends StatelessWidget {
//   final String label;
//   final Color color;
//   const _Chip({required this.label, required this.color});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
//       decoration: BoxDecoration(
//         color: color.withValues(alpha: 0.08),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: color.withValues(alpha: 0.2)),
//       ),
//       child: Text(
//         label,
//         style: TextStyle(
//             fontSize: 9, fontWeight: FontWeight.w600, color: color),
//       ),
//     );
//   }
// }
//
// // ── Stat cell ─────────────────────────────────────────────────────────────────
//
// class _StatCell extends StatelessWidget {
//   final String label;
//   final String value;
//   final Color color;
//   final IconData icon;
//   const _StatCell(
//       {required this.label,
//         required this.value,
//         required this.color,
//         required this.icon});
//
//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon, size: 11, color: color),
//               const SizedBox(width: 3),
//               Text(label,
//                   style: const TextStyle(
//                       fontSize: 10, color: Color(0xFF9CA3AF))),
//             ],
//           ),
//           const SizedBox(height: 3),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w800,
//               color: color,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ── Stock Details Sheet ───────────────────────────────────────────────────────
//
// class _StockDetailsSheet extends StatelessWidget {
//   final CityStockData stock;
//   final ScrollController scrollController;
//
//   const _StockDetailsSheet({
//     required this.stock,
//     required this.scrollController,
//   });
//
//   Color get _color {
//     final s = stock.stock ?? 0;
//     if (s == 0) return const Color(0xFFEF4444);
//     if (s <= 10) return const Color(0xFFF59E0B);
//     return const Color(0xFF10B981);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final current = stock.stock ?? 0;
//     final received = int.tryParse(stock.totalReceived ?? '0') ?? 0;
//     final progress =
//     received > 0 ? (current / received).clamp(0.0, 1.0) : 0.0;
//
//     return Container(
//       decoration: const BoxDecoration(
//         color: Color(0xFFF5F7FA),
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       child: Column(
//         children: [
//           // Handle
//           Container(
//             margin: const EdgeInsets.only(top: 12, bottom: 4),
//             width: 36,
//             height: 4,
//             decoration: BoxDecoration(
//               color: Colors.grey.shade300,
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//
//           Expanded(
//             child: ListView(
//               controller: scrollController,
//               padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
//               children: [
//                 // ── Hero card ──────────────────────────────────────
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(20),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withValues(alpha: 0.05),
//                         blurRadius: 16,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     children: [
//                       // Image
//                       ClipRRect(
//                         borderRadius: const BorderRadius.vertical(
//                             top: Radius.circular(20)),
//                         child: stock.product?.img != null
//                             ? Image.network(
//                           stock.product?.img!,
//                           height: 200,
//                           width: double.infinity,
//                           fit: BoxFit.cover,
//                           errorBuilder: (_, __, ___) =>
//                               _imgPlaceholder(),
//                         )
//                             : _imgPlaceholder(),
//                       ),
//
//                       Padding(
//                         padding: const EdgeInsets.all(16),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // Name + status
//                             Row(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Expanded(
//                                   child: Text(
//                                     stock.product?.name ?? 'Unknown',
//                                     style: const TextStyle(
//                                       fontSize: 20,
//                                       fontWeight: FontWeight.w800,
//                                       color: Color(0xFF111827),
//                                       letterSpacing: -0.3,
//                                     ),
//                                   ),
//                                 ),
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 10, vertical: 5),
//                                   decoration: BoxDecoration(
//                                     color:
//                                     _color.withValues(alpha: 0.1),
//                                     borderRadius:
//                                     BorderRadius.circular(20),
//                                   ),
//                                   child: Text(
//                                     current == 0
//                                         ? 'Out of Stock'
//                                         : current <= 10
//                                         ? 'Low Stock'
//                                         : 'In Stock',
//                                     style: TextStyle(
//                                       fontSize: 11,
//                                       fontWeight: FontWeight.w700,
//                                       color: _color,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 8),
//
//                             // Category chips
//                             Wrap(
//                               spacing: 6,
//                               runSpacing: 6,
//                               children: [
//                                 if (stock.category?.mainCategoryName != null)
//                                   _DetailChip(
//                                     icon: Icons.category_rounded,
//                                     label: stock.category?.mainCategoryName!,
//                                     color: const Color(0xFF2563EB),
//                                   ),
//                                 if (stock.category != null)
//                                   _DetailChip(
//                                     icon: Icons.label_rounded,
//                                     label: stock.category?.mainCategoryName!,
//                                     color: const Color(0xFF7C3AED),
//                                   ),
//                                 if (stock.category?.subcategoryName != null)
//                                   _DetailChip(
//                                     icon: Icons.subdirectory_arrow_right_rounded,
//                                     label: stock.category?.subcategoryName!,
//                                     color: const Color(0xFF0891B2),
//                                   ),
//                                 if (stock.variant?.name != null &&
//                                     stock.variant?.name != 'Default')
//                                   _DetailChip(
//                                     icon: Icons.tune_rounded,
//                                     label: stock.variant?.name!,
//                                     color: const Color(0xFFF59E0B),
//                                   ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 const SizedBox(height: 16),
//
//                 // ── Stats row ──────────────────────────────────────
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withValues(alpha: 0.04),
//                         blurRadius: 10,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const _SheetSectionLabel('Stock Overview'),
//                       const SizedBox(height: 14),
//                       Row(
//                         children: [
//                           _BigStatCard(
//                             label: 'Current',
//                             value: '$current',
//                             icon: Icons.inventory_rounded,
//                             color: _color,
//                           ),
//                           const SizedBox(width: 10),
//                           _BigStatCard(
//                             label: 'Received',
//                             value: '$received',
//                             icon: Icons.download_rounded,
//                             color: const Color(0xFF10B981),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 14),
//                       Row(
//                         mainAxisAlignment:
//                         MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text('Stock Level',
//                               style: TextStyle(
//                                   fontSize: 11,
//                                   color: Colors.grey.shade500)),
//                           Text(
//                             '${(progress * 100).toStringAsFixed(0)}%',
//                             style: TextStyle(
//                                 fontSize: 11,
//                                 fontWeight: FontWeight.w700,
//                                 color: _color),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 6),
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(4),
//                         child: LinearProgressIndicator(
//                           value: progress,
//                           backgroundColor: const Color(0xFFF3F4F6),
//                           valueColor:
//                           AlwaysStoppedAnimation<Color>(_color),
//                           minHeight: 7,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 const SizedBox(height: 14),
//
//                 // ── Detail rows ────────────────────────────────────
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withValues(alpha: 0.04),
//                         blurRadius: 10,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     children: [
//                       const Padding(
//                         padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
//                         child: _SheetSectionLabel('Product Details'),
//                       ),
//                       _DetailRow(
//                           'Product ID',
//                           '#${stock.productid?.toString() ?? "N/A"}',
//                           Icons.tag_rounded),
//                       _DetailRow(
//                           'Variant',
//                           stock.variant?.name ?? 'Default',
//                           Icons.tune_rounded),
//                       _DetailRow(
//                           'Main Category',
//                           stock.category?.mainCategoryName ?? 'N/A',
//                           Icons.category_rounded),
//                       _DetailRow(
//                           'Category',
//                           stock.category?.categoryName ?? 'N/A',
//                           Icons.label_rounded),
//                       _DetailRow(
//                           'Sub Category',
//                           stock.category?.subcategoryName ?? 'N/A',
//                           Icons.subdirectory_arrow_right_rounded,
//                           isLast: true),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _imgPlaceholder() {
//     return Container(
//       height: 200,
//       decoration: const BoxDecoration(
//         color: Color(0xFFF3F4F6),
//         borderRadius:
//         BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       child: const Center(
//         child: Icon(Icons.image_not_supported_rounded,
//             size: 48, color: Color(0xFF9CA3AF)),
//       ),
//     );
//   }
// }
//
// // ── Sheet sub-widgets ─────────────────────────────────────────────────────────
//
// class _SheetSectionLabel extends StatelessWidget {
//   final String label;
//   const _SheetSectionLabel(this.label);
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Container(
//           width: 3,
//           height: 14,
//           decoration: BoxDecoration(
//             color: ColorConst.primaryGreen,
//             borderRadius: BorderRadius.circular(2),
//           ),
//         ),
//         const SizedBox(width: 7),
//         Text(label,
//             style: const TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w700,
//                 color: Color(0xFF1F2937))),
//       ],
//     );
//   }
// }
//
// class _DetailChip extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final Color color;
//   const _DetailChip(
//       {required this.icon, required this.label, required this.color});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
//       decoration: BoxDecoration(
//         color: color.withValues(alpha: 0.08),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: color.withValues(alpha: 0.2)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 11, color: color),
//           const SizedBox(width: 4),
//           Text(label,
//               style: TextStyle(
//                   fontSize: 11,
//                   fontWeight: FontWeight.w600,
//                   color: color)),
//         ],
//       ),
//     );
//   }
// }
//
// class _BigStatCard extends StatelessWidget {
//   final String label;
//   final String value;
//   final IconData icon;
//   final Color color;
//   const _BigStatCard(
//       {required this.label,
//         required this.value,
//         required this.icon,
//         required this.color});
//
//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 12),
//         decoration: BoxDecoration(
//           color: color.withValues(alpha: 0.06),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: color.withValues(alpha: 0.15)),
//         ),
//         child: Column(
//           children: [
//             Icon(icon, size: 16, color: color),
//             const SizedBox(height: 6),
//             Text(value,
//                 style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w800,
//                     color: color)),
//             Text(label,
//                 style: const TextStyle(
//                     fontSize: 10, color: Color(0xFF9CA3AF))),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _DetailRow extends StatelessWidget {
//   final String label;
//   final String value;
//   final IconData icon;
//   final bool isLast;
//   const _DetailRow(this.label, this.value, this.icon,
//       {this.isLast = false});
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Padding(
//           padding:
//           const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           child: Row(
//             children: [
//               Icon(icon, size: 15, color: const Color(0xFF9CA3AF)),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Text(label,
//                     style: const TextStyle(
//                         fontSize: 13, color: Color(0xFF6B7280))),
//               ),
//               Text(value,
//                   style: const TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF111827))),
//             ],
//           ),
//         ),
//         if (!isLast)
//           Divider(
//             height: 1,
//             indent: 42,
//             color: Colors.grey.shade100,
//           ),
//       ],
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/tost_msg/custom_snackbar.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/city_stock_model.dart' as prefix0;
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/city_stock_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/city_stock_view_model.dart';


class CityStockScreen extends StatefulWidget {
  const CityStockScreen({super.key});

  @override
  State<CityStockScreen> createState() => _CityStockScreenState();
}

class _CityStockScreenState extends State<CityStockScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  String _searchQuery = '';
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CityStockViewModel>().getCityStockDataApi(context);
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CityStockViewModel>(context);
    final model = vm.cityStockModel;

    final allItems = model?.data ?? [];
    final categories = allItems
        .map((e) => e.category?.mainCategoryName ?? '').toSet().toList();

    final filtered = allItems.where((item) {
      final name = (item.product?.name ?? '').toLowerCase();
      final brand = (item.brand?.name ?? '').toLowerCase();
      final cat = item.category?.mainCategoryName ?? '';
      final matchQuery = _searchQuery.isEmpty ||
          name.contains(_searchQuery.toLowerCase()) ||
          brand.contains(_searchQuery.toLowerCase());
      final matchCat =
          _selectedCategory == null || cat == _selectedCategory;
      return matchQuery && matchCat;
    }).toList();

    return Scaffold(
      backgroundColor: ColorConst.bgColor,
      body: Column(
        children: [
          _buildHeader(categories),
          Expanded(
            child: model == null
                ? _buildLoading()
                : filtered.isEmpty
                ? _buildEmpty()
                : FadeTransition(
              opacity: _fadeController,
              child: _buildStockList(filtered),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header + Search + Filter ──────────────────────────────────────────────
  Widget _buildHeader(List<dynamic> categories) {
    return Container(
      decoration: const BoxDecoration(
        color: ColorConst.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Row
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: ColorConst.primaryExtraLightGreen,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.inventory_2_rounded,
                      color: ColorConst.primaryGreen,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'City Stock',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: ColorConst.textDark,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        'Manage your inventory',
                        style: TextStyle(
                          fontSize: 11,
                          color: ColorConst.textGrey,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(onPressed: (){
                    context.read<CityStockViewModel>().getCityStockDataApi(context);

                  }, icon: Icon(Icons.refresh,color: ColorConst.primaryGreen))
                ],
              ),
              const SizedBox(height: 14),

              // Search Bar
              Container(
                height: 42,
                decoration: BoxDecoration(
                  color: ColorConst.containerGrey,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ColorConst.borderColor),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: const TextStyle(
                    fontSize: 13,
                    color: ColorConst.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search products or brands…',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: ColorConst.textGrey1,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: ColorConst.textGrey,
                      size: 18,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                      child: const Icon(
                        Icons.close_rounded,
                        color: ColorConst.textGrey,
                        size: 16,
                      ),
                    )
                        : null,
                    border: InputBorder.none,
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 11),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Category Filter Chips
              SizedBox(
                height: 32,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildFilterChip('All', null),
                    ...categories.map((c) => _buildFilterChip(c, c)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String? value) {
    final selected = _selectedCategory == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? ColorConst.primaryGreen
              : ColorConst.containerGrey,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? ColorConst.primaryGreen
                : ColorConst.borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight:
            selected ? FontWeight.w600 : FontWeight.w500,
            color: selected
                ? ColorConst.white
                : ColorConst.textSecondary,
          ),
        ),
      ),
    );
  }

  // ── Stock List ────────────────────────────────────────────────────────────
  Widget _buildStockList(List<CityStockData> items) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 300 + index * 60),
          curve: Curves.easeOut,
          builder: (context, value, child) => Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Opacity(opacity: value, child: child),
          ),
          child: _StockCard(item: items[index]),
        );
      },
    );
  }

  // ── States ────────────────────────────────────────────────────────────────
  Widget _buildLoading() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: 5,
      itemBuilder: (_, __) => const _ShimmerCard(),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: ColorConst.primaryExtraLightGreen,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: ColorConst.primaryGreen,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No stock found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ColorConst.textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try adjusting your search or filter',
            style: TextStyle(
              fontSize: 13,
              color: ColorConst.textGrey,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stock Card ──────────────────────────────────────────────────────────────
class _StockCard extends StatefulWidget {
  final CityStockData item;
  const _StockCard({required this.item});

  @override
  State<_StockCard> createState() => _StockCardState();
}

class _StockCardState extends State<_StockCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.item.product;
    final brand = widget.item.brand;
    final category = widget.item.category;
    final variant = widget.item.variant;
    final images = widget.item.images ?? [];

    final stock = widget.item.stock ?? 0;
    final unitPrice = double.tryParse(
        widget.item.perUnitPrice?.toString() ?? '0') ??
        0;
    final originalPrice = p?.price ?? 0;
    final discountPrice = p?.discountPrice ?? 0;
    final totalReceived =
        int.tryParse(widget.item.totalReceived?.toString() ?? '0') ?? 0;
    final totalSent =
        int.tryParse(widget.item.totalSent?.toString() ?? '0') ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: ColorConst.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorConst.borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // ── Main Row ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  _ProductImage(
                    url: p?.img ?? '',
                    size: 68,
                  ),
                  const SizedBox(width: 12),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name + status badge
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                p?.name ?? '-',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: ColorConst.textDark,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            _StockStatusBadge(status: widget.item.stockStatus),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Brand + Category
                        Row(
                          children: [
                            if (brand?.img != null) ...[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: Image.network(
                                  brand!.img,
                                  width: 14,
                                  height: 14,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                  const SizedBox(),
                                ),
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              brand?.name ?? '-',
                              style: const TextStyle(
                                fontSize: 11,
                                color: ColorConst.primaryGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 3,
                              height: 3,
                              decoration: const BoxDecoration(
                                color: ColorConst.textGrey1,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                category?.categoryName ?? '-',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: ColorConst.textGrey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Price Row
                        Row(
                          children: [
                            Text(
                              '₹${unitPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: ColorConst.primaryGreen,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '₹${originalPrice.toString()}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: ColorConst.textGrey1,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const Spacer(),
                            // Unit
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: ColorConst.containerGrey,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                p?.unit ?? '-',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: ColorConst.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Stock Progress Bar
                        _StockProgressBar(stock: stock, maxStock: 300),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Stats Row ─────────────────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                color: ColorConst.containerGrey2,
                border: Border(
                  top: BorderSide(color: ColorConst.borderColor),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  _StatChip(
                    icon: Icons.inventory_rounded,
                    label: 'In Stock',
                    value: '$stock',
                    color: ColorConst.primaryGreen,
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    icon: Icons.arrow_downward_rounded,
                    label: 'Received',
                    value: '$totalReceived',
                    color: ColorConst.info,
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    icon: Icons.arrow_upward_rounded,
                    label: 'Sent',
                    value: '$totalSent',
                    color: ColorConst.warning,
                  ),
                  const Spacer(),
                  // Expand toggle
                  GestureDetector(
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: ColorConst.primaryExtraLightGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'Details',
                            style: TextStyle(
                              fontSize: 11,
                              color: ColorConst.primaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 2),
                          AnimatedRotation(
                            turns: _expanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 14,
                              color: ColorConst.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Expanded Details ──────────────────────────────────────
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: _expanded
                  ? _ExpandedDetails(
                item: widget.item,
                images: images,
              )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Expanded Details ────────────────────────────────────────────────────────
class _ExpandedDetails extends StatelessWidget {
  final CityStockData item;
  final List<Images> images;

  const _ExpandedDetails({required this.item, required this.images});

  @override
  Widget build(BuildContext context) {
    final p = item.product;
    final brand = item.brand;
    final category = item.category;
    final variant = item.variant;

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: ColorConst.borderColor),
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Gallery
          if (images.isNotEmpty) ...[
            const _SectionLabel('Gallery'),
            const SizedBox(height: 8),
            SizedBox(
              height: 72,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                itemBuilder: (_, i) => Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: ColorConst.borderColor),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      images[i].image ?? '',
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 72,
                        height: 72,
                        color: ColorConst.containerGrey,
                        child: const Icon(Icons.image_not_supported_outlined,
                            size: 20, color: ColorConst.textGrey1),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Product Details
          const _SectionLabel('Product Info'),
          const SizedBox(height: 8),
          _DetailGrid(items: [
            _DetailItem('SKU', p?.sku ?? '-'),
            _DetailItem('Unit', p?.unit ?? '-'),
            _DetailItem(
                'Featured', (p?.isFeatured == 1) ? 'Yes' : 'No'),
            _DetailItem(
                'Trending', (p?.isTrending == 1) ? 'Yes' : 'No'),
          ]),
          const SizedBox(height: 8),

          // Description
          if (p?.shortDescription != null) ...[
            Text(
              p!.shortDescription,
              style: const TextStyle(
                fontSize: 12,
                color: ColorConst.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Category Breadcrumb
          const _SectionLabel('Category'),
          const SizedBox(height: 8),
          _BreadcrumbRow(
            parts: [
              category?.mainCategoryName ?? '-',
              category?.categoryName ?? '-',
              category?.subcategoryName ?? '-',
            ],
          ),
          const SizedBox(height: 14),

          // Variant Info
          if (variant != null) ...[
            const _SectionLabel('Variant'),
            const SizedBox(height: 8),
            _DetailGrid(items: [
              _DetailItem(
                  'Name', '${variant.name} · ${variant.value}'),
              _DetailItem('SKU', variant.sku ?? '-'),
              _DetailItem('Price', '₹${variant.price}'),
              _DetailItem(
                  'Discount', '₹${variant.discountPrice}'),
            ]),
            const SizedBox(height: 14),
          ],

        ],
      ),
    );
  }
}

// ─── Helper Widgets ──────────────────────────────────────────────────────────

class _ProductImage extends StatelessWidget {
  final String url;
  final double size;
  const _ProductImage({required this.url, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: ColorConst.containerGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorConst.borderColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              size: 24,
              color: ColorConst.textGrey1,
            ),
          ),
        ),
      ),
    );
  }
}

class _StockStatusBadge extends StatelessWidget {
  final dynamic status;
  const _StockStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isActive = status == 1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isActive
            ? ColorConst.primaryExtraLightGreen
            : const Color(0xFFFFF3F3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: isActive
                  ? ColorConst.primaryGreen
                  : ColorConst.criticalRed,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? 'Active' : 'Low',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isActive
                  ? ColorConst.primaryGreen
                  : ColorConst.criticalRed,
            ),
          ),
        ],
      ),
    );
  }
}

class _StockProgressBar extends StatelessWidget {
  final int stock;
  final int maxStock;
  const _StockProgressBar({required this.stock, required this.maxStock});

  @override
  Widget build(BuildContext context) {
    final ratio = (stock / maxStock).clamp(0.0, 1.0);
    final color = ratio > 0.5
        ? ColorConst.primaryGreen
        : ratio > 0.25
        ? ColorConst.warning
        : ColorConst.criticalRed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Stock level',
              style: const TextStyle(
                fontSize: 10,
                color: ColorConst.textGrey,
              ),
            ),
            Text(
              '$stock / $maxStock',
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 5,
            backgroundColor: ColorConst.containerGrey,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                  height: 1.1,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9,
                  color: ColorConst.textGrey,
                ),
              ),
            ],
          ),
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
        fontWeight: FontWeight.w700,
        color: ColorConst.textGrey,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _DetailGrid extends StatelessWidget {
  final List<_DetailItem> items;
  const _DetailGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 6,
      crossAxisSpacing: 6,
      childAspectRatio: 4,
      children: items,
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  const _DetailItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: ColorConst.containerGrey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: ColorConst.textGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              color: ColorConst.textDark,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _BreadcrumbRow extends StatelessWidget {
  final List<String> parts;
  const _BreadcrumbRow({required this.parts});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: parts.asMap().entries.map((e) {
        final isLast = e.key == parts.length - 1;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isLast
                    ? ColorConst.primaryExtraLightGreen
                    : ColorConst.containerGrey,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                e.value,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                  isLast ? FontWeight.w600 : FontWeight.w400,
                  color: isLast
                      ? ColorConst.primaryGreen
                      : ColorConst.textSecondary,
                ),
              ),
            ),
            if (!isLast)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 14,
                  color: ColorConst.textGrey1,
                ),
              ),
          ],
        );
      }).toList(),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool primary;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: primary ? ColorConst.primaryGreen : ColorConst.containerGrey,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: primary
                    ? ColorConst.white
                    : ColorConst.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: primary
                      ? ColorConst.white
                      : ColorConst.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Shimmer Card ─────────────────────────────────────────────────────────────
class _ShimmerCard extends StatefulWidget {
  const _ShimmerCard();

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ColorConst.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ColorConst.borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _shimmerBox(68, 68, radius: 12),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmerBox(16, double.infinity),
                  const SizedBox(height: 6),
                  _shimmerBox(12, 140),
                  const SizedBox(height: 10),
                  _shimmerBox(14, 80),
                  const SizedBox(height: 10),
                  _shimmerBox(6, double.infinity),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox(double h, double w, {double radius = 6}) {
    return Container(
      height: h,
      width: w,
      decoration: BoxDecoration(
        color: ColorConst.containerGrey,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

