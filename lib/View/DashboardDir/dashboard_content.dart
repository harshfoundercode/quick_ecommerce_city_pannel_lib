import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/responsive_sizes.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/header_widget.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/DashboardDir/city_green_card.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/DashboardDir/dashboard_header.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/DashboardDir/despute_screen.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/DashboardDir/hub_overview.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/DashboardDir/revenue_card.dart' show RevenueCard;
import 'package:quick_ecommerce_city_panel_redefined/View/DashboardDir/today_overview.dart' show TodayOverviewCard;

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  @override
  Widget build(BuildContext context) {
    final mobileSize = Responsive.isMobile(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          mobileSize ? SizedBox.shrink() : DashboardHeader(),
          mobileSize
              ? Padding(
                  padding: EdgeInsets.all(mobileSize?5:20),
                  child: Container(
                    height: Sizes.screenHeight,
                    width: Sizes.screenWidth,
                    margin: EdgeInsets.symmetric(horizontal: Sizes.screenWidth*0.02),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          CityCard(),
                          CustomWidgets.verticalSpace(0.02),
                          TodayOverviewCard(),
                          CustomWidgets.verticalSpace(0.02),
                          RevenueCard(),
                          CustomWidgets.verticalSpace(0.02),
                          DisputeCard(),
                          SizedBox(height: Sizes.screenHeight * 0.03),
                          HubManagementTable(),
                        ],
                      ),
                    ),
                  ),
                )
              : Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CityCard(),
                          SizedBox(width: Sizes.screenWidth * 0.01),
                          Expanded(child: TodayOverviewCard()),
                        ],
                      ),
                      SizedBox(height: Sizes.screenHeight * 0.03),
                      Row(
                        children: [
                          Expanded(child: RevenueCard()),
                          SizedBox(width: Sizes.screenWidth * 0.01),
                          Expanded(child: DisputeCard()),
                        ],
                      ),
                      SizedBox(height: Sizes.screenHeight * 0.03),
                      HubManagementTable(),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
