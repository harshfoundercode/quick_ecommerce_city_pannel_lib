import 'package:flutter/foundation.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/api_url.dart';
import 'package:quick_ecommerce_city_panel_redefined/helper/network/network_api_service.dart';


class OrdersRepo {
  final NetworkApiServices _apiServices = NetworkApiServices();


  Future<dynamic> ordersListApi(dynamic data) async {
    await _apiServices.initializeToken();
    try {
      dynamic response = await _apiServices.getPostApiResponse(ApiUrl.orderListUrl, data);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during orderList api: $e');
      }
      rethrow;
    }
  }
}

