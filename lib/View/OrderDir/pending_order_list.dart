
import 'package:flutter/material.dart';

class PendingOrdersList extends StatefulWidget {
  const PendingOrdersList({super.key});

  @override
  State<PendingOrdersList> createState() => _PendingOrdersListState();
}

class _PendingOrdersListState extends State<PendingOrdersList> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pending_actions_rounded, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            "Pending Orders",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}
