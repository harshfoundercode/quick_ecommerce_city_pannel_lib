import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/responsive_sizes.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/text_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/header_widget.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/dashboard_model.dart';

class ViewAllHubsScreen extends StatelessWidget {
  final List<Hubs> hubs;
  const ViewAllHubsScreen({super.key, required this.hubs});

  @override
  Widget build(BuildContext context) {
    final mobileSize = Responsive.isMobile(context);

    return Scaffold(
      appBar: AppBar(
        title: CustomText.semiBold("All Hub"),
        backgroundColor: ColorConst.bgColor,
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: Sizes.screenWidth*0.03,vertical: Sizes.screenHeight*0.01),
        shrinkWrap: true,
        itemCount: hubs.length,
        itemBuilder: (context, index) {
          final hub = hubs[index];
          return mobileSize
              ? _buildHubMobileCard(hub,context)
              : _buildHubRow(hub, index,context);

        },
      ),
    );
  }
  Widget _buildHubMobileCard(Hubs hub,context) {
    return InkWell(
      onTap: (){
        _showHubDetails(hub,context);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ColorConst.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                hubIcon(icon: Icons.dashboard_customize_sharp),
                const SizedBox(width: 10),
                Expanded(
                  child: hubText(name: hub.hubName, location: hub.address),
                ),
                CustomWidgets.statusBadge(isActive: hub.status==1?true:false,width: Sizes.screenWidth*0.18)
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _mobileMetric(hub.deliveryBoys.toString(), "Boys", Colors.blue),
                _mobileMetric(
                  hub.inProgress.toString(),
                  "Progress",
                  Colors.orange,
                ),
                _mobileMetric(
                  hub.completedToday.toString(),
                  "Done",
                  Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget hubText({required String name, required String location}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "Hub - $name",
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      const SizedBox(height: 2),
      Text(
        location,
        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
      ),
    ],
  );

  Widget hubIcon({required IconData icon}) => Container(
    height: 44,
    width: 44,
    decoration: BoxDecoration(
      color: ColorConst.primaryExtraLightGreen,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(icon, color: ColorConst.primaryGreen),
  );

  Widget _mobileMetric(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
        ),
      ],
    );
  }

  Widget _buildHubRow(Hubs hub, int index,context) {
    return InkWell(
      onTap: (){
        _showHubDetails(hub,context);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: index.isEven ? Colors.white : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ColorConst.borderColor),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  hubIcon(icon: Icons.dashboard),
                  const SizedBox(width: 12),
                  hubText(name: hub.hubName, location: hub.address),
                ],
              ),
            ),
            Expanded(
              child: metric(
                value: hub.deliveryBoys.toString(),
                label: "Delivery boys",
                color: Colors.blue,
              ),
            ),
            Expanded(
              child: metric(
                value: hub.inProgress.toString(),
                label: "Orders in progress",
                color: Colors.orange,
              ),
            ),
            Expanded(
              child: metric(
                value: hub.completedToday.toString(),
                label: "Completed today",
                color: Colors.green,
              ),
            ),
            Expanded(child: CustomWidgets.statusBadge(isActive: hub.status==1?true:false)),
            _buildArrowButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildArrowButton() => Container(
    height: 36,
    width: 36,
    decoration: BoxDecoration(
      color: const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(10),
    ),
    child: const Icon(Icons.chevron_right, color: ColorConst.primaryGreen),
  );

  void _showHubDetails(Hubs hub,context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: ColorConst.primaryGreen.withValues(
                    alpha: 0.1,
                  ),
                  child: Icon(Icons.dashboard, color: ColorConst.primaryGreen),
                ),
                title: Text(hub.hubName),
                subtitle: Text(hub.address),
              ),
              const Divider(),
              _buildDetailRow("Delivery Boys", hub.deliveryBoys.toString()),
              _buildDetailRow(
                "Orders in Progress",
                hub.inProgress.toString(),
              ),
              _buildDetailRow("Completed Today", hub.completedToday.toString()),
              _buildDetailRow("Status", hub.status==1 ? "Active" : "Inactive"),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget metric({
    required String value,
    required String label,
    required Color color,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        value,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        label,
        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
      ),
    ],
  );
}