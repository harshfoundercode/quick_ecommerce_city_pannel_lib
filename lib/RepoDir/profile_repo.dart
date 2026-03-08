import 'package:flutter/foundation.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/api_url.dart';
import 'package:quick_ecommerce_city_panel_redefined/helper/network/network_api_service.dart';


class ProfileRepo {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<dynamic> profileApi() async {
    await _apiServices.initializeToken();
    try {
      dynamic response = await _apiServices.getGetApiResponse(ApiUrl.profileUrl);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during profile api: $e');
      }
      rethrow;
    }
  }

  Future<dynamic> hubProfileApi() async {
    await _apiServices.initializeToken();
    try {
      dynamic response = await _apiServices.getGetApiResponse(ApiUrl.hubProfileUrl);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during hubProfileUrl api: $e');
      }
      rethrow;
    }
  }
}

