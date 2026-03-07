import 'package:flutter/material.dart';

class HubManagementViewModel extends ChangeNotifier {
  // ================= DATA =================

  final List<HubModel> _hubs = [
    HubModel(
      name: "Gomti Nagar",
      location: "Gomti Nagar, Lucknow",
      deliveryBoys: 12,
      ordersInProgress: 34,
      completedToday: 87,
      isActive: true,
      icon: Icons.account_tree_outlined,
    ),
    HubModel(
      name: "Hazratganj",
      location: "Hazratganj, Lucknow",
      deliveryBoys: 18,
      ordersInProgress: 42,
      completedToday: 96,
      isActive: true,
      icon: Icons.business_center_outlined,
    ),
    HubModel(
      name: "Alambagh",
      location: "Alambagh, Lucknow",
      deliveryBoys: 8,
      ordersInProgress: 21,
      completedToday: 45,
      isActive: false,
      icon: Icons.store_mall_directory_outlined,
    ),
  ];

  final TextEditingController searchController = TextEditingController();

  // ================= STATE =================

  String _searchQuery = '';
  String _filterStatus = 'All';

  // ================= GETTERS =================

  String get searchQuery => _searchQuery;
  String get filterStatus => _filterStatus;
  List<HubModel> get hubs => _hubs;

  List<HubModel> get filteredHubs {
    return _hubs.where((hub) {
      final matchesSearch =
          hub.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              hub.location.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesStatus = _filterStatus == 'All' ||
          (_filterStatus == 'Active' && hub.isActive) ||
          (_filterStatus == 'Inactive' && !hub.isActive);

      return matchesSearch && matchesStatus;
    }).toList();
  }

  // ================= ACTIONS =================

  void updateSearch(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void updateFilter(String value) {
    _filterStatus = value;
    notifyListeners();
  }

  void addHub(HubModel hub) {
    _hubs.add(hub);
    notifyListeners();
  }
}
class HubModel {
  final String name;
  final String location;
  final int deliveryBoys;
  final int ordersInProgress;
  final int completedToday;
  final bool isActive;
  final IconData icon;

  HubModel({
    required this.name,
    required this.location,
    required this.deliveryBoys,
    required this.ordersInProgress,
    required this.completedToday,
    required this.isActive,
    required this.icon,
  });
}
