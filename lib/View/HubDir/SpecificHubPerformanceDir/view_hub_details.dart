import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/app_button.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/responsive_sizes.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/text_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/header_widget.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/hub_details_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/HubDir/SpecificHubPerformanceDir/DesputeDir/despute_screen.dart'
    show RecentDisruptionsCard;
import 'package:quick_ecommerce_city_panel_redefined/View/HubDir/SpecificHubPerformanceDir/DeliveryBoysDir/top_delivery_boys_card.dart'
    show TopDeliveryBoysCard;
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/all_hub_list_view_model.dart';

class ViewHubDetails extends StatefulWidget {
  final String name;
  final String id;
  const ViewHubDetails({super.key, required this.name, required this.id});

  @override
  State<ViewHubDetails> createState() => _ViewHubDetailsState();
}

class _ViewHubDetailsState extends State<ViewHubDetails> {

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_){
      final hubDetails = Provider.of<AllHubViewModel>(context,listen: false);
      hubDetails.getHubDetailsDataApi(context, widget.id.toString());
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mobile = Responsive.isMobile(context);

    return Consumer<AllHubViewModel>(
      builder: (context,hdvm,child) {
        final hubDetailsData = hdvm.hubDetailsModel?.data?.hub;
        final performanceDetailsData = hdvm.hubDetailsModel?.data?.performance;
        final driversDetailsData = hdvm.hubDetailsModel?.data?.drivers;

        return Material(
          color: Colors.white,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(
              Sizes.screenWidth * (mobile ? 0.04 : 0.015),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppBackBtn(color: Colors.black),

                CustomWidgets.verticalSpace(0.02),

                CustomWidgets.pageHeader(
                  title: hubDetailsData!.hubName,
                  subtitle: "Performance Metrics",
                ),

                CustomWidgets.verticalSpace(0.025),

                statsSection(mobile,performanceDetailsData),

                CustomWidgets.verticalSpace(0.025),

                mobile
                    ? Column(
                  children: [
                    orderVolumeCard(mobile,hubDetailsData),
                    const SizedBox(height: 16),
                    keyIndicatorCard(),
                  ],
                )
                    : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: orderVolumeCard(mobile,hubDetailsData)),
                    const SizedBox(width: 20),
                    Expanded(flex: 1, child: keyIndicatorCard()),
                  ],
                ),

                CustomWidgets.verticalSpace(0.025),

                /// 🔥 Responsive section 2
                mobile
                    ? Column(
                  children: const [
                    TopDeliveryBoysCard(),
                    SizedBox(height: 16),
                    RecentDisruptionsCard(),
                  ],
                )
                    : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Expanded(flex: 2, child: TopDeliveryBoysCard()),
                    SizedBox(width: 20),
                    Expanded(flex: 1, child: RecentDisruptionsCard()),
                  ],
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  // ===================== STATS =====================

  Widget statsSection(bool mobile, Performance? performanceDetailsData) {
    final stats = [
      {
        'title': "Completed Deliveries",
        'value': "${performanceDetailsData!.completedDeliveries}",
        'icon': Icons.check_circle_outline,
      },
      {
        'title': "Success Rate",
        'value': "${performanceDetailsData.successRate ?? "0"}%",
        'icon': Icons.analytics_outlined,
      },
      {
        'title': "Avg. Delivery Time",
        'value': "${performanceDetailsData.completedDeliveries}m",
        'icon': Icons.timer_outlined,
      },
      {
        'title': "Cancellation Rate",
        'value': "${performanceDetailsData.cancellationRate ?? "0"}%",
        'icon': Icons.cancel_outlined,
      },
    ];

    return CustomWidgets.statsRow(
      stats: stats,
      isMobile: mobile,
    );
  }

  // ===================== CARDS =====================

  Widget orderVolumeCard(bool mobile, Hub hubDetailsData) {
    final stats = [
      {
        'title': "City Name",
        'value': hubDetailsData.cityName ?? "-",
        'icon': Icons.location_city,
      },
      {
        'title': "Address",
        'value': hubDetailsData.address ?? "-",
        'icon': Icons.home,
      },
      {
        'title': "Hub Name",
        'value': hubDetailsData.hubName ?? "-",
        'icon': Icons.warehouse,
      },
      {
        'title': "Manager Phone",
        'value': hubDetailsData.managerPhone ?? "-",
        'icon': Icons.phone,
      },
      {
        'title': "Manager Name",
        'value': hubDetailsData.managerName ?? "-",
        'icon': Icons.person,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 Header
          Row(
            children: [
              Icon(Icons.warehouse, color: ColorConst.primaryGreen),
              const SizedBox(width: 8),
              Text(
                "Hub Details",
                style: TextStyle(
                  fontSize: mobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// 🔹 Grid Data
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stats.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: mobile ? 1 : 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: mobile ? 4 : 5,
            ),
            itemBuilder: (context, index) {
              final stat = stats[index];

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    /// 🔹 Icon Circle
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: ColorConst.primaryExtraLightGreen,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        stat['icon'] as IconData,
                        color: ColorConst.primaryGreen,
                        size: 20,
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// 🔹 Texts
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            stat['title'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            stat['value'] as String,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget keyIndicatorCard() {
    return CustomWidgets.cardWrapperWithOptional(
      onTap: () {},
      title: "Key Indicators",
      child: Column(
        children: [
          indicatorRow(
            title: "On-time Delivery",
            value: 0.88,
            color: Colors.blue,
          ),
          indicatorRow(
            title: "Customer Rating",
            value: 0.92,
            color: Colors.amber,
          ),
          indicatorRow(
            title: "Hub Capacity",
            value: 0.74,
            color: Colors.green,
          ),
          indicatorRow(
            title: "Boy Availability",
            value: 0.65,
            color: Colors.purple,
          ),
        ],
      ),
    );
  }

  // ===================== INDICATOR =====================

  Widget indicatorRow({
    required String title,
    required double value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText.medium(title, fontSize: 13),
              Row(
                children: [
                  CustomText.semiBold(
                    "${(value * 100).round()}%",
                    fontSize: 14,
                    color: color,
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color:
                      value >= 0.8 ? Colors.green : Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      value >= 0.8
                          ? Icons.check
                          : Icons.priority_high,
                      size: 10,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          CustomWidgets.verticalSpace(0.01),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: value,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withValues(alpha: 0.7), color],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}