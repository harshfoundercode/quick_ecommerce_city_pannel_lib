import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/hub_performance_order_list_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/all_order_from_hub_view_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/hub_performance_view_model.dart';

class OrdersListPanel extends StatefulWidget {
  final List<HubPerformanceOrderListData> data;
  const OrdersListPanel({super.key, required this.data});

  @override
  State<OrdersListPanel> createState() => _OrdersListPanelState();
}

class _OrdersListPanelState extends State<OrdersListPanel> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<HubPerformanceViewModel>(context);
    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.02),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.grey.shade50,
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: ColorConst.primaryGreen.withValues(alpha:0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            color: ColorConst.primaryGreen,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Orders",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade900,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "${vm.orders.length} total",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    _buildLiveIndicator(),
                  ],
                ),
                const SizedBox(height: 20),

                // Enhanced Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
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
                    onChanged: vm.updateSearch,
                    decoration: InputDecoration(
                      hintText: "Search by order ID, customer...",
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: Colors.grey.shade400,
                        size: 22,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          vm.updateSearch('');
                        },
                      )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Filter Chips
                _buildFilterChips(vm),
              ],
            ),
          ),

          // Table Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTableHeader("Order ID", Icons.receipt_outlined),
                ),
                Expanded(
                  child: _buildTableHeader("Customer", Icons.person_outline),
                ),
                Expanded(
                  child: _buildTableHeader("Amount", Icons.currency_rupee),
                ),
                Expanded(
                  child: _buildTableHeader("Status", Icons.circle_outlined),
                ),
              ],
            ),
          ),

          // Divider with gradient
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.grey.shade300,
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Orders List
          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              radius: const Radius.circular(10),
              thickness: 6,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: vm.orders.length,
                itemBuilder: (context, index) {
                  final order =  vm.orders[index];
                  final isSelected = vm.selectedOrder?.orderNo == order.orderNo;
                  return _buildOrderListItem(order, isSelected, vm);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: ColorConst.primaryGreen.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: ColorConst.primaryGreen.withValues(alpha:0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: ColorConst.primaryGreen,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            "LIVE",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: ColorConst.primaryGreen,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(HubPerformanceViewModel vm) {
    final filters = [
      {"label": "All", "icon": Icons.view_list_rounded},
      {"label": "Delivered", "icon": Icons.check_circle_rounded},
      {"label": "In Transit", "icon": Icons.local_shipping_rounded},
      {"label": "Pending", "icon": Icons.pending_actions_rounded},
      {"label": "Cancelled", "icon": Icons.cancel_rounded},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final label = filter["label"] as String;
          final icon = filter["icon"] as IconData;
          final isSelected = vm.selectedFilter == label;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Material(
              borderRadius: BorderRadius.circular(30),
              child: InkWell(
                onTap: () => vm.updateFilter(label),
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? ColorConst.primaryGreen
                        : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isSelected
                          ? ColorConst.primaryGreen
                          : Colors.grey.shade200,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: ColorConst.primaryGreen.withValues(alpha:0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ] : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 16,
                        color: isSelected
                            ? Colors.white
                            : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTableHeader(String title, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey.shade500,
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderListItem(
      HubPerformanceOrderListData order,
      bool isSelected,
      HubPerformanceViewModel vm,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        color: isSelected
            ? ColorConst.primaryGreen.withValues(alpha: 0.04)
            : Colors.transparent,
        child: InkWell(
          onTap: () => vm.selectOrder(context, order),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? ColorConst.primaryGreen.withValues(alpha: 0.3)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [

                /// 🔹 ORDER ID
                Expanded(
                  flex: 2,
                  child: Text(
                    order.orderNo?.toString() ?? "",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? ColorConst.primaryGreen
                          : Colors.black,
                    ),
                  ),
                ),

                /// 🔹 CUSTOMER
                Expanded(
                  child: Text(
                    order.customerName ?? "",
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                /// 🔹 AMOUNT
                Expanded(
                  child: Text(
                    "₹${_formatAmount(order.finalAmount.toString())}",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),

                /// 🔹 STATUS
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                          (order.statusText ?? "").toString())
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.statusText ?? "",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStatusColor(
                            (order.statusText ?? "").toString()),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return const Color(0xFF10B981); // Emerald green
      case 'in transit':
        return const Color(0xFF3B82F6); // Blue
      case 'pending':
        return const Color(0xFFF59E0B); // Amber
      case 'cancelled':
        return const Color(0xFFEF4444); // Red
      default:
        return Colors.grey;
    }
  }

  String _formatAmount(String amount) {
    // Add commas for thousands separator
    final number = double.tryParse(amount) ?? 0;
    return number.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );
  }
}

// Add this extension for updatedAt field if not present in your model
extension HubOrderModelExtension on HubOrderModel {
  DateTime? get updatedAt => null; // Implement based on your actual model
  String? get customerAvatar => null; // Implement based on your actual model
}
