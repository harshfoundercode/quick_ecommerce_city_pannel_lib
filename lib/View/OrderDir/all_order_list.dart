import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/text_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/header_widget.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/orders_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/OrderDir/orders_details_screen.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/order_view_model.dart';

import '../../ConstDir/widgets/dialog_box.dart';

class AllOrdersList extends StatefulWidget {
  final List<Orders>? pvm;
  const AllOrdersList({super.key, this.pvm});

  @override
  State<AllOrdersList> createState() => AllOrdersListState();
}

class AllOrdersListState extends State<AllOrdersList> {

  @override
  Widget build(BuildContext context) {
    final orders = widget.pvm ?? [];
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pending_actions_rounded, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              "No Orders Found",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      itemCount: widget.pvm?.length,
      itemBuilder: (context, index) {
        final data = widget.pvm![index];
        return _buildOrderListItem(index,data);
      },
    );
  }

  Widget _buildOrderListItem(int index, Orders data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: CustomText.semiBold(
              data.orderNo ?? "-",
              fontSize: 13,
              color: Colors.grey.shade900,
            ),
          ),
          Expanded(
            child: CustomText.semiBold(
              data.customerName ?? "-",
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
                color: _getStatusColor(data.status ?? "0").withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: CustomText.semiBold(
                _getStatusText(data.status ?? "0"),
                fontSize: 11,
                color: _getStatusColor(data.status ?? "0"),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Container(
            width: Sizes.screenWidth*0.12,
            child: InkWell(
              onTap: (){
                openRightDrawer(context, OrderDetailsView(index:index,orderId:data.id.toString()));
                print("dediubekdbe");
              },
              child: Icon(CupertinoIcons.eye_fill, size: 18, color: Colors.grey.shade600),
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
      case 4:
        return Colors.teal;
      case 5:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(int index) {
    switch (index % 4) {
      case 0:
        return "Placed";
      case 1:
        return "Confirmed";
      case 2:
        return "Packed";
      case 3:
        return "Dispatched";
      case 4:
        return "Out for Delivery";
      case 5:
        return "Delivered";
      default:
        return "Cancelled";
    }
  }
}
