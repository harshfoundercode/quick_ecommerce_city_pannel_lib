import 'package:flutter/foundation.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/api_url.dart';
import 'package:quick_ecommerce_city_panel_redefined/helper/network/network_api_service.dart';

class UrgentAddInventoryRepo {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<dynamic> mainCategoryListApi() async {
    await _apiServices.initializeToken();
    try {
      dynamic response = await _apiServices.getGetApiResponse(ApiUrl.mainCategoryListUrl);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during mainCategoryListUrl api: $e');
      }
      rethrow;
    }
  }

  Future<dynamic> categoryFromMainCategoryListApi(dynamic data) async {
    await _apiServices.initializeToken();
    try {
      dynamic response = await _apiServices.getPostApiResponse(ApiUrl.categoryListUrl,data);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during categoryListUrl api: $e');
      }
      rethrow;
    }
  }

  Future<dynamic> requestAddOnInventoryApi(dynamic data) async {
    await _apiServices.initializeToken();
    try {
      dynamic response = await _apiServices.getPostApiResponse(ApiUrl.cityRequestInventoryUrl,data);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during requestAddOnInventory api: $e');
      }
      rethrow;
    }
  }
}

