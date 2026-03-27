import 'package:flutter/foundation.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/api_url.dart';
import 'package:quick_ecommerce_city_panel_redefined/helper/network/network_api_service.dart';

class HubManagerCreateRepo {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<dynamic> hubManagerCreateApi(dynamic data) async {
    await _apiServices.initializeToken();
    try {
      dynamic response = await _apiServices.getPostApiResponse(
        ApiUrl.hubManagerCreateUrl,
        data,
      );
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during hubZoneCreate Api: $e');
      }
      rethrow;
    }
  }
}
