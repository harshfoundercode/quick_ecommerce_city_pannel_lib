import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/utils/routes/routes.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/utils/routes/routes_name.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/HubDir/all_hub_list_screen.dart';
import 'package:quick_ecommerce_city_panel_redefined/app_initializer.dart'
    show AppInitializer;
import 'package:quick_ecommerce_city_panel_redefined/provider_home.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    Sizes.init(context);

    return MultiProvider(
      providers: ProvidersHome().providers,
      child: AppInitializer(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Fasto City Panel',
          theme: ThemeData(
            scaffoldBackgroundColor: ColorConst.bgColor,
            fontFamily: "Poppins",
          ),
          navigatorKey: navigatorKey,
          initialRoute: RoutesName.splashScreen,
          onGenerateRoute: (settings) {
            if (settings.name != null) {
              return CupertinoPageRoute(
                builder: Routers.generateRoute(settings.name!),
                settings: settings,
              );
            }
            return null;
          },
        ),
      ),
    );
  }
}
