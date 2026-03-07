import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/text_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/dialog_box.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/header_widget.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/HubDir/SpecificHubPerformanceDir/DesputeDir/despute_view_all_screen.dart';

enum DisruptionType { warning, danger }

class RecentDisruptionsCard extends StatefulWidget {
  const RecentDisruptionsCard({super.key});

  @override
  State<RecentDisruptionsCard> createState() => RecentDisruptionsCardState();
}

class RecentDisruptionsCardState extends State<RecentDisruptionsCard> {
  @override
  Widget build(BuildContext context) {
    return CustomWidgets.cardWrapperWithOptional(
      onTap: () {
        openRightDrawer(context, DisruptionLogsScreen());
      },
      title: "Recent Disruptions",
      actionText: "View Logs",
      child: Column(
        children:  [
          disruptionTile(
            title: "High Delay Rate Detected",
            subtitle: "Orders taking >45 mins in Sector 8 area.",
            time: "2 hours ago",
            type: DisruptionType.warning,
          ),
          SizedBox(height: 12),
          disruptionTile(
            title: "Staff Shortage",
            subtitle: "6 delivery boys marked offline unexpectedly.",
            time: "4 hours ago",
            type: DisruptionType.danger,
          ),
        ],
      ),
    );
  }
}
Widget disruptionTile({required final String title, required final String subtitle, required final String time, required  final DisruptionType type}){
  final isDanger = type == DisruptionType.danger;
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: isDanger
          ? const Color(0xffFFF1F1)
          : const Color(0xffFFF7E6),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: isDanger
            ? const Color(0xffF5C2C2)
            : const Color(0xffF3D9A4),
      ),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Icon
        Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            color: isDanger
                ? const Color(0xffFDE2E2)
                : const Color(0xffFFF0C2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isDanger ? Icons.error_outline : Icons.warning_amber_rounded,
            size: 20,
            color: isDanger ? Colors.red : Colors.orange,
          ),
        ),

        const SizedBox(width: 12),

        /// Texts
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText.semiBold(title, fontSize: 13),
              const SizedBox(height: 4),
              CustomText.medium(
                subtitle,
                fontSize: 12,
                color: Colors.grey,
              ),
              const SizedBox(height: 6),
              CustomText.medium(
                time,
                fontSize: 11,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
