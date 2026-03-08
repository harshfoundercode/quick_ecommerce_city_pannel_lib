import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/utils/routes/routes.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/utils/routes/routes_name.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/ServicesDir/splash_services.dart';
import 'package:quick_ecommerce_city_panel_redefined/provider_home.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final SplashServices _splashServices = SplashServices();

  @override
  void initState() {
    _splashServices.checkAuthentication(context);
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Sizes.init(context);

    return MultiProvider(
      providers: ProvidersHome().providers,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Quick Mart City Panel',
        theme: ThemeData(
          scaffoldBackgroundColor: ColorConst.bgColor,
          fontFamily: "Poppins"
        ),
        navigatorKey: navigatorKey,
        initialRoute: RoutesName.adminLoginScreen,
        onGenerateRoute: (settings) {
          if (settings.name != null) {
            return CupertinoPageRoute(
              builder: Routers.generateRoute(settings.name!),
              settings: settings,
            );
          }
          return null;
        },
        // builder: (context, child) {
        //   final width = MediaQuery.of(context).size.width;
        //
        //   if (width < 800) {
        //     return const NoPreviewScreen();
        //   }
        //
        //   return child!;
        // },

      ),
    );
  }
}

