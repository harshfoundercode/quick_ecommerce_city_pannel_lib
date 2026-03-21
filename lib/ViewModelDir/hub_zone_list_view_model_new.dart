import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/tost_msg/custom_snackbar.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/hub_zone_list_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/RepoDir/hub_zone_list_repo.dart';

class HubZoneViewModel extends ChangeNotifier {
  List<HubZoneListData> _hubZones = [];
  bool _isLoading = false;
  bool _isGridView = false;

  List<HubZoneListData> get hubZones => _hubZones;
  bool get isLoading => _isLoading;
  bool get isGridView => _isGridView;

  void toggleViewMode() {
    _isGridView = !_isGridView;
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
    _hubZones.insert(0, zone);
    notifyListeners();
  }

  Future<void> updateHubZone(HubZoneListData updatedZone) async {
    final index = _hubZones.indexWhere((z) => z.id == updatedZone.id);
    if (index != -1) {
      _hubZones[index] = updatedZone;
      notifyListeners();
    }
  }

  Future<void> deleteHubZone(String id) async {
    _hubZones.removeWhere((z) => z.id == id);
    notifyListeners();
  }

  // 📊 Statistics
  int get totalZones => _hubZones.length;

  int get activeZones =>
      _hubZones.where((z) => z.status == HubZoneStatus.active).length;

  double get averageCoverage => _hubZones.isEmpty
      ? 0
      : _hubZones.fold(
      0.0,
          (sum, z) =>
      sum + double.tryParse(z.radiuskm.toString())! // safer
  ) /
      _hubZones.length;

  final _hubZoneListRepo = HubZoneListRepo();

  HubZoneListDataModel? _hubZoneListDataModel;
  HubZoneListDataModel? get hubZoneListDataModel =>
      _hubZoneListDataModel;

  void setHubZoneListDataModel(HubZoneListDataModel data) {
    _hubZoneListDataModel = data;
    notifyListeners();
  }

  Future<void> getHubZoneListDataApi(context) async {
    _isLoading = true;
    notifyListeners();

    try {
      final value = await _hubZoneListRepo.hubZoneListApi(context);
      int statusCode = value['statusCode'] ?? 0;
      Map<String, dynamic> body = value['body'] ?? {};

      if (statusCode == 200) {
        final model = HubZoneListDataModel.fromJson(body);
        _hubZones = model.data ?? [];
        setHubZoneListDataModel(model);
      } else {
        CustomSnackBar.show(
          context,
          message: body["message"],
          title: 'Error',
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      print(e);
    }

    _isLoading = false;
    notifyListeners();
  }
}