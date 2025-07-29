// import 'dart:io';
//
// import 'package:app_tracking_transparency/app_tracking_transparency.dart';
// import 'package:azpire_new/View/Dashboard_screen.dart';
// import 'package:azpire_new/View/login_Screen.dart';
// import 'package:azpire_new/View/bluetoothscreen.dart';
// import 'package:azpire_new/utils/app_color.dart';
// import 'package:azpire_new/utils/appimages.dart';
// import 'package:azpire_new/utils/apptext.dart';
// import 'package:azpire_new/utils/apptextstyle.dart';
// import 'package:easy_splash_screen/easy_splash_screen.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:get/get.dart';
// import 'package:get/get_navigation/src/root/get_material_app.dart';
// import 'package:hive/hive.dart';
// import 'package:hive_flutter/adapters.dart';
// import 'package:lottie/lottie.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/foundation.dart';
// import 'Cling Connections/health_data.dart';
// import 'Cling Connections/hive_model.dart';
//
//
//
//
//
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
// FlutterLocalNotificationsPlugin();
//
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   _showNotification(message.notification?.title, message.notification?.body);
// }
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   if (kIsWeb) {
//     await Firebase.initializeApp(
//       options: const FirebaseOptions(
//         apiKey: "AIzaSyDuRkpyB2efP-U9Ild4zTXzmJUvSIY1CiQ",
//         authDomain: "aspirenew-5085f.firebaseapp.com",
//         projectId: "aspirenew-5085f",
//         storageBucket: "aspirenew-5085f.appspot.com",
//         messagingSenderId: "989276102678",
//         appId: "1:989276102678:web:057645535a645b2364d537",
//         measurementId: "G-D3VW2P8SEC",
//       ),
//     );
//   } else {
//     await Firebase.initializeApp();
//   }
//
//
//   //await Firebase.initializeApp();
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//   // await Hive.initFlutter();
//   // await Hive.openBox('minuteDataBox');
//   // await Hive.initFlutter(); // initialize Hive for Flutter
//   // Hive.registerAdapter(MinuteDataAdapter());
//   // ✅ Register adapter here
//
//
//
//   // Show ATT prompt if on iOS
//   if (Platform.isIOS) {
//     final status = await AppTrackingTransparency.trackingAuthorizationStatus;
//
//     if (status == TrackingStatus.notDetermined) {
//       await AppTrackingTransparency.requestTrackingAuthorization();
//       print("ATT prompt shown to the user.");
//     } else {
//       print("ATT already determined: $status");
//     }
//   } else {
//     print("Platform is not iOS — skipping ATT request.");
//   }
//
//
//
//
//   const AndroidInitializationSettings initializationSettingsAndroid =
//   AndroidInitializationSettings('@mipmap/ic_launcher');
//   const DarwinInitializationSettings initializationSettingsIOS =
//   DarwinInitializationSettings();
//
//   const InitializationSettings initializationSettings = InitializationSettings(
//     android: initializationSettingsAndroid,
//     iOS: initializationSettingsIOS,
//   );
//
//   await flutterLocalNotificationsPlugin.initialize(initializationSettings);
//   runApp(MyApp());
// }
//
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final FirebaseMessaging messaging = FirebaseMessaging.instance;
//
//     messaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//
//     if (kIsWeb) {
//       // Web FCM token with VAPID key
//       messaging
//           .getToken(
//         vapidKey:
//         "BBDchPDDIaVe_9T10UA-yxAzZfhWN68KuYExqsvwdOwZxcKItXJhj93VYGgyoaAaoafelKRzcfJWggC2ftMRXuA", // put your VAPID key here
//       )
//           .then((String? webToken) async {
//         print("Web FCM Token: $webToken");
//         final SharedPreferences prefs = await SharedPreferences.getInstance();
//         await prefs.setString('token', webToken ?? "");
//       }).catchError((e) {
//         print("Error fetching Web FCM token: $e");
//       });
//     } else {
//       // Android / iOS FCM token
//       messaging.getToken().then((String? apnsToken) async {
//         print("APNs/FCM Token: $apnsToken");
//         final SharedPreferences prefs = await SharedPreferences.getInstance();
//         await prefs.setString('token', apnsToken ?? "");
//       }).catchError((e) {
//         print("Error fetching APNs token: $e");
//       });
//     }
//
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       _showNotification(
//           message.notification?.title, message.notification?.body);
//     });
//
//     return GetMaterialApp(
//       title: 'Flutter Demo',
//       debugShowCheckedModeBanner: false,
//       home: SplashPage(),
//     );
//   }
// }
//
//
//
// class SplashPage extends StatefulWidget {
//   SplashPage({Key? key}) : super(key: key);
//
//   @override
//   _SplashPageState createState() => _SplashPageState();
// }
//
// class _SplashPageState extends State<SplashPage> {
//   bool isLoggedIn = false;
//   bool isLoading = true;
//   static const platform = MethodChannel('cling_sdk');
//   String? _registeredDevice;
//
//
//   @override
//   void initState() {
//     super.initState();
//     checkSession();
//
//   }
//
//
//
//
//
//
//
//   Future<void> checkSession() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool loggedIn = prefs.getBool('isLoggedIn') ?? false;
//
//     setState(() {
//       isLoggedIn = loggedIn;
//     });
//
// // If logged in, check for paired device
//     if (loggedIn) {
//       try {
//         final String? lastDeviceID = await platform.invokeMethod('getLastActiveDevice');
//         if (lastDeviceID != null && lastDeviceID.isNotEmpty) {
//           setState(() {
//             _registeredDevice = lastDeviceID;
//           });
// // Navigate to Sync Screen immediately if a paired device is found
//           Future.delayed(Duration(seconds: 1), () {
//             _navigateToSyncScreen();
//           });
//         }
//       } on PlatformException catch (e) {
//         print("Failed to get last active device: ${e.message}");
//       }
//     }
//
//     setState(() {
//       isLoading = false;
//     });
//   }
//
//   void _navigateToSyncScreen() {
//     if (_registeredDevice != null) {
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(
//           builder: (context) => DashboardScreen(deviceID: _registeredDevice!),
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Wait until checkSession() completes before showing the splash screen
//     if (isLoading) {
//       return Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     return EasySplashScreen(
//       logo: Image.asset(
//         Appimages.applogo,
//       ),
//       title: Text(
//         AppText.splashAppname,
//         style : Apptextstyle.s16wbcothers,
//       ),
//       logoWidth: 75,
//       backgroundColor: Colors.white,
//       showLoader: true,
//       navigator: isLoggedIn ? BluetoothPair() : LoginScreen(),
//       durationInSeconds: 5,
//     );
//   }
// }
//
//
//
//
// Future<void> _showNotification(String? title, String? body) async {
//   const AndroidNotificationDetails androidPlatformChannelSpecifics =
//   AndroidNotificationDetails(
//     'your_channel_id',
//     'your_channel_name',
//     importance: Importance.max,
//     priority: Priority.high,
//   );
//
//   const NotificationDetails platformChannelSpecifics = NotificationDetails(
//     android: androidPlatformChannelSpecifics,
//     iOS: DarwinNotificationDetails(),
//   );
//
//   await flutterLocalNotificationsPlugin.show(
//     0,
//     title,
//     body,
//     platformChannelSpecifics,
//     payload: 'notification_payload',
//   );
// }
//
//
// // void main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //   await Hive.initFlutter();
// //   await Hive.openBox('minuteDataBox');
// //   runApp(MyApp());
// // }
// //
// //
// // class MyApp extends StatelessWidget {
// //
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return GetMaterialApp(
// //       debugShowCheckedModeBanner: false,
// //       home: Scaffold(
// //         body: DashboardScreen(deviceID: '',),
// //       ),
// //     );
// //   }
// // }
//
//

import 'package:azpire_new/root/root.dart';
import 'package:azpire_new/web_app/platform_utils_stub.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'View/login_Screen.dart';
import 'View/bluetoothscreen.dart';
import 'View/Dashboard_screen.dart';
import 'utils/app_color.dart';
import 'utils/appimages.dart';
import 'utils/apptext.dart';
import 'utils/apptextstyle.dart';


// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
// FlutterLocalNotificationsPlugin();
//
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   _showNotification(message.notification?.title, message.notification?.body);
// }
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   if (kIsWeb) {
//     await Firebase.initializeApp(
//       options: const FirebaseOptions(
//         apiKey: "AIzaSyDuRkpyB2efP-U9Ild4zTXzmJUvSIY1CiQ",
//         authDomain: "aspirenew-5085f.firebaseapp.com",
//         projectId: "aspirenew-5085f",
//         storageBucket: "aspirenew-5085f.appspot.com",
//         messagingSenderId: "989276102678",
//         appId: "1:989276102678:web:057645535a645b2364d537",
//         measurementId: "G-D3VW2P8SEC",
//       ),
//     );
//   } else {
//     await Firebase.initializeApp();
//   }
//
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//
//   // ✅ Show ATT prompt only on iOS (safe check)
//   if (isIOS) {
//     final status = await AppTrackingTransparency.trackingAuthorizationStatus;
//     if (status == TrackingStatus.notDetermined) {
//       await AppTrackingTransparency.requestTrackingAuthorization();
//       print("ATT prompt shown to the user.");
//     } else {
//       print("ATT already determined: $status");
//     }
//   }
//
//   const AndroidInitializationSettings initializationSettingsAndroid =
//   AndroidInitializationSettings('@mipmap/ic_launcher');
//   const DarwinInitializationSettings initializationSettingsIOS =
//   DarwinInitializationSettings();
//
//   const InitializationSettings initializationSettings = InitializationSettings(
//     android: initializationSettingsAndroid,
//     iOS: initializationSettingsIOS,
//   );
//
//   await flutterLocalNotificationsPlugin.initialize(initializationSettings);
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final FirebaseMessaging messaging = FirebaseMessaging.instance;
//
//
//     messaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//
//     if (kIsWeb) {
//       messaging
//           .getToken(
//         vapidKey:"BBDchPDDIaVe_9T10UA-yxAzZfhWN68KuYExqsvwdOwZxcKItXJhj93VYGgyoaAaoafelKRzcfJWggC2ftMRXuA",
//       )
//           .then((String? webToken) async {
//         print("Web FCM Token: $webToken");
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString('token', webToken ?? "");
//       }).catchError((e) {
//         print("Error fetching Web FCM token: $e");
//       });
//     } else {
//       messaging.getToken().then((String? apnsToken) async {
//         print("APNs/FCM Token: $apnsToken");
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString('token', apnsToken ?? "");
//       }).catchError((e) {
//         print("Error fetching APNs token: $e");
//       });
//     }
//
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       _showNotification(
//           message.notification?.title, message.notification?.body);
//     });
//
//     return GetMaterialApp(
//       title: 'Flutter Demo',
//       debugShowCheckedModeBanner: false,
//       home: SplashPage(),
//     );
//   }
// }
//
// class SplashPage extends StatefulWidget {
//   SplashPage({Key? key}) : super(key: key);
//
//   @override
//   _SplashPageState createState() => _SplashPageState();
// }
//
// class _SplashPageState extends State<SplashPage> {
//   bool isLoggedIn = false;
//   bool isLoading = true;
//   static const platform = MethodChannel('cling_sdk');
//   String? _registeredDevice;
//
//   @override
//   void initState() {
//     super.initState();
//     checkSession();
//     requestWebNotificationPermission();
//   }
//
//   Future<void> requestWebNotificationPermission() async {
//     NotificationSettings settings = await FirebaseMessaging.instance.requestPermission();
//     print('Permission status: ${settings.authorizationStatus}');
//   }
//
//
//   Future<void> checkSession() async {
//     final prefs = await SharedPreferences.getInstance();
//     bool loggedIn = prefs.getBool('isLoggedIn') ?? false;
//
//     setState(() {
//       isLoggedIn = loggedIn;
//     });
//
//     if (loggedIn) {
//       try {
//         final String? lastDeviceID =
//         await platform.invokeMethod('getLastActiveDevice');
//         if (lastDeviceID != null && lastDeviceID.isNotEmpty) {
//           setState(() {
//             _registeredDevice = lastDeviceID;
//           });
//           Future.delayed(Duration(seconds: 1), () {
//             _navigateToSyncScreen();
//           });
//         }
//       } on PlatformException catch (e) {
//         print("Failed to get last active device: ${e.message}");
//       }
//     }
//
//     setState(() {
//       isLoading = false;
//     });
//   }
//
//   void _navigateToSyncScreen() {
//     if (_registeredDevice != null) {
//      Get.to(()=>  DashboardScreen(deviceID: _registeredDevice!));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     return EasySplashScreen(
//       logo: Image.asset(Appimages.applogo),
//       title: Text(
//         AppText.splashAppname,
//         style: Apptextstyle.s16wbcothers,
//       ),
//       logoWidth: 75,
//       backgroundColor: Colors.white,
//       showLoader: true,
//       navigator: isLoggedIn ? BluetoothPair() : LoginScreen(),
//       //durationInSeconds: 5,
//     );
//   }
// }
//
// Future<void> _showNotification(String? title, String? body) async {
//   const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//     'your_channel_id',
//     'your_channel_name',
//     importance: Importance.max,
//     priority: Priority.high,
//   );
//
//   const NotificationDetails platformDetails = NotificationDetails(
//     android: androidDetails,
//     iOS: DarwinNotificationDetails(),
//   );
//
//   await flutterLocalNotificationsPlugin.show(
//     0,
//     title,
//     body,
//     platformDetails,
//     payload: 'notification_payload',
//   );
// }


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  _showNotification(message.notification?.title, message.notification?.body);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (isIOS) {
    final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    if (status == TrackingStatus.notDetermined) {
      await AppTrackingTransparency.requestTrackingAuthorization();
      print("ATT prompt shown to the user.");
    } else {
      print("ATT already determined: $status");
    }
  }

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings initializationSettingsIOS =
  DarwinInitializationSettings();

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  runApp(
      OKToast(
          position: kIsWeb ? ToastPosition.top : ToastPosition.bottom,
          child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Aspire Healthspan',
      debugShowCheckedModeBanner: false,
      home: SplashPage(),
    );
  }
}

class SplashPage extends StatefulWidget {
  SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool isLoggedIn = false;
  bool isLoading = true;
  static const platform = MethodChannel('cling_sdk');
  String? _registeredDevice;
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    initializeNotifications();
    checkSession();
  }

  Future<void> initializeNotifications() async {
    NotificationSettings settings = await messaging.requestPermission();
    print('Permission status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("✅ Notification permission granted");

      if (kIsWeb) {
        final token = await messaging.getToken(
          vapidKey:
          "BBDchPDDIaVe_9T10UA-yxAzZfhWN68KuYExqsvwdOwZxcKItXJhj93VYGgyoaAaoafelKRzcfJWggC2ftMRXuA",
        );
        print("Web FCM Token: $token");
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token ?? "");
      } else {
        final token = await messaging.getToken();
        print("Mobile Token: $token");
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token ?? "");
      }

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print("Foreground Notification Received");
        _showNotification(
          message.notification?.title,
          message.notification?.body,
        );
      });
    } else {
      print("❌ Notification permission denied");
    }
  }

  Future<void> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    bool loggedIn = prefs.getBool('isLoggedIn') ?? false;

    setState(() {
      isLoggedIn = loggedIn;
      isLoading = false;
    });

    // if (loggedIn) {
    //   try {
    //     final String? lastDeviceID =
    //     await platform.invokeMethod('getLastActiveDevice');
    //     if (lastDeviceID != null && lastDeviceID.isNotEmpty) {
    //       setState(() {
    //         _registeredDevice = lastDeviceID;
    //       });
    //       Future.delayed(Duration(seconds: 1), _navigateToSyncScreen);
    //     }
    //   } on PlatformException catch (e) {
    //     print("Failed to get last active device: ${e.message}");
    //   }
    // }
    if (loggedIn) {
      try {
        final String? lastDeviceID = await platform.invokeMethod('getLastActiveDevice');
        if (lastDeviceID != null && lastDeviceID.isNotEmpty) {
          setState(() {
            _registeredDevice = lastDeviceID;
          });
          Future.delayed(Duration(seconds: 1), _navigateToSyncScreen);
        } else {
          // No device found, navigate to BluetoothPair
          Future.delayed(Duration(seconds: 1), () {
            Get.offAll(() => BluetoothPair());
          });
        }
      } on PlatformException catch (e) {
        print("Failed to get last active device: ${e.message}");
        // Future.delayed(Duration(seconds: 1), () {
        //   Get.offAll(() => BluetoothPair());
        // });
      }
    } else {
      // Not logged in, show login
      Future.delayed(Duration(seconds: 1), () {
        Get.offAll(() => LoginScreen());
      });
    }


    // setState(() {
    //   isLoading = false;
    // });
  }

  // Future<void> checkSession() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   bool loggedIn = prefs.getBool('isLoggedIn') ?? false;
  //
  //   setState(() {
  //     isLoggedIn = loggedIn;
  //     isLoading = false;
  //   });
  // }


  void _navigateToSyncScreen() {
    if (_registeredDevice != null) {
      Get.to(() => DashboardScreen(deviceID: _registeredDevice!));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return EasySplashScreen(
      logo: Image.asset(Appimages.applogo),
      title: Text(
          AppText.splashAppname,
          style: Apptextstyle.s16wbcothers),
      logoWidth: 75,
      backgroundColor: Colors.white,
      showLoader: true,
      navigator: isLoggedIn ? BluetoothPair() : LoginScreen(),
    );
  }
}

Future<void> _showNotification(String? title, String? body) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'your_channel_id',
    'your_channel_name',
    importance: Importance.max,
    priority: Priority.high,
  );

  const NotificationDetails platformDetails = NotificationDetails(
    android: androidDetails,
    iOS: DarwinNotificationDetails(),
  );

  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformDetails,
    payload: 'notification_payload',
  );
}

