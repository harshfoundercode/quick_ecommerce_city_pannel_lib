import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/utils/routes/routes_name.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/ServicesDir/user_view_model.dart' show UserViewModel;

class SplashServices {

  Future<void> checkAuthentication(BuildContext context) async {
    final userProvider = Provider.of<UserViewModel>(context, listen: false);

    final String? token = await userProvider.getToken();
    final bool isExpired = await userProvider.isSessionExpired();

    if (kDebugMode) {
      print("Token ⭐⭐⭐⭐⭐⭐⭐⭐⭐: $token");
    }


    if (!context.mounted) return;

    if (token == null || token.isEmpty || isExpired) {
      await userProvider.clearToken();

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
