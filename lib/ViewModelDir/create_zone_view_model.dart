import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/tost_msg/custom_snackbar.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/utils/routes/routes_name.dart';
import 'package:quick_ecommerce_city_panel_redefined/RepoDir/create_zone_repo.dart';

class CreateZoneViewModel extends ChangeNotifier {
  final CreateZoneRepo _createZoneRepo = CreateZoneRepo();

  bool _createZoneLoading = false;
  bool get createZoneLoading => _createZoneLoading;

  void _setCreateZoneLoading(bool value) {
    _createZoneLoading = value;
    notifyListeners();
  }

  Future<void> createZoneApi(BuildContext context,String cityZoneId,String name,String radiusKm,String lat,String lng) async {
    if (!context.mounted) return;

    _setCreateZoneLoading(true);

    final data = {
      "cityzoneid": cityZoneId,
      "name": name,
      "radiuskm": radiusKm,
      "lat": lat,
      "long": lng
    };

    try {
      final response = await _createZoneRepo.createZoneApi(data);

      if (!context.mounted) {
        _setCreateZoneLoading(false);
        return;
      }

      final statusCode = response['statusCode'] ?? 0;
      final body = response['body'] ?? {};

      if (statusCode == 200 || statusCode == 201) {
        if (!context.mounted) {
          _setCreateZoneLoading(false);
          return;
        }
        CustomSnackBar.show(
          context,
          message: body['message'] ?? 'Create Zone Successful',
          title: 'Success',
          type: SnackBarType.success,
        );
        Navigator.pushReplacementNamed(
          context,
          RoutesName.adminSliderLayoutScreen,
        );
      } else {
        CustomSnackBar.show(
          context,
          message: body['message'] ?? 'Create Zone Failed',
          title: 'Oh Snap!',
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      if (kDebugMode) print('❌ Create Zone error: $e');
      if (context.mounted) {
        CustomSnackBar.show(
          context,
          message: 'Something went wrong',
          title: 'Oh Snap!',
          type: SnackBarType.warning,
        );
      }
    } finally {
      _setCreateZoneLoading(false);
    }
  }
}
