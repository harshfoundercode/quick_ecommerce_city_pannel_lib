import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/ServicesDir/splash_services.dart';

class AppInitializer extends StatefulWidget {
  final Widget child;
  const AppInitializer({super.key, required this.child});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {

  bool _done = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_){
      if (!_done) {
        _done = true;
        SplashServices().checkAuthentication();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}