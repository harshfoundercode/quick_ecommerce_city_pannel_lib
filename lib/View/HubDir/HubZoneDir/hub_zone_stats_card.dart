import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/hub_zone_list_view_model_new.dart' show HubZoneViewModel;

class HubZoneStatsCards extends StatefulWidget {
  const HubZoneStatsCards({super.key});

  @override
  State<HubZoneStatsCards> createState() => _HubZoneStatsCardsState();
}

class _HubZoneStatsCardsState extends State<HubZoneStatsCards> {
  @override
  Widget build(BuildContext context) {
    return Consumer<HubZoneViewModel>(
      builder: (context, hvm, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              _buildStatCard(
                'Total Zones',
                '${hvm.totalZones}',
                Icons.location_city_rounded,
                const Color(0xFF3B82F6),
              ),
               SizedBox(width: 16),
              _buildStatCard(
                'Active Zones',
                '${hvm.activeZones}',
                Icons.check_circle_rounded,
                const Color(0xFF10B981),
              ),],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}