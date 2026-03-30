import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/api_url.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/profile_view_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/helper/network/network_api_service.dart';


class HubZoneListRepo {
  final NetworkApiServices _apiServices = NetworkApiServices();

  Future<dynamic> hubZoneListApi(context) async {
    await _apiServices.initializeToken();
    final profileData = Provider.of<ProfileViewModel>(context,listen: false);
    final data = {
      "cityzoneid":profileData.profileData?.data?.cityzoneid.toString()
    };
    print("sdjshdgj");
    try {
      dynamic response = await _apiServices.getPostApiResponse(ApiUrl.hubZoneListUrl,data);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during hubZoneList api: $e');
      }
      rethrow;
    }
  }
}

