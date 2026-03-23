import 'package:flutter/foundation.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/api_url.dart';
import 'package:quick_ecommerce_city_panel_redefined/helper/network/network_api_service.dart';

class CityStockListRepo {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<dynamic> cityStockListApi() async {
    await _apiServices.initializeToken();
    try {
      dynamic response = await _apiServices.getGetApiResponse(ApiUrl.cityStockListUrl);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during cityStockListUrl api: $e');
      }
      rethrow;
    }
  }


  Future<dynamic> cityTransferToHubApi(dynamic data) async {
    await _apiServices.initializeToken();
    try {
      dynamic response = await _apiServices.getPostApiResponse(ApiUrl.cityTransferToHubUrl,data);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during cityTransferToHub api: $e');
      }
      rethrow;
    }
  }

  Future<dynamic> cityRequestInventoryApi(dynamic data) async {
    await _apiServices.initializeToken();
    try {
      dynamic response = await _apiServices.getPostApiResponse(ApiUrl.cityRequestInventoryUrl,data);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during cityRequestInventory api: $e');
      }
      rethrow;
    }
  }
}

