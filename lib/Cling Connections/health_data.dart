
import 'dart:async';
import 'dart:convert';
import 'package:azpire_new/root/root.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../View/Dashboard_screen.dart';

// class HealthDataController {
//   static const platform = MethodChannel('cling_sdk');
//   Timer? _syncTimer;
//
//   void startSyncTimer() {
//     _syncTimer = Timer.periodic(Duration(minutes: 2), (timer) {
//       syncDeviceData();
//     });
//   }
//
//   void stopSyncTimer() {
//     _syncTimer?.cancel();
//   }
//
//   Future<void> syncDeviceData() async {
//     try {
//       await platform.invokeMethod('syncDeviceData');
//     } on PlatformException catch (e) {
//       print("Failed to sync data: ${e.message}");
//     }
//   }
//
//   Future<void> sendHeartRateToAPI(int heartRate, int totalSteps, int systolicBP, int diastolicBP, int totalSleep) async {
//     String formattedDate = DateFormat('yyyy-MM-dd hh:mm:ss a').format(DateTime.now());
//     String formattedDate1 = DateFormat('yyyy-MM-dd').format(DateTime.now());
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     var user_id = prefs.getString('user_id') ?? "";
//     final url = Uri.parse("$root/add");
//
//     final body = {
//       "heart_rate": heartRate.toString(),
//       "user_id": user_id,
//       "datetime": formattedDate,
//       "blood_pressure_systolic": systolicBP.toString(),
//       "blood_pressure_diastolic": diastolicBP.toString(),
//       "no_of_steps": totalSteps.toString(),
//       "sleep": totalSleep.toString(),
//       "weight": "50",
//       "datetime_now": formattedDate1,
//     };
//
//     try {
//       final response = await http.post(
//         url,
//         headers: {
//           "Content-Type": "application/x-www-form-urlencoded"
//         },
//         body: body,
//       );
//
//       final responseData = jsonDecode(response.body);
//       if (response.statusCode == 201 && responseData['status'] == 'SUCCESS') {
//         print("healthData sent successfully");
//       } else {
//         print("API error: ${responseData['message']}");
//       }
//     } catch (e) {
//       print("Error sending heart rate: $e");
//     }
//   }
//
//   void setupMethodChannelListener(Function(Map<String, dynamic>) onDataReceived) {
//     platform.setMethodCallHandler((call) async {
//       if (call.method == "onDailyTotalReceived") {
//         final dailyData = Map<String, dynamic>.from(call.arguments);
//         onDataReceived(dailyData);
//       }
//     });
//   }
// }
