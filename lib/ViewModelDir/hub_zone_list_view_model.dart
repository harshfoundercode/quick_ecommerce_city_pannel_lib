import 'package:flutter/foundation.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/tost_msg/custom_snackbar.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/hub_zone_list_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/RepoDir/hub_zone_list_repo.dart';

class HubZoneListViewModel with ChangeNotifier {
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
