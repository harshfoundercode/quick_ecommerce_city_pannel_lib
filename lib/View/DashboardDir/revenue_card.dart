import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/responsive_sizes.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/text_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/header_widget.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/dashboard_model.dart';

class RevenueCard extends StatefulWidget {
  final List<Hubs>? dashboardHubData;
  final Summary dashboardSummaryData;
  const RevenueCard({
    super.key,
    required this.dashboardHubData,
    required this.dashboardSummaryData,
  });

  @override
  State<RevenueCard> createState() => _RevenueCardState();
}

class _RevenueCardState extends State<RevenueCard> {
  @override
  Widget build(BuildContext context) {
    final mobileSize = Responsive.isMobile(context);
    List<double> revenues = widget.dashboardHubData!
        .map((e) => double.tryParse(e.revenue ?? "0") ?? 0.0)
        .toList();
    double maxRevenue = revenues.isNotEmpty
        ? revenues.reduce((a, b) => a > b ? a : b)
        : 1;

    return CustomWidgets.cardWrapper(
      height: Sizes.screenHeight * 0.49,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomWidgets.hubHeader(
            title: "Revenue Analytics",
            subtitle: "Weekly earning performance",
            titleSize: mobileSize ? 20 : 18,
            subtitleSize: mobileSize ? 15 : 10,
          ),
          CustomWidgets.verticalSpace(0.012),
          CustomText.bold(
            "₹${widget.dashboardSummaryData.revenue ?? "0"}",
            fontSize: 26,
          ),
          Spacer(),

          SizedBox(
            height: Sizes.screenHeight * 0.28,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(widget.dashboardHubData!.length, (index) {
                final hub = widget.dashboardHubData![index];
                double revenue = double.tryParse(hub.revenue ?? "0") ?? 0.0;

                double barHeight = maxRevenue == 0
                    ? 10
                    : (revenue / maxRevenue) * 150;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      revenue.toStringAsFixed(0),
                      style: TextStyle(fontSize: 10),
                    ),
                    SizedBox(height: Sizes.screenHeight * 0.012),
                    Container(
                      width: Sizes.screenWidth * 0.02,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: revenue > 0
                            ? ColorConst.primaryGreen
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),

                    SizedBox(height: Sizes.screenHeight * 0.012),

                    SizedBox(
                      width: Sizes.screenWidth * 0.07,
                      child: Text(
                        hub.hubName ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
