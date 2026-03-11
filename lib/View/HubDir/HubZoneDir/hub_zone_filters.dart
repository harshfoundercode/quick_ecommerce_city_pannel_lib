import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/hub_zone_list_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/hub_zone_model_list.dart';

class HubZoneFilters extends StatefulWidget {
  final Function(HubZoneStatus?) onStatusChanged;
  final Function(String) onCityChanged;

  const HubZoneFilters({
    Key? key,
    required this.onStatusChanged,
    required this.onCityChanged,
  }) : super(key: key);

  @override
  State<HubZoneFilters> createState() => _HubZoneFiltersState();
}

class _HubZoneFiltersState extends State<HubZoneFilters> {
  HubZoneStatus? _selectedStatus;
  String _selectedCity = 'All';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter by',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Status Filters
                _buildFilterChip(
                  label: 'All Status',
                  selected: _selectedStatus == null,
                  onSelected: (selected) {
                    setState(() => _selectedStatus = null);
                    widget.onStatusChanged(null);
                  },
                ),
                ...HubZoneStatus.values.map((status) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _buildFilterChip(
                      label: status.displayName,
                      selected: _selectedStatus == status,
                      color: status.color,
                      onSelected: (selected) {
                        setState(() => _selectedStatus = status);
                        widget.onStatusChanged(status);
                      },
                    ),
                  );
                }),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: VerticalDivider(width: 1),
                ),

                // City Filter (you can populate this from ViewModel)
                _buildFilterChip(
                  label: 'All Cities',
                  selected: _selectedCity == 'All',
                  onSelected: (selected) {
                    setState(() => _selectedCity = 'All');
                    widget.onCityChanged('All');
                  },
                ),
                // Add more cities dynamically
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required Function(bool) onSelected,
    Color? color,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: Colors.grey.shade100,
      selectedColor: color?.withOpacity(0.2) ?? const Color(0xFF10B981).withOpacity(0.2),
      checkmarkColor: color ?? const Color(0xFF10B981),
      labelStyle: TextStyle(
        fontSize: 12,
        color: selected ? color ?? const Color(0xFF10B981) : Colors.grey.shade700,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}