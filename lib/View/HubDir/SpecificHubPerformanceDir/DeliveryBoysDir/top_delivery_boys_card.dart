import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/text_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/dialog_box.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/header_widget.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/HubDir/SpecificHubPerformanceDir/DeliveryBoysDir/view_all_delivery_boy_screen.dart';

class TopDeliveryBoysCard extends StatefulWidget {
  const TopDeliveryBoysCard({super.key});

  @override
  State<TopDeliveryBoysCard> createState() => TopDeliveryBoysCardState();
}

class TopDeliveryBoysCardState extends State<TopDeliveryBoysCard> {
  @override
  Widget build(BuildContext context) {
    return CustomWidgets.cardWrapperWithOptional(
      title: "Top Delivery Boys",
      actionText: "View All Directory",
      onTap: () {
        openRightDrawer(context, DeliveryBoysDirectoryScreen());
      },
      child: Column(
        children: [
          deliveryBoyTile(
            name: "Rahul Sharma",
            subtitle: "Active • 1.2km away",
            deliveries: "142",
          ),
          SizedBox(height: 12),
          deliveryBoyTile(
            name: "Amit Kumar",
            subtitle: "Active • Hub Station",
            deliveries: "128",
          ),
          SizedBox(height: 12),
          deliveryBoyTile(
            name: "Suresh Yadav",
            subtitle: "Active • 3.4km away",
            deliveries: "115",
          ),
        ],
      ),
    );
  }

  Widget deliveryBoyTile({
    required final String name,
    required final String subtitle,
    required final String deliveries,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xffF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          /// Avatar
          const CircleAvatar(radius: 22, backgroundColor: Colors.grey),

          const SizedBox(width: 12),

          /// Name + status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText.semiBold(name, fontSize: 14),
                const SizedBox(height: 2),
                CustomText.medium(subtitle, fontSize: 12, color: Colors.grey),
              ],
            ),
          ),

          /// Deliveries
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CustomText.bold(deliveries, fontSize: 16, color: Colors.green),
              CustomText.medium("Deliveries", fontSize: 11, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }
}
