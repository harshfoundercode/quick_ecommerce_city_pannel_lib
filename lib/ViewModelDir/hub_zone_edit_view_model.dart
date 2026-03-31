import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/tost_msg/custom_snackbar.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/utils/routes/routes_name.dart';
import 'package:quick_ecommerce_city_panel_redefined/RepoDir/hub_zone_create_repo.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/DashboardDir/dashboard_content.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/admin_panel_view_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/hub_zone_list_view_model_new.dart';

class HubZoneEditViewModel extends ChangeNotifier {
  final HubZoneCreateRepo _editZoneRepo = HubZoneCreateRepo();

  bool _editZoneLoading = false;
  bool get editZoneLoading => _editZoneLoading;

  void _setEditZoneLoading(bool value) {
    _editZoneLoading = value;
    notifyListeners();
  }

  Future<void> editZoneApi(
      BuildContext context,
      String id,
      String cityZoneId,
      String name,
      String radiusKm,
      String lat,
      String lng,
      String pincode,
      String address
      ) async {
    if (!context.mounted) return;

    _setEditZoneLoading(true);

    final data = {
      "id": id,
      "cityzoneid": cityZoneId,
      "name": name,
      "address": address,
      "pincode": pincode,
      "radiuskm": radiusKm,
      "lat": lat,
      "long": lng
    };

    try {
      final response = await _editZoneRepo.hubZoneEditApi(data);

      if (!context.mounted) {
        _setEditZoneLoading(false);
        return;
      }

      final statusCode = response['statusCode'] ?? 0;
      final body = response['body'] ?? {};

      if (statusCode == 200 || statusCode == 201) {
        if (!context.mounted) {
          _setEditZoneLoading(false);
          return;
        }
        CustomSnackBar.show(
          context,
          message: body['message'] ?? 'Edit Zone Successful',
          title: 'Success',
          type: SnackBarType.success,
        );
        final hvm = Provider.of<HubZoneViewModel>(context, listen: false);
        hvm.getHubZoneListDataApi(context);
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
          message: body['message'] ?? 'Edit Zone Failed',
          title: 'Oh Snap!',
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      if (kDebugMode) print('❌ Edit Zone error: $e');
      if (context.mounted) {
        CustomSnackBar.show(
          context,
          message: 'Something went wrong',
          title: 'Oh Snap!',
          type: SnackBarType.warning,
        );
      }
    } finally {
      _setEditZoneLoading(false);
    }
  }
}
