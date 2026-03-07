import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/app_button.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/text_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/utils/utils.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/dialog_box.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/header_widget.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/HubDir/HubPerformanceDir/deliveries_by_hub_chart.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/HubDir/HubPerformanceDir/success_rate_chart.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/HubDir/HubPerformanceDir/ViewAllOrderHubDir/view_all_order_specific_hub.dart';

class AllHubsPerformanceScreen extends StatefulWidget {
  const AllHubsPerformanceScreen({super.key});

  @override
  State<AllHubsPerformanceScreen> createState() => _AllHubsPerformanceScreenState();
}

class _AllHubsPerformanceScreenState extends State<AllHubsPerformanceScreen> {
  @override
  Widget build(BuildContext context) {
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
           statsSection(),
          CustomWidgets.verticalSpace(0.025),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:  [
              Expanded(flex: 1, child: DeliveriesChartCard()),
              SizedBox(width: 20),
              Expanded(flex: 1, child: SuccessRateChartCard()),
            ],
          ),
          CustomWidgets.verticalSpace(0.025),
          performanceTableCard(context),
        ],
      ),
    );
  }
  Widget statsSection() {
    final stats = [
      {
        'title': "Total Deliveries",
        'value': "42,850",
        'icon': Icons.check_circle_outline,
      },
      {
        'title': "Avg Success Rate",
        'value': "91.5%",
        'icon': Icons.analytics_outlined,
      },
      {
        'title':"Active Delivery Boys",
        'value': "148",
        'icon': Icons.timer_outlined,
      },
      {
        'title':"Total Hubs",
        'value': "12",
        'icon': Icons.cancel_outlined,
      },
    ];

    return CustomWidgets.statsRow(stats: stats, isMobile: true);
  }

  Widget performanceTableCard(BuildContext context) {
    return CustomWidgets.cardWrapperWithActionWidget(
      title: "Hub Performance Details",
      actionWidget: Row(
        children: [
          _buildFilterChip(
            label: "Filter",
            icon: Icons.filter_alt_outlined,
            onTap: () => _showFilterDialog(context),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: "Sort",
            icon: Icons.swap_vert,
            onTap: () => _showSortDialog(context),
          ),
          const SizedBox(width: 8),
          _buildRefreshButton(context),
        ],
      ),
      child: Column(
        children: [
          _buildEnhancedTableHeader(),
          const Divider(height: 24, thickness: 1, color: Color(0xFFE5E7EB)),

          // Hub Rows
          _buildEnhancedHubRow(
            context,
            name: "Gomti Nagar Hub",
            orders: "8,502",
            rate: "94.2%",
            time: "28 mins",
            boys: "34",
            optimal: true,
            trend: "+12%",
          ),
          _buildEnhancedHubRow(
            context,
            name: "Hazratganj Hub",
            orders: "7,245",
            rate: "92.8%",
            time: "32 mins",
            boys: "28",
            optimal: true,
            trend: "+8%",
          ),
          _buildEnhancedHubRow(
            context,
            name: "Aliganj Hub",
            orders: "6,512",
            rate: "88.5%",
            time: "35 mins",
            boys: "22",
            optimal: true,
            trend: "+5%",
          ),
          _buildEnhancedHubRow(
            context,
            name: "Indira Nagar Hub",
            orders: "5,580",
            rate: "85.2%",
            time: "42 mins",
            boys: "18",
            optimal: false,
            trend: "-3%",
          ),
          _buildEnhancedHubRow(
            context,
            name: "Chowk Hub",
            orders: "4,890",
            rate: "82.7%",
            time: "48 mins",
            boys: "15",
            optimal: false,
            trend: "-8%",
          ),

          const SizedBox(height: 16),
          AppBtn(
            title:  "View All Hubs Performance",
            onTap:(){ _navigateToAllHubs(context);},

          )
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
          Expanded(
            child: _buildHeaderCell("Success Rate", Icons.percent),
          ),
          Expanded(
            child: _buildHeaderCell("Avg. Delivery", Icons.timer),
          ),
          Expanded(
            child: _buildHeaderCell("Active Boys", Icons.pedal_bike),
          ),
          Expanded(
            child: _buildHeaderCell("Status", Icons.circle),
          ),
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
        required bool optimal,
        required String trend,
      }) {
    final rateColor = optimal ? Colors.green : Colors.orange;
    final trendColor = trend.startsWith('+') ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Hub Details with Icon
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ColorConst.primaryGreen.withValues(alpha:0.1),
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
                      CustomText.medium(
                        name,
                        fontSize: 14,
                      ),
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
          SizedBox(width: Sizes.screenWidth*0.02,),
          // Total Orders with Trend
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText.bold(orders, fontSize: 16),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: trendColor.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    trend,
                    style: TextStyle(
                      fontSize: 10,
                      color: trendColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Success Rate
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText.bold(rate, fontSize: 16, color: rateColor),
                const SizedBox(height: 2),
                LinearProgressIndicator(
                  value: double.parse(rate.replaceAll('%', '')) / 100,
                  backgroundColor: rateColor.withValues(alpha:0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(rateColor),
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
            ),
          ),
          SizedBox(width: Sizes.screenWidth*0.01,),
          // Avg Delivery Time
          Expanded(
            child: Row(
              children: [
                Icon(Icons.access_time, size: 12, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                CustomText.medium(time, fontSize: 13),
              ],
            ),
          ),

          // Active Boys
          Expanded(
            child: Row(
              children: [
                Icon(Icons.person, size: 12, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                CustomText.medium(boys, fontSize: 13),
              ],
            ),
          ),


          // Status Badge
          Expanded(
            child: _buildEnhancedStatusBadge(optimal),
          ),

          // View Orders Button
          _buildViewOrdersButton(context, name),
        ],
      ),
    );
  }

// Enhanced Status Badge
  Widget _buildEnhancedStatusBadge(bool optimal) {
    final color = optimal ? Colors.green : Colors.orange;
    final bgColor = optimal ? const Color(0xffE6F7EF) : const Color(0xffFFF4E5);
    final text = optimal ? "Optimal" : "Needs Attention";

    return Center(
      child: Container(
        width: Sizes.screenWidth*0.099,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha:0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha:0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Center(
              child: CustomText.medium(
                text,
                fontSize: 11,
                color: color,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

// View Orders Button
  Widget _buildViewOrdersButton(BuildContext context, String hubName) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          openRightDrawer(context,ViewAllOrderSpecificHub(hubName: hubName) );
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: ColorConst.primaryGreen.withValues(alpha:0.1),
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

// Filter Chip
  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey.shade700),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Refresh Button
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


  void _navigateToAllHubs(BuildContext context) {
    Utils.show("Navigating to all hubs performance", context);
  }

// Filter Dialog
  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Filter Hubs"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.circle, color: Colors.green),
                title: const Text("Optimal Hubs"),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.circle, color: Colors.orange),
                title: const Text("Needs Attention"),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.star, color: Colors.blue),
                title: const Text("Top Performing"),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

// Sort Dialog
  void _showSortDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Sort By"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.trending_up),
                title: const Text("Highest Orders"),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.timer),
                title: const Text("Fastest Delivery"),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.percent),
                title: const Text("Success Rate"),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

}

