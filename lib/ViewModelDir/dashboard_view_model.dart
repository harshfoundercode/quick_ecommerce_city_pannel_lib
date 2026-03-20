import 'package:flutter/foundation.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/tost_msg/custom_snackbar.dart';
import 'package:quick_ecommerce_city_panel_redefined/ModelDir/dashboard_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/RepoDir/dashboard_repo.dart';

class DashboardViewModel with ChangeNotifier {
  final DashboardRepo _dashboardRepo = DashboardRepo();

  DashboardDetailsModel? _dashboardDetailsModel;
  DashboardDetailsModel? get dashboardDetailsModel => _dashboardDetailsModel;

  void setDashboardDataModel(DashboardDetailsModel data) {
    _dashboardDetailsModel = data;
    notifyListeners();
  }

  Future<void> getDashBoardDataApi(context) async {
    _dashboardDetailsModel = null;
    notifyListeners();
    try {
      final value = await _dashboardRepo.dashboardApi();
      int statusCode = value['statusCode'] ?? 0;
      Map<String, dynamic> body = value['body'] ?? {};

      if (statusCode == 200) {
        final dashboardDataModel = DashboardDetailsModel.fromJson(body);
        setDashboardDataModel(dashboardDataModel);
      } else {
        CustomSnackBar.show(
          context,
          message: body["message"],
          title: 'Error',
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
