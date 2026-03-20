import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/responsive_sizes.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/text_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/dialog_box.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/header_widget.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/hub_list_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/HubDir/SpecificHubPerformanceDir/view_hub_details.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/HubDir/edit_hub_details.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/HubDir/filter_hub_screen.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/all_hub_list_view_model.dart';

class AllHubScreen extends StatefulWidget {
  const AllHubScreen({super.key});

  @override
  State<AllHubScreen> createState() => _AllHubScreenState();
}

class _AllHubScreenState extends State<AllHubScreen> {

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_){
      final hubListProvider = Provider.of<AllHubViewModel>(context,listen: false);
      hubListProvider.getHubListDataApi(context);
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mobile = Responsive.isMobile(context);
    return Consumer<AllHubViewModel>(
      builder: (context, vm, child) {
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: Sizes.screenWidth * (mobile ? 0.04 : 0.02),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomWidgets.pageHeader(
                title: "Hub Management",
                subtitle:
                "Manage and monitor all delivery hubs across the city",
              ),

              CustomWidgets.verticalSpace(0.04),

              statsSection(vm, mobile),

              CustomWidgets.verticalSpace(0.02),

              const SearchFilterSection(),

              CustomWidgets.verticalSpace(0.03),

              hubTableSection(vm, mobile),
            ],
          ),
        );
      },
    );
  }

  // ===================== STATS =====================

  Widget statsSection(AllHubViewModel vm, bool mobile) {
    final stats = [
      {
        'title': "Total Hubs",
        'value': vm.hubListModel?.data?.summary?.totalHubs.toString(),
        'icon': Icons.hub_outlined,
      },
      {
        'title': "Active Hubs",
        'value': vm.hubListModel?.data?.summary?.activeHubs.toString(),
        'icon': Icons.check_circle_outline,
      },
      {
        'title': "Total Delivery Boys",
        'value': vm.hubListModel?.data?.summary?.totalDeliveryBoys.toString(),
        'icon': Icons.pedal_bike_outlined,
      },
      {
        'title': "Total Active Orders",
        'value': vm.hubListModel?.data?.summary?.totalActiveOrders.toString(),
        'icon': Icons.receipt_long_outlined,
      },
    ];

    return CustomWidgets.statsRow(
      stats: stats,
      isMobile: mobile,
    );
  }

  // ===================== TABLE SECTION =====================

  Widget hubTableSection(AllHubViewModel vm, bool mobile) {
    return CustomWidgets.borderedContainer(
      child: Column(
        children: [
          if (!mobile) hubTableHeader(),
          if (!mobile) CustomWidgets.sectionDivider(),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: vm.hubListModel?.data?.hubs?.length,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              final hub = vm.hubListModel?.data?.hubs?[index];

              return mobile
                  ? hubMobileCard(hub)
                  : hubTableRow(hub);
            },
          ),

          // Padding(
          //   padding:
          //   const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          //   child: paginationSection(vm),
          // ),
        ],
      ),
    );
  }

  // ===================== MOBILE CARD =====================

  Widget hubMobileCard(Hubs? hub) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: hubCell(hub)),
              CustomWidgets.statusBadge(isActive: hub!.status==1?true:false,width: Sizes.screenWidth*0.2),
            ],
          ),

          CustomWidgets.verticalSpace(0.018),

          managerCell(hub),

          CustomWidgets.verticalSpace(0.018),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _mobileMetric("${hub.deliveryBoys}", "Delivery Boys",),
              _mobileMetric("${hub.activeOrders}", "Active Orders",),
            ],
          ),

          CustomWidgets.verticalSpace(0.02),

          Align(
            alignment: Alignment.centerRight,
            child: actionButtons(
                  () => openRightDrawer(
                context,
                ViewHubDetails(name: hub.hubName,id:hub.hubId.toString()),
              ),
                  () => openRightDrawer(context, EditCityDrawer()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mobileMetric(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText.bold(value, fontSize: 16),
        CustomText.medium(
          label,
          fontSize: 12,
          color: const Color(0xFF94A3B8),
        ),
      ],
    );
  }

  // ===================== PAGINATION =====================

  // Widget paginationSection(AllHubViewModel vm) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.end,
  //     children: [
  //       IconButton(
  //         onPressed: vm.currentPage == 1 ? null : vm.previousPage,
  //         icon: const Icon(Icons.chevron_left),
  //       ),
  //       CustomText.medium(
  //         "Page ${vm.currentPage} of ${vm.totalPages}",
  //         fontSize: 13,
  //       ),
  //       IconButton(
  //         onPressed:
  //         vm.currentPage == vm.totalPages ? null : vm.nextPage,
  //         icon: const Icon(Icons.chevron_right),
  //       ),
  //     ],
  //   );
  // }

  // ===================== TABLE HEADER =====================

  Widget hubTableHeader() {
    return CustomWidgets.tableHeader(
      headers: const [
        "HUB DETAILS",
        "MANAGER",
        "WORKFORCE",
        "PERFORMANCE",
        "STATUS",
      ],
      flexValues: const [2, 1, 1, 1, 1],
    );
  }

  // ===================== DESKTOP ROW =====================

  Widget hubTableRow(Hubs? hub) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(flex: 2, child: hubCell(hub)),
          CustomWidgets.horizontalSpace(0.05),
          Expanded(child: managerCell(hub)),
          CustomWidgets.horizontalSpace(0.04),
          Expanded(child: CustomText.medium("${hub!.deliveryBoys} Boys")),
          Expanded(
            child: CustomText.medium("${hub.activeOrders} Active Orders"),
          ),
          Expanded(child: CustomWidgets.statusBadge(isActive: hub.status==1?true:false)),
          actionButtons(
                () => openRightDrawer(
              context,
              ViewHubDetails(name: hub.hubName, id: hub.hubId.toString(),),
            ),
                () => openRightDrawer(context, EditCityDrawer()),
          ),
        ],
      ),
    );
  }

  // ===================== COMMON CELLS =====================

  Widget hubCell(Hubs? hub) {
    return CustomWidgets.hubCell(
      name: hub!.hubName,
      location: hub.address,
    );
  }

  Widget managerCell(Hubs? hub) {
    return CustomWidgets.managerCell(
      name: hub!.managerName,
      phone: hub.managerPhone,
    );
  }

  Widget actionButtons(VoidCallback onView, VoidCallback onEdit) {
    return Row(
      children: [
        CustomWidgets.iconButton(
          icon: Icons.visibility_outlined,
          onPressed: onView,
        ),
        CustomWidgets.horizontalSpace(0.008),
        CustomWidgets.iconButton(
          icon: Icons.edit_outlined,
          onPressed: onEdit,
        ),
      ],
    );
  }
}