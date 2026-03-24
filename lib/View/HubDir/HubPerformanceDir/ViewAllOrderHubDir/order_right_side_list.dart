import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/hub_performance_view_order_details_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/hub_performance_view_model.dart';

class OrderDetailsPanel extends StatefulWidget {
  const OrderDetailsPanel({super.key});

  @override
  State<OrderDetailsPanel> createState() => _OrderDetailsPanelState();
}

class _OrderDetailsPanelState extends State<OrderDetailsPanel> {
  @override
  Widget build(BuildContext context) {
    return Consumer<HubPerformanceViewModel>(
      builder: (context, vm, _) {
        final details = vm.hubPerformanceViewOrderDetailsModel;

        if (details == null || details.data!.items!.isEmpty) {
          return _buildEmptyState();
        }

        if(vm.isLoading){
          return SizedBox.shrink();

        }
        final order = details.data;
        return Container(
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with gradient background
                _buildHeader(order),

                // Content with consistent padding
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Timeline section
                      _buildTimelineSection(order),
                      const SizedBox(height: 32),

                      // Info cards grid
                      _buildInfoGrid(order),
                      const SizedBox(height: 32),

                      // Order items section
                      _buildOrderItemsSection(order),
                      const SizedBox(height: 32),

                      // Payment summary section
                      _buildPaymentSummary(order),
                      const SizedBox(height: 32),

                      // Action buttons
                      // _buildActionButtons(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
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
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated empty state illustration
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: ColorConst.primaryGreen.withValues(alpha:0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                size: 48,
                color: ColorConst.primaryGreen.withValues(alpha:0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "No Order Selected",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Select an order from the list to view detailed information",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: ColorConst.primaryGreen.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_back_rounded,
                    size: 16,
                    color: ColorConst.primaryGreen,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Select from orders list",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ColorConst.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(HubPerformanceViewOrderDetailsData? order) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            _getStatusColor(order!.order!.status.toString()).withValues(alpha:0.05),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Order ID and Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                            Icons.shopping_bag_rounded,
                            size: 18,
                            color: ColorConst.primaryGreen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Order ID",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                order.order!.orderNo.toString(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildStatusBadge(order.order!.status.toString()),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDate(order.order!.createdAt.toString()),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action buttons
              Row(
                children: [
                  _buildActionChip(
                    icon: Icons.print_rounded,
                    label: "Print",
                    color: Colors.grey.shade700,
                    onTap: () {},
                  ),
                  const SizedBox(width: 8),
                  _buildActionChip(
                    icon: Icons.share_rounded,
                    label: "Share",
                    color: Colors.grey.shade700,
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha:0.1),
            color.withValues(alpha:0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha:0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineSection(HubPerformanceViewOrderDetailsData? order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timeline_rounded,
                size: 20,
                color: ColorConst.primaryGreen,
              ),
              const SizedBox(width: 8),
              const Text(
                "Order Timeline",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildEnhancedTimeline(order),
        ],
      ),
    );
  }

  Widget _buildEnhancedTimeline(HubPerformanceViewOrderDetailsData? order) {
    final timelineEvents = [
      TimelineEvent(
        title: "Order Placed",
        time: order!.order!.createdAt.toString(),
        status: "completed",
        description: "Order has been placed successfully",
        icon: Icons.shopping_cart_rounded,
      ),
      TimelineEvent(
        title: "Order Confirmed",
        time: _addMinutes(order.order!.createdAt.toString(), 5),
        status: order.order!.status.toString() == "cancelled" ? "cancelled" : "completed",
        description: "Restaurant has confirmed your order",
        icon: Icons.check_circle_rounded,
      ),
      TimelineEvent(
        title: "Picked by Delivery Boy",
        time: _addMinutes(order.order!.createdAt.toString(), 15),
        status: order.order!.status.toString() == "pending" ? "pending" :
        order.order!.status.toString() == "cancelled" ? "cancelled" : "completed",
        description: order.order!.deliveryBoy.toString(),
        icon: Icons.pedal_bike_rounded,
      ),
      TimelineEvent(
        title: "Out for Delivery",
        time: _addMinutes(order.order!.createdAt.toString(), 25),
        status: order.order!.status.toString() == "in transit" ? "active" :
        order.order!.status.toString() == "delivered" ? "completed" :
        order.order!.status.toString() == "cancelled" ? "cancelled" : "pending",
        description: "Your order is on the way",
        icon: Icons.local_shipping_rounded,
      ),
      TimelineEvent(
        title: "Delivered",
        time: _addMinutes(order.order!.createdAt.toString(), 45),
        status: order.order!.status.toString() == "delivered" ? "completed" : "pending",
        description: "Order has been delivered",
        icon: Icons.check_box_rounded,
      ),
    ];

    return Column(
      children: List.generate(timelineEvents.length, (index) {
        final event = timelineEvents[index];
        final isLast = index == timelineEvents.length - 1;
        return _buildEnhancedTimelineItem(event, isLast);
      }),
    );
  }

  Widget _buildEnhancedTimelineItem(TimelineEvent event, bool isLast) {
    Color getStatusColor() {
      switch (event.status) {
        case 'completed':
          return const Color(0xFF10B981);
        case 'active':
          return const Color(0xFF3B82F6);
        case 'pending':
          return const Color(0xFFF59E0B);
        case 'cancelled':
          return const Color(0xFFEF4444);
        default:
          return Colors.grey;
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline icon and line
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    getStatusColor().withValues(alpha:0.2),
                    getStatusColor().withValues(alpha:0.1),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: getStatusColor().withValues(alpha:0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                event.icon,
                size: 16,
                color: getStatusColor(),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      getStatusColor().withValues(alpha:0.5),
                      getStatusColor().withValues(alpha:0.1),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),

        // Event details
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      event.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: event.status == 'active'
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: event.status == 'cancelled'
                            ? Colors.red
                            : Colors.grey.shade900,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        event.time,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  event.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoGrid(HubPerformanceViewOrderDetailsData? order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 20,
              color: ColorConst.primaryGreen,
            ),
            const SizedBox(width: 8),
            const Text(
              "Order Information",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.8,
          children: [
            _buildEnhancedInfoCard(
              title: "Customer Details",
              icon: Icons.person_rounded,
              color: const Color(0xFF3B82F6),
              items: [
                InfoItem("Name", order!.order!.customerName.toString()),
                InfoItem("Phone", order.order!.phone.toString()),
              ],
            ),
            _buildEnhancedInfoCard(
              title: "Delivery Address",
              icon: Icons.location_on_rounded,
              color: const Color(0xFF10B981),
              items: [
                InfoItem("Address", order.order!.address.toString()),
                InfoItem("Landmark", order.order!.landmark.toString()),
                InfoItem("Pincode", order.order!.pincode.toString()),
              ],
            ),
            _buildEnhancedInfoCard(
              title: "Delivery Partner",
              icon: Icons.delivery_dining_rounded,
              color: const Color(0xFFF59E0B),
              items: [
                InfoItem("Name", order.order!.deliveryBoy.toString()),
                InfoItem("Phone", order.order!.phone.toString()),
              ],
            ),
            _buildEnhancedInfoCard(
              title: "Payment Details",
              icon: Icons.payment_rounded,
              color: const Color(0xFF8B5CF6),
              items: [
                InfoItem("Method", order.order!.paymentMethod.toString()),
                InfoItem("Status", order.order!.paymentStatus==0?"Pending":order.order!.paymentStatus==1?"Success":"Failed"),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEnhancedInfoCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<InfoItem> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            color.withValues(alpha:0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 14,
                  color: color,
                ),
              ),
               SizedBox(width: Sizes.screenWidth*0.01),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
           SizedBox(height: Sizes.screenHeight*0.013),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: Sizes.screenWidth*0.042,
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    item.value,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildOrderItemsSection(HubPerformanceViewOrderDetailsData? order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.shopping_bag_rounded,
                    size: 20,
                    color: ColorConst.primaryGreen,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Order Items",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${order!.items!.length} items",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Items list
          ...List.generate(order.items!.length, (index) {

            final item = order.items![index];

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://via.placeholder.com/48',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 4),
                        Text(
                          "Qty: ${item.qty} × ₹${item.price}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "₹${(item.totalPrice)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: ColorConst.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),

          // Special instructions
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha:0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withValues(alpha:0.2)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.note_alt_rounded,
                  size: 18,
                  color: Colors.amber.shade700,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Special Instructions",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber.shade800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Please deliver to the back entrance. Call upon arrival.",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade700,
                        ),
                      ),
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

  Widget _buildPaymentSummary(HubPerformanceViewOrderDetailsData? order) {
    final subtotal = order!.order!.totalAmount.toString();
    final delivery = order.order!.deliveryCharge.toString();
    final total = order.order!.totalAmount.toString();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorConst.primaryGreen.withValues(alpha:0.05),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorConst.primaryGreen.withValues(alpha:0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_rounded,
                size: 20,
                color: ColorConst.primaryGreen,
              ),
              const SizedBox(width: 8),
              const Text(
                "Payment Summary",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryRow("Subtotal", "₹$subtotal"),
          const SizedBox(height: 10),
          _buildSummaryRow("Delivery Fee", "₹$delivery"),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          _buildSummaryRow(
            "Total Amount",
            "₹$total",
            isTotal: true,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha:0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.payment_rounded,
                  size: 14,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  "Payment Method: ",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  order.order!.paymentMethod.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            color: isTotal ? ColorConst.primaryGreen : Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            color: valueColor ?? (isTotal ? ColorConst.primaryGreen : Colors.grey.shade900),
          ),
        ),
      ],
    );
  }

  // Widget _buildActionButtons() {
  //   return Container(
  //     padding: const EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       color: Colors.grey.shade50,
  //       borderRadius: BorderRadius.circular(16),
  //     ),
  //     child: Row(
  //       children: [
  //         Expanded(
  //           child: ElevatedButton(
  //             onPressed: () {},
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: ColorConst.primaryGreen,
  //               foregroundColor: Colors.white,
  //               padding: const EdgeInsets.symmetric(vertical: 16),
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(14),
  //               ),
  //               elevation: 0,
  //             ),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: const [
  //                 Icon(Icons.update_rounded, size: 18),
  //                 SizedBox(width: 8),
  //                 Text(
  //                   "Update Status",
  //                   style: TextStyle(
  //                     fontSize: 14,
  //                     fontWeight: FontWeight.w600,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //         const SizedBox(width: 12),
  //         Expanded(
  //           child: OutlinedButton(
  //             onPressed: () {},
  //             style: OutlinedButton.styleFrom(
  //               foregroundColor: Colors.red,
  //               side: const BorderSide(color: Colors.red, width: 1.5),
  //               padding: const EdgeInsets.symmetric(vertical: 16),
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(14),
  //               ),
  //             ),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: const [
  //                 Icon(Icons.cancel_rounded, size: 18),
  //                 SizedBox(width: 8),
  //                 Text(
  //                   "Cancel Order",
  //                   style: TextStyle(
  //                     fontSize: 14,
  //                     fontWeight: FontWeight.w600,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return const Color(0xFF10B981);
      case 'in transit':
        return const Color(0xFF3B82F6);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String time) {
    try {
      final now = DateTime.now();
      return DateFormat('dd MMM yyyy • hh:mm a').format(now);
    } catch (e) {
      return time;
    }
  }

  String _addMinutes(String time, int minutes) {
    try {
      final now = DateTime.now();
      final newTime = now.add(Duration(minutes: minutes));
      return DateFormat('hh:mm a').format(newTime);
    } catch (e) {
      return time;
    }
  }
}

// Supporting classes
class TimelineEvent {
  final String title;
  final String time;
  final String status;
  final String description;
  final IconData icon;

  TimelineEvent({
    required this.title,
    required this.time,
    required this.status,
    required this.description,
    required this.icon,
  });
}

class InfoItem {
  final String label;
  final String value;

  InfoItem(this.label, this.value);
}

class OrderItem {
  final String name;
  final int quantity;
  final double price;
  final IconData image;
  final String? note;

  OrderItem({
    required this.name,
    required this.quantity,
    required this.price,
    required this.image,
    this.note,
  });
}
