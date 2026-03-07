import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/responsive_sizes.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/text_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/header_widget.dart';

class DisputeCard extends StatefulWidget {
  const DisputeCard({super.key});

  @override
  State<DisputeCard> createState() => _DisputeCardState();
}

class _DisputeCardState extends State<DisputeCard> {

  @override
  Widget build(BuildContext context) {
    final mobileSize = Responsive.isMobile(context);
    return CustomWidgets.cardWrapper(
      height: mobileSize?Sizes.screenHeight*0.3903:Sizes.screenHeight*0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomWidgets.hubHeader(
            title: "Recent Disputes",
             subtitle:  "Action required on 3 orders",
              titleSize: mobileSize?20:18,
              subtitleSize: mobileSize?15:10
          ),
          CustomWidgets.verticalSpace(0.03),
          ListView.builder(
            itemCount: 3,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context,int i){
            return _disputeItem(
              title: "Order #ORD-5524",
              subtitle: "Customer reported missing items",
              status: "Open",
              color: Colors.red,
            );
          })

        ],
      ),
    );
  }

  Widget _disputeItem({
    required String title,
    required String subtitle,
    required String status,
    required Color color,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: Sizes.screenHeight*0.01),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorConst.borderColor),
      ),
      child: Row(
        children: [
           Icon(Icons.error_outline, color: Colors.red),
           CustomWidgets.horizontalSpace(0.02),
           Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText.semiBold(title),
                CustomText.medium(
                  subtitle,
                  color: ColorConst.textSecondary,
                  fontSize: 12,
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: CustomText.semiBold(
              status,
              color: color,
              fontSize: 12,
            ),
          )
        ],
      ),
    );
  }
}