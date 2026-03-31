import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/tost_msg/custom_snackbar.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/utils/routes/routes_name.dart';
import 'package:quick_ecommerce_city_panel_redefined/RepoDir/hub_zone_create_repo.dart';

class HubManagerEditViewModel extends ChangeNotifier {
  final HubZoneCreateRepo _editManagerRepo = HubZoneCreateRepo();

  bool _editMangerLoading = false;
  bool get editMangerLoading => _editMangerLoading;

  void _setEditZoneLoading(bool value) {
    _editMangerLoading = value;
    notifyListeners();
  }

  Future<void> hubManagerEditApi(
    BuildContext context,
    String id,
    String hubZoneId,
    String name,
    String phone,
    String adharno,
    String address,
    String panno,
    String img,
    String email,
    String password,
  ) async {
    if (!context.mounted) return;

    _setEditZoneLoading(true);

    final data = {
      "id": id,
      "hubzoneid": hubZoneId,
      "name": name,
      "phone": phone,
      "address": address,
      "adharno": adharno,
      "panno": panno,
      "img": img,
      "email": email,
      "password": password,
    };
    print({
      "id": id,
      "hubzoneid": hubZoneId,
      "name": name,
      "phone": phone,
      "address": address,
      "adharno": adharno,
      "panno": panno,
      "img": img,
      "email": email,
      "password": password,
    });
    print("sgdv");
    try {
      final response = await _editManagerRepo.hubManagerEditApi(data);

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
          message: body['message'] ?? 'Edit Manager Details Successful',
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
          message: body['message'] ?? 'Edit Manager Details Failed',
          title: 'Oh Snap!',
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      if (kDebugMode) print('❌ Edit Manager Details error: $e');
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
