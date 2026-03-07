import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/responsive_sizes.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/text_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/header_widget.dart';

class RevenueCard extends StatefulWidget {
  const RevenueCard({super.key});

  @override
  State<RevenueCard> createState() => _RevenueCardState();
}

class _RevenueCardState extends State<RevenueCard> {
  @override
  Widget build(BuildContext context) {
    final mobileSize = Responsive.isMobile(context);
    return CustomWidgets.cardWrapper(
      height: Sizes.screenHeight*0.49,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomWidgets.hubHeader(
              title: "Revenue Analytics",
              subtitle: "Weekly earning performance",
              titleSize: mobileSize?20:18,
              subtitleSize: mobileSize?15:10
          ),
          CustomWidgets.verticalSpace(0.012),
          Row(
            children: [
              CustomText.bold(
                "₹1,24,500",
                fontSize: 26,
              ),
              CustomWidgets.horizontalSpace(0.03),
              CustomText.semiBold(
                "↑ 12.5%",
                color: ColorConst.primaryGreen,
              ),
            ],
          ),

          Spacer(),
          SizedBox(
            height:Sizes.screenHeight*0.28,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                7,
                    (index) => Container(
                  width: 18,
                  height: 50.0 + (index * 10),
                  decoration: BoxDecoration(
                    color: index == 5
                        ? ColorConst.primaryGreen
                        : ColorConst.primaryGreen.withValues(alpha: .25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}