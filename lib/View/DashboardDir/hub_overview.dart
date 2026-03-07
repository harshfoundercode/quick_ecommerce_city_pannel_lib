import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/header_widget.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/responsive_sizes.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/hub_desktop_view_model.dart';

class HubManagementTable extends StatefulWidget {
  const HubManagementTable({super.key});

  @override
  State<HubManagementTable> createState() => _HubManagementTableState();
}

class _HubManagementTableState extends State<HubManagementTable> {

  @override
  Widget build(BuildContext context) {
    final mobileSize = Responsive.isMobile(context);

    return Consumer<HubManagementViewModel>(
      builder: (context,hvm,child) {
        return CustomWidgets.cardWrapper(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(mobileSize,hvm),
              CustomWidgets.verticalSpace(0.02),
              if (!mobileSize) hubTableHeader(),
              CustomWidgets.verticalSpace(0.01),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount:hvm.filteredHubs.length,
                itemBuilder: (context, index) {
                  final hub = hvm.filteredHubs[index];
                  return mobileSize
                      ? _buildHubMobileCard(hub)
                      : _buildHubRow(hub, index);
                },
              ),

              _buildPaginationFooter(hvm),
            ],
          ),
        );
      }
    );
  }

  void _showHubDetails(HubModel hub) {
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
                  child: Icon(hub.icon, color: ColorConst.primaryGreen),
                ),
                title: Text(hub.name),
                subtitle: Text(hub.location),
              ),
              const Divider(),
              _buildDetailRow("Delivery Boys", hub.deliveryBoys.toString()),
              _buildDetailRow(
                "Orders in Progress",
                hub.ordersInProgress.toString(),
              ),
              _buildDetailRow("Completed Today", hub.completedToday.toString()),
              _buildDetailRow("Status", hub.isActive ? "Active" : "Inactive"),
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


  // ================= TOP BAR =================

  Widget _buildTopBar(bool isMobile, HubManagementViewModel hvm) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomWidgets.hubHeader(
              title: "Hub Management",
              subtitle: "Monitor and manage all hubs in Lucknow",
              titleSize: 20,
              subtitleSize: 15
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: CustomWidgets.searchField(controller: hvm.searchController,width: double.infinity)),
              const SizedBox(width: 8),
              _buildFilterDropdown(hvm),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child:  CustomWidgets.hubHeader(
            title: "Hub Management",
            subtitle: "Monitor and manage all hubs in Lucknow",
            titleSize: 18,
            subtitleSize: 10
        )),
        CustomWidgets.searchField(controller: hvm.searchController,width: 200),
        SizedBox(width: Sizes.screenWidth * 0.01),
        _buildFilterDropdown(hvm),
      ],
    );
  }


  // ================= FILTER =================

  Widget _buildFilterDropdown(HubManagementViewModel hvm) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorConst.borderColor),
      ),
      child: DropdownButton<String>(
        value: hvm.filterStatus,
        onChanged: (val) => hvm.updateFilter(val!),
        underline: const SizedBox(),
        items: [
          'All',
          'Active',
          'Inactive',
        ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      ),
    );
  }

  // ================= TABLE HEADER =================


  Widget hubTableHeader() {
    return CustomWidgets.tableHeader(
      headers: const ["Hub Information", "Delivery Boys", "In Progress", "Completed", "Status"],
      flexValues: const [3, 1, 1, 1, 1],
    );
  }

  // ================= DESKTOP ROW =================

  Widget _buildHubRow(HubModel hub, int index) {
    return InkWell(
      onTap: (){
        _showHubDetails(hub);
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
                  hubIcon(icon: hub.icon),
                  const SizedBox(width: 12),
                  hubText(name: hub.name, location: hub.location),
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
                value: hub.ordersInProgress.toString(),
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
            Expanded(child: CustomWidgets.statusBadge(isActive: hub.isActive)),
            _buildArrowButton(),
          ],
        ),
      ),
    );
  }

  // ================= MOBILE CARD =================

  Widget _buildHubMobileCard(HubModel hub) {
    return InkWell(
      onTap: (){
        _showHubDetails(hub);
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
                hubIcon(icon: hub.icon),
                const SizedBox(width: 10),
                Expanded(
                  child: hubText(name: hub.name, location: hub.location),
                ),
                CustomWidgets.statusBadge(isActive: hub.isActive,width: Sizes.screenWidth*0.18)
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
                  hub.ordersInProgress.toString(),
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

  // ================= COMMON WIDGETS =================

  Widget _buildArrowButton() => Container(
    height: 36,
    width: 36,
    decoration: BoxDecoration(
      color: const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(10),
    ),
    child: const Icon(Icons.chevron_right, color: ColorConst.primaryGreen),
  );

  Widget _buildPaginationFooter(HubManagementViewModel hvm) => Padding(
    padding: const EdgeInsets.only(top: 16),
    child: Text(
      'Showing ${hvm.filteredHubs.length} of ${hvm.hubs.length} hubs',
      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
    ),
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


