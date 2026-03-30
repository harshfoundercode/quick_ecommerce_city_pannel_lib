import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/utils/routes/routes_name.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/ServicesDir/user_view_model.dart' show UserViewModel;
import 'package:quick_ecommerce_city_panel_redefined/main.dart';

class SplashServices {

  Future<void> checkAuthentication() async {

    final context = navigatorKey.currentContext!;

    final userProvider = Provider.of<UserViewModel>(context, listen: false);
    final String? token = await userProvider.getToken();

    if (kDebugMode) {
      print("Token ⭐⭐⭐⭐⭐⭐⭐⭐⭐: $token");
    }

    if (token == null || token.isEmpty) {
      navigatorKey.currentState!.pushReplacementNamed(
        RoutesName.adminLoginScreen,
      );
      return;
    }

    navigatorKey.currentState!.pushReplacementNamed(
      RoutesName.adminSliderLayoutScreen,
    );
  }
}
