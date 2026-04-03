import 'package:flutter/foundation.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/tost_msg/custom_snackbar.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/city_zone_list_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/RepoDir/city_zone_list_repo.dart';

class CityZoneListViewModel with ChangeNotifier {
  final _cityZoneListRepo = CityZoneListRepo();

  CityZoneDataModel? _cityZoneDataModel;
  CityZoneDataModel? get cityZoneDataModel => _cityZoneDataModel;

  void setCityZoneDataModel(CityZoneDataModel data) {
    _cityZoneDataModel = data;
    notifyListeners();
  }



  Future<void> getCityZoneDataApi(context) async {
    _cityZoneDataModel = null;
    notifyListeners();
    try {
      final value = await _cityZoneListRepo.cityZoneListApi();
      int statusCode = value['statusCode'] ?? 0;
      Map<String, dynamic> body = value['body'] ?? {};

      if (statusCode == 200) {
        final cityZoneDataModel = CityZoneDataModel.fromJson(body);
        setCityZoneDataModel(cityZoneDataModel);
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
