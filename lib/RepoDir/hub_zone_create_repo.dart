import 'package:flutter/foundation.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/api_url.dart';
import 'package:quick_ecommerce_city_panel_redefined/helper/network/network_api_service.dart';


class HubZoneCreateRepo {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<dynamic> hubZoneCreateApi(dynamic data) async {
    await _apiServices.initializeToken();
    try {
      dynamic response = await _apiServices.getPostApiResponse(ApiUrl.hubZoneCreateUrl, data);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during hubZoneCreateUrl: $e');
      }
      rethrow;
    }
  }

  Future<dynamic> hubZoneEditApi(dynamic data) async {
    await _apiServices.initializeToken();
    try {
      dynamic response = await _apiServices.getPostApiResponse(ApiUrl.hubZoneEditUrl, data);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during hubZoneEditUrl: $e');
      }
      rethrow;
    }
  }
  Future<dynamic> hubManagerEditApi(dynamic data) async {
    await _apiServices.initializeToken();
    try {
      dynamic response = await _apiServices.getPostApiResponse(ApiUrl.hubManagerEditUrl, data);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during hubManagerEditUrl: $e');
      }
      rethrow;
    }
  }
}

