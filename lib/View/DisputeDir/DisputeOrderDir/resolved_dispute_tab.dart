import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/dispute_view_model.dart';

class ResolvedDisputeTab extends StatefulWidget {
  final DisputeViewModel vm;
  const ResolvedDisputeTab({super.key, required this.vm});

  @override
  State<ResolvedDisputeTab> createState() => _ResolvedDisputeTabState();
}

class _ResolvedDisputeTabState extends State<ResolvedDisputeTab> {

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha:0.02),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    final resolved = widget.vm.disputes.where((d) => d.status == "Resolved").toList();

    return Column(
      children: [
        // Resolution Stats
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _boxDecoration(),
          child: Row(
            children: [
              _buildResolutionStat("Today", 8, Colors.green),
              const SizedBox(width: 20),
              _buildResolutionStat("This Week", 24, Colors.blue),
              const SizedBox(width: 20),
              _buildResolutionStat("This Month", 62, Colors.orange),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Resolved List
        Expanded(
          child: Container(
            decoration: _boxDecoration(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: resolved.length,
              itemBuilder: (context, index) {
                return _buildResolvedCard(resolved[index]);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResolutionStat(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResolvedCard(DisputeModel dispute) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withValues(alpha:0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dispute.id,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${dispute.customerName} • ${dispute.hubName}",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "Resolved: ${_formatDate(dispute.lastUpdated)}",
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha:0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded, size: 14, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    dispute.resolution ?? "Issue resolved successfully",
                    style: const TextStyle(
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

}
