import 'package:flutter/material.dart';

class CancelledOrdersList extends StatefulWidget {
  const CancelledOrdersList({super.key});

  @override
  State<CancelledOrdersList> createState() => _CancelledOrdersListState();
}

class _CancelledOrdersListState extends State<CancelledOrdersList> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cancel_rounded, size: 48, color: Colors.red.shade200),
          const SizedBox(height: 16),
          Text(
            "Cancelled Orders",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}