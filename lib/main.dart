import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/const_color.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/size_const.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/utils/routes/routes.dart';
import 'package:quick_ecommerce_city_panel_redefined/ConstDir/utils/routes/routes_name.dart';
import 'package:quick_ecommerce_city_panel_redefined/ViewModelDir/ServicesDir/user_view_model.dart';
import 'package:quick_ecommerce_city_panel_redefined/activity_tracker.dart';
import 'package:quick_ecommerce_city_panel_redefined/provider_home.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
String? fcmToken;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  // // 🔹 Get FCM Token
  // fcmToken = await FirebaseMessaging.instance.getToken();
  // if (kDebugMode) {
  //   print("✅ FCM Token: $fcmToken");
  // }
  final userVM = UserViewModel();
  await userVM.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  // final notificationService = NotificationService(navigatorKey: navigatorKey);
  //
  // @override
  // void initState() {
  //   super.initState();
  //   notificationService.requestedNotificationPermission();
  //   notificationService.firebaseInit(context);
  //   notificationService.setupInteractMassage(context);
  // }


  @override
  Widget build(BuildContext context) {
    Sizes.init(context);

    return MultiProvider(
      providers: ProvidersHome().providers,
      child: ActivityTracker(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Fasto City Panel',
          theme: ThemeData(
            scaffoldBackgroundColor: ColorConst.bgColor,
            fontFamily: "Poppins",
          ),
          navigatorKey: navigatorKey,
          initialRoute: RoutesName.appInitializer,
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
