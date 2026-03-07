// import 'package:flutter/material.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ConstDir/app_button.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ConstDir/text_const.dart';
// import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/header_widget.dart';
// import 'package:quick_ecommerce_city_panel_redefined/View/HubDir/SpecificHubPerformanceDir/DesputeDir/despute_screen.dart' show RecentDisruptionsCard;
// import 'package:quick_ecommerce_city_panel_redefined/View/HubDir/SpecificHubPerformanceDir/DeliveryBoysDir/top_delivery_boys_card.dart' show TopDeliveryBoysCard;
//
//
// class ViewHubDetails extends StatefulWidget {
//   final String name;
//   const ViewHubDetails({super.key, required this.name});
//
//   @override
//   State<ViewHubDetails> createState() => _ViewHubDetailsState();
// }
//
// class _ViewHubDetailsState extends State<ViewHubDetails> {
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.white,
//       child: SingleChildScrollView(
//         padding: EdgeInsets.all(Sizes.screenWidth * 0.015),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             AppBackBtn(color: Colors.black,),
//             CustomWidgets.verticalSpace(0.02),
//             CustomWidgets.pageHeader(
//               title: widget.name,
//               subtitle: "Performance Metrics",
//             ),
//
//             CustomWidgets.verticalSpace(0.025),
//
//             statsSection(),
//
//             CustomWidgets.verticalSpace(0.025),
//
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children:  [
//                 Expanded(flex: 3, child: orderVolumeCard()),
//                 SizedBox(width: 20),
//                 Expanded(flex: 1, child: keyIndicatorCard()),
//               ],
//             ),
//
//             CustomWidgets.verticalSpace(0.025),
//
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children:  [
//                 Expanded(flex: 2, child: TopDeliveryBoysCard()),
//                 SizedBox(width: 20),
//                 Expanded(flex: 1, child: RecentDisruptionsCard()),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget statsSection() {
//     final stats = [
//       {
//         'title': "Completed Deliveries",
//         'value': "1,248",
//         'icon': Icons.check_circle_outline,
//       },
//       {
//         'title': "Success Rate",
//         'value': "94.2%",
//         'icon': Icons.analytics_outlined,
//       },
//       {
//         'title':"Avg. Delivery Time",
//         'value': "28m",
//         'icon': Icons.timer_outlined,
//       },
//       {
//         'title':"Cancellation Rate",
//         'value': "3.8%",
//         'icon': Icons.cancel_outlined,
//       },
//     ];
//
//     return CustomWidgets.statsRow(stats: stats, isMobile: true);
//   }
//
//   Widget orderVolumeCard(){
//     return CustomWidgets.cardWrapperWithOptional(
//       onTap: () {  },
//       title: "Order Volume & Completion",
//       child: Container(
//         height: 260,
//         alignment: Alignment.center,
//         child: const Text("📊 Chart goes here"),
//       ),
//     );
//   }
//
//
//
//   Widget keyIndicatorCard() {
//     return CustomWidgets.cardWrapperWithOptional(
//       onTap: () {  },
//       title: "Key Indicators",
//       child: Column(
//         children: [
//           indicatorRow(
//             title: "On-time Delivery",
//             value: 0.88,
//             color: Colors.blue,
//           ),
//           indicatorRow(
//             title: "Customer Rating",
//             value: 0.92,
//             color: Colors.amber,
//           ),
//           indicatorRow(
//             title: "Hub Capacity",
//             value: 0.74,
//             color: Colors.green,
//           ),
//           indicatorRow(
//             title: "Boy Availability",
//             value: 0.65,
//             color: Colors.purple,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget indicatorRow({
//     required String title,
//     required double value,
//     required Color color,
//   }) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: 16),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               CustomText.medium(title, fontSize: 13),
//               Row(
//                 children: [
//                   CustomText.semiBold(
//                     "${(value * 100).round()}%",
//                     fontSize: 14,
//                     color: color,
//                   ),
//                    SizedBox(width: 4),
//                   Container(
//                     padding: const EdgeInsets.all(2),
//                     decoration: BoxDecoration(
//                       color: value >= 0.8 ? Colors.green : Colors.orange,
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       value >= 0.8 ? Icons.check : Icons.priority_high,
//                       size: 10,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           CustomWidgets.verticalSpace(0.01),
//           Stack(
//             children: [
//               Container(
//                 height: 8,
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade200,
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//               ),
//               FractionallySizedBox(
//                 widthFactor: value,
//                 child: Container(
//                   height: 8,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [color.withValues(alpha:0.7), color],
//                     ),
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/app_button.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/responsive_sizes.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/text_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/header_widget.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/HubDir/SpecificHubPerformanceDir/DesputeDir/despute_screen.dart'
    show RecentDisruptionsCard;
import 'package:quick_ecommerce_city_panel_redefined/View/HubDir/SpecificHubPerformanceDir/DeliveryBoysDir/top_delivery_boys_card.dart'
    show TopDeliveryBoysCard;

class ViewHubDetails extends StatefulWidget {
  final String name;
  const ViewHubDetails({super.key, required this.name});

  @override
  State<ViewHubDetails> createState() => _ViewHubDetailsState();
}

class _ViewHubDetailsState extends State<ViewHubDetails> {
  @override
  Widget build(BuildContext context) {
    final mobile = Responsive.isMobile(context);

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
              title: widget.name,
              subtitle: "Performance Metrics",
            ),

            CustomWidgets.verticalSpace(0.025),

            statsSection(mobile),

            CustomWidgets.verticalSpace(0.025),

            mobile
                ? Column(
              children: [
                orderVolumeCard(),
                const SizedBox(height: 16),
                keyIndicatorCard(),
              ],
            )
                : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: orderVolumeCard()),
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

  // ===================== STATS =====================

  Widget statsSection(bool mobile) {
    final stats = [
      {
        'title': "Completed Deliveries",
        'value': "1,248",
        'icon': Icons.check_circle_outline,
      },
      {
        'title': "Success Rate",
        'value': "94.2%",
        'icon': Icons.analytics_outlined,
      },
      {
        'title': "Avg. Delivery Time",
        'value': "28m",
        'icon': Icons.timer_outlined,
      },
      {
        'title': "Cancellation Rate",
        'value': "3.8%",
        'icon': Icons.cancel_outlined,
      },
    ];

    return CustomWidgets.statsRow(
      stats: stats,
      isMobile: mobile,
    );
  }

  // ===================== CARDS =====================

  Widget orderVolumeCard() {
    return CustomWidgets.cardWrapperWithOptional(
      onTap: () {},
      title: "Order Volume & Completion",
      child: Container(
        height: 260,
        alignment: Alignment.center,
        child: const Text("📊 Chart goes here"),
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