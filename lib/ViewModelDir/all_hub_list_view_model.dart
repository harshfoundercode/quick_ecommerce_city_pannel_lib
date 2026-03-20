import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/tost_msg/custom_snackbar.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/hub_details_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/RepoDir/hub_list_repo.dart';

import '../ModelDir/hub_list_model.dart';

class AllHubViewModel extends ChangeNotifier {
  final HubListRepo _hubListRepo = HubListRepo();

  final TextEditingController searchController = TextEditingController();

  HubListModel? _hubListModel;
  HubListModel? get hubListModel => _hubListModel;

  void setHubListDataModel(HubListModel data) {
    _hubListModel = data;
    notifyListeners();
  }

  Future<void> getHubListDataApi(BuildContext context) async {
    _hubListModel = null;
    notifyListeners();

    try {
      final value = await _hubListRepo.hubListApi();

      int statusCode = value['statusCode'] ?? 0;
      Map<String, dynamic> body = value['body'] ?? {};

      if (statusCode == 200) {
        final hubListDataModel = HubListModel.fromJson(body);
        setHubListDataModel(hubListDataModel);
      } else {
        CustomSnackBar.show(
          context,
          message: body["message"] ?? "Something went wrong",
          title: 'Error',
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("API ERROR: $e");
      }

      CustomSnackBar.show(
        context,
        message: "Something went wrong",
        title: 'Error',
        type: SnackBarType.error,
      );
    }
  }


  ///=================== HUB LIST DETAILS API ============================

  HubDetailsModel? _hubDetailsModel;
  HubDetailsModel? get hubDetailsModel => _hubDetailsModel;

  void setHubDetailsListModel(HubDetailsModel data){
    _hubDetailsModel = data;
    notifyListeners();
  }

  Future<void> getHubDetailsDataApi(BuildContext context,String hubId) async {
    _hubDetailsModel = null;
    notifyListeners();

    try {
      final value = await _hubListRepo.hubListDetailsApi(hubId);

      int statusCode = value['statusCode'] ?? 0;
      Map<String, dynamic> body = value['body'] ?? {};

      if (statusCode == 200) {
        final hubDetailsDataModel = HubDetailsModel.fromJson(body);
        setHubDetailsListModel(hubDetailsDataModel);
      } else {
        CustomSnackBar.show(
          context,
          message: body["message"] ?? "Something went wrong",
          title: 'Error',
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("API ERROR: $e");
      }

      CustomSnackBar.show(
        context,
        message: "Something went wrong",
        title: 'Error',
        type: SnackBarType.error,
      );
    }
  }


  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}