
import 'dart:io';

import 'package:azpire_new/Cling%20Connections/hive_model.dart';
import 'package:azpire_new/cling_ble_service.dart';
import 'package:azpire_new/root/root.dart';
import 'package:azpire_new/web_app/platform_utils_stub.dart';
import 'package:azpire_new/widgets/notifications_mobile.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'Controller/ToggleController.dart';
import 'View/login_Screen.dart';
import 'View/bluetoothscreen.dart';
import 'View/Dashboard_screen.dart';
import 'View/syncing data screen.dart';
import 'utils/app_color.dart';
import 'utils/appimages.dart';
import 'utils/apptext.dart';
import 'utils/apptextstyle.dart';



Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (message.notification == null) {
    print("Background message has no notification payload, skipping notification display.");
    return;
  }

  await showNotification(message.notification?.title, message.notification?.body);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('Flutter Error: ${details.exceptionAsString()}');
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    print('Uncaught platform error: $error');
    return true;
  };

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDuRkpyB2efP-U9Ild4zTXzmJUvSIY1CiQ",
        authDomain: "aspirenew-5085f.firebaseapp.com",
        projectId: "aspirenew-5085f",
        storageBucket: "aspirenew-5085f.appspot.com",
        messagingSenderId: "989276102678",
        appId: "1:989276102678:web:057645535a645b2364d537",
        measurementId: "G-D3VW2P8SEC",
      ),
    );
  } else {
    await Firebase.initializeApp();
    await initLocalNotifications(); // only runs on mobile
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await Hive.initFlutter();
  await Hive.openBox('minuteDataBox');
  Hive.registerAdapter(MinuteDataAdapter());

  runApp(

    OKToast(
      position: kIsWeb ? ToastPosition.top : ToastPosition.bottom,
      child: ChangeNotifierProvider(
        create: (context) => ToggleService(),
        child: MyApp(),
      ),
    ),
  );

}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Aspire Healthspan',
      debugShowCheckedModeBanner: false,
      home: kIsWeb
          ? (LoginScreen())
          : SplashPage(),
    );
  }
}

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool isLoggedIn = false;
  bool isLoading = true;
  static const MethodChannel iosChannel =
  MethodChannel('cling_sdk');

  static const MethodChannel androidChannel =
  MethodChannel('cling/methods');

  String? _registeredDevice;
  String? _lastdeviceId;
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    initializeNotifications();

    if (!kIsWeb && isIOS) {
      Future.delayed(const Duration(seconds: 1), () async {
        if (!mounted) return;
        final status = await AppTrackingTransparency.trackingAuthorizationStatus;
        print("Current ATT status: $status");

        if (status == TrackingStatus.notDetermined) {
          if (!mounted) return;
          final newStatus = await AppTrackingTransparency.requestTrackingAuthorization();
          print("ATT prompt shown. New status: $newStatus");
        } else {
          print("ATT already determined: $status");
        }
      });
    }

    checkSession();
  }



  Future<void> initializeNotifications() async {
    NotificationSettings settings = await messaging.requestPermission();
    print('Permission status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("✅ Notification permission granted");

      final prefs = await SharedPreferences.getInstance();

      if (kIsWeb) {
        final token = await messaging.getToken(
          vapidKey: "BBDchPDDIaVe_9T10UA-yxAzZfhWN68KuYExqsvwdOwZxcKItXJhj93VYGgyoaAaoafelKRzcfJWggC2ftMRXuA",
        );
        print("Web FCM Token: $token");
        await prefs.setString('token', token ?? "");
      } else {
        final token = await messaging.getToken();
        print("FCM Token: ${token ?? 'null'}");
        await prefs.setString('token', token ?? "");

        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          print("Foreground Notification Received");
          showNotification(message.notification?.title, message.notification?.body);
        });
      }
    } else {
      print("Notification permission denied");
    }
  }



  Future<void> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    bool loggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!mounted) return;

    setState(() {
      isLoggedIn = loggedIn;
      isLoading = false;
    });

    if (!loggedIn || kIsWeb) return;

    if (Platform.isAndroid) {
      try {

        final String? clingId =
        await androidChannel.invokeMethod("getSavedClingId");

        print("🔥 Android Saved clingId → $clingId");

        if (clingId != null && clingId.isNotEmpty) {


          Get.offAll(() =>
              SyncDataScreen(deviceID: clingId));
          // Get.offAll(() =>
          //     DashboardScreen(deviceID: clingId));

        } else {

          Get.offAll(() => BluetoothPair());
        }

      } catch (e) {
        print("Android session error: $e");
        //Get.offAll(() => BluetoothPair());
      }
    }

    if (Platform.isIOS) {
      try {

        final String? lastDeviceID =
        await iosChannel.invokeMethod('getLastActiveDevice');

        print("🍎 iOS Last Device → $lastDeviceID");

        if (lastDeviceID != null && lastDeviceID.isNotEmpty) {

          _registeredDevice = lastDeviceID;

          Get.offAll(() =>
              DashboardScreen(deviceID: lastDeviceID));

        } else {

          Get.offAll(() => BluetoothPair());
        }

      } catch (e) {
        print("iOS session error: $e");
        Get.offAll(() => BluetoothPair());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    precacheImage(const AssetImage("assets/gif/logo.gif"), context);
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return EasySplashScreen(
      logo: Image.asset(Appimages.applogo),
      title: Text(
        AppText.splashAppname,
        style: Apptextstyle.s16wbcothers,
      ),
      logoWidth: 75,
      backgroundColor: Colors.white,
      showLoader: true,
      navigator: isLoggedIn
          ? (kIsWeb
          ? BluetoothPair()
          : (_registeredDevice != null &&
          _registeredDevice!.isNotEmpty
          ? (Platform.isIOS
          ? DashboardScreen(deviceID: _registeredDevice!)
          : SyncDataScreen(deviceID: _registeredDevice!))
          : BluetoothPair()))
          : LoginScreen(),
    );
  }
}


