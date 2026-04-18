import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/utils/routes/routes.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/utils/routes/routes_name.dart';
import 'package:quick_ecommerce_city_panel_redefined/activity_tracker.dart';
import 'package:quick_ecommerce_city_panel_redefined/main.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return ActivityTracker(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Fasto City Panel',
        theme: ThemeData(
          scaffoldBackgroundColor: ColorConst.bgColor,
          fontFamily: "Poppins",
          useMaterial3: true,
        ),
        navigatorKey: navigatorKey,
        initialRoute: RoutesName.appInitializer,
        builder: (context, child) {
          Sizes.init(context);
          return child!;
        },
        onGenerateRoute: (settings) {
          return CupertinoPageRoute(
            builder: Routers.generateRoute(settings.name!),
            settings: settings,
          );
        },
      ),
    );
  }
}