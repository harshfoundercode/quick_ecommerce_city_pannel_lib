import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/app_button.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/header_widget.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/HubDir/HubPerformanceDir/ViewAllOrderHubDir/order_left_side_list.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/HubDir/HubPerformanceDir/ViewAllOrderHubDir/order_right_side_list.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/hub_performance_view_model.dart';


class ViewAllOrderSpecificHub extends StatefulWidget {
  final String hubName;
  final String hubId;
  const ViewAllOrderSpecificHub({super.key, required this.hubName, required this.hubId});

  @override
  State<ViewAllOrderSpecificHub> createState() => _ViewAllOrderSpecificHubState();
}

class _ViewAllOrderSpecificHubState extends State<ViewAllOrderSpecificHub> {

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_){
      final orderData = Provider.of<HubPerformanceViewModel>(context,listen: false);
      orderData.getHubPerformanceOrderListDataApi(context,widget.hubId.toString());
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HubPerformanceViewModel>(
      builder: (context,hpvm,child) {

        final data = hpvm.hubPerformanceOrderListModel?.data;

        if (data == null || data.isEmpty) {
          return Material(
            color: Colors.white,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    /// 🔹 ICON
                    Container(
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                        color: ColorConst.primaryGreen.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        size: 40,
                        color: ColorConst.primaryGreen.withValues(alpha: 0.6),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// 🔹 TITLE
                    Text(
                      "No Orders Found",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade900,
                      ),
                    ),

                    const SizedBox(height: 8),

                    /// 🔹 SUBTEXT
                    Text(
                      "There are no orders available right now.\nTry changing filters or check again later.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// 🔹 BUTTON (optional but useful)
                    ElevatedButton(
                      onPressed: () {
                        // reload or reset filter
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorConst.primaryGreen,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Refresh",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

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
                          child: OrdersListPanel(data:data),
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
    );
  }
}


