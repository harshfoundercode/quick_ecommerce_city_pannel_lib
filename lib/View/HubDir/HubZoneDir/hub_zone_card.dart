import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/hub_zone_list_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/HubDir/HubZoneDir/hub_zone_map_popup.dart';


class HubZoneCard extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final HubZoneListData zone;

  const HubZoneCard({
    super.key,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.zone,

  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    // Icon/Image
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            zone.statuss.color.withValues(alpha:0.1),
                            zone.statuss.color.withValues(alpha:0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.location_city_rounded,
                        color: zone.statuss.color,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  zone.name.toString(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ),
                              // Status Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: zone.statuss.color.withValues(alpha:0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      zone.statuss.icon,
                                      size: 12,
                                      color: zone.statuss.color,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      zone.statuss.displayName,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: zone.statuss.color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const SizedBox(width: 12),
                              _buildInfoChip(
                                Icons.radio_button_unchecked,
                                '${zone.radiuskm} km',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                Center(
                  child: _buildActionButton(
                    icon: Icons.map_rounded,
                    label: 'View Map',
                    color: Colors.blue,
                    onPressed: () => _showMapPopup(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMapPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha:0.5),
      builder: (context) => Dialog(backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: HubZoneMapPopup(
          zone: zone,
          onEdit: onEdit,
        ),
      ),
    );
  }
}