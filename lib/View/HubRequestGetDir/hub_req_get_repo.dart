import 'package:flutter/foundation.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/api_url.dart';
import 'package:quick_ecommerce_city_panel_redefined/helper/network/network_api_service.dart';

class HubReqGetRepo {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<dynamic> getHubReqListApi(dynamic data) async {
    await _apiServices.initializeToken();
    try {
      dynamic response = await _apiServices.getPostApiResponse(ApiUrl.hubGetInventoryRequestListUrl,data);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during hubGetInventoryRequestListUrl api: $e');
      }
      rethrow;
    }
  }

  Future<dynamic> acceptHubGetInventoryApi(dynamic data) async {
    await _apiServices.initializeToken();
    try {
      dynamic response = await _apiServices.getPostApiResponse(ApiUrl.hubGetInventoryAcceptUrl,data);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during hubGetInventoryAcceptUrl api: $e');
      }
      rethrow;
    }
  }
}

