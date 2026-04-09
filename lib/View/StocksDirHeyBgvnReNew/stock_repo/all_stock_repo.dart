import 'package:flutter/foundation.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/api_url.dart';
import 'package:quick_ecommerce_city_panel_redefined/helper/network/network_api_service.dart';

class AllCityStockDataNewRepo {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<dynamic> cityStockNewApi() async {
    await _apiServices.initializeToken();
    try {
      dynamic response = await _apiServices.getGetApiResponse(ApiUrl.cityStockListUrl);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during cityStockList newUrl api: $e');
      }
      rethrow;
    }
  }
}

