import 'package:flutter/material.dart';

class AllHubViewModel extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();

  final List<HubModel> _hubs = [
    HubModel(
      id: '1',
      name: 'Hub - Gomti Nagar',
      location: 'Gomti Nagar, Lucknow',
      managerName: 'Rahul Sharma',
      managerPhone: '+91 98765 43210',
      workforce: 12,
      activeOrders: 34,
      isActive: true,
    ),
    HubModel(
      id: '2',
      name: 'Hub - Hazratganj',
      location: 'Hazratganj, Lucknow',
      managerName: 'Priya Singh',
      managerPhone: '+91 98765 43211',
      workforce: 8,
      activeOrders: 22,
      isActive: true,
    ),
    HubModel(
      id: '3',
      name: 'Hub - Alambagh',
      location: 'Alambagh, Lucknow',
      managerName: 'Amit Kumar',
      managerPhone: '+91 98765 43212',
      workforce: 6,
      activeOrders: 15,
      isActive: false,
    ),
    HubModel(
      id: '4',
      name: 'Hub - Chowk',
      location: 'Chowk, Lucknow',
      managerName: 'Vikram Yadav',
      managerPhone: '+91 98765 43213',
      workforce: 10,
      activeOrders: 28,
      isActive: true,
    ),
    HubModel(
      id: '5',
      name: 'Hub - Chowk',
      location: 'Chowk, Lucknow',
      managerName: 'Vikram Yadav',
      managerPhone: '+91 98765 43213',
      workforce: 10,
      activeOrders: 28,
      isActive: true,
    ),

  ];

  List<HubModel> get hubs => _hubs;

  int get totalHubs => _hubs.length;
  int get activeHubs => _hubs.where((h) => h.isActive).length;
  int get totalDeliveryBoys => _hubs.fold(0, (sum, h) => sum + h.workforce);
  int get totalActiveOrders => _hubs.fold(0, (sum, h) => sum + h.activeOrders);

  void onAddHubPressed() {
    // Navigate to add hub screen or show dialog
    debugPrint('Add hub pressed');
  }

  int _currentPage = 1;
  final int _itemsPerPage = 7;

  int get currentPage => _currentPage;
  int get itemsPerPage => _itemsPerPage;

  int get totalPages {
    if (hubs.isEmpty) return 1;
    return (hubs.length / _itemsPerPage).ceil();
  }
  List<HubModel> get paginatedHubs {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;

    if (startIndex >= hubs.length) return [];

    return hubs.sublist(
      startIndex,
      endIndex > hubs.length ? hubs.length : endIndex,
    );
  }
  void nextPage() {
    if (_currentPage < totalPages) {
      _currentPage++;
      notifyListeners();
    }
  }

  void previousPage() {
    if (_currentPage > 1) {
      _currentPage--;
      notifyListeners();
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      _currentPage = page;
      notifyListeners();
    }
  }
  void onFilterPressed() {
    debugPrint('Filter pressed');
  }

  void onSortPressed() {
    debugPrint('Sort pressed');
  }

  void onViewHub(String hubId) {
    debugPrint('View hub: $hubId');

  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}

class HubModel {
  final String id;
  final String name;
  final String location;
  final String managerName;
  final String managerPhone;
  final int workforce;
  final int activeOrders;
  final bool isActive;

  HubModel({
    required this.id,
    required this.name,
    required this.location,
    required this.managerName,
    required this.managerPhone,
    required this.workforce,
    required this.activeOrders,
    required this.isActive,
  });
}