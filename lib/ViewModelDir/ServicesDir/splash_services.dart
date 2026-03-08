import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/utils/routes/routes_name.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/ServicesDir/user_view_model.dart' show UserViewModel;



class SplashServices {
  Future<void> checkAuthentication(context) async {
    final userProvider = Provider.of<UserViewModel>(context, listen: false);

    final String? token = await userProvider.getToken();

    await Future.delayed(const Duration(seconds: 3));

    if (kDebugMode) {
      print("Token ⭐⭐⭐⭐⭐⭐⭐⭐⭐: $token");
    }

    if (token == null || token.isEmpty) {
      Navigator.pushReplacementNamed(context, RoutesName.adminLoginScreen);
      return;
    }

    Navigator.pushReplacementNamed(context, RoutesName.adminSliderLayoutScreen);

  }
}
