import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/app_button.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/text_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/widgets/header_widget.dart';

enum DisruptionType { info, warning, danger, resolved }
enum DisruptionStatus { active, investigating, resolved, closed }

class DisruptionLogsScreen extends StatefulWidget {


  const DisruptionLogsScreen({
    super.key,

  });

  @override
  State<DisruptionLogsScreen> createState() => _DisruptionLogsScreenState();
}

class _DisruptionLogsScreenState extends State<DisruptionLogsScreen> {
  String _selectedFilter = "All";
  final List<String> _filterOptions = ["All", "Active", "Investigating", "Resolved"];

  final List<Map<String, dynamic>> _disruptions = [
    {
      'id': 'D001',
      'title': 'High Delay Rate Detected',
      'subtitle': 'Orders taking >45 mins in Sector 8 area. 12 orders affected.',
      'time': '2 hours ago',
      'type': DisruptionType.warning,
      'status': DisruptionStatus.active,
      'affectedOrders': 12,
      'affectedBoys': 3,
      'eta': '30 mins',
      'assignedTo': 'Rahul Sharma',
      'priority': 'High',
      'hub': 'Gomti Nagar',
    },
    {
      'id': 'D002',
      'title': 'Staff Shortage',
      'subtitle': '6 delivery boys marked offline unexpectedly in Hazratganj hub.',
      'time': '4 hours ago',
      'type': DisruptionType.danger,
      'status': DisruptionStatus.investigating,
      'affectedOrders': 24,
      'affectedBoys': 6,
      'eta': '1 hour',
      'assignedTo': 'Priya Singh',
      'priority': 'Critical',
      'hub': 'Hazratganj',
    },
    {
      'id': 'D003',
      'title': 'Vehicle Breakdown',
      'subtitle': '2 delivery bikes reported mechanical issues in Alambagh.',
      'time': '6 hours ago',
      'type': DisruptionType.warning,
      'status': DisruptionStatus.resolved,
      'affectedOrders': 8,
      'affectedBoys': 2,
      'eta': 'Resolved',
      'assignedTo': 'Amit Kumar',
      'priority': 'Medium',
      'hub': 'Alambagh',
    },
    {
      'id': 'D004',
      'title': 'Area Congestion',
      'subtitle': 'Heavy traffic due to local event in Chowk area.',
      'time': '1 day ago',
      'type': DisruptionType.info,
      'status': DisruptionStatus.closed,
      'affectedOrders': 5,
      'affectedBoys': 2,
      'eta': 'Resolved',
      'assignedTo': 'Vikram Yadav',
      'priority': 'Low',
      'hub': 'Chowk',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SizedBox(
        width: Sizes.screenWidth * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),

            Expanded(
              child: Padding(
                padding: EdgeInsets.all(Sizes.screenWidth * 0.015),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Stats
                    _buildSummaryStats(),

                    CustomWidgets.verticalSpace(0.02),

                    // Filter Bar
                    _buildFilterBar(),

                    CustomWidgets.verticalSpace(0.02),

                    // Logs List
                    Expanded(
                      child: _buildLogsList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(Sizes.screenWidth * 0.015),
      decoration: BoxDecoration(
        color: ColorConst.primaryExtraLightGreen,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        )
            ,
        border: const Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ColorConst.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: ColorConst.primaryGreen,
              size: 24,
            ),
          ),

          CustomWidgets.horizontalSpace(0.015),

          // Title and Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText.bold(
                  "Disruption Logs",
                  fontSize: 18 ,
                ),
                CustomText.medium(
                 "Monitor operational issues and alerts across all hubs",
                  fontSize: 12,
                  color: ColorConst.textGrey,
                ),
              ],
            ),
          ),

            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.close, size: 18),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryStats() {
    final activeCount = _disruptions.where((d) => d['status'] == DisruptionStatus.active).length;
    final investigatingCount = _disruptions.where((d) => d['status'] == DisruptionStatus.investigating).length;
    final resolvedCount = _disruptions.where((d) => d['status'] == DisruptionStatus.resolved).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            label: "Active",
            value: activeCount.toString(),
            icon: Icons.circle,
            color: Colors.red,
          ),
          _buildStatItem(
            label: "Investigating",
            value: investigatingCount.toString(),
            icon: Icons.search,
            color: Colors.orange,
          ),
          _buildStatItem(
            label: "Resolved",
            value: resolvedCount.toString(),
            icon: Icons.check_circle,
            color: Colors.green,
          ),
          _buildStatItem(
            label: "Total",
            value: _disruptions.length.toString(),
            icon: Icons.warning,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText.bold(value, fontSize: 16, color: color),
            CustomText.medium(label, fontSize: 11, color: ColorConst.textGrey),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Row(
      children: [
        // Filter Chips
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filterOptions.map((filter) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: CustomText.medium(filter, fontSize: 12),
                    selected: _selectedFilter == filter,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    backgroundColor: Colors.white,
                    selectedColor: ColorConst.primaryGreen.withValues(alpha:0.1),
                    checkmarkColor: ColorConst.primaryGreen,
                    side: BorderSide(
                      color: _selectedFilter == filter
                          ? ColorConst.primaryGreen
                          : Colors.black12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Refresh Button
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black12),
          ),
          child: IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: () {
              // Refresh data
            },
          ),
        ),

        const SizedBox(width: 8),

        // Export Button
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black12),
          ),
          child: IconButton(
            icon: const Icon(Icons.download_outlined, size: 20),
            onPressed: () {
              // Export logs
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLogsList() {
    final filteredLogs = _selectedFilter == "All"
        ? _disruptions
        : _disruptions.where((d) {
      String status = d['status'].toString().split('.').last;
      return status.toLowerCase().contains(_selectedFilter.toLowerCase());
    }).toList();

    if (filteredLogs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 48,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            CustomText.medium(
              "No disruptions found",
              fontSize: 16,
              color: Colors.grey,
            ),
            const SizedBox(height: 8),
            CustomText.medium(
              "All systems are operating normally",
              fontSize: 12,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: filteredLogs.length,
      itemBuilder: (context, index) {
        final log = filteredLogs[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildEnhancedDisruptionTile(log),
        );
      },
    );
  }

  Widget _buildEnhancedDisruptionTile(Map<String, dynamic> log) {
    final type = log['type'] as DisruptionType;
    final status = log['status'] as DisruptionStatus;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getTypeColor(type).withValues(alpha:0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        shape: Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _getTypeColor(type).withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getTypeIcon(type),
            color: _getTypeColor(type),
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomText.semiBold(
                          log['title'],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildPriorityBadge(log['priority']),
                    ],
                  ),
                  const SizedBox(height: 4),
                  CustomText.medium(
                    log['subtitle'],
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildStatusChip(status),
                const SizedBox(height: 4),
                CustomText.medium(
                  log['time'],
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ],
            ),
          ],
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.black12)),
            ),
            child: Column(
              children: [
                // Impact Summary
                Row(
                  children: [
                    _buildImpactChip(
                      icon: Icons.receipt_outlined,
                      label: "Orders",
                      value: "${log['affectedOrders']} affected",
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    _buildImpactChip(
                      icon: Icons.pedal_bike_outlined,
                      label: "Boys",
                      value: "${log['affectedBoys']} affected",
                      color: Colors.blue,
                    ),
                    const Spacer(),
                    _buildImpactChip(
                      icon: Icons.timer_outlined,
                      label: "ETA",
                      value: log['eta'],
                      color: Colors.purple,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Details Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        icon: Icons.hub_outlined,
                        label: "Hub",
                        value: log['hub'],
                      ),
                    ),
                    Expanded(
                      child: _buildDetailItem(
                        icon: Icons.person_outline,
                        label: "Assigned To",
                        value: log['assignedTo'],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppBtn(
                      width: Sizes.screenWidth*0.1,
                      height: Sizes.screenHeight*0.05,
                      onTap: () {},
                      title:"Investigate",
                      titleColor: ColorConst.white,
                      color: ColorConst.textGrey,
                    ),
                    CustomWidgets.horizontalSpace(0.012),
                    AppBtn(
                      width: Sizes.screenWidth*0.1,
                      height: Sizes.screenHeight*0.05,
                      title: "View Details",
                      onTap: (){},
                      color: ColorConst.primaryGreen,
                    ),
                  ],
                ),
                if (status != DisruptionStatus.resolved && status != DisruptionStatus.closed) ...[
                  const SizedBox(height: 12),

                  // Resolution Timeline
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText.medium(
                                "Resolution Timeline",
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: 0.7,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getTypeColor(type),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        CustomText.semiBold(
                          "70%",
                          fontSize: 12,
                          color: _getTypeColor(type),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color color;
    switch (priority) {
      case 'Critical':
        color = Colors.red;
        break;
      case 'High':
        color = Colors.orange;
        break;
      case 'Medium':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: CustomText.medium(
        priority,
        fontSize: 9,
        color: color,
      ),
    );
  }

  Widget _buildStatusChip(DisruptionStatus status) {
    Color color;
    String text;

    switch (status) {
      case DisruptionStatus.active:
        color = Colors.red;
        text = "Active";
        break;
      case DisruptionStatus.investigating:
        color = Colors.orange;
        text = "Investigating";
        break;
      case DisruptionStatus.resolved:
        color = Colors.green;
        text = "Resolved";
        break;
      case DisruptionStatus.closed:
        color = Colors.grey;
        text = "Closed";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          CustomText.medium(
            text,
            fontSize: 10,
            color: color,
          ),
        ],
      ),
    );
  }

  Widget _buildImpactChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText.medium(label, fontSize: 8, color: color),
              CustomText.semiBold(value, fontSize: 10, color: color),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: ColorConst.textGrey),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText.medium(label, fontSize: 10, color: Colors.grey),
              CustomText.medium(value, fontSize: 12),
            ],
          ),
        ),
      ],
    );
  }

  Color _getTypeColor(DisruptionType type) {
    switch (type) {
      case DisruptionType.info:
        return Colors.blue;
      case DisruptionType.warning:
        return Colors.orange;
      case DisruptionType.danger:
        return Colors.red;
      case DisruptionType.resolved:
        return Colors.green;
    }
  }

  IconData _getTypeIcon(DisruptionType type) {
    switch (type) {
      case DisruptionType.info:
        return Icons.info_outline;
      case DisruptionType.warning:
        return Icons.warning_amber_outlined;
      case DisruptionType.danger:
        return Icons.dangerous_outlined;
      case DisruptionType.resolved:
        return Icons.check_circle_outline;
    }
  }
}