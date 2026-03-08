import 'package:flutter/foundation.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/api_url.dart';
import 'package:quick_ecommerce_city_panel_redefined/helper/network/base_api_service.dart';
import 'package:quick_ecommerce_city_panel_redefined/helper/network/network_api_service.dart';


class HubZoneCreateRepo {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<dynamic> hubZoneCreateApi(dynamic data) async {
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
}

