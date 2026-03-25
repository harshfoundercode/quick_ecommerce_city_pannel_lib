import 'package:flutter/foundation.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/api_url.dart';
import 'package:quick_ecommerce_city_panel_redefined/helper/network/network_api_service.dart';

class CreateZoneRepo {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<dynamic> createZoneApi(dynamic data) async {
    await _apiServices.initializeToken();
    try {
      dynamic response = await _apiServices.getPostApiResponse(
        ApiUrl.createZoneUrl,
        data,
      );
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during createZone Api: $e');
      }
      rethrow;
    }
  }
}
