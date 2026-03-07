import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/header_widget.dart';

class SuccessRateChartCard extends StatefulWidget {
  const SuccessRateChartCard({super.key});

  @override
  State<SuccessRateChartCard> createState() => _SuccessRateChartCardState();
}

class _SuccessRateChartCardState extends State<SuccessRateChartCard> {
  @override
  Widget build(BuildContext context) {
    return CustomWidgets.cardWrapperWithOptional(
      onTap: (){},
      title: "Success Rate by Hub (Top 5)",
      child: Container(
        height: 260,
        alignment: Alignment.center,
        child: const Text("📊 Bar Chart Here"),
      ),
    );
  }
}
