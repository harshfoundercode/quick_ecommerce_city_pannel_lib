import 'package:flutter/material.dart';

class CompletedOrdersList extends StatefulWidget {
  const CompletedOrdersList({super.key});

  @override
  State<CompletedOrdersList> createState() => _CompletedOrdersListState();
}

class _CompletedOrdersListState extends State<CompletedOrdersList> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_rounded, size: 48, color: Colors.green.shade200),
          const SizedBox(height: 16),
          Text(
            "Completed Orders",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}
