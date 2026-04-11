import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/responsive_sizes.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/text_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/header_widget.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/dashboard_model.dart';

class CityCard extends StatefulWidget {
  final Summary? dashboardSummaryData;
  const CityCard({super.key, required this.dashboardSummaryData});

  @override
  State<CityCard> createState() => _CityCardState();
}

class _CityCardState extends State<CityCard> {
  @override
  Widget build(BuildContext context) {
    final mobileSize = Responsive.isMobile(context);
    return Container(
      width: mobileSize ? Sizes.screenWidth * 0.93 : Sizes.screenWidth * 0.44,
      height: mobileSize
          ? Sizes.screenHeight * 0.35
          : Sizes.screenHeight * 0.45,
      padding: EdgeInsets.symmetric(
        horizontal: mobileSize
            ? Sizes.screenWidth * 0.038
            : Sizes.screenWidth * 0.02,
        vertical: mobileSize
            ? Sizes.screenHeight * 0.025
            : Sizes.screenHeight * 0.03,
      ),
      decoration: BoxDecoration(
        color: ColorConst.primaryGreen.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ColorConst.primaryGreen.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(-5, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCityInfo(mobileSize),
          CustomWidgets.verticalSpace(0.02),
          _buildStatsRow(),
        ],
      ),
    );
  }

  Widget _buildCityInfo(bool mobileSize) {
    return CustomText.bold(
      widget.dashboardSummaryData?.cityName ?? "N/n",
      color: Colors.white,
      fontSize: mobileSize ? 25 : 34,
      letterSpacing: 1,
    );
  }


  Widget _buildStatsRow() {
    final verticalDivider = Container(
      height: 40,
      width: 1,
      color: Colors.white.withValues(alpha: 0.2),
    );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            widget.dashboardSummaryData!.totalHubs.toString(),
            "Total Hubs",
            Icons.hub_rounded,
            Colors.white,
          ),
          verticalDivider,
          _buildStatItem(
            widget.dashboardSummaryData!.deliveryBoys.toString(),
            "Delivery Boys",
            Icons.delivery_dining_rounded,
            Colors.white,
          ),
          verticalDivider,
          _buildStatItem(
            widget.dashboardSummaryData!.activeOrders.toString(),
            "Active Orders",
            Icons.local_shipping_rounded,
            Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String value,
    String label,
    IconData icon,
    Color iconColor,
  ) {
    return Column(
      children: [
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.2),
                Colors.white.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        CustomWidgets.verticalSpace(0.01),
        CustomText.bold(value, color: Colors.white, fontSize: 25),
        CustomWidgets.verticalSpace(0.01),
        CustomText.medium(
          label,
          color: Colors.white.withValues(alpha: 0.7),
          fontSize: 10,
        ),
      ],
    );
  }
}
