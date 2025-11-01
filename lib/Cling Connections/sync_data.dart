
import 'dart:async';
import 'dart:convert';
import 'package:aspire/Cling%20Connections/clingchannelHandler.dart';
import 'package:aspire/Cling%20Connections/hive_model.dart';
import 'package:aspire/root/root.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SyncService {

  Timer? _periodicSyncTimer; // 2-minute periodic sync timer
  final Duration periodicSyncDuration = Duration(minutes: 2);
  Timer? _debounceTimer;
  final Duration debounceDuration = Duration(seconds: 5);
  bool isSyncInProgress = false;
  final Function(String) updateMessage;
  final Function(Map<String, dynamic>) onDailyDataReceived;
  final VoidCallback onSyncComplete;
  final bool shouldSync;
  static const platform = MethodChannel('cling_sdk');
  Timer? _retrySyncTimer;
  final Duration retryDuration = Duration(minutes: 5);


  SyncService({
    required this.updateMessage,
    required this.onDailyDataReceived,
    required this.onSyncComplete,
    required this.shouldSync,
  });

  void startSync() async {
    if (!shouldSync || isSyncInProgress) return;

    isSyncInProgress = true;

    final clingHandler = ClingChannelHandler();

    clingHandler.onDailyData = (data) async {
      updateMessage("📥 Received daily data");

      onDailyDataReceived(data);

      await _sendHeartRateToAPI(
        heartRate: data['heartRate']?.toInt() ?? 0,
        totalSteps: data['totalSteps']?.toInt() ?? 0,
        systolicBP: data['iBPHigh']?.toInt() ?? 0,
        diastolicBP: data['iBPLow']?.toInt() ?? 0,
        totalSleep: data['totalSleep']?.toInt() ?? 0,
        totalspo2: data['spo2']?.toInt() ?? 0
      );
    };

    clingHandler.onMinuteData = (List<dynamic> list) async {
      if (list.isEmpty) return;

      final box = await Hive.openBox<MinuteData>('minute_data_box');
      final newItems = list.map((e) => MinuteData(data: Map<String, dynamic>.from(e))).toList();
      await box.addAll(newItems);

      print("✅ Stored ${newItems.length} minute records in Hive");

      await _triggerDebouncedSync();
      await _twominutessync();
      // ⏳ Start debounce logic
    };
  }



  Future<void> syncDeviceData() async {
    try {
      await platform.invokeMethod('syncDeviceData');
    } on PlatformException catch (e) {
      print("Failed to sync data: ${e.message}");
    }
  }

  Future <void> _twominutessync() async{
    print(" Started 2-minute sync timer");
    _periodicSyncTimer?.cancel(); // Cancel if already running

    _periodicSyncTimer = Timer.periodic(periodicSyncDuration, (timer) async {
      print("2-minute timer triggered syncDeviceData");
      await syncDeviceData();
      await _syncHiveDataToApi();
    });


  }


  Future <void> _triggerDebouncedSync() async {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDuration, () async {
      print("No new data in last 3 seconds — syncing to API");
      await _syncHiveDataToApi();
    });
  }

  Future<void> _syncHiveDataToApi() async {
    final box = await Hive.openBox<MinuteData>('minute_data_box');
    final allData = box.values.map((e) => e.data).toList();

    if (allData.isEmpty) {
      isSyncInProgress = false;
      return;
    }

    final success = await sendBulkMinuteDataToApi(allData);

    if (success) {
      print("✅ Sync success: $success");
      await box.clear();
      print("Cleared synced data from Hive:$success");
      onSyncComplete();

      // Cancel any scheduled retry on success
      _retrySyncTimer?.cancel();
      _retrySyncTimer = null;
    } else {
      print("Sync failed, retrying in 5 minutes...");
      // Cancel existing retry timer if it's already running
      _retrySyncTimer?.cancel();

      // Schedule retry after 5 minutes
      _retrySyncTimer = Timer(retryDuration, () async {
        print("Retrying sync after 5 minutes...");
        await _syncHiveDataToApi();
      });
    }

    isSyncInProgress = false;
  }


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
    print("sendHeartRateToAPI");
    final url = Uri.parse("$root/health_variable/add");

    final body = {
      "heart_rate": heartRate.toString(),
      "user_id": user_id,
      "datetime": DateFormat('yyyy-MM-dd hh:mm:ss a').format(DateTime.now()),
      "blood_pressure_systolic": systolicBP.toString(),
      "blood_pressure_diastolic": diastolicBP.toString(),
      "no_of_steps": totalSteps.toString(),
      "sleep": totalSleep.toString(),
      "spo2" : totalspo2.toString(),
      "weight": "50",
      "datetime_now": DateFormat('yyyy-MM-dd').format(DateTime.now()),
    };
    
    print("spo2_data:$body");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: body,
      );

      print("DailyData API response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['status'] == 'SUCCESS') {
          print("DailyData data sent successfully: ${jsonResponse['message'] ?? 'Success'}");
        } else {
          print("API responded but status is not SUCCESS: ${jsonResponse['status']}");
        }
      } else {
        print("Retry after 5 minutes if the request fails: ${response.statusCode}");
        // Retry after 5 minutes if the request fails
        await _retrySendHeartRateToAPI(heartRate, totalSteps, systolicBP, diastolicBP, totalSleep,totalspo2);
      }
    } catch (e) {
      print("Error sending DailyData: $e");
      // // Retry after 5 minutes if there is an error
      // await _retrySendHeartRateToAPI(heartRate, totalSteps, systolicBP, diastolicBP, totalSleep);
    }
  }

  Future<void> _retrySendHeartRateToAPI(
      int heartRate,
      int totalSteps,
      int systolicBP,
      int diastolicBP,
      int totalSleep,
      int totalspo2
      ) async {
    print("Retrying in 5 minutes...");
    // Wait for 5 minutes before retrying the API call
    await Future.delayed(Duration(minutes: 5));
    // Retry sending the heart rate data
    await _sendHeartRateToAPI(
      heartRate: heartRate,
      totalSteps: totalSteps,
      systolicBP: systolicBP,
      diastolicBP: diastolicBP,
      totalSleep: totalSleep,
      totalspo2: totalspo2
    );
  }


  Future<bool> sendBulkMinuteDataToApi(List<Map<String, dynamic>> dataList) async {
    print("sendBulkMinuteDataToApi");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id') ?? "";
    final url = Uri.parse('$root/minute_health_variable/add');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": user_id, "data": dataList}),
      );

      print("Minute data API response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['status'] == "SUCCESS") {
          print("Success message: ${jsonResponse['message'] ?? 'Data sent successfully'}");
          return true;
        } else {
          print("API responded but status is not SUCCESS: ${jsonResponse['status']}");
          return false;
        }
      } else {
        print("Failed to send data. Status code: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error sending minute data: $e");
      return false;
    }
  }


  void dispose() {
    _debounceTimer?.cancel();
    _periodicSyncTimer?.cancel();
    _retrySyncTimer?.cancel();
  }
}
