import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class MinuteDataController {
  static const platform = MethodChannel('cling_sdk');
  String notificationMessage = "Waiting for data...";
  List<Map<String, dynamic>> minuteDataList = [];

  // Timer for periodic sync
  Timer? _syncTimer;

  // Callbacks for the screen to listen for updates
  Function(List<Map<String, dynamic>>) onDataReceived;
  Function(String) onError;

  // Constructor to accept callbacks
  MinuteDataController({required this.onDataReceived, required this.onError});

  // Method to start the syncing process
  void startSyncing() {
    // Set up the method call handler to receive data from Swift
    platform.setMethodCallHandler((call) async {
      if (call.method == "onSyncDataReceived") {
        await _handleMethodCall(call);
      }
    });

    _syncDeviceData();

    // Start periodic syncing every 2 minutes
    _syncTimer = Timer.periodic(Duration(minutes: 2), (timer) {
      if (minuteDataList.isNotEmpty) {
        sendBulkMinuteDataToApi(minuteDataList);
        minuteDataList.clear(); // Clear after sending
      }
      _syncDeviceData(); // This continues to trigger data collection
    });
  }

  // Method to sync data
  Future<void> _syncDeviceData() async {
    try {
      await platform.invokeMethod('syncDeviceData');
    } on PlatformException catch (e) {
      onError("Failed to sync data: ${e.message}");
    }
  }

  // Method to handle incoming data from the method channel
  Future<void> _handleMethodCall(MethodCall call) async {
    final dynamic arguments = call.arguments;
    List<Map<String, dynamic>> receivedList = [];

    if (arguments is List) {
      receivedList = List<Map<String, dynamic>>.from(
        arguments.map((item) => Map<String, dynamic>.from(item)),
      );
    } else if (arguments is Map) {
      receivedList.add(Map<String, dynamic>.from(arguments));
    }

    minuteDataList.addAll(receivedList);
    notificationMessage = "Data Received";

    // Notify the screen with the updated data
    onDataReceived(minuteDataList);
  }

  // Method to send bulk minute data to API
  Future<void> sendBulkMinuteDataToApi(List<Map<String, dynamic>> dataList) async {
    final url = Uri.parse('https://app.aspirehealthspan.ai/aspire_api/minute_health_variable/add');

    print("📤 Sending raw bulk minute data to API");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "user_id": "102",
          "data": dataList,
        }),
      );

      print("📨 Raw Response Body: ${response.body}");
      print("📨 Status Code: ${response.statusCode}");
    } catch (e) {
      print("⚠️ Error sending bulk minute data: $e");
    }
  }

  // Stop the timer when it's no longer needed
  void stopSyncing() {
    _syncTimer?.cancel();
  }
}


