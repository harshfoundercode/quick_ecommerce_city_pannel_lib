import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/header_widget.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/OrderDir/all_order_list.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/OrderDir/cancelled_order_list.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/OrderDir/completed_order_list.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/OrderDir/pending_order_list.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/order_view_model.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  int allOrdersCount = 120;
  int pendingOrdersCount = 35;
  int completedOrdersCount = 85;
  int cancelledOrdersCount = 12;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_){
      final ordersData = Provider.of<OrderDetailsViewModel>(context,listen: false);
      ordersData.getOrdersListDataApi(context);
    });
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderDetailsViewModel>(
      builder: (context,pvm,child) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEnhancedHeader(pvm),
                const SizedBox(height: 24),

                _buildSearchAndFilterBar(),
                const SizedBox(height: 20),

                _buildEnhancedTabBar(pvm),
                const SizedBox(height: 20),



                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                          child: Row(
                            children: [
                              _buildTableHeader("Order ID", Icons.receipt_outlined),
                              CustomWidgets.horizontalSpace(0.23),
                              _buildTableHeader("Customer", Icons.person_outlined),
                              CustomWidgets.horizontalSpace(0.075),
                              _buildTableHeader("Amount", Icons.currency_rupee),
                              CustomWidgets.horizontalSpace(0.14),
                              _buildTableHeader("Status", Icons.circle_outlined),
                            ],
                          ),
                        ),

                        Container(
                          height: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          color: Colors.grey.shade200,
                        ),

                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children:  [
                              AllOrdersList(pvm:pvm.orderDataModel?.data?.orders),
                              PendingOrdersList(),
                              CompletedOrdersList(),
                              CancelledOrdersList(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildEnhancedHeader(OrderDetailsViewModel pvm) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            ColorConst.primaryGreen.withValues(alpha:0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: ColorConst.primaryGreen.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.shopping_bag_rounded,
                      color: ColorConst.primaryGreen,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Order Management",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Your orders right here of all hubs",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              _buildHeaderStat("Total Orders", pvm.orderDataModel?.data?.total.toString() ?? "0", Icons.receipt_long),
              const SizedBox(width: 20),
              _buildHeaderStat("Revenue", "₹${pvm.orderDataModel?.data?.totalRevenue.toString() ?? "0"}", Icons.currency_rupee),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: ColorConst.primaryGreen),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search orders by ID, customer...",
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Colors.grey.shade400,
                  size: 22,
                ),
                suffixIcon:
                _searchController.text.isNotEmpty ?
                    IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                  onPressed: () {
                    _searchController.clear();
                  },
                ):SizedBox(),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedTabBar(OrderDetailsViewModel pvm) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: ColorConst.primaryGreen.withValues(alpha:0.1),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: ColorConst.primaryGreen,
        unselectedLabelColor: Colors.grey.shade600,
        tabs: [
          _buildEnhancedTab(
            "All Orders",
            int.tryParse(pvm.orderDataModel?.data?.total.toString() ?? "0") ?? 0,
            Icons.view_list_rounded,
          ),
          _buildEnhancedTab(
            "Pending",
            int.tryParse(pvm.orderDataModel?.data?.placed.toString() ?? "0") ?? 0,
            Icons.pending_actions_rounded,
          ),

          _buildEnhancedTab(
            "Completed",
            int.tryParse(pvm.orderDataModel?.data?.completed.toString() ?? "0") ?? 0,
            Icons.check_circle_rounded,
          ),

          _buildEnhancedTab(
            "Cancelled",
            int.tryParse(pvm.orderDataModel?.data?.cancelled.toString() ?? "0") ?? 0,
            Icons.cancel_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedTab(String title, int count, IconData icon) {
    return Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getTabColor(title).withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: _getTabColor(title),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTabColor(String title) {
    switch (title) {
      case "Pending":
        return const Color(0xFFF59E0B);
      case "Completed":
        return const Color(0xFF10B981);
      case "Cancelled":
        return const Color(0xFFEF4444);
      default:
        return ColorConst.primaryGreen;
    }
  }

  Widget _buildTableHeader(String title, IconData icon) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade600,
      ),
    );
  }
}




