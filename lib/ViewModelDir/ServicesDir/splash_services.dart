import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/utils/routes/routes_name.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/ServicesDir/user_view_model.dart' show UserViewModel;
import 'package:quick_ecommerce_city_panel_redefined/main.dart';

class SplashServices {

  Future<void> checkAuthentication(BuildContext context) async {

    final userProvider = Provider.of<UserViewModel>(context, listen: false);
    final String? token = await userProvider.getToken();

    if (kDebugMode) {
      print("Token ⭐⭐⭐⭐⭐⭐⭐⭐⭐: $token");
    }

    if (!context.mounted) return; // ✅ safety

    if (token == null || token.isEmpty) {
      Navigator.pushReplacementNamed(
        context,
        RoutesName.adminLoginScreen,
      );
    } else {
      Navigator.pushReplacementNamed(
        context,
        RoutesName.adminSliderLayoutScreen,
      );
    }
  }
}