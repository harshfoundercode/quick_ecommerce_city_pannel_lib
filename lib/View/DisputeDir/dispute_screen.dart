// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
// import 'package:quick_ecommerce_city_panel_redefined/View/DisputeDir/all_dispute_tab_screen.dart';
// import 'package:quick_ecommerce_city_panel_redefined/View/DisputeDir/in_progress_dispute_tab.dart';
// import 'package:quick_ecommerce_city_panel_redefined/View/DisputeDir/open_dispute_tab.dart';
// import 'package:quick_ecommerce_city_panel_redefined/View/DisputeDir/resolved_dispute_tab.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/dispute_view_model.dart' show DisputeViewModel;
//
//
// class DisputeScreen extends StatefulWidget {
//   const DisputeScreen({super.key});
//
//   @override
//   State<DisputeScreen> createState() => _DisputeScreenState();
// }
//
// class _DisputeScreenState extends State<DisputeScreen> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final TextEditingController _searchController = TextEditingController();
//   bool _showFilters = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 4, vsync: this);
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   BoxDecoration _boxDecoration() {
//     return BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(16),
//       border: Border.all(color: Colors.grey.shade200),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withValues(alpha:0.02),
//           blurRadius: 10,
//           offset: const Offset(0, 4),
//         ),
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<DisputeViewModel>(
//       builder: (context, vm, _) {
//         return Scaffold(
//           backgroundColor: ColorConst.bgColor,
//           body: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               children: [
//                 _buildHeader(),
//                 const SizedBox(height: 20),
//
//                 _buildStatsCards(vm),
//                 const SizedBox(height: 20),
//
//                 _buildFilterBar(vm, context),
//                 const SizedBox(height: 20),
//
//                 _buildTabBar(),
//                 const SizedBox(height: 20),
//                 //
//                 Expanded(
//                   child: TabBarView(
//                     controller: _tabController,
//                     children: [
//                       AllDisputeTabScreen(vm:vm),
//
//                       OpenDisputeTab(vm:vm),
//                       //
//                       InProgressDisputeTab(vm:vm),
//                       //
//                       ResolvedDisputeTab(vm:vm),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildHeader() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.red.withValues(alpha:0.1),
//                 borderRadius: BorderRadius.circular(14),
//               ),
//               child: Icon(
//                 Icons.support_agent_rounded,
//                 color: Colors.red,
//                 size: 24,
//               ),
//             ),
//             const SizedBox(width: 16),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Dispute Management",
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.w700,
//                     color: Colors.grey.shade900,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   "Manage customer disputes and resolutions",
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey.shade600,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         Row(
//           children: [
//             _buildHeaderChip(
//               icon: Icons.download_rounded,
//               label: "Export Report",
//               onTap: () {},
//             ),
//             const SizedBox(width: 10),
//             _buildHeaderChip(
//               icon: Icons.refresh_rounded,
//               label: "Refresh",
//               onTap: () {},
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildHeaderChip({
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//   }) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(30),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(30),
//             border: Border.all(color: Colors.grey.shade200),
//           ),
//           child: Row(
//             children: [
//               Icon(icon, size: 16, color: Colors.grey.shade700),
//               const SizedBox(width: 8),
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.grey.shade700,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildStatsCards(DisputeViewModel vm) {
//     return Container(
//       padding: const EdgeInsets.all(15),
//       decoration: _boxDecoration(),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             "Dispute Overview",
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 20),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildStatCard(
//                   title: "Total Disputes",
//                   value: vm.stats['totalDisputes'].toString(),
//                   icon: Icons.receipt_long_rounded,
//                   color: const Color(0xFF3B82F6),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: _buildStatCard(
//                   title: "Open Disputes",
//                   value: vm.stats['openDisputes'].toString(),
//                   icon: Icons.pending_actions_rounded,
//                   color: const Color(0xFFF59E0B),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: _buildStatCard(
//                   title: "In Progress",
//                   value: vm.stats['inProgress'].toString(),
//                   icon: Icons.autorenew_rounded,
//                   color: const Color(0xFF8B5CF6),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: _buildStatCard(
//                   title: "Resolved",
//                   value: vm.stats['resolved'].toString(),
//                   icon: Icons.check_circle_rounded,
//                   color: const Color(0xFF10B981),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: _buildStatCard(
//                   title: "Escalated",
//                   value: vm.stats['escalated'].toString(),
//                   icon: Icons.warning_rounded,
//                   color: const Color(0xFFEF4444),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStatCard({
//     required String title,
//     required String value,
//     required IconData icon,
//     required Color color,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             color.withValues(alpha:0.1),
//             color.withValues(alpha:0.05),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withValues(alpha:0.2)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: color.withValues(alpha:0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(icon, size: 16, color: color),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 11,
//               color: Colors.grey.shade600,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             value,
//             style: const TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFilterBar(DisputeViewModel vm, BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: _boxDecoration(),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               // Search Bar
//               Expanded(
//                 flex: 3,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade50,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.grey.shade200),
//                   ),
//                   child: TextField(
//                     controller: _searchController,
//                     onChanged: vm.updateSearch,
//                     decoration: InputDecoration(
//                       hintText: "Search by dispute ID, order ID, customer...",
//                       hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
//                       prefixIcon: Icon(
//                         Icons.search_rounded,
//                         size: 18,
//                         color: Colors.grey.shade400,
//                       ),
//                       suffixIcon: _searchController.text.isNotEmpty
//                           ? IconButton(
//                         icon: Icon(
//                           Icons.close_rounded,
//                           size: 18,
//                           color: Colors.grey.shade400,
//                         ),
//                         onPressed: () {
//                           _searchController.clear();
//                           vm.updateSearch('');
//                         },
//                       )
//                           : null,
//                       border: InputBorder.none,
//                       contentPadding: const EdgeInsets.symmetric(vertical: 12),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//
//               // Hub Filter
//               Expanded(
//                 flex: 2,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 12),
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade50,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.grey.shade200),
//                   ),
//                   child: DropdownButtonHideUnderline(
//                     child: DropdownButton<String>(
//                       value: vm.selectedHub,
//                       isExpanded: true,
//                       items: ["All Hubs", "Gomti Nagar Hub", "Indira Nagar Hub", "Alambagh Hub", "Charbagh Hub"]
//                           .map((e) => DropdownMenuItem(
//                         value: e,
//                         child: Row(
//                           children: [
//                             Icon(
//                               Icons.store_rounded,
//                               size: 14,
//                               color: ColorConst.primaryGreen,
//                             ),
//                             const SizedBox(width: 6),
//                             Expanded(
//                               child: Text(
//                                 e,
//                                 style: const TextStyle(fontSize: 12),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ))
//                           .toList(),
//                       onChanged: (v) => vm.updateHub(v!),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//
//               // Date Range
//               Expanded(
//                 flex: 2,
//                 child: Material(
//                   color: Colors.transparent,
//                   child: InkWell(
//                     onTap: () async {
//                       final picked = await showDateRangePicker(
//                         context: context,
//                         firstDate: DateTime(2023),
//                         lastDate: DateTime.now(),
//                         builder: (context, child) {
//                           return Theme(
//                             data: Theme.of(context).copyWith(
//                               primaryColor: Colors.red,
//                               colorScheme: const ColorScheme.light(
//                                 primary: Colors.red,
//                               ),
//                             ),
//                             child: child!,
//                           );
//                         },
//                       );
//                       if (picked != null) {
//                         vm.dateRange = picked;
//                       }
//                     },
//                     borderRadius: BorderRadius.circular(12),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade50,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: Colors.grey.shade200),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(
//                             Icons.calendar_today_rounded,
//                             size: 14,
//                             color: Colors.red,
//                           ),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Text(
//                               vm.dateRange == null
//                                   ? "Select Dates"
//                                   : "${_formatDate(vm.dateRange!.start)} - ${_formatDate(vm.dateRange!.end)}",
//                               style: TextStyle(
//                                 fontSize: 11,
//                                 color: vm.dateRange == null
//                                     ? Colors.grey.shade500
//                                     : Colors.grey.shade800,
//                               ),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//
//               // Filter Toggle
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade50,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.grey.shade200),
//                 ),
//                 child: IconButton(
//                   icon: Icon(
//                     _showFilters ? Icons.filter_list_rounded : Icons.filter_list_outlined,
//                     color: _showFilters ? Colors.red : Colors.grey.shade600,
//                     size: 20,
//                   ),
//                   onPressed: () {
//                     setState(() {
//                       _showFilters = !_showFilters;
//                     });
//                   },
//                 ),
//               ),
//             ],
//           ),
//
//           // Advanced Filters
//           if (_showFilters) ...[
//             const SizedBox(height: 12),
//             const Divider(),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildFilterChipGroup(
//                     label: "Priority",
//                     options: ["All", "High", "Medium", "Low"],
//                     selected: "All",
//                     onSelected: (v) {},
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: _buildFilterChipGroup(
//                     label: "Issue Type",
//                     options: ["All", "Delivery", "Quality", "Payment", "Refund"],
//                     selected: "All",
//                     onSelected: (v) {},
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: _buildFilterChipGroup(
//                     label: "Hub",
//                     options: ["All", "Gomti Nagar", "Indira Nagar", "Alambagh"],
//                     selected: "All",
//                     onSelected: (v) {},
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFilterChipGroup({
//     required String label,
//     required List<String> options,
//     required String selected,
//     required Function(String) onSelected,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 11,
//             fontWeight: FontWeight.w600,
//             color: Colors.grey.shade700,
//           ),
//         ),
//         const SizedBox(height: 8),
//         SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: Row(
//             children: options.map((option) {
//               final isSelected = option == selected;
//               return Padding(
//                 padding: const EdgeInsets.only(right: 8),
//                 child: FilterChip(
//                   label: Text(option),
//                   selected: isSelected,
//                   onSelected: (_) => onSelected(option),
//                   backgroundColor: Colors.grey.shade100,
//                   selectedColor: Colors.red.withValues(alpha:0.1),
//                   checkmarkColor: Colors.red,
//                   labelStyle: TextStyle(
//                     fontSize: 11,
//                     color: isSelected ? Colors.red : Colors.grey.shade700,
//                     fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildTabBar() {
//     return Container(
//       padding: const EdgeInsets.all(3),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: TabBar(
//         controller: _tabController,
//         indicator: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           color: Colors.red.withValues(alpha:0.1),
//         ),
//         indicatorSize: TabBarIndicatorSize.tab,
//         dividerColor: Colors.transparent,
//         labelColor: Colors.red,
//         unselectedLabelColor: Colors.grey.shade600,
//         tabs: const [
//           Tab(
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.list_alt_rounded, size: 18),
//                 SizedBox(width: 8),
//                 Text("All Disputes"),
//               ],
//             ),
//           ),
//           Tab(
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.pending_rounded, size: 18),
//                 SizedBox(width: 8),
//                 Text("Open"),
//               ],
//             ),
//           ),
//           Tab(
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.autorenew_rounded, size: 18),
//                 SizedBox(width: 8),
//                 Text("In Progress"),
//               ],
//             ),
//           ),
//           Tab(
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.check_circle_rounded, size: 18),
//                 SizedBox(width: 8),
//                 Text("Resolved"),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   String _formatDate(DateTime date) {
//     return "${date.day}/${date.month}/${date.year}";
//   }
//
//
//
//
//
//
//
//
//
//
//
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/DisputeDir/all_dispute_tab_screen.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/DisputeDir/in_progress_dispute_tab.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/DisputeDir/open_dispute_tab.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/DisputeDir/resolved_dispute_tab.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/dispute_view_model.dart';

class DisputeScreen extends StatefulWidget {
  const DisputeScreen({super.key});

  @override
  State<DisputeScreen> createState() => _DisputeScreenState();
}

class _DisputeScreenState extends State<DisputeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha:0.02),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DisputeViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          backgroundColor: ColorConst.bgColor,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: ColorConst.bgColor,
                elevation: 0,
                automaticallyImplyLeading: false,
                toolbarHeight: Sizes.screenHeight*0.12,
                title: _buildHeader(),
              ),

              // Main Content
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildStatsCards(vm),
                    const SizedBox(height: 20),

                    // Filter Bar
                    _buildFilterBar(vm, context),
                    const SizedBox(height: 20),

                    // Tab Bar
                    _buildTabBar(),
                    const SizedBox(height: 20),

                    // Tab Bar View Container
                    SizedBox(
                      height: Sizes.screenHeight*0.7,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          AllDisputeTabScreen(vm:vm),

                      OpenDisputeTab(vm:vm),

                      InProgressDisputeTab(vm:vm),

                      ResolvedDisputeTab(vm:vm),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.support_agent_rounded,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dispute Management",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Manage customer disputes and resolutions",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            _buildHeaderChip(
              icon: Icons.download_rounded,
              label: "Export Report",
              onTap: () {},
            ),
            const SizedBox(width: 10),
            _buildHeaderChip(
              icon: Icons.refresh_rounded,
              label: "Refresh",
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey.shade700),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards(DisputeViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Dispute Overview",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: "Total Disputes",
                  value: vm.stats['totalDisputes'].toString(),
                  icon: Icons.receipt_long_rounded,
                  color: const Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: "Open Disputes",
                  value: vm.stats['openDisputes'].toString(),
                  icon: Icons.pending_actions_rounded,
                  color: const Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: "In Progress",
                  value: vm.stats['inProgress'].toString(),
                  icon: Icons.autorenew_rounded,
                  color: const Color(0xFF8B5CF6),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: "Resolved",
                  value: vm.stats['resolved'].toString(),
                  icon: Icons.check_circle_rounded,
                  color: const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: "Escalated",
                  value: vm.stats['escalated'].toString(),
                  icon: Icons.warning_rounded,
                  color: const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha:0.1),
            color.withValues(alpha:0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha:0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(DisputeViewModel vm, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              // Search Bar
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: vm.updateSearch,
                    decoration: InputDecoration(
                      hintText: "Search by dispute ID, order ID, customer...",
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 18,
                        color: Colors.grey.shade400,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Colors.grey.shade400,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          vm.updateSearch('');
                        },
                      )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Hub Filter
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: vm.selectedHub,
                      isExpanded: true,
                      items: ["All Hubs", "Gomti Nagar Hub", "Indira Nagar Hub", "Alambagh Hub", "Charbagh Hub"]
                          .map((e) => DropdownMenuItem(
                        value: e,
                        child: Row(
                          children: [
                            Icon(
                              Icons.store_rounded,
                              size: 14,
                              color: ColorConst.primaryGreen,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                e,
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ))
                          .toList(),
                      onChanged: (v) => vm.updateHub(v!),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Date Range
              Expanded(
                flex: 2,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2023),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              primaryColor: Colors.red,
                              colorScheme: const ColorScheme.light(
                                primary: Colors.red,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        vm.dateRange = picked;
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              vm.dateRange == null
                                  ? "Select Dates"
                                  : "${_formatDate(vm.dateRange!.start)} - ${_formatDate(vm.dateRange!.end)}",
                              style: TextStyle(
                                fontSize: 11,
                                color: vm.dateRange == null
                                    ? Colors.grey.shade500
                                    : Colors.grey.shade800,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Filter Toggle
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: IconButton(
                  icon: Icon(
                    _showFilters ? Icons.filter_list_rounded : Icons.filter_list_outlined,
                    color: _showFilters ? Colors.red : Colors.grey.shade600,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _showFilters = !_showFilters;
                    });
                  },
                ),
              ),
            ],
          ),

          // Advanced Filters
          if (_showFilters) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildFilterChipGroup(
                    label: "Priority",
                    options: ["All", "High", "Medium", "Low"],
                    selected: "All",
                    onSelected: (v) {},
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFilterChipGroup(
                    label: "Issue Type",
                    options: ["All", "Delivery", "Quality", "Payment", "Refund"],
                    selected: "All",
                    onSelected: (v) {},
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFilterChipGroup(
                    label: "Hub",
                    options: ["All", "Gomti Nagar", "Indira Nagar", "Alambagh"],
                    selected: "All",
                    onSelected: (v) {},
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChipGroup({
    required String label,
    required List<String> options,
    required String selected,
    required Function(String) onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: options.map((option) {
              final isSelected = option == selected;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(option),
                  selected: isSelected,
                  onSelected: (_) => onSelected(option),
                  backgroundColor: Colors.grey.shade100,
                  selectedColor: Colors.red.withValues(alpha:0.1),
                  checkmarkColor: Colors.red,
                  labelStyle: TextStyle(
                    fontSize: 11,
                    color: isSelected ? Colors.red : Colors.grey.shade700,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.red.withValues(alpha:0.1),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.red,
        unselectedLabelColor: Colors.grey.shade600,
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.list_alt_rounded, size: 18),
                SizedBox(width: 8),
                Text("All Disputes"),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pending_rounded, size: 18),
                SizedBox(width: 8),
                Text("Open"),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.autorenew_rounded, size: 18),
                SizedBox(width: 8),
                Text("In Progress"),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_rounded, size: 18),
                SizedBox(width: 8),
                Text("Resolved"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

}