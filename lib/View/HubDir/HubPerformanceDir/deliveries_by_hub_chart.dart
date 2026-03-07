import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/header_widget.dart';

class DeliveriesChartCard extends StatefulWidget {
  const DeliveriesChartCard({super.key});

  @override
  State<DeliveriesChartCard> createState() => DeliveriesChartCardState();
}

class DeliveriesChartCardState extends State<DeliveriesChartCard> {
  @override
  Widget build(BuildContext context) {
    return CustomWidgets.cardWrapperWithOptional(
      onTap: (){},
      title: "Deliveries by Hub (Top 5)",
      child: Container(
        height: 260,
        alignment: Alignment.center,
        child: const Text("📊 Bar Chart Here"),
      ),
    );
  }
}
