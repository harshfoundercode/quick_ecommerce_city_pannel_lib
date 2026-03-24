import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/responsive_sizes.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/header_widget.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/DashboardDir/city_green_card.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/DashboardDir/dashboard_header.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/DashboardDir/despute_screen.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/DashboardDir/hub_overview.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/DashboardDir/revenue_card.dart' show RevenueCard;
import 'package:quick_ecommerce_city_panel_redefined/View/DashboardDir/today_overview.dart' show TodayOverviewCard;
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/dashboard_view_model.dart';

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_){
      final dashboardData = Provider.of<DashboardViewModel>(context,listen: false);
      dashboardData.getDashBoardDataApi(context);
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mobileSize = Responsive.isMobile(context);
    return Consumer<DashboardViewModel>(
      builder: (context,dvm,child) {
        final dashboardHubData = dvm.dashboardDetailsModel?.data?.hubs;
        final dashboardSummaryData = dvm.dashboardDetailsModel?.data?.summary;
        final dashboardRecentDisputeData = dvm.dashboardDetailsModel?.data?.recentDisputes;

        if (dvm.dashboardDetailsModel == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (dashboardSummaryData == null) {
          return const Center(
            child: Text("No Data Available"),
          );
        }

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
                              CityCard(dashboardSummaryData: dashboardSummaryData,),
                              CustomWidgets.verticalSpace(0.02),
                              TodayOverviewCard(dashboardSummaryData: dashboardSummaryData),
                              CustomWidgets.verticalSpace(0.02),
                              RevenueCard(dashboardHubData:dashboardHubData,dashboardSummaryData:dashboardSummaryData),
                              CustomWidgets.verticalSpace(0.02),
                              DisputeCard(dashboardRecentDisputeData:dashboardRecentDisputeData),
                              CustomWidgets.verticalSpace(0.02),
                              HubManagementTable(dashboardHubData:dashboardHubData),
                              CustomWidgets.verticalSpace(0.16),
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
                              CityCard(dashboardSummaryData: dashboardSummaryData),
                              SizedBox(width: Sizes.screenWidth * 0.01),
                              Expanded(child: TodayOverviewCard(dashboardSummaryData: dashboardSummaryData)),
                            ],
                          ),
                          SizedBox(height: Sizes.screenHeight * 0.03),
                          Row(
                            children: [
                              Expanded(child: RevenueCard(dashboardHubData:dashboardHubData,dashboardSummaryData:dashboardSummaryData)),
                              SizedBox(width: Sizes.screenWidth * 0.01),
                              Expanded(child: DisputeCard(dashboardRecentDisputeData:dashboardRecentDisputeData)),
                            ],
                          ),
                          SizedBox(height: Sizes.screenHeight * 0.03),
                          HubManagementTable(dashboardHubData:dashboardHubData),
                        ],
                      ),
                    ),
            ],
          ),
        );
      }
    );
  }
}
