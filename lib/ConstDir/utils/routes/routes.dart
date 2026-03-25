import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/utils/routes/routes_name.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/AdminLayoutDir/admin_panel_layout.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/AuthDir/login_screen.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/AuthDir/splash_screen.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/HubDir/SpecificHubPerformanceDir/view_hub_details.dart';

class Routers {
  static WidgetBuilder generateRoute(String routeName) {
    switch (routeName) {
      case RoutesName.adminSliderLayoutScreen:
        return (context) => const AdminMainLayout();
        case RoutesName.splashScreen:
        return (context) => const SplashScreen();
      case RoutesName.viewHubDetailsScreen:
        return (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;
          final name = args?['name'];
          final id = args?['id'];
          return ViewHubDetails(hubName: name, hubId: id,);
        };
      case RoutesName.adminLoginScreen:
        return (context)=>AdminLoginScreen();
      default:
        return (context) => const Scaffold(
          body: Center(
            child: Text(
              'No Route Found!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        );
    }
  }
}
