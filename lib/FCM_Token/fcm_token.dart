

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FCMToken {

Future<void> getToken({
  required SharedPreferences prefs,
  required StateSetter setState,
  required String? token,
}) async {
  try {
    token = await FirebaseMessaging.instance.getToken();

    if (token != null) {
      await prefs.setString('token', token);
      print('FCM Token stored: $token');
    } else {
      print('Failed to retrieve FCM Token.');
    }

    setState(() {}); // Refresh UI to display token if available

    // Listen for token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      print('FCM Token refreshed: $newToken');
      prefs.setString('token', newToken); // Update token
      setState(() {
        token = newToken;
      });
    });
  } catch (e) {
    print('Error retrieving token: $e');
  }
    }
}