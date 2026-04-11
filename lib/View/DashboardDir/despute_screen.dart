import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/responsive_sizes.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/text_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/header_widget.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/dashboard_model.dart';

class DisputeCard extends StatefulWidget {
  final List<RecentDisputes>? dashboardRecentDisputeData;

  const DisputeCard({
    super.key,
    required this.dashboardRecentDisputeData,
  });

  @override
  State<DisputeCard> createState() => _DisputeCardState();
}

class _DisputeCardState extends State<DisputeCard> {
  @override
  Widget build(BuildContext context) {
    final hubsDispute = widget.dashboardRecentDisputeData ?? [];

    final showLimited = hubsDispute.length > 3;
    final displayList =
    showLimited ? hubsDispute.take(3).toList() : hubsDispute;

    final mobileSize = Responsive.isMobile(context);

    return CustomWidgets.cardWrapper(
      height: mobileSize
          ? Sizes.screenHeight * 0.5
          : Sizes.screenHeight * 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomWidgets.hubHeader(
            title: "Recent Disputes",
            subtitle: hubsDispute.isEmpty
                ? "No disputes available"
                : "Action required on ${displayList.length} orders",
            titleSize: mobileSize ? 20 : 15,
            subtitleSize: mobileSize ? 15 : 10,
          ),

          CustomWidgets.verticalSpace(0.03),

          /// ✅ EMPTY STATE
          if (hubsDispute.isEmpty)
            _emptyState()

          /// ✅ LIST DATA
          else
            ListView.builder(
              itemCount: displayList.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int i) {
                final item = displayList[i];

                return _disputeItem(
                  title: item.orderNo ?? "N/A",
                  subtitle: "Customer reported an issue",
                  status: "Open",
                  color: Colors.red,
                );
              },
            ),
        ],
      ),
    );
  }

  /// ✅ EMPTY STATE UI
  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 40,
            color: ColorConst.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 10),
          CustomText.semiBold(
            "No Disputes Found",
            color: ColorConst.textSecondary,
            fontSize: 14,
          ),
          const SizedBox(height: 4),
          CustomText.medium(
            "You're all caught up 🎉",
            color: ColorConst.textSecondary.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ],
      ),
    );
  }

  /// ✅ DISPUTE ITEM
  Widget _disputeItem({
    required String title,
    required String subtitle,
    required String status,
    required Color color,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: Sizes.screenHeight * 0.01),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorConst.borderColor),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: color),

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
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: CustomText.semiBold(
              status,
              color: color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}