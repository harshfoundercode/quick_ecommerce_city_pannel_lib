import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/text_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/dialog_box.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/header_widget.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/OrderDir/orders_details_screen.dart';

class AllOrdersList extends StatefulWidget {
  const AllOrdersList({super.key});

  @override
  State<AllOrdersList> createState() => AllOrdersListState();
}

class AllOrdersListState extends State<AllOrdersList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) {
        return _buildOrderListItem(index);
      },
    );
  }

  Widget _buildOrderListItem(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText.semiBold(
                  "#ORD-${2024000 + index}",
                  fontSize: 13,
                  color: Colors.grey.shade900,
                ),
                CustomWidgets.verticalSpace(0.01),
                CustomText.medium(
                  "2 items",
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ],
            ),
          ),
          Expanded(
            child: CustomText.semiBold(
              "Rahul Sharma",
              fontSize: 13,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          CustomWidgets.horizontalSpace(0.01),
          Expanded(
            child: CustomText.semiBold(
              "₹${(index + 1) * 450}",
              fontSize: 13,
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(index).withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: CustomText.semiBold(
                _getStatusText(index),
                fontSize: 11,
                color: _getStatusColor(index),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(CupertinoIcons.eye_fill, size: 18, color: Colors.grey.shade600),
                  onPressed: () {
                    openRightDrawer(context, OrderDetailsView(index:index));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(int index) {
    switch (index % 4) {
      case 0:
        return const Color(0xFF10B981);
      case 1:
        return const Color(0xFF3B82F6);
      case 2:
        return const Color(0xFFF59E0B);
      case 3:
        return const Color(0xFFEF4444);
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
}
