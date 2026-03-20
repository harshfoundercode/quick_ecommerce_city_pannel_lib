import 'package:flutter/foundation.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/api_url.dart';
import 'package:quick_ecommerce_city_panel_redefined/helper/network/network_api_service.dart';

class DashboardRepo {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<dynamic> dashboardApi() async {
    await _apiServices.initializeToken();
    try {
      dynamic response = await _apiServices.getGetApiResponse(
          ApiUrl.dashboardUrl
      );
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during dashboard Url Api: $e');
      }
      rethrow;
    }
  }
}
