import 'package:flutter/foundation.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/api_url.dart';
import 'package:quick_ecommerce_city_panel_redefined/helper/network/network_api_service.dart';

class HubPerformanceRepo {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<dynamic> hubPerformanceApi() async {
    await _apiServices.initializeToken();
    try {
      dynamic response = await _apiServices.getGetApiResponse(ApiUrl.hubPerformanceUrl);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during hubPerformanceUrl api: $e');
      }
      rethrow;
    }
  }

  Future<dynamic> hubPerformanceOrderListApi(String hubId) async {
    await _apiServices.initializeToken();
    try {
      dynamic response = await _apiServices.getGetApiResponse(ApiUrl.hubPerformanceOrderListUrl(hubId));
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during hubPerformanceOrderListUrl api: $e');
      }
      rethrow;
    }
  }

  Future<dynamic> hubPerformanceViewOrderListApi(String orderId) async {
    await _apiServices.initializeToken();
    try {
      dynamic response = await _apiServices.getGetApiResponse(ApiUrl.hubPerformanceViewOrderDetailsUrl(orderId));
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during hubPerformanceViewOrderDetailsUrl api: $e');
      }
      rethrow;
    }
  }
}

