import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/tost_msg/custom_snackbar.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/hub_zone_list_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/hub_zone_model_list.dart';
import 'package:quick_ecommerce_city_panel_redefined/RepoDir/hub_zone_list_repo.dart';

class HubZoneViewModel extends ChangeNotifier {
  List<HubZoneListData> _hubZones = [];
  List<HubZoneListData> _filteredZones = [];
  bool _isLoading = false;
  String _searchQuery = '';
  HubZoneStatus? _selectedStatus;
  String _selectedCity = 'All';
  bool _isGridView = false;

  List<HubZoneListData> get hubZones => _filteredZones;
  bool get isLoading => _isLoading;
  bool get isGridView => _isGridView;


  // In HubZoneViewModel
  // Future<void> toggleZoneStatus(String zoneId, bool isActive) async {
  //   _isLoading = true;
  //   notifyListeners();
  //
  //   await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call
  //
  //   final index = _hubZones.indexWhere((z) => z.id.toString() == zoneId);
  //   if (index != -1) {
  //     final zone = _hubZones[index];
  //     final updatedZone = zone.copyWith(
  //       status: isActive ? HubZoneStatus.active : HubZoneStatus.inactive,
  //     );
  //     _hubZones[index] = updatedZone;
  //     _applyFilters();
  //   }
  //
  //   _isLoading = false;
  //   notifyListeners();
  // }

  void toggleViewMode() {
    _isGridView = !_isGridView;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
  }

  void setStatusFilter(HubZoneStatus? status) {
    _selectedStatus = status;
    _applyFilters();
  }

  void setCityFilter(String city) {
    _selectedCity = city;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredZones = _hubZones.where((zone) {
      // Search filter
      final matchesSearch = _searchQuery.isEmpty ||
          zone.name!.toLowerCase().contains(_searchQuery);

      // Status filter
      final matchesStatus = _selectedStatus == null || zone.status == _selectedStatus;


      return matchesSearch && matchesStatus;
    }).toList();

    notifyListeners();
  }

  Future<void> refreshZones() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addHubZone(HubZoneListData zone) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));
    _hubZones.insert(0, zone);
    _applyFilters();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateHubZone(HubZoneListData updatedZone) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));
    final index = _hubZones.indexWhere((z) => z.id == updatedZone.id);
    if (index != -1) {
      _hubZones[index] = updatedZone;
      _applyFilters();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteHubZone(String id) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));
    _hubZones.removeWhere((z) => z.id == id);
    _applyFilters();

    _isLoading = false;
    notifyListeners();
  }

  // Statistics
  int get totalZones => _hubZones.length;
  int get activeZones => _hubZones.where((z) => z.status == HubZoneStatus.active).length;
  double get averageCoverage => _hubZones.isEmpty
      ? 0
      : _hubZones.fold(0.0, (sum, z) => sum + int.parse(z.radiuskm.toString())) / _hubZones.length;

  final _hubZoneListRepo = HubZoneListRepo();

  HubZoneListDataModel? _hubZoneListDataModel;
  HubZoneListDataModel? get hubZoneListDataModel => _hubZoneListDataModel;

  void setHubZoneListDataModel(HubZoneListDataModel data) {
    _hubZoneListDataModel = data;
    notifyListeners();
  }

  Future<void> getHubZoneListDataApi(context) async {
    _hubZoneListDataModel = null;
    notifyListeners();
    try {
      final value = await _hubZoneListRepo.hubZoneListApi();
      int statusCode = value['statusCode'] ?? 0;
      Map<String, dynamic> body = value['body'] ?? {};

      if (statusCode == 200) {
        final hubZoneListDataModel = HubZoneListDataModel.fromJson(body);
        setHubZoneListDataModel(hubZoneListDataModel);
      } else {
        CustomSnackBar.show(
          context,
          message: body["message"],
          title: 'Error',
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

}