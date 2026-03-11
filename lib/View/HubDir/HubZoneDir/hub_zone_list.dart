import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/hub_zone_list_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/hub_zone_model_list.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/HubDir/HubZoneDir/hub_zone_card.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/HubDir/HubZoneDir/hub_zone_filters.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/HubDir/HubZoneDir/hub_zone_stats_card.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/hub_zone_list_view_model_new.dart' show HubZoneViewModel;


class HubZoneListScreen extends StatefulWidget {
  const HubZoneListScreen({super.key});

  @override
  State<HubZoneListScreen> createState() => _HubZoneListScreenState();
}

class _HubZoneListScreenState extends State<HubZoneListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_){
      final hubZoneData = Provider.of<HubZoneViewModel>(context,listen: false);
      hubZoneData.getHubZoneListDataApi(context);
    });
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<HubZoneViewModel>().setSearchQuery(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<HubZoneViewModel>(
        builder: (context, hvm, child) {
          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                floating: true,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                automaticallyImplyLeading: false,
                title: const Text(
                  'Hub Zones',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(60),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search zones by name, code, city...',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: Colors.grey.shade500,
                                size: 20,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),

              // Stats Cards
              SliverToBoxAdapter(
                child: const HubZoneStatsCards(),
              ),

              // Filters
              SliverToBoxAdapter(
                child: HubZoneFilters(
                  onStatusChanged: (status) => hvm.setStatusFilter(status),
                  onCityChanged: (city) => hvm.setCityFilter(city),
                ),
              ),

              // Zones List/Grid
              hvm.isLoading
                  ? const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
                  : hvm.hubZones.isEmpty
                  ? SliverFillRemaining(
                child: _buildEmptyState(),
              )
                  : SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final zone = hvm.hubZones[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: index == hvm.hubZones.length - 1 ? 20 : 12,
                      ),
                      child: HubZoneCard(
                        zone: zone,
                        onTap: (){},
                        onEdit: (){},
                        // onTap: () => _navigateToDetail(context, zone),
                        // onEdit: () => _navigateToEditZone(context, zone),
                        onDelete: () => _showDeleteDialog(context, zone.id.toString()),
                        onStatusToggle: (isActive) => _handleStatusToggle(zone, isActive),
                      ),
                    );
                  },
                  childCount: hvm.hubZones.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _handleStatusToggle(HubZoneListData zone, bool isActive) {
    // context.read<HubZoneViewModel>().toggleZoneStatus(zone.id.toString(), isActive);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${zone.name} is now ${isActive ? 'Active' : 'Inactive'}',
        ),
        backgroundColor: isActive ? Colors.green : Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_off_rounded,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Hub Zones Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or add a new zone',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }


  void _showDeleteDialog(BuildContext context, String zoneId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Delete Hub Zone'),
        content: const Text(
          'Are you sure you want to delete this hub zone? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<HubZoneViewModel>().deleteHubZone(zoneId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}