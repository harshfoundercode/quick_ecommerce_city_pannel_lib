import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/dispute_view_model.dart';

class InProgressDisputeTab extends StatefulWidget {
  final  DisputeViewModel vm;
  const InProgressDisputeTab({super.key, required this.vm});

  @override
  State<InProgressDisputeTab> createState() => _InProgressDisputeTabState();
}

class _InProgressDisputeTabState extends State<InProgressDisputeTab> {

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
    final inProgress = widget.vm.disputes.where((d) => d.status == "In Progress").toList();

    return Column(
      children: [
        // Team Assignment
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _boxDecoration(),
          child: Row(
            children: [
              _buildTeamMember("Support Team", 18, Colors.blue),
              const SizedBox(width: 20),
              _buildTeamMember("Hub Managers", 12, Colors.orange),
              const SizedBox(width: 20),
              _buildTeamMember("Finance Team", 8, Colors.green),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // In Progress List
        Expanded(
          child: Container(
            decoration: _boxDecoration(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: inProgress.length,
              itemBuilder: (context, index) {
                return _buildInProgressCard(inProgress[index]);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTeamMember(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha:0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color.withValues(alpha:0.1),
                shape: BoxShape.circle,
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInProgressCard(DisputeModel dispute) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha:0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.blue.shade50,
                      child: Text(
                        dispute.customerAvatar,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dispute.customerName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            dispute.issueType,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    dispute.assignedTo,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Progress: 60%",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: 0.6,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time_rounded, size: 12, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    "Last updated: ${_formatTimeAgo(dispute.lastUpdated)}",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  String _formatTimeAgo(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inMinutes < 60) {
      return "${difference.inMinutes}m ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}h ago";
    } else {
      return "${difference.inDays}d ago";
    }
  }
}
