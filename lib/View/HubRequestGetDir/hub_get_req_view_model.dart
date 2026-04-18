
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/tost_msg/custom_snackbar.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/utils/routes/routes_name.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/DashboardDir/dashboard_content.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/HubRequestGetDir/hub_req_get_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/HubRequestGetDir/hub_req_get_repo.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/ServicesDir/user_view_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/admin_panel_view_model.dart';

class HubReqGetViewModel with ChangeNotifier {
  final _hubReqGetRepo = HubReqGetRepo();

  // ── Main Category ──────────────────────────────────────────────────────────

  HubRequestListModel? _hubRequestListModel;
  HubRequestListModel? get hubRequestListModel =>
      _hubRequestListModel;

  void setHubRequestListModel(HubRequestListModel data) {
    _hubRequestListModel = data;
    notifyListeners();
  }

  Future<void> getHubReqGetDataApi(context) async {
    _hubRequestListModel = null;
    notifyListeners();
    final userPref = Provider.of<UserViewModel>(context, listen: false);
    final authModel = await userPref.getUser();
    final data = {
      "citymanagerid": authModel.id.toString()
    };
    try {
      final value = await _hubReqGetRepo.getHubReqListApi(data);
      int statusCode = value['statusCode'] ?? 0;
      Map<String, dynamic> body = value['body'] ?? {};

      if (statusCode == 200) {
        final model = HubRequestListModel.fromJson(body);
        setHubRequestListModel(model);
      } else {
        CustomSnackBar.show(context,
            message: body["message"], title: 'Error', type: SnackBarType.error);
      }
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }



  /// ======== ACCEPT HUB GET REQ API =================

  bool _addLoading = false;
  bool get addLoading => _addLoading;

  void _setAddLoading(bool value) {
    _addLoading = value;
    notifyListeners();
  }

  Future<void> acceptHubRequestApi( BuildContext context,String id) async {
    if (!context.mounted) return;
    _setAddLoading(true);
    final data = {
      "request_id": id
    };
    try {
      final response = await _hubReqGetRepo.acceptHubGetInventoryApi(data);

      final statusCode = response['statusCode'] ?? 0;
      final body = response['body'] ?? {};

      if (statusCode == 200 || statusCode == 201) {
        if (!context.mounted) return;

        CustomSnackBar.show(
          context,
          message: body['message'] ?? 'Request Successful',
          title: 'Success',
          type: SnackBarType.success,
        );
        final adminVM = Provider.of<AdminViewModel>(context, listen: false);
        adminVM.changeScreen(const DashboardContent(), 0);
        Navigator.pushNamedAndRemoveUntil(
          context,
          RoutesName.adminSliderLayoutScreen,
              (route) => false,
        );
      } else {
        CustomSnackBar.show(
          context,
          message: body['message'] ?? 'Request Failed',
          title: 'Oh Snap!',
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      if (kDebugMode) print('❌ request error: $e');
      if (context.mounted) {
        CustomSnackBar.show(
          context,
          message: 'Something went wrong',
          title: 'Oh Snap!',
          type: SnackBarType.warning,
        );
      }
    } finally {
      _setAddLoading(false);
    }
  }
}