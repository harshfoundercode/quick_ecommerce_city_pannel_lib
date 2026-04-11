import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/responsive_sizes.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/text_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/header_widget.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/dashboard_model.dart';

class TodayOverviewCard extends StatefulWidget {
  final Summary? dashboardSummaryData;
  const TodayOverviewCard({super.key, this.dashboardSummaryData});

  @override
  State<TodayOverviewCard> createState() => _TodayOverviewCardState();
}

class _TodayOverviewCardState extends State<TodayOverviewCard> {
  @override
  Widget build(BuildContext context) {
    final mobileSize = Responsive.isMobile(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ColorConst.borderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomWidgets.hubHeader(
            title: "Today's Overview",
            subtitle: "Orders performance for this city",
            titleSize: mobileSize?20:16,
            subtitleSize: mobileSize?15:10
          ),
          CustomWidgets.verticalSpace(0.03),
            overviewGrid(mobileSize),
        ],
      ),
    );
  }

  Widget overviewGrid(bool mobileSize) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: mobileSize?1.42:2.3,
      children: [
        overViewItem(
          title: "Total Orders",
          value: widget.dashboardSummaryData!.totalOrders.toString(),
          icon: Icons.receipt_long_outlined,
          iconBg: Color(0xFFD1FAE5),
          iconColor: Color(0xFF16A34A),
        ),
        overViewItem(
          title: "Delivered",
          value:  widget.dashboardSummaryData!.deliveredOrders.toString(),
          icon: Icons.check_circle_outline,
          iconBg: Color(0xFFD1FAE5),
          iconColor: Color(0xFF059669),
        ),
        overViewItem(
          title: "Pending",
          value: widget.dashboardSummaryData!.pendingOrders.toString(),
          icon: Icons.access_time,
          iconBg: Color(0xFFFFEDD5),
          iconColor: Color(0xFFEA580C),
        ),
        overViewItem(
          title: "Revenue",
          value: "₹${widget.dashboardSummaryData!.revenue.toString()}",
          icon: Icons.currency_rupee,
          iconBg: Color(0xFFEDE9FE),
          iconColor: Color(0xFF7C3AED),
        ),
      ],
    );
  }

  Widget overViewItem({
    required final String title,
    required final String value,
    required final IconData icon,
    required final Color iconBg,
    required final Color iconColor,}
  ) {
    return Container(
      padding:  EdgeInsets.symmetric(horizontal: 16,vertical:Sizes.screenHeight*0.017),
      decoration: BoxDecoration(
        color: ColorConst.containerGrey2,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 33,
                width: 33,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor,size: 20,),
              ),
              SizedBox(width: Sizes.screenWidth*0.012,),
              CustomText.bold(
                title,
                fontSize: 13,
                color: ColorConst.textPrimary
              ),

            ],
          ),
          CustomWidgets.verticalSpace(0.012),
          CustomText.bold(
            value,
            fontSize: 20,
            color:ColorConst.black
          ),
        ],
      ),
    );
  }
}
