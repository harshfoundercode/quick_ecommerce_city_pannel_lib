import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quick_ecommerce_city_panel_redefined/View/OrderDir/order_list_new.dart';



class NotificationService {
  final GlobalKey<NavigatorState> navigatorKey;
  NotificationService({required this.navigatorKey});

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // request notification permission
  Future<void> requestedNotificationPermission() async {
    await Permission.notification.request();
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('user granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint('user provisional granted permission');
    } else {
      debugPrint(
        "notification permission denied\n please allow notification to recieve call's",
      );
      Future.delayed(Duration(seconds: 2), () {
        AppSettings.openAppSettings(type: AppSettingsType.notification);
      });
    }
  }

  // get fcm(device) token
  Future<String> getDeviceToken() async {
    // NotificationSettings settings =
    await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
    String? token = await messaging.getToken();
    debugPrint("token:$token");
    return token!;
  }

  void initLocalNotification(
    BuildContext context,
    RemoteMessage massage,
  ) async {
    var androidInitSetting = AndroidInitializationSettings(
      "@mipmap/ic_launcher",
    );
    var iosInitSetting = DarwinInitializationSettings();

    var initializationSettings = InitializationSettings(
      android: androidInitSetting,
      iOS: iosInitSetting,
    );
    await _flutterLocalNotificationsPlugin.initialize(
      onDidReceiveNotificationResponse: (payload) {
        handleMassage(massage, context);
      }, settings: initializationSettings,
    );
  }

  // firebase init
  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((massage) {
      RemoteNotification? notification = massage.notification;
      AndroidNotification? android = massage.notification!.android;
      if (kDebugMode) {
        print("Notification title:${notification!.title}");
        print("Notification body:${notification.body}");
        print("Notificationn Data: ${massage.data}");
      }
      if (Platform.isAndroid) {
        initLocalNotification(context, massage);
        // handleMassage(context, massage);
        showNotification(massage);
      }
    });
  }

  // function to show notification
  Future<void> showNotification(RemoteMessage massage) async {
    // final player = FlutterRingtonePlayer();
    // player.playRingtone();
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      massage.notification!.android!.channelId.toString(),
      massage.notification!.android!.channelId.toString(),
      importance: Importance.high,
      showBadge: true,
      playSound: true,
    );
    // android setting
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          channel.id.toString(),
          channel.name.toString(),
          channelDescription: "Channel Description",
          importance: Importance.high,
          priority: Priority.high,
          fullScreenIntent: true,
          timeoutAfter: 60000,
          visibility: NotificationVisibility.public,
          playSound: true,
          sound: channel.sound,
        );
    // ios setting
    DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );
    // marge-setting
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );
    //show notification
    Future.delayed(Duration.zero, () {
      _flutterLocalNotificationsPlugin.show(
          id: 0,
        title: massage.notification!.title.toString(),
        body: massage.notification!.body.toString(),
        notificationDetails: notificationDetails,
        payload: "send data"
      );
    });
  }

  // background and terminated
  Future<void> setupInteractMassage(BuildContext context) async {
    // background state
    FirebaseMessaging.onMessageOpenedApp.listen((massage) {
      handleMassage(massage, context);
      debugPrint("Notification tapped (background):");
      debugPrint("Data: ${massage.data}");
    });
    // terminated state
    FirebaseMessaging.instance.getInitialMessage().then((
      RemoteMessage? massage,
    ) {
      if (massage != null && massage.data.isNotEmpty) {
        handleMassage(massage, context);
        debugPrint("Notification tapped (terminated):");
        debugPrint("Data: ${massage.data}");
      }
    });
  }

  Future<void> handleMassage(RemoteMessage message, BuildContext context) async {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => OrderListScreen(),
        ),
      );
    }

}
