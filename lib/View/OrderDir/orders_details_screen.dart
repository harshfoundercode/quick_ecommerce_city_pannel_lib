import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/app_button.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/order_view_details_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/order_view_model.dart';

class OrderDetailsView extends StatefulWidget {
  final int index;
  final String orderId;
  const OrderDetailsView({super.key, required this.index, required this.orderId});

  @override
  State<OrderDetailsView> createState() => OrderDetailsViewState();
}

class OrderDetailsViewState extends State<OrderDetailsView> {


  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_){
      final dataFetch = Provider.of<OrderDetailsViewModel>(context,listen: false);
      dataFetch.getOrdersViewDataApi(context, widget.orderId.toString());
      print(widget.orderId.toString());
      print("widget.orderId.toString()");
      print(dataFetch.orderViewDataModel?.data?.order?.hubName);
      print("sjnenfe");
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.bgColor,
      appBar: AppBar(
        backgroundColor: ColorConst.bgColor,
        elevation: 0,
        leading: AppBackBtn(color: Colors.black) ,
        surfaceTintColor: Colors.transparent,
      ),
      body: Consumer<OrderDetailsViewModel>(
        builder: (context,odvm,child) {
          final itemsData = odvm.orderViewDataModel?.data!.items;
          final orderData = odvm.orderViewDataModel?.data!.order;
          final paymentData = odvm.orderViewDataModel?.data!.payment;
          final trackingData = odvm.orderViewDataModel?.data!.tracking;

          // if(itemsData==null || itemsData.isEmpty || trackingData==null || trackingData.isEmpty){
          //   return Center(child: Text("No data found"));
          // }
          return ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
            children: [
              _buildEnhancedHeader(orderData),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        _buildOrderItemsCard(itemsData!,orderData),
                        const SizedBox(height: 20),
                        _buildEnhancedTrackingCard(trackingData!),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _buildCustomerCard(orderData),
                        const SizedBox(height: 20),
                        _buildDeliveryHubCard(orderData),
                        const SizedBox(height: 20),
                        _buildPaymentCard(paymentData),
                        const SizedBox(height: 20),
                        widget.index == 0 || widget.index == 3?SizedBox.shrink():
                        _buildActionButtons()
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildEnhancedHeader(Order? orderData) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            _getStatusColor(widget.index).withValues(alpha:0.05),
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Order ID with copy
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "ORDER ID",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: ColorConst.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          orderData!.orderNo.toString(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: ColorConst.textPrimary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => _copyToClipboard(orderData!.orderNo.toString(), context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.copy_rounded,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      orderData!.createdAt.toString(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getStatusColor(widget.index),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getStatusText(widget.index),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(widget.index),
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
    );
  }

  Widget _buildOrderItemsCard(List<Items> vm, Order? orderData) {
    return _buildModernCard(
      title: "Order Items",
      icon: Icons.shopping_bag_rounded,
      child: Column(
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: vm.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final item = vm[i];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            item.img ?? "https://via.placeholder.com/48",
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 70,
                              height: 70,
                              color: Colors.grey.shade200,
                              child: Icon(
                                Icons.image_not_supported_rounded,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: ColorConst.primaryGreen,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              "${item.qty}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),

                    // Product Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: ColorConst.primaryGreen.withValues(alpha:0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "₹${item.price.toStringAsFixed(2)} each",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: ColorConst.primaryGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Total Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "₹${(item.price * item.qty).toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: ColorConst.primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${item.qty} × ₹${item.price.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // Price Summary with modern design
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColorConst.primaryGreen.withValues(alpha:0.05),
                  Colors.white,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ColorConst.primaryGreen.withValues(alpha:0.2)),
            ),
            child: Column(
              children: [
                _buildModernPriceRow("Subtotal (${(vm.length)} items)", orderData!.totalAmount ?? "-"),
                const SizedBox(height: 8),
                _buildModernPriceRow("Shipping Fee", orderData.deliveryCharge ?? "-"),
                const SizedBox(height: 8),
                const Divider(height: 24),
                _buildModernPriceRow("Grand Total", orderData.finalAmount ?? "-", isTotal: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernPriceRow(String label, String value, {bool isTotal = false, bool isDiscount = false}) {
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
            color: isDiscount
                ? Colors.green
                : (isTotal ? ColorConst.primaryGreen : Colors.grey.shade900),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedTrackingCard(List<Tracking> trackingData) {
    int currentStep = trackingData.length - 1;

    return _buildModernCard(
      title: "Tracking Timeline",
      icon: Icons.timeline_rounded,
      child: Column(
        children: List.generate(trackingData.length, (index) {
          final event = trackingData[index];

          final isCompleted = index <= currentStep;
          final isLast = index == trackingData.length - 1;

          return _buildModernTimelineItem(
            status: getStatusText(event.status ?? 0),
            time: formatDate(event.createdAt ?? ""),
            isCompleted: isCompleted,
            isLast: isLast,
          );
        }),
      ),
    );
  }

  String formatDate(String date) {
    try {
      final dt = DateTime.parse(date);
      return "${dt.day}/${dt.month}/${dt.year} • ${dt.hour}:${dt.minute}";
    } catch (e) {
      return date;
    }
  }
  String getStatusText(int status) {
    switch (status) {
      case 0:
        return "Order Placed";
      case 1:
        return "Order Confirmed";
      case 2:
        return "Order is packed";
      case 3:
        return "Order is dispatched";
      case 4:
        return "Out for delivery";
      case 5:
        return "Delivered";
      default:
        return "Cancelled";
    }
  }

  Widget _buildModernTimelineItem({
    required String status,
    required String time,
    required bool isCompleted,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                gradient: isCompleted
                    ? LinearGradient(
                  colors: [
                    ColorConst.primaryGreen,
                    ColorConst.primaryGreen.withValues(alpha:0.7),
                  ],
                )
                    : LinearGradient(
                  colors: [
                    Colors.grey.shade300,
                    Colors.grey.shade200,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: isCompleted
                    ? [
                  BoxShadow(
                    color: ColorConst.primaryGreen.withValues(alpha:0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                    : null,
              ),
              child: Center(
                child: Icon(
                  isCompleted ? Icons.check_rounded : Icons.circle_rounded,
                  size: isCompleted ? 14 : 8,
                  color: isCompleted ? Colors.white : Colors.grey.shade500,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isCompleted
                        ? [
                      ColorConst.primaryGreen,
                      ColorConst.primaryGreen.withValues(alpha:0.3),
                    ]
                        : [
                      Colors.grey.shade300,
                      Colors.grey.shade200,
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
                    color: isCompleted ? Colors.grey.shade900 : Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 11,
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

  Widget _buildCustomerCard(Order? orderData) {
    return _buildModernCard(
      title: "Customer Information",
      icon: Icons.person_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ColorConst.primaryGreen,
                      ColorConst.primaryGreen.withValues(alpha:0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    orderData!.customerName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      orderData.customerName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                _buildContactRow(Icons.phone_outlined, orderData.customerPhone),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF3B82F6).withValues(alpha:0.05),
                  Colors.white,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha:0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 16,
                      color: const Color(0xFF3B82F6),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "SHIPPING ADDRESS",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: ColorConst.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  orderData.address,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryHubCard(Order? orderData) {
    return _buildModernCard(
      title: "Delivery Hub",
      icon: Icons.local_shipping_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFF59E0B).withValues(alpha:0.05),
                  Colors.white,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha:0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.store_rounded,
                    color: const Color(0xFFF59E0B),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        orderData!.hubName ?? "-",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "ASSIGNED DELIVERY PARTNER",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: ColorConst.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [ColorConst.primaryGreen, Color(0xFF45B7B0)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      orderData.deliveryName.substring(0, 1).toUpperCase() ?? "-",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        orderData.deliveryName ?? "-",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.phone_rounded,
                            size: 12,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            orderData.deliveryPhone ?? "-",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.message_rounded,
                    size: 16,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(Payment? paymentData) {
    return _buildModernCard(
      title: "Payment Information",
      icon: Icons.payment_rounded,
      child: Column(
        children: [
          _buildPaymentDetailRow(
            "Payment Method",
            paymentData!.paymentMethod ?? "-",
            Icons.credit_card_rounded,
          ),
          const SizedBox(height: 12),
          _buildPaymentDetailRow(
            "Transaction ID",
            paymentData!.transactionId ?? "-",
            Icons.receipt_rounded,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColorConst.primaryGreen.withValues(alpha:0.1),
                  ColorConst.primaryGreen.withValues(alpha:0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Payment Status",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: ColorConst.primaryGreen.withValues(alpha:0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: ColorConst.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        paymentData.status=="0"?"Pending":paymentData.status=="1"?"Success":"Failed",
                        style: TextStyle(
                          fontSize: 11,
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
        ],
      ),
    );
  }

  Widget _buildPaymentDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          AppBtn(
            width: Sizes.screenWidth*0.14,
            height: Sizes.screenHeight*0.05,
            title: "Update Order Status",
            onTap: (){},
            fontSize: 12,
          ),
          SizedBox(height: 10),
          AppBtn(
            width: Sizes.screenWidth*0.14,
            height: Sizes.screenHeight*0.05,
            title: "Cancel Order",
            onTap: (){},
            color: ColorConst.error,
            fontSize: 12,
          )

        ],
      ),
    );
  }

  Widget _buildModernCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ColorConst.primaryGreen.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: ColorConst.primaryGreen),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ColorConst.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  // Helper Methods
  Color _getStatusColor(int index) {
    switch (index % 4) {
      case 0:
        return const Color(0xFF10B981); // Delivered - Green
      case 1:
        return const Color(0xFF3B82F6); // In Transit - Blue
      case 2:
        return const Color(0xFFF59E0B); // Pending - Orange
      case 3:
        return const Color(0xFFEF4444); // Cancelled - Red
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(int index) {
    switch (index % 4) {
      case 0:
        return "Delivered";
      case 1:
        return "In Transit";
      case 2:
        return "Pending";
      case 3:
        return "Cancelled";
      default:
        return "Unknown";
    }
  }

  void _copyToClipboard(String text, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Order ID copied to clipboard'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
