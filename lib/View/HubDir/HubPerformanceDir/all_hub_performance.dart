import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/app_button.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/text_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/utils/utils.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/dialog_box.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/header_widget.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/hub_performance_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/HubDir/HubPerformanceDir/ViewAllOrderHubDir/view_all_order_specific_hub.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/HubDir/HubPerformanceDir/view_all_hub_performance_screen.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/hub_performance_view_model.dart';

class AllHubsPerformanceScreen extends StatefulWidget {
  const AllHubsPerformanceScreen({super.key});

  @override
  State<AllHubsPerformanceScreen> createState() =>
      _AllHubsPerformanceScreenState();
}

class _AllHubsPerformanceScreenState extends State<AllHubsPerformanceScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hubPerformance = Provider.of<HubPerformanceViewModel>(
        context,
        listen: false,
      );
      hubPerformance.getHubPerformanceDataApi(context);
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HubPerformanceViewModel>(
      builder: (context, hvm, child) {
        final hubData = hvm.hubPerformanceModel?.data?.hubs;
        final summaryData = hvm.hubPerformanceModel?.data?.summary;

        if (hubData == null || hubData.isEmpty) {
          return Text("No data found");
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(Sizes.screenWidth * 0.015),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomWidgets.pageHeader(
                title: "All Hubs Performance",
                subtitle: "City Overview",
              ),
              CustomWidgets.verticalSpace(0.025),
              statsSection(summaryData: summaryData),
              CustomWidgets.verticalSpace(0.025),
              performanceTableCard(context, hubData),
            ],
          ),
        );
      },
    );
  }

  Widget statsSection({Summary? summaryData}) {
    final stats = [
      {
        'title': "Total Deliveries",
        'value': summaryData?.totalDeliveries.toString() ?? "-",
        'icon': Icons.check_circle_outline,
      },
      {
        'title': "Avg Success Rate",
        'value': "${summaryData?.avgSuccessRate.toString() ?? "-"} %",
        'icon': Icons.analytics_outlined,
      },
      {
        'title': "Active Delivery Boys",
        'value': summaryData?.activeDeliveryBoys.toString() ?? "-",
        'icon': Icons.timer_outlined,
      },
      {
        'title': "Total Hubs",
        'value': summaryData?.totalHubs.toString() ?? "-",
        'icon': Icons.cancel_outlined,
      },
    ];

    return CustomWidgets.statsRow(stats: stats, isMobile: false);
  }

  Widget performanceTableCard(BuildContext context, List<Hubs> hubData) {
    final hubs = hubData;
    final showLimited = hubs.length > 4;
    final displayList = showLimited ? hubs.take(4).toList() : hubs;
    return CustomWidgets.cardWrapperWithActionWidget(
      title: "Hub Performance Details",
      actionWidget: _buildRefreshButton(context),
      child: Column(
        children: [
          _buildEnhancedTableHeader(),
          const Divider(height: 24, thickness: 1, color: Color(0xFFE5E7EB)),
          ListView.builder(
            itemCount: displayList.length,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int i) {
              return _buildEnhancedHubRow(
                context,
                name: displayList[i].hubName,
                orders: displayList[i].totalOrders.toString(),
                rate: "${displayList[i].successRate.toString()} %",
                time: "${displayList[i].avgDeliveryTime.toString()} Min",
                boys: displayList[i].activeBoys.toString(),
                hubId:displayList[i].hubId.toString()
              );
            },
          ),
          SizedBox(height: Sizes.screenHeight*0.02),
          if(displayList.length>4)
          AppBtn(
            title: "View All Hubs Performance",
            onTap: () {
              openRightDrawer(context,ViewAllHubPerformanceScreen(hub:hubs));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: _buildHeaderCell("Hub Details", Icons.location_city),
          ),
          Expanded(
            child: _buildHeaderCell("Total Orders", Icons.shopping_cart),
          ),
          Expanded(child: _buildHeaderCell("Success Rate", Icons.percent)),
          Expanded(child: _buildHeaderCell("Avg. Delivery", Icons.timer)),
          Expanded(child: _buildHeaderCell("Active Boys", Icons.pedal_bike)),
          Expanded(child: _buildHeaderCell("Status", Icons.circle)),
          Container(width: 40),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  // Enhanced Hub Row
  Widget _buildEnhancedHubRow(
    BuildContext context, {
    required String name,
    required String orders,
    required String rate,
    required String time,
    required String boys,
        required String hubId,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: Sizes.screenWidth*0.235,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ColorConst.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.account_tree_outlined,
                    size: 16,
                    color: ColorConst.primaryGreen,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText.medium(name, fontSize: 14),
                      const SizedBox(height: 2),
                      CustomText.regular(
                        "ID: HUB${name.hashCode.abs() % 1000}",
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          CustomText.bold(orders, fontSize: 16),

          SizedBox(width: Sizes.screenWidth*0.055),
          SizedBox(
            width: Sizes.screenWidth*0.1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText.bold(rate, fontSize: 16, color: ColorConst.primaryGreen),
                const SizedBox(height: 2),
                LinearProgressIndicator(
                  value: double.parse(rate.replaceAll('%', '')) / 100,
                  backgroundColor: ColorConst.primaryGreen.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(ColorConst.primaryGreen),
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
            ),
          ),
          SizedBox(width: Sizes.screenWidth * 0.028),
          SizedBox(
            width: Sizes.screenWidth*0.048,
            child: Row(
              children: [
                Icon(Icons.access_time, size: 12, color: Colors.grey.shade500),
                 SizedBox(width: Sizes.screenWidth*0.007),
                CustomText.medium(time, fontSize: 13),
              ],
            ),
          ),
          SizedBox(width: Sizes.screenWidth * 0.058),
          SizedBox(
            width: Sizes.screenWidth*0.023,
            child: Row(
              children: [
                Icon(Icons.person, size: 12, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                CustomText.medium(boys, fontSize: 13),
              ],
            ),
          ),
          SizedBox(width: Sizes.screenWidth*0.08,),
          _buildViewOrdersButton(context, name,hubId),
        ],
      ),
    );
  }


  Widget _buildViewOrdersButton(BuildContext context, String hubName, String hubId) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {

          openRightDrawer(context, ViewAllOrderSpecificHub(hubName: hubName,hubId:hubId));
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: ColorConst.primaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.visibility_outlined,
            size: 18,
            color: ColorConst.primaryGreen,
          ),
        ),
      ),
    );
  }

  Widget _buildRefreshButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Utils.show("Refreshing data...", context);
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(Icons.refresh, size: 16, color: Colors.grey.shade700),
        ),
      ),
    );
  }

}
