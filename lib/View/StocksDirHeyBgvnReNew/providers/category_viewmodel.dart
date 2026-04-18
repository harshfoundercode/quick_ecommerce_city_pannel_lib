import 'package:flutter/foundation.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/tost_msg/custom_snackbar.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/StocksDirHeyBgvnReNew/models/main_catsubcat_all_data_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/StocksDirHeyBgvnReNew/stock_repo/all_stock_repo.dart';

class AllCityStockDataNewViewModel with ChangeNotifier {
  final _allCityStockListRepo = AllCityStockDataNewRepo();

  CityStocksFullModel? _cityStocksFullModel;

  CityStocksFullModel? get cityStockModel => _cityStocksFullModel;

  void setAllCityStockModel(CityStocksFullModel data) {
    _cityStocksFullModel = data;
    notifyListeners();
  }

  Future<void> getCityStockDataApi(context) async {
    _cityStocksFullModel = null;
    notifyListeners();
    try {
      final value = await _allCityStockListRepo.cityStockNewApi();
      int statusCode = value['statusCode'] ?? 0;
      Map<String, dynamic> body = value['body'] ?? {};

      if (statusCode == 200) {
        final allCityStockDataModel = CityStocksFullModel.fromJson(body);
        setAllCityStockModel(allCityStockDataModel);
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
