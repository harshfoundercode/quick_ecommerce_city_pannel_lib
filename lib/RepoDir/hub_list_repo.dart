import 'package:flutter/foundation.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/api_url.dart';
import 'package:quick_ecommerce_city_panel_redefined/helper/network/network_api_service.dart';

class HubListRepo {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<dynamic> hubListApi() async {
    await _apiServices.initializeToken();
    try {
      dynamic response = await _apiServices.getGetApiResponse(
        ApiUrl.hubListUrl
      );
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during hub list Api: $e');
      }
      rethrow;
    }
  }
  Future<dynamic> hubListDetailsApi(String hubId) async {
    await _apiServices.initializeToken();
    try {
      dynamic response = await _apiServices.getGetApiResponse(
        ApiUrl.hubListDetailsUrl(hubId)
      );
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during hubListDetails Api: $e');
      }
      rethrow;
    }
  }
}
