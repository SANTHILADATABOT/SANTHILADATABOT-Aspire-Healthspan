import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> initLocalNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings initializationSettingsIOS =
  DarwinInitializationSettings();

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

// Future<void> showNotification(String? title, String? body) async {
//   if (title == null && body == null) {
//     print("Skipping notification: both title and body are null");
//     return;
//   }
//
//   try {
//     const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//       'your_channel_id',
//       'your_channel_name',
//       importance: Importance.max,
//       priority: Priority.high,
//     );
//
//     const NotificationDetails platformDetails = NotificationDetails(
//       android: androidDetails,
//       iOS: DarwinNotificationDetails(),
//     );
//
//     await flutterLocalNotificationsPlugin.show(
//       0,
//       title ?? 'No Title',
//       body ?? 'No Body',
//       platformDetails,
//       payload: 'notification_payload',
//     );
//   } catch (e, st) {
//     print("Error showing notification: $e\n$st");
//   }
// }

Future<void> showNotification(String? title, String? body) async {
  if (kIsWeb) {
    print("Skipping local notifications on Web");
    return;
  }

  final safeTitle = title ?? 'No Title';
  final safeBody = body ?? 'No Body';

  try {
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
      safeTitle,
      safeBody,
      platformDetails,
      payload: 'notification_payload',
    );
  } catch (e, st) {
    print("Error showing notification: $e\n$st");
  }
}

