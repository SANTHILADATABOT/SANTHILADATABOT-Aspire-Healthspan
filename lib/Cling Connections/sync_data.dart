import 'dart:async';
import 'dart:convert';
import '../web_app/platform_utils_io.dart';
import 'package:azpire_new/Cling%20Connections/clingchannelHandler.dart';
import 'package:azpire_new/Cling%20Connections/health_connect_service.dart';
import 'package:azpire_new/Cling%20Connections/hive_model.dart';
import 'package:azpire_new/cling_ble_service.dart';
import 'package:azpire_new/root/root.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:azpire_new/Controller/AdminController.dart';

// class SyncService {
//
//   Timer? _periodicSyncTimer; // 2-minute periodic sync timer
//   final Duration periodicSyncDuration = Duration(minutes: 2);
//   Timer? _debounceTimer;
//   final Duration debounceDuration = Duration(seconds: 5);
//   bool isSyncInProgress = false;
//   final Function(String) updateMessage;
//   final Function(Map<String, dynamic>) onDailyDataReceived;
//   final VoidCallback onSyncComplete;
//   final bool shouldSync;
//   static const platform = MethodChannel('cling_sdk');
//   Timer? _retrySyncTimer;
//   final Duration retryDuration = Duration(minutes: 5);
//
//
//   SyncService({
//     required this.updateMessage,
//     required this.onDailyDataReceived,
//     required this.onSyncComplete,
//     required this.shouldSync,
//   });
//
//   void startSync() async {
//     if (!shouldSync || isSyncInProgress) return;
//
//     isSyncInProgress = true;
//
//     final clingHandler = ClingChannelHandler();
//
//     clingHandler.onDailyData = (data) async {
//       updateMessage("📥 Received daily data");
//
//       onDailyDataReceived(data);
//
//       await _sendHeartRateToAPI(
//         heartRate: data['heartRate']?.toInt() ?? 0,
//         totalSteps: data['totalSteps']?.toInt() ?? 0,
//         systolicBP: data['iBPHigh']?.toInt() ?? 0,
//         diastolicBP: data['iBPLow']?.toInt() ?? 0,
//         totalSleep: data['totalSleep']?.toInt() ?? 0,
//         totalspo2: data['spo2']?.toInt() ?? 0
//       );
//     };
//
//     clingHandler.onMinuteData = (List<dynamic> list) async {
//       if (list.isEmpty) return;
//
//       final box = await Hive.openBox<MinuteData>('minute_data_box');
//       final newItems = list.map((e) => MinuteData(data: Map<String, dynamic>.from(e))).toList();
//       await box.addAll(newItems);
//
//       print("✅ Stored ${newItems.length} minute records in Hive");
//
//       await _triggerDebouncedSync();
//       await _twominutessync();
//       // ⏳ Start debounce logic
//     };
//   }
//
//
//
//   Future<void> syncDeviceData() async {
//     try {
//       await platform.invokeMethod('syncDeviceData');
//     } on PlatformException catch (e) {
//       print("Failed to sync data: ${e.message}");
//     }
//   }
//
//   Future <void> _twominutessync() async{
//     print(" Started 2-minute sync timer");
//     _periodicSyncTimer?.cancel(); // Cancel if already running
//
//     _periodicSyncTimer = Timer.periodic(periodicSyncDuration, (timer) async {
//       print("2-minute timer triggered syncDeviceData");
//       await syncDeviceData();
//       await _syncHiveDataToApi();
//     });
//
//
//   }
//
//
//   Future <void> _triggerDebouncedSync() async {
//     _debounceTimer?.cancel();
//     _debounceTimer = Timer(debounceDuration, () async {
//       print("No new data in last 3 seconds — syncing to API");
//       await _syncHiveDataToApi();
//     });
//   }
//
//   Future<void> _syncHiveDataToApi() async {
//     final box = await Hive.openBox<MinuteData>('minute_data_box');
//     final allData = box.values.map((e) => e.data).toList();
//
//     if (allData.isEmpty) {
//       isSyncInProgress = false;
//       return;
//     }
//
//     final success = await sendBulkMinuteDataToApi(allData);
//
//     if (success) {
//       print("✅ Sync success: $success");
//       await box.clear();
//       print("Cleared synced data from Hive:$success");
//       onSyncComplete();
//
//       // Cancel any scheduled retry on success
//       _retrySyncTimer?.cancel();
//       _retrySyncTimer = null;
//     } else {
//       print("Sync failed, retrying in 5 minutes...");
//       // Cancel existing retry timer if it's already running
//       _retrySyncTimer?.cancel();
//
//       // Schedule retry after 5 minutes
//       _retrySyncTimer = Timer(retryDuration, () async {
//         print("Retrying sync after 5 minutes...");
//         await _syncHiveDataToApi();
//       });
//     }
//
//     isSyncInProgress = false;
//   }
//
//
//   Future<void> _sendHeartRateToAPI({
//     required int heartRate,
//     required int totalSteps,
//     required int systolicBP,
//     required int diastolicBP,
//     required int totalSleep,
//     required int totalspo2,
//   }) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     var user_id = prefs.getString('user_id') ?? "";
//     print("sendHeartRateToAPI");
//     final url = Uri.parse("$root/health_variable/add");
//
//     final body = {
//       "heart_rate": heartRate.toString(),
//       "user_id": user_id,
//       "datetime": DateFormat('yyyy-MM-dd hh:mm:ss a').format(DateTime.now()),
//       "blood_pressure_systolic": systolicBP.toString(),
//       "blood_pressure_diastolic": diastolicBP.toString(),
//       "no_of_steps": totalSteps.toString(),
//       "sleep": totalSleep.toString(),
//       "spo2" : totalspo2.toString(),
//
//       "weight": "50",
//       "datetime_now": DateFormat('yyyy-MM-dd').format(DateTime.now()),
//     };
//
//     print("spo2_data:$body");
//
//     try {
//       final response = await http.post(
//         url,
//         headers: {"Content-Type": "application/x-www-form-urlencoded"},
//         body: body,
//       );
//
//       print("DailyData API response: ${response.body}");
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final jsonResponse = jsonDecode(response.body);
//
//         if (jsonResponse['status'] == 'SUCCESS') {
//           print("DailyData data sent successfully: ${jsonResponse['message'] ?? 'Success'}");
//         } else {
//           print("API responded but status is not SUCCESS: ${jsonResponse['status']}");
//         }
//       } else {
//         print("Retry after 5 minutes if the request fails: ${response.statusCode}");
//         // Retry after 5 minutes if the request fails
//         await _retrySendHeartRateToAPI(heartRate, totalSteps, systolicBP, diastolicBP, totalSleep,totalspo2);
//       }
//     } catch (e) {
//       print("Error sending DailyData: $e");
//       // // Retry after 5 minutes if there is an error
//       // await _retrySendHeartRateToAPI(heartRate, totalSteps, systolicBP, diastolicBP, totalSleep);
//     }
//   }
//
//   Future<void> _retrySendHeartRateToAPI(
//       int heartRate,
//       int totalSteps,
//       int systolicBP,
//       int diastolicBP,
//       int totalSleep,
//       int totalspo2
//       ) async {
//     print("Retrying in 5 minutes...");
//     // Wait for 5 minutes before retrying the API call
//     await Future.delayed(Duration(minutes: 5));
//     // Retry sending the heart rate data
//     await _sendHeartRateToAPI(
//       heartRate: heartRate,
//       totalSteps: totalSteps,
//       systolicBP: systolicBP,
//       diastolicBP: diastolicBP,
//       totalSleep: totalSleep,
//       totalspo2: totalspo2
//     );
//   }
//
//
//   Future<bool> sendBulkMinuteDataToApi(List<Map<String, dynamic>> dataList) async {
//     print("sendBulkMinuteDataToApi");
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     var user_id = prefs.getString('user_id') ?? "";
//     final url = Uri.parse('$root/minute_health_variable/add');
//
//     try {
//       final response = await http.post(
//         url,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({"user_id": user_id, "data": dataList}),
//       );
//
//       print("Minute data API response: ${response.body}");
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final jsonResponse = jsonDecode(response.body);
//
//         if (jsonResponse['status'] == "SUCCESS") {
//           print("Success message: ${jsonResponse['message'] ?? 'Data sent successfully'}");
//           return true;
//         } else {
//           print("API responded but status is not SUCCESS: ${jsonResponse['status']}");
//           return false;
//         }
//       } else {
//         print("Failed to send data. Status code: ${response.statusCode}");
//         return false;
//       }
//     } catch (e) {
//       print("Error sending minute data: $e");
//       return false;
//     }
//   }
//
//
//   void dispose() {
//     _debounceTimer?.cancel();
//     _periodicSyncTimer?.cancel();
//     _retrySyncTimer?.cancel();
//   }
// }

class SyncService {
  Timer? _periodicSyncTimer; // 2-minute periodic sync timer
  final Duration periodicSyncDuration = const Duration(minutes: 2);

  Timer? _debounceTimer;
  final Duration debounceDuration = const Duration(seconds: 5);

  bool isSyncInProgress = false;
  bool _isTwoMinTimerStarted = false;

  final Function(String) updateMessage;
  final Function(Map<String, dynamic>) onDailyDataReceived;
  final VoidCallback onSyncComplete;
  final bool shouldSync;

  static const platform = MethodChannel('cling_sdk');
// 🤖 Android
  static const MethodChannel _androidChannel = MethodChannel('cling/methods');

  Timer? _retrySyncTimer;
  final Duration retryDuration = const Duration(minutes: 5);
  StreamSubscription? _minuteSub;
  StreamSubscription? _dailySub;
  static const _minuteChannel = EventChannel('cling/minute_data');
  static const _dailyChannel = EventChannel('cling/daily_total');
  final VoidCallback onDashboardRefresh;

  SyncService({
    required this.updateMessage,
    required this.onDailyDataReceived,
    required this.onSyncComplete,
    required this.shouldSync,
    required this.onDashboardRefresh,
  });

  // 🔹 ENTRY POINT
  void startSync() async {
    if (!shouldSync) return;

    final clingHandler = ClingChannelHandler();

    // ---------------- DAILY DATA ----------------
    clingHandler.onDailyData = (data) async {
      updateMessage("📥 Received daily data");

      onDailyDataReceived(data);

      await _sendHeartRateToAPI(
        heartRate: data['heartRate']?.toInt() ?? 0,
        totalSteps: data['totalSteps']?.toInt() ?? 0,
        systolicBP: data['iBPHigh']?.toInt() ?? 0,
        diastolicBP: data['iBPLow']?.toInt() ?? 0,
        totalSleep: data['totalSleep']?.toInt() ?? 0,
        totalspo2: data['spo2']?.toInt() ?? 0,
      );

      // 🔗 Mirror to Health Connect (Android compliance) - NON-BLOCKING
      _syncToHealthConnectBackground(data);
    };

    // ---------------- MINUTE DATA ----------------
    clingHandler.onMinuteData = (List<dynamic> list) async {
      if (list.isEmpty) return;

      final box = await Hive.openBox<MinuteData>('minute_data_box');

      final newItems = list
          .map((e) => MinuteData(data: Map<String, dynamic>.from(e)))
          .toList();

      await box.addAll(newItems);

      print("✅ Stored ${newItems.length} minute records in Hive");

      // Keep only 1 week data
      // await _retainOneWeekData(box);

      // Debounced API sync
      await _triggerDebouncedSync();

      // 🔗 Mirror bulk data to Health Connect - NON-BLOCKING
      _syncBulkToHealthConnectBackground(newItems.map((e) => e.data).toList());
    };

    // 🔥 NEW: Trigger first sync and start periodic timer immediately
    print("🚀 Initializing startup sync and starting 2-minute timer");
    await syncDeviceData();
    _startTwoMinuteTimerOnce();
  }

  // 🔹 NON-BLOCKING Sync to Health Connect
  void _syncToHealthConnectBackground(Map<String, dynamic> data) async {
    try {
      final toggles = await _fetchToggles();
      await HealthConnectService().syncToHealthConnect(data, toggles: toggles);
    } catch (e) {
      print("⚠️ Health Connect Background Sync Error: $e");
    }
  }

  // 🔹 NON-BLOCKING Bulk Sync to Health Connect
  void _syncBulkToHealthConnectBackground(
      List<Map<String, dynamic>> rawList) async {
    try {
      final toggles = await _fetchToggles();
      await HealthConnectService()
          .syncBulkToHealthConnect(rawList, toggles: toggles);
    } catch (e) {
      print("⚠️ Health Connect Background Bulk Sync Error: $e");
    }
  }

  // Helper to fetch toggles for Health Connect sync logic
  Future<Map<String, bool>?> _fetchToggles() async {
    try {
      final result = await AdminController().fetchAllToggles();
      if (result != null && result.data.isNotEmpty) {
        Map<String, bool> toggles = {};
        for (final toggle in result.data) {
          toggles[toggle.tableType] = toggle.toggleStatus.toUpperCase() == "ON";
        }
        return toggles;
      }
    } catch (e) {
      print("Error fetching toggles for sync: $e");
    }
    return null;
  }

  // // ---------------- WATCH SYNC COMPLETED ----------------
  // clingHandler.onWatchSyncCompleted = () {
  //   print("⌚ Watch sync completed");
  //   _startTwoMinuteTimerOnce();
  // };

  Future<void> syncDeviceData() async {
    try {
      if (isIOS) {
        print("🍎 iOS → syncDeviceData()");
        await platform.invokeMethod('syncDeviceData');
      } else if (isAndroid) {
        print("🤖 Android → loadDeviceData()");
        await ClingBleService.syncdata();
      }
    } on PlatformException catch (e) {
      print("Failed to sync data: ${e.message}");
    }
  }

  // 🔹 START 2-MIN TIMER (ONLY ONCE)
  void _startTwoMinuteTimerOnce() {
    if (_isTwoMinTimerStarted) return;

    print("⏱️ Started 2-minute sync timer");
    _isTwoMinTimerStarted = true;

    _periodicSyncTimer = Timer.periodic(periodicSyncDuration, (timer) async {
      print("⏰ 2-minute timer triggered");

      await syncDeviceData();
      await _syncHiveDataToApi();
    });
  }

  // 🔹 DEBOUNCE API CALL
  Future<void> _triggerDebouncedSync() async {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDuration, () async {
      print("No new data in last 5 seconds — syncing to API");
      await _syncHiveDataToApi();
    });
  }

  // 🔹 HIVE → BULK API
  Future<void> _syncHiveDataToApi() async {
    if (isSyncInProgress) {
      print("⏳ Sync already in progress");
      return;
    }

    isSyncInProgress = true;

    final box = await Hive.openBox<MinuteData>('minute_data_box');
    final allData = box.values.map((e) => e.data).toList();

    if (allData.isEmpty) {
      print("📭 No minute data available in Hive");
      isSyncInProgress = false;
      return;
    }

    print("📤 Sending ${allData.length} minute records to API");

    final success = await sendBulkMinuteDataToApi(allData);

    // if (success) {
    //   print("✅ Sync success");
    //   await box.clear();
    //   print("🧹 Cleared synced data from Hive");
    //
    //   onSyncComplete();
    //
    //   _retrySyncTimer?.cancel();
    //   _retrySyncTimer = null;
    // }

    if (success) {
      print("✅ Sync success");
      await box.clear();

      print("🧹 Cleared synced data from Hive");

      onSyncComplete();

      // 🔥 ADD THIS
      onDashboardRefresh();

      _retrySyncTimer?.cancel();
      _retrySyncTimer = null;
    } else {
      print("❌ Sync failed, retrying in 5 minutes");

      _retrySyncTimer?.cancel();
      _retrySyncTimer = Timer(retryDuration, () async {
        print("🔁 Retrying sync after 5 minutes");
        await _syncHiveDataToApi();
      });
    }

    isSyncInProgress = false;
  }

  // 🔹 DAILY DATA API (UNCHANGED)
  Future<void> _sendHeartRateToAPI({
    required int heartRate,
    required int totalSteps,
    required int systolicBP,
    required int diastolicBP,
    required int totalSleep,
    required int totalspo2,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id') ?? "";

    print("heart_Rate:$heartRate");
    print("total_Steps:$totalSteps");
    print("systolic_BP:$systolicBP");
    print("diastolic_BP:$diastolicBP");
    print("total_Sleep:$totalSleep");
    print("total_spo2:$totalspo2");
    print("Userid:$user_id");

    final url = Uri.parse("$root/health_variable/add");

    print("Daily_URL:$url");

    try {
      print("daily");
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "heart_rate": heartRate,
          "user_id": user_id,
          "datetime":
              DateFormat('yyyy-MM-dd hh:mm:ss a').format(DateTime.now()),
          "blood_pressure_systolic": systolicBP,
          "blood_pressure_diastolic": diastolicBP,
          "no_of_steps": totalSteps,
          "sleep": totalSleep,
          "oxygen": totalspo2,
          "weight": 50,
          "datetime_now": DateFormat('yyyy-MM-dd').format(DateTime.now()),
        }),
      );

      print("daily1");
      print("Total_data:$response");

      print("Status Code: ${response.statusCode}");
      print("Raw Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("DailyData API response: ${response.body}");
      } else {
        print(
            "❌ DailyData Error ${response.statusCode}: ${response.body} :${response.statusCode}");
      }
    } catch (e) {
      print("Error sending DailyData: $e");
    }
  }

  // 🔹 BULK MINUTE API (UNCHANGED)
  Future<bool> sendBulkMinuteDataToApi(
      List<Map<String, dynamic>> dataList) async {
    print("sendBulkMinuteDataToApi");

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id') ?? "";

    final url = Uri.parse('$root/minute_health_variable/add');
    print("minuteurl:$url");

    try {
      print("minutedata123456");
      print("userid: $user_id");
      print("data: $dataList");
      // final response = await http.post(
      //   url,
      //   headers: {"Content-Type": "application/json"},
      //   body: jsonEncode({"user_id": user_id, "data": dataList}),
      // );
      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "user_id": user_id,
              "data": dataList,
            }),
          )
          .timeout(Duration(minutes: 5));
      print("Minute data API response: ${response.body}");
      //print("Minute_data: $response");
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Minute_Data_list:${response.body}");
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['status'] == "SUCCESS";
      } else {
        print("❌ MinuteData Error ${response.statusCode}: ${response.body}");
        return false; // ✅ FIX
      }
    } catch (e) {
      print("Error sending minute data: $e");
      return false;
    }
  }

  // Future<bool> sendBulkMinuteDataToApi(
  //     List<Map<String, dynamic>> dataList) async {
  //   print("sendBulkMinuteDataToApi START");
  //
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   var user_id = prefs.getString('user_id') ?? "";
  //
  //   final url = Uri.parse('$root/minute_health_variable/add');
  //   print("API URL: $url");
  //
  //   // 🔥 Split data into chunks (important for performance)
  //   const int chunkSize = 20;
  //   bool allSuccess = true;
  //
  //   try {
  //     for (int i = 0; i < dataList.length; i += chunkSize) {
  //       final chunk = dataList.sublist(
  //         i,
  //         i + chunkSize > dataList.length ? dataList.length : i + chunkSize,
  //       );
  //
  //       print("Sending chunk ${i ~/ chunkSize + 1}");
  //       print("Chunk size: ${chunk.length}");
  //
  //       final bodyData = {
  //         "user_id": user_id,
  //         "data": chunk,
  //       };
  //
  //       final response = await http
  //           .post(
  //         url,
  //         headers: {"Content-Type": "application/json"},
  //         body: jsonEncode(bodyData),
  //       )
  //           .timeout(const Duration(seconds: 30)); // ⏱ timeout added
  //
  //       // ✅ Proper logging
  //       print("Status Code: ${response.statusCode}");
  //       print("Minute Response Body: ${response.body}");
  //
  //       if (response.statusCode == 200 || response.statusCode == 201) {
  //         if (response.body.isEmpty) {
  //           print("⚠️ Empty response body");
  //           allSuccess = false;
  //           continue;
  //         }
  //
  //         final jsonResponse = jsonDecode(response.body);
  //
  //         if (jsonResponse['status'] != "SUCCESS") {
  //           print("❌ API returned failure: ${jsonResponse}");
  //           allSuccess = false;
  //         }
  //       } else {
  //         print("❌ HTTP Error ${response.statusCode}: ${response.body}");
  //         allSuccess = false;
  //       }
  //     }
  //
  //     print("sendBulkMinuteDataToApi END");
  //     return allSuccess;
  //   } catch (e) {
  //     print("🔥 Exception: $e");
  //     return false;
  //   }
  // }

  void dispose() {
    _debounceTimer?.cancel();
    _periodicSyncTimer?.cancel();
    _retrySyncTimer?.cancel();
    _minuteSub?.cancel();
    _dailySub?.cancel();
    print("🧹 SyncService disposed and timers/subscriptions cancelled");
  }
}
