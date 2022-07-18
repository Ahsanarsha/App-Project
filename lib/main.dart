import 'dart:async';
import 'dart:developer';
import 'package:card_club/resources/cache_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description: "This channel is used for important notifications.",
  // description
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Stripe.instance.applySettings();

  await Firebase.initializeApp();
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'InventoryWhiz',
      theme: ThemeData(
        primarySwatch: Palette.kToDark,
      ),
      home: const MySplashScreen(),
    );
  }
  // child:

}

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({Key? key}) : super(key: key);

  @override
  _MySplashScreen createState() => _MySplashScreen();
}

class _MySplashScreen extends State<MySplashScreen> with CacheManager {
  @override
  void initState() {
    super.initState();

    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                icon: android.smallIcon,
              ),
            ));
      }
    });
    getFCMToken();

    saveGetContactLogic();

    // Timer(
    //   Duration(seconds: 3),
    //   () => checkUserIsLogin(),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFF2CFD4),
      child: Padding(
        padding: EdgeInsets.all(100),
        child: Image(
          image: AssetImage('assets/images/app_icon.png'),
        ),
      ),
    );
  }

  saveGetContactLogic() {
    final saveContactLength = GetStorage();

    saveContactLength.writeIfNull("count", 0);
    if (saveContactLength.read('count') != null) {
      saveContactLength.write("count", 0);
    }
  }

  getFCMToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    log(token!);
  }
}

class Palette {
  static const MaterialColor kToDark = const MaterialColor(
    0xFFF2CFD4, // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
    const <int, Color>{
      50: const Color(0xFFF2CFD4), //10%
      100: const Color(0xFFF2CFD4), //20%
      200: const Color(0xFFF2CFD4), //30%
      300: const Color(0xFFF2CFD4), //40%
      400: const Color(0xFFD5B0B0), //50%
      500: const Color(0xff5c261d), //60%
      600: const Color(0xff451c16), //70%
      700: const Color(0xff2e130e), //80%
      800: const Color(0xff170907), //90%
      900: const Color(0xff000000), //100%
    },
  );
}
