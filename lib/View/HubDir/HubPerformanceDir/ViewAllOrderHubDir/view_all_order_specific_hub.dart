import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/app_button.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/header_widget.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/HubDir/HubPerformanceDir/ViewAllOrderHubDir/order_left_side_list.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/HubDir/HubPerformanceDir/ViewAllOrderHubDir/order_right_side_list.dart';


class ViewAllOrderSpecificHub extends StatefulWidget {
  final String hubName;
  const ViewAllOrderSpecificHub({super.key, required this.hubName});

  @override
  State<ViewAllOrderSpecificHub> createState() => _ViewAllOrderSpecificHubState();
}

class _ViewAllOrderSpecificHubState extends State<ViewAllOrderSpecificHub> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Container(
        width: Sizes.screenWidth,
        height: Sizes.screenHeight,
        padding: EdgeInsets.symmetric(
          horizontal: Sizes.screenWidth * 0.012,
          vertical: Sizes.screenHeight * 0.012,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppBackBtn(color: Colors.black),
            CustomWidgets.hubHeader(
              title: "All Orders - Hub ${widget.hubName}",
              subtitle:
              "Showing today's orders from this hub. Use filters to find any ecommerce order.",
            ),
            CustomWidgets.verticalSpace(0.02),
            Expanded(
              child: CustomWidgets.cardWrapper(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: OrdersListPanel(),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 6,
                      child: OrderDetailsPanel(),
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
}


