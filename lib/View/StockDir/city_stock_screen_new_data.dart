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
// class _CityStockListScreenState extends State<CityStockListScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = '';
//   String _selectedFilter = 'All';
//
//   final List<String> _filterOptions = ['All', 'Low Stock', 'Out of Stock', 'In Stock'];
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_){
//       _loadData();
//     });
//   }
//
//   Future<void> _loadData() async {
//     final viewModel = Provider.of<CityStockViewModel>(context, listen: false);
//     await viewModel.getCityStockDataApi(context);
//   }
//
//   List<CityStockData> _getFilteredStocks(List<CityStockData>? stocks) {
//     return stocks!.where((stock) {
//       // Apply search filter
//       final matchesSearch = _searchQuery.isEmpty ||
//           stock.product?.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
//           stock.category?.subcategoryName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
//           stock.brand?.name.toLowerCase().contains(_searchQuery.toLowerCase());
//
//       // Apply stock status filter
//       bool matchesFilter = true;
//       switch (_selectedFilter) {
//         case 'Low Stock':
//           matchesFilter = stock.stock > 0 && stock.stock <= 10;
//           break;
//         case 'Out of Stock':
//           matchesFilter = stock.stock == 0;
//           break;
//         case 'In Stock':
//           matchesFilter = stock.stock > 10;
//           break;
//         default:
//           matchesFilter = true;
//       }
//
//       return matchesSearch && matchesFilter;
//     }).toList();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ColorConst.bgColor,
//       appBar: AppBar(
//         title: const Text(
//           'City Stock Management',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         automaticallyImplyLeading: false,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _loadData,
//           ),
//         ],
//       ),
//       body: Consumer<CityStockViewModel>(
//         builder: (context, viewModel, child) {
//           if (viewModel.cityStockModel == null) {
//             return const Center(
//               child: CircularProgressIndicator(
//                 color: ColorConst.primaryGreen,
//                 strokeWidth: 2,
//               ),
//             );
//           }
//
//           final filteredStocks = _getFilteredStocks(viewModel.cityStockModel!.data);
//
//           return Column(
//             children: [
//               // Search and Filter Section
//               _buildSearchAndFilter(),
//
//               // Summary Cards
//               _buildSummaryCards(viewModel.cityStockModel!.data!),
//
//               // Stock List Header
//               _buildListHeader(filteredStocks.length),
//
//               // Stock List
//               Expanded(
//                 child: filteredStocks.isEmpty
//                     ? _buildEmptyState()
//                     : ListView.builder(
//                   padding: const EdgeInsets.all(16),
//                   itemCount: filteredStocks.length,
//                   itemBuilder: (context, index) {
//                     return AnimationConfiguration.staggeredList(
//                       position: index,
//                       duration: const Duration(milliseconds: 375),
//                       child: SlideAnimation(
//                         verticalOffset: 50.0,
//                         child: FadeInAnimation(
//                           child: _buildStockCard(filteredStocks[index]),
//                         ),
//                       ),
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
//   Widget _buildSearchAndFilter() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       color: Colors.white,
//       child: Column(
//         children: [
//           TextField(
//             controller: _searchController,
//             onChanged: (value) {
//               setState(() {
//                 _searchQuery = value;
//               });
//             },
//             decoration: InputDecoration(
//               hintText: 'Search by product, category, or brand...',
//               prefixIcon: const Icon(Icons.search),
//               suffixIcon: _searchQuery.isNotEmpty
//                   ? IconButton(
//                 icon: const Icon(Icons.clear),
//                 onPressed: () {
//                   setState(() {
//                     _searchController.clear();
//                     _searchQuery = '';
//                   });
//                 },
//               )
//                   : null,
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(color: Colors.grey[300]!),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(color: Colors.grey[300]!),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: const BorderSide(color: Colors.blue, width: 2),
//               ),
//               filled: true,
//               fillColor: Colors.grey[50],
//             ),
//           ),
//           const SizedBox(height: 12),
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               children: _filterOptions.map((filter) {
//                 final isSelected = _selectedFilter == filter;
//                 return Padding(
//                   padding: const EdgeInsets.only(right: 8),
//                   child: FilterChip(
//                     label: Text(filter),
//                     selected: isSelected,
//                     onSelected: (selected) {
//                       setState(() {
//                         _selectedFilter = filter;
//                       });
//                     },
//                     backgroundColor: Colors.white,
//                     selectedColor: Colors.blue.shade50,
//                     checkmarkColor: Colors.blue,
//                     labelStyle: TextStyle(
//                       color: isSelected ? Colors.blue : Colors.grey[700],
//                       fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSummaryCards(List<CityStockData> stocks) {
//     final totalProducts = stocks.length;
//     int totalStock = stocks.fold(
//       0,
//           (sum, item) => sum + (int.tryParse(item.stock?.toString() ?? '0') ?? 0),
//     );
//     final lowStockCount = stocks.where((s) => s.stock > 0 && s.stock <= 10).length;
//     final outOfStockCount = stocks.where((s) => s.stock == 0).length;
//
//     return Container(
//       padding: const EdgeInsets.all(16),
//       child: Row(
//         children: [
//           Expanded(
//             child: _buildSummaryCard(
//               'Total Products',
//               totalProducts.toString(),
//               Icons.inventory,
//               Colors.blue,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: _buildSummaryCard(
//               'Total Stock',
//               totalStock.toString(),
//               Icons.production_quantity_limits,
//               Colors.green,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: _buildSummaryCard(
//               'Low Stock',
//               lowStockCount.toString(),
//               Icons.warning_amber,
//               Colors.orange,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: _buildSummaryCard(
//               'Out of Stock',
//               outOfStockCount.toString(),
//               Icons.error_outline,
//               Colors.red,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withValues(alpha:0.1),
//             spreadRadius: 1,
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(icon, size: 20, color: color),
//               const SizedBox(width: 4),
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 11,
//                   color: Colors.grey[600],
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildListHeader(int count) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         color: Colors.grey[100],
//         border: Border(
//           bottom: BorderSide(color: Colors.grey[300]!),
//           top: BorderSide(color: Colors.grey[300]!),
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             'Stock Items',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey[800],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: BoxDecoration(
//               color: Colors.blue,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Text(
//               '$count items',
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 12,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStockCard(CityStockData stock) {
//     final isLowStock = stock.stock > 0 && stock.stock <= 10;
//     final isOutOfStock = stock.stock == 0;
//
//     Color stockColor = Colors.green;
//     String stockStatus = 'In Stock';
//
//     if (isOutOfStock) {
//       stockColor = Colors.red;
//       stockStatus = 'Out of Stock';
//     } else if (isLowStock) {
//       stockColor = Colors.orange;
//       stockStatus = 'Low Stock';
//     }
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withValues(alpha:0.1),
//             spreadRadius: 1,
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: () {
//             _showStockDetails(context, stock);
//           },
//           borderRadius: BorderRadius.circular(12),
//           child: Padding(
//             padding: const EdgeInsets.all(12),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Product Image
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(8),
//                       child: Image.network(
//                         stock.product?.img,
//                         width: 80,
//                         height: 80,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) {
//                           return Container(
//                             width: 80,
//                             height: 80,
//                             color: Colors.grey[200],
//                             child: const Icon(Icons.image_not_supported),
//                           );
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     // Product Details
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             stock.product?.name,
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           const SizedBox(height: 4),
//                           Row(
//                             children: [
//                               Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 8,
//                                   vertical: 2,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: Colors.grey[200],
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: Text(
//                                   stock.brand?.name,
//                                   style: TextStyle(
//                                     fontSize: 11,
//                                     color: Colors.grey[700],
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 8,
//                                   vertical: 2,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: Colors.blue.shade50,
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: Text(
//                                   stock.category?.subcategoryName,
//                                   style: TextStyle(
//                                     fontSize: 11,
//                                     color: Colors.blue.shade700,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.shopping_bag,
//                                 size: 14,
//                                 color: Colors.grey[600],
//                               ),
//                               const SizedBox(width: 4),
//                               Text(
//                                 'Variant: ${stock.variant?.value}',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.grey[600],
//                                 ),
//                               ),
//                               const SizedBox(width: 12),
//                               Icon(
//                                 Icons.currency_rupee,
//                                 size: 14,
//                                 color: Colors.grey[600],
//                               ),
//                               const SizedBox(width: 4),
//                               Text(
//                                 stock.perUnitPrice,
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.green[700],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 Divider(color: Colors.grey[200]),
//                 const SizedBox(height: 8),
//                 // Stock Information
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Current Stock',
//                           style: TextStyle(
//                             fontSize: 11,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Row(
//                           children: [
//                             Text(
//                               stock.stock.toString(),
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                                 color: stockColor,
//                               ),
//                             ),
//                             const SizedBox(width: 4),
//                             Text(
//                               stock.product?.unit,
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey[600],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         color: stockColor.withValues(alpha:0.1),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(
//                             isOutOfStock
//                                 ? Icons.cancel_outlined
//                                 : isLowStock
//                                 ? Icons.warning_amber_outlined
//                                 : Icons.check_circle_outline,
//                             size: 16,
//                             color: stockColor,
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             stockStatus,
//                             style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w500,
//                               color: stockColor,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 // Movement Information
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Colors.grey[50],
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       _buildMovementInfo(
//                         'Total Received',
//                         stock.totalReceived,
//                         Icons.arrow_downward,
//                         Colors.green,
//                       ),
//                       Container(
//                         width: 1,
//                         height: 30,
//                         color: Colors.grey[300],
//                       ),
//                       _buildMovementInfo(
//                         'Total Sent',
//                         stock.totalSent,
//                         Icons.arrow_upward,
//                         Colors.red,
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildMovementInfo(String label, String value, IconData icon, Color color) {
//     return Expanded(
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(icon, size: 16, color: color),
//           const SizedBox(width: 4),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 10,
//                   color: Colors.grey[600],
//                 ),
//               ),
//               Text(
//                 value,
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                   color: color,
//                 ),
//               ),
//             ],
//           ),
//         ],
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
//             size: 80,
//             color: Colors.grey[400],
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'No stock items found',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               color: Colors.grey[600],
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Try adjusting your search or filter',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey[500],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showStockDetails(BuildContext context, CityStockData stock) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => DraggableScrollableSheet(
//         initialChildSize: 0.9,
//         minChildSize: 0.5,
//         maxChildSize: 0.95,
//         expand: false,
//         builder: (context, scrollController) {
//           return StockDetailsSheet(
//             stock: stock,
//             scrollController: scrollController,
//           );
//         },
//       ),
//     );
//   }
// }
//
// // Stock Details Sheet Widget
// class StockDetailsSheet extends StatelessWidget {
//   final CityStockData stock;
//   final ScrollController scrollController;
//
//   const StockDetailsSheet({
//     super.key,
//     required this.stock,
//     required this.scrollController,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         color: Colors.white,
//       ),
//       child: Column(
//         children: [
//           Container(
//             margin: const EdgeInsets.only(top: 12),
//             width: 40,
//             height: 4,
//             decoration: BoxDecoration(
//               color: Colors.grey[300],
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//           Expanded(
//             child: ListView(
//               controller: scrollController,
//               padding: const EdgeInsets.all(20),
//               children: [
//                 // Product Image
//                 Center(
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(12),
//                     child: Image.network(
//                       stock.product?.img,
//                       height: 200,
//                       width: double.infinity,
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) {
//                         return Container(
//                           height: 200,
//                           color: Colors.grey[200],
//                           child: const Icon(Icons.image_not_supported, size: 50),
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 // Product Title
//                 Text(
//                   stock.product?.name,
//                   style: const TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 // Brand and Category
//                 Row(
//                   children: [
//                     Chip(
//                       label: Text(stock.brand?.name),
//                       avatar: const Icon(Icons.branding_watermark, size: 16),
//                       backgroundColor: Colors.grey[200],
//                     ),
//                     const SizedBox(width: 8),
//                     Chip(
//                       label: Text(stock.category?.subcategoryName),
//                       avatar: const Icon(Icons.category, size: 16),
//                       backgroundColor: Colors.blue.shade50,
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//                 // Stock Details
//                 _buildDetailCard(),
//                 const SizedBox(height: 20),
//                 // Additional Information
//                 _buildAdditionalInfo(),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDetailCard() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(12),
//       ),
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           _buildDetailRow('SKU', stock.product?.sku),
//           _buildDivider(),
//           _buildDetailRow('Variant', '${stock.variant?.name}: ${stock.variant?.value}'),
//           _buildDivider(),
//           _buildDetailRow('Price per Unit', '₹${stock.perUnitPrice}'),
//           _buildDivider(),
//           _buildDetailRow('Original Price', '₹${stock.product?.price.toString()}'),
//           _buildDivider(),
//           _buildDetailRow('Discount Price', '₹${stock.product?.discountPrice}'),
//           _buildDivider(),
//           _buildDetailRow('Current Stock', '${stock.stock} ${stock.product?.unit}'),
//           _buildDivider(),
//           _buildDetailRow('Total Received', stock.totalReceived),
//           _buildDivider(),
//           _buildDetailRow('Total Sent', stock.totalSent),
//           _buildDivider(),
//           // _buildDetailRow(
//           //   'Last Updated',
//           //   DateFormat('dd MMM yyyy, hh:mm a').format(stock.updatedAt.to),
//           // ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey[600],
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           Text(
//             value,
//             style: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDivider() {
//     return Divider(
//       color: Colors.grey[300],
//       height: 1,
//     );
//   }
//
//   Widget _buildAdditionalInfo() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.blue.shade50,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Product Description',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             stock.product?.description,
//             style: const TextStyle(
//               fontSize: 14,
//               height: 1.5,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/city_stock_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/city_stock_view_model.dart';

class CityStockListScreen extends StatefulWidget {
  const CityStockListScreen({super.key});

  @override
  State<CityStockListScreen> createState() => _CityStockListScreenState();
}

class _CityStockListScreenState extends State<CityStockListScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';
  late AnimationController _headerAnimCtrl;
  late Animation<double> _headerFade;

  final List<String> _filterOptions = [
    'All',
    'In Stock',
    'Low Stock',
    'Out of Stock',
  ];

  @override
  void initState() {
    super.initState();
    _headerAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _headerFade = CurvedAnimation(
      parent: _headerAnimCtrl,
      curve: Curves.easeOut,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _headerAnimCtrl.forward();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _headerAnimCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Provider.of<CityStockViewModel>(context, listen: false)
        .getCityStockDataApi(context);
  }

  List<CityStockData> _getFilteredStocks(List<CityStockData>? stocks) {
    if (stocks == null) return [];
    return stocks.where((stock) {
      final matchesSearch = _searchQuery.isEmpty ||
          (stock.product?.name?.toLowerCase().contains(
              _searchQuery.toLowerCase()) ??
              false) ||
          (stock.category?.categoryName?.toLowerCase().contains(
              _searchQuery.toLowerCase()) ??
              false);

      bool matchesFilter = true;
      final s = stock.stock ?? 0;
      switch (_selectedFilter) {
        case 'Low Stock':
          matchesFilter = s > 0 && s <= 10;
          break;
        case 'Out of Stock':
          matchesFilter = s == 0;
          break;
        case 'In Stock':
          matchesFilter = s > 10;
          break;
        default:
          matchesFilter = true;
      }
      return matchesSearch && matchesFilter;
    }).toList();
  }

  // ── Color helpers ────────────────────────────────────────────────────────

  Color _stockColor(int stock) {
    if (stock == 0) return const Color(0xFFEF4444);
    if (stock <= 10) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  String _stockLabel(int stock) {
    if (stock == 0) return 'Out of Stock';
    if (stock <= 10) return 'Low Stock';
    return 'In Stock';
  }

  IconData _stockIcon(int stock) {
    if (stock == 0) return Icons.cancel_outlined;
    if (stock <= 10) return Icons.warning_amber_rounded;
    return Icons.check_circle_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Consumer<CityStockViewModel>(
        builder: (context, vm, _) {
          final allStocks = vm.cityStockModel?.data ?? [];
          final filtered = _getFilteredStocks(allStocks);

          return CustomScrollView(
            slivers: [
              // ── SliverAppBar ─────────────────────────────────────
              SliverAppBar(
                pinned: true,
                expandedHeight: 120,
                backgroundColor: ColorConst.primaryGreen,
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded,
                        color: Colors.white),
                    onPressed: _loadData,
                    tooltip: 'Refresh',
                  ),
                  const SizedBox(width: 4),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildAppBarBg(allStocks),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(0),
                  child: Container(
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20)),
                    ),
                  ),
                ),
              ),

              // ── Search + Filters ──────────────────────────────────
              SliverToBoxAdapter(
                child: _buildSearchAndFilter(),
              ),

              // ── Summary cards ─────────────────────────────────────
              if (allStocks.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildSummaryCards(allStocks),
                ),

              // ── List header ───────────────────────────────────────
              SliverToBoxAdapter(
                child: _buildListHeader(filtered.length),
              ),

              // ── Loading ───────────────────────────────────────────
              if (vm.cityStockModel == null)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                        color: ColorConst.primaryGreen, strokeWidth: 2),
                  ),
                )
              // ── Empty ─────────────────────────────────────────────
              else if (filtered.isEmpty)
                SliverFillRemaining(child: _buildEmptyState())
              // ── List ──────────────────────────────────────────────
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 350),
                          child: SlideAnimation(
                            verticalOffset: 30.0,
                            child: FadeInAnimation(
                              child: _buildStockCard(filtered[index]),
                            ),
                          ),
                        );
                      },
                      childCount: filtered.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ── AppBar background ─────────────────────────────────────────────────────

  Widget _buildAppBarBg(List<CityStockData> stocks) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorConst.primaryGreen,
            ColorConst.primaryGreen.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 60, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeTransition(
                    opacity: _headerFade,
                    child: const Text(
                      'City Stock',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  FadeTransition(
                    opacity: _headerFade,
                    child: Text(
                      '${stocks.length} products in inventory',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Search + Filter ───────────────────────────────────────────────────────

  Widget _buildSearchAndFilter() {
    return Container(
      color: const Color(0xFFF5F7FA),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        children: [
          // Search field
          Container(
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                const Icon(Icons.search_rounded,
                    size: 18, color: ColorConst.primaryGreen),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF1F2937),
                        fontWeight: FontWeight.w500),
                    decoration: const InputDecoration(
                      hintText: 'Search products, categories…',
                      hintStyle: TextStyle(
                          fontSize: 13, color: Color(0xFF9CA3AF)),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () => setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    }),
                    child: Container(
                      width: 26,
                      height: 26,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: const Icon(Icons.close_rounded,
                          size: 13, color: Color(0xFF6B7280)),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Filter chips
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filterOptions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final f = _filterOptions[i];
                final isSelected = _selectedFilter == f;
                final chipColor = f == 'Out of Stock'
                    ? const Color(0xFFEF4444)
                    : f == 'Low Stock'
                    ? const Color(0xFFF59E0B)
                    : f == 'In Stock'
                    ? const Color(0xFF10B981)
                    : ColorConst.primaryGreen;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? chipColor
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? chipColor
                            : const Color(0xFFE5E7EB),
                      ),
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                          color: chipColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                          : [],
                    ),
                    child: Text(
                      f,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Summary cards ─────────────────────────────────────────────────────────

  Widget _buildSummaryCards(List<CityStockData> stocks) {
    final total = stocks.length;
    final totalUnits = stocks.fold<int>(
        0,
            (s, i) =>
        s + (int.tryParse(i.stock?.toString() ?? '0') ?? 0));
    final low = stocks.where((s) {
      final v = s.stock ?? 0;
      return v > 0 && v <= 10;
    }).length;
    final out = stocks.where((s) => (s.stock ?? 0) == 0).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: [
          _SummaryCard(
            label: 'Products',
            value: '$total',
            icon: Icons.inventory_2_outlined,
            color: const Color(0xFF2563EB),
          ),
          const SizedBox(width: 8),
          _SummaryCard(
            label: 'Total Units',
            value: '$totalUnits',
            icon: Icons.stacked_bar_chart_rounded,
            color: const Color(0xFF10B981),
          ),
          const SizedBox(width: 8),
          _SummaryCard(
            label: 'Low',
            value: '$low',
            icon: Icons.warning_amber_rounded,
            color: const Color(0xFFF59E0B),
          ),
          const SizedBox(width: 8),
          _SummaryCard(
            label: 'Out',
            value: '$out',
            icon: Icons.cancel_outlined,
            color: const Color(0xFFEF4444),
          ),
        ],
      ),
    );
  }

  // ── List header ───────────────────────────────────────────────────────────

  Widget _buildListHeader(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: ColorConst.primaryGreen,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Stock Items',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          const Spacer(),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: ColorConst.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count items',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: ColorConst.primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Stock Card ────────────────────────────────────────────────────────────

  Widget _buildStockCard(CityStockData stock) {
    final current = stock.stock ?? 0;
    final received = int.tryParse(stock.totalReceived ?? '0') ?? 0;
    final progress =
    received > 0 ? (current / received).clamp(0.0, 1.0) : 0.0;
    final color = _stockColor(current);
    final isOut = current == 0;
    final isLow = current > 0 && current <= 10;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: (isOut || isLow)
            ? Border.all(color: color.withValues(alpha: 0.25), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showStockDetails(context, stock),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Row 1: image + info ───────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: stock.product?.img != null
                        ? Image.network(
                      stock.product?.img!,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _imagePlaceholder(),
                    )
                        : _imagePlaceholder(),
                  ),
                  const SizedBox(width: 12),

                  // Details
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
                                stock.product?.name ?? 'Unknown Product',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Status badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(_stockIcon(current),
                                      size: 10, color: color),
                                  const SizedBox(width: 3),
                                  Text(
                                    _stockLabel(current),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Chips row
                        Wrap(
                          spacing: 5,
                          runSpacing: 4,
                          children: [
                            if (stock.category != null)
                              _Chip(
                                label: stock.category?.categoryName!,
                                color: const Color(0xFF2563EB),
                              ),
                            if (stock.category?.subcategoryName != null)
                              _Chip(
                                label: stock.category?.subcategoryName,
                                color: const Color(0xFF7C3AED),
                              ),
                            if (stock.variant?.name != null &&
                                stock.variant?.name != 'Default')
                              _Chip(
                                label: stock.variant?.name!,
                                color: const Color(0xFF0891B2),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              Divider(color: Colors.grey.shade100),
              const SizedBox(height: 8),

              // ── Row 2: stats ──────────────────────────────────
              Row(
                children: [
                  _StatCell(
                    label: 'Current',
                    value: '$current',
                    color: color,
                    icon: Icons.inventory_rounded,
                  ),
                  _vDivider(),
                  _StatCell(
                    label: 'Received',
                    value: '$received',
                    color: const Color(0xFF10B981),
                    icon: Icons.download_rounded,
                  ),

                ],
              ),

              const SizedBox(height: 10),

              // ── Progress bar ──────────────────────────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Stock Level',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: const Color(0xFFF3F4F6),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 5,
                    ),
                  ),
                ],
              ),

              // ── Warning banner ────────────────────────────────
              if (isOut || isLow) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: color.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isOut
                            ? Icons.cancel_outlined
                            : Icons.warning_amber_rounded,
                        size: 13,
                        color: color,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isOut
                            ? 'Out of stock — reorder immediately'
                            : 'Low stock — consider restocking',
                        style: TextStyle(
                          fontSize: 11,
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 10),

              // ── Detail button ─────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => _showStockDetails(context, stock),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: ColorConst.primaryGreen
                            .withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: ColorConst.primaryGreen
                              .withValues(alpha: 0.2),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info_outline_rounded,
                              size: 13, color: ColorConst.primaryGreen),
                          SizedBox(width: 5),
                          Text(
                            'View Details',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: ColorConst.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.image_not_supported_rounded,
          color: Color(0xFF9CA3AF), size: 28),
    );
  }

  Widget _vDivider() {
    return Container(
      width: 1,
      height: 32,
      color: const Color(0xFFF3F4F6),
      margin: const EdgeInsets.symmetric(horizontal: 12),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: ColorConst.primaryGreen.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.inventory_2_outlined,
                size: 52, color: ColorConst.primaryGreen.withValues(alpha: 0.4)),
          ),
          const SizedBox(height: 16),
          const Text(
            'No products found',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF374151)),
          ),
          const SizedBox(height: 6),
          Text(
            'Try adjusting your search or filter',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => setState(() {
              _searchController.clear();
              _searchQuery = '';
              _selectedFilter = 'All';
            }),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Clear Filters'),
            style: TextButton.styleFrom(
                foregroundColor: ColorConst.primaryGreen),
          ),
        ],
      ),
    );
  }

  // ── Details bottom sheet ──────────────────────────────────────────────────

  void _showStockDetails(BuildContext context, CityStockData stock) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.88,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _StockDetailsSheet(
          stock: stock,
          scrollController: scrollController,
        ),
      ),
    );
  }
}

// ── Summary Card ──────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 15, color: color),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 9,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Chip ──────────────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 9, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

// ── Stat cell ─────────────────────────────────────────────────────────────────

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _StatCell(
      {required this.label,
        required this.value,
        required this.color,
        required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 11, color: color),
              const SizedBox(width: 3),
              Text(label,
                  style: const TextStyle(
                      fontSize: 10, color: Color(0xFF9CA3AF))),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stock Details Sheet ───────────────────────────────────────────────────────

class _StockDetailsSheet extends StatelessWidget {
  final CityStockData stock;
  final ScrollController scrollController;

  const _StockDetailsSheet({
    required this.stock,
    required this.scrollController,
  });

  Color get _color {
    final s = stock.stock ?? 0;
    if (s == 0) return const Color(0xFFEF4444);
    if (s <= 10) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  @override
  Widget build(BuildContext context) {
    final current = stock.stock ?? 0;
    final received = int.tryParse(stock.totalReceived ?? '0') ?? 0;
    final progress =
    received > 0 ? (current / received).clamp(0.0, 1.0) : 0.0;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF5F7FA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                // ── Hero card ──────────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Image
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20)),
                        child: stock.product?.img != null
                            ? Image.network(
                          stock.product?.img!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _imgPlaceholder(),
                        )
                            : _imgPlaceholder(),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name + status
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    stock.product?.name ?? 'Unknown',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF111827),
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color:
                                    _color.withValues(alpha: 0.1),
                                    borderRadius:
                                    BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    current == 0
                                        ? 'Out of Stock'
                                        : current <= 10
                                        ? 'Low Stock'
                                        : 'In Stock',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: _color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Category chips
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                if (stock.category?.mainCategoryName != null)
                                  _DetailChip(
                                    icon: Icons.category_rounded,
                                    label: stock.category?.mainCategoryName!,
                                    color: const Color(0xFF2563EB),
                                  ),
                                if (stock.category != null)
                                  _DetailChip(
                                    icon: Icons.label_rounded,
                                    label: stock.category?.mainCategoryName!,
                                    color: const Color(0xFF7C3AED),
                                  ),
                                if (stock.category?.subcategoryName != null)
                                  _DetailChip(
                                    icon: Icons.subdirectory_arrow_right_rounded,
                                    label: stock.category?.subcategoryName!,
                                    color: const Color(0xFF0891B2),
                                  ),
                                if (stock.variant?.name != null &&
                                    stock.variant?.name != 'Default')
                                  _DetailChip(
                                    icon: Icons.tune_rounded,
                                    label: stock.variant?.name!,
                                    color: const Color(0xFFF59E0B),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Stats row ──────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SheetSectionLabel('Stock Overview'),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          _BigStatCard(
                            label: 'Current',
                            value: '$current',
                            icon: Icons.inventory_rounded,
                            color: _color,
                          ),
                          const SizedBox(width: 10),
                          _BigStatCard(
                            label: 'Received',
                            value: '$received',
                            icon: Icons.download_rounded,
                            color: const Color(0xFF10B981),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Stock Level',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500)),
                          Text(
                            '${(progress * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _color),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: const Color(0xFFF3F4F6),
                          valueColor:
                          AlwaysStoppedAnimation<Color>(_color),
                          minHeight: 7,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ── Detail rows ────────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
                        child: _SheetSectionLabel('Product Details'),
                      ),
                      _DetailRow(
                          'Product ID',
                          '#${stock.productid?.toString() ?? "N/A"}',
                          Icons.tag_rounded),
                      _DetailRow(
                          'Variant',
                          stock.variant?.name ?? 'Default',
                          Icons.tune_rounded),
                      _DetailRow(
                          'Main Category',
                          stock.category?.mainCategoryName ?? 'N/A',
                          Icons.category_rounded),
                      _DetailRow(
                          'Category',
                          stock.category?.categoryName ?? 'N/A',
                          Icons.label_rounded),
                      _DetailRow(
                          'Sub Category',
                          stock.category?.subcategoryName ?? 'N/A',
                          Icons.subdirectory_arrow_right_rounded,
                          isLast: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imgPlaceholder() {
    return Container(
      height: 200,
      decoration: const BoxDecoration(
        color: Color(0xFFF3F4F6),
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: const Center(
        child: Icon(Icons.image_not_supported_rounded,
            size: 48, color: Color(0xFF9CA3AF)),
      ),
    );
  }
}

// ── Sheet sub-widgets ─────────────────────────────────────────────────────────

class _SheetSectionLabel extends StatelessWidget {
  final String label;
  const _SheetSectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: ColorConst.primaryGreen,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 7),
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937))),
      ],
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _DetailChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }
}

class _BigStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _BigStatCard(
      {required this.label,
        required this.value,
        required this.icon,
        required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: color)),
            Text(label,
                style: const TextStyle(
                    fontSize: 10, color: Color(0xFF9CA3AF))),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isLast;
  const _DetailRow(this.label, this.value, this.icon,
      {this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 15, color: const Color(0xFF9CA3AF)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF6B7280))),
              ),
              Text(value,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827))),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 42,
            color: Colors.grey.shade100,
          ),
      ],
    );
  }
}