import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../Cling Connections/minute_data.dart';


class MinuteData extends StatefulWidget {
  const MinuteData({super.key});

  @override
  State<MinuteData> createState() => _MinuteDataState();
}

class _MinuteDataState extends State<MinuteData> {
  static const platform = MethodChannel('cling_sdk');
  String notificationMessage = "Waiting for data...";
  List<Map<String, dynamic>> minuteDataList = [];
  Timer? _syncTimer;

  @override
  void initState() {
    super.initState();

    platform.setMethodCallHandler(_handleMethodCall);
    _syncDeviceData();

    // Periodic 2-minute sync
    _syncTimer = Timer.periodic(Duration(minutes: 2), (timer) async {
      if (minuteDataList.isNotEmpty) {
        print("⏱ Triggered 2-minute sync...");
        await sendBulkMinuteDataToApi(minuteDataList);
        minuteDataList.clear();
      }
      _syncDeviceData(); // Continue syncing with device
    });
  }

  Future<void> sendBulkMinuteDataToApi(List<Map<String, dynamic>> dataList) async {
    final url = Uri.parse('https://app.aspirehealthspan.ai/aspire_api/minute_health_variable/add');

    print("📤 Sending bulk minute data to API...");

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

      print("📨 Response Status: ${response.statusCode}");
      print("📨 Response Body: ${response.body}");
    } catch (e) {
      print("⚠️ Error sending data to API: $e");
    }
  }

  Future<void> _syncDeviceData() async {
    if (mounted) {
      setState(() {
        notificationMessage = "Syncing data...";
      });
    }

    try {
      await platform.invokeMethod('syncDeviceData');
    } on PlatformException catch (e) {
      if (mounted) {
        setState(() {
          notificationMessage = "Failed to sync: ${e.message}";
        });
      }
    }
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method == "onSyncDataReceived") {
      final dynamic arguments = call.arguments;
      List<Map<String, dynamic>> receivedList = [];

      if (arguments is List) {
        receivedList = List<Map<String, dynamic>>.from(
          arguments.map((item) => Map<String, dynamic>.from(item)),
        );
      } else if (arguments is Map) {
        receivedList.add(Map<String, dynamic>.from(arguments));
      }

      // Add to buffer
      setState(() {
        minuteDataList.addAll(receivedList);
        notificationMessage = "Data Received";
      });

      // Immediately send only the new data (not entire buffer)
      //   if (receivedList.isNotEmpty) {
      //     print("Immediate send on new data...");
      //     await sendBulkMinuteDataToApi(receivedList);
      //   }
      // }
    }
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFffffff),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Minute Data'),
        backgroundColor: Color(0xFFffffff),
      ),
      body: minuteDataList.isEmpty
          ? Center(child: Text(notificationMessage))
          : Padding(
        padding: const EdgeInsets.fromLTRB(30, 50, 0, 0),
        child: ListView.builder(
          itemCount: minuteDataList.length,
          itemBuilder: (context, index) {
            final data = minuteDataList[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Time: ${data['formattedIST']}"),
                  Text("Heart Rate: ${data['heartRate']}"),
                  Text("Walk Steps: ${data['walkSteps']}"),
                  Text("Run Steps: ${data['runSteps']}"),
                  Text("BP Low: ${data['bp_low']}"),
                  Text("BP High: ${data['bp_high']}"),
                  Text("SpO2: ${data['spo2']}"),
                  Text("Sleep State: ${data['sleepState']}"),
                  Text("Sleep Seconds: ${data['sleepSeconds']}"),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}


// class _MinuteDataState extends State<MinuteData> {
//   static const platform = MethodChannel('cling_sdk');
//   String notificationMessage = "Waiting for data...";
//   List<Map<String, dynamic>> minuteDataList = []; // List to hold minute data
//   Timer? _syncTimer;
//
//   @override
//   void initState() {
//     super.initState();
//     // Set up the method call handler to receive data from Swift
//     platform.setMethodCallHandler(_handleMethodCall);
//     _syncDeviceData();
//
//     // Start periodic syncing every 10 minutes
//     _syncTimer = Timer.periodic(Duration(minutes: 2), (timer) {
//       if (minuteDataList.isNotEmpty) {
//         sendBulkMinuteDataToApi(minuteDataList);
//         minuteDataList.clear(); // Clear after sending
//       }
//       _syncDeviceData(); // This continues to trigger data collection
//     });
//   }
//
//
//
//
//   Future<void> sendBulkMinuteDataToApi(List<Map<String, dynamic>> dataList) async {
//     final url = Uri.parse('https://app.aspirehealthspan.ai/aspire_api/minute_health_variable/add');
//
//     print("📤 Sending raw bulk minute data to API");
//
//     try {
//       final response = await http.post(
//         url,
//         headers: {
//           "Content-Type": "application/json",
//
//         },
//         body: jsonEncode({
//           "user_id": "102",
//           "data": dataList,
//         }),
//       );
//
//       print("📨 Raw Response Body: ${response.body}");
//       print("📨 Status Code: ${response.statusCode}");
//     } catch (e) {
//       print("⚠️ Error sending bulk minute data: $e");
//     }
//   }
//
//   // Method to sync data
//   Future<void> _syncDeviceData() async {
//     if(mounted)
//       setState(() {
//         notificationMessage = "Syncing data...";
//       });
//
//     try {
//       await platform.invokeMethod('syncDeviceData');
//     } on PlatformException catch (e) {
//       setState(() {
//         notificationMessage = "Failed to sync data: ${e.message}";
//       });
//     }
//   }
//
//   // Method to handle incoming data from the method channel
//   Future<void> _handleMethodCall(MethodCall call) async {
//     if (call.method == "onSyncDataReceived") {
//       final dynamic arguments = call.arguments;
//       List<Map<String, dynamic>> receivedList = [];
//
//       if (arguments is List) {
//         receivedList = List<Map<String, dynamic>>.from(
//           arguments.map((item) => Map<String, dynamic>.from(item)),
//         );
//       } else if (arguments is Map) {
//         receivedList.add(Map<String, dynamic>.from(arguments));
//       }
//
//       setState(() {
//         minuteDataList.addAll(receivedList); // Just add to main list
//         notificationMessage = "Data Received";
//       });
//
//     }
//   }
//
//   @override
//   void dispose() {
//     // TODO: implement dispose
//     super.dispose();
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFffffff),
//       appBar: AppBar(
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         title: Text('Minute Data'),
//         backgroundColor: Color(0xFFffffff),
//       ),
//       body: minuteDataList.isEmpty
//           ? Center(child: Text(notificationMessage))
//           : Padding(
//         padding: const EdgeInsets.fromLTRB(30, 50, 0, 0),
//         child: ListView.builder(
//           itemCount: minuteDataList.length,
//           itemBuilder: (context, index) {
//             final data = minuteDataList[index];
//             return Padding(
//               padding: const EdgeInsets.only(bottom: 20.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text("Time: ${data['formattedIST']}"),
//                   Text("Heart Rate: ${data['heartRate']}"),
//                   Text("Walk Steps: ${data['walkSteps']}"),
//                   Text("Run Steps: ${data['runSteps']}"),
//                   Text("BP Low: ${data['bp_low']}"),
//                   Text("BP High: ${data['bp_high']}"),
//                   Text("SpO2: ${data['spo2']}"),
//                   Text("Sleep State: ${data['sleepState']}"),
//                   Text("Sleep Seconds: ${data['sleepSeconds']}"),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

