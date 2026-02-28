import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:azpire_new/View/bluetoothscreen.dart';
import 'package:azpire_new/cling_ble_service.dart';
import 'package:azpire_new/root/root.dart';
import 'package:azpire_new/utils/apptext.dart';
import 'package:azpire_new/utils/apptextstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../View/Dashboard_screen.dart';
import '../utils/app_color.dart';


class SyncDataScreen extends StatefulWidget {
  final String deviceID;

  SyncDataScreen({required this.deviceID});

  @override
  _SyncDataScreenState createState() => _SyncDataScreenState();
}

class _SyncDataScreenState extends State<SyncDataScreen> {
  // static const platform = MethodChannel('cling_sdk');
  // static const platform1 = MethodChannel('cling/methods');
  late final MethodChannel platform;


  static const _minuteChannel = EventChannel('cling/minute_data');
  static const _dailyChannel = EventChannel('cling/daily_total');
  //static const MethodChannel _dailyChannel = MethodChannel('cling/daily_total');
  static const _syncStatusChannel = EventChannel('cling/sync_status');
  String notificationMessage = "Waiting for data...";
  Map<String, dynamic>? dailyData;
  Map<String, dynamic>? minuteDataList;
  List<Map<String, dynamic>> _bulkMinuteBuffer = [];
  Timer? _bulkSendTimer;
  Timer? _syncTimer;
  bool _hasNavigatedToDashboard = false; // Flag to track navigation

  StreamSubscription? _minuteSub;
  StreamSubscription? _dailySub;
  StreamSubscription? _syncStatusSub;




  @override
  void initState() {
    super.initState();

    // 🔥 Select correct channel per platform
    if (Platform.isAndroid) {
      platform = const MethodChannel('cling/methods');
    } else if (Platform.isIOS) {
      platform = const MethodChannel('cling_sdk');
    }

    print("🟢 Active MethodChannel: ${platform.name}");

    // 🔥 Register listeners first (VERY IMPORTANT)
    WidgetsBinding.instance.addPostFrameCallback((_) {

      if (Platform.isAndroid) {

        _setupAndroidListeners();

        setState(() {
          notificationMessage = "Waiting for Android sync...";
        });

      } else if (Platform.isIOS) {

        _setupMethodChannelListener();

        _syncDeviceData();

        _syncTimer =
            Timer.periodic(const Duration(minutes: 2), (_) {
              _syncDeviceData();
            });
      }
    });
  }

  //
  // void _setupAndroidListeners() {
  //
  //   _minuteSub = _minuteChannel.receiveBroadcastStream().listen((event) async {
  //
  //     print("📥 Minute data received: $event");
  //
  //     final entry = Map<String, dynamic>.from(event);
  //
  //     _bulkMinuteBuffer.add(entry);
  //
  //     _bulkSendTimer?.cancel();
  //     _bulkSendTimer = Timer(const Duration(seconds: 3), () async {
  //
  //       if (_bulkMinuteBuffer.isNotEmpty) {
  //
  //         await sendBulkMinuteDataToApi(_bulkMinuteBuffer);
  //
  //         _bulkMinuteBuffer.clear();
  //
  //       }
  //
  //     });
  //
  //   });
  //
  //
  //   _dailyChannel.setMethodCallHandler((call) async {
  //
  //     if (call.method == "onDailyData") {
  //
  //       final map = Map<String, dynamic>.from(call.arguments);
  //
  //       print("✅ DAILY DATA RECEIVED: $map");
  //
  //       setState(() {
  //         notificationMessage = "Sync completed";
  //         dailyData = map;
  //       });
  //
  //       Future.delayed(const Duration(milliseconds: 1500), () {
  //         _navigateToDashboard();
  //       });
  //
  //
  //     }
  //
  //   });
  //
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     _syncDeviceData();
  //   });
  //
  // }

  void _setupAndroidListeners() {

    // // ✅ Minute Data Listener (ANDROID)
    // _minuteSub = _minuteChannel.receiveBroadcastStream().listen((event) {
    //
    //   print("📥 Minute data received (Android): $event");
    //
    //   // ❌ Do NOT send to API
    //   // ❌ Do NOT buffer
    //   // ❌ Do NOT call sendBulkMinuteDataToApi
    //
    //   if (!_hasNavigatedToDashboard) {
    //     _hasNavigatedToDashboard = true;
    //     _navigateToDashboard();
    //   }
    // });


    // ✅ Daily Data Listener (ANDROID)
    // _dailyChannel.setMethodCallHandler((call) async {
    //
    //   if (call.method == "onDailyData") {
    //
    //     final map = Map<String, dynamic>.from(call.arguments);
    //
    //     print("✅ DAILY DATA RECEIVED (Android): $map");
    //
    //     setState(() {
    //       notificationMessage = "Sync completed";
    //       dailyData = map;
    //     });
    //
    //     // ❌ Do NOT call _sendHeartRateToAPI
    //     // ❌ Do NOT call sendBulkMinuteDataToApi
    //
    //     Future.delayed(const Duration(milliseconds: 800), () {
    //       if (!_hasNavigatedToDashboard) {
    //         _hasNavigatedToDashboard = true;
    //         _navigateToDashboard();
    //       }
    //     });
    //   }
    // });

    _dailySub = _dailyChannel
        .receiveBroadcastStream()
        .listen((event) {

      print("🟢 ANDROID DAILY DATA RECEIVED:");
      print("📦 $event");

      if (event is! Map) {
        print("❌ Daily event is not a Map");
        return;
      }

      final map = Map<String, dynamic>.from(event);

      setState(() {
        notificationMessage = "Sync completed";
        dailyData = map;
      });

      // ❌ Do NOT call _sendHeartRateToAPI
      // ❌ Do NOT call sendBulkMinuteDataToApi

      Future.delayed(const Duration(milliseconds: 800), () {
        if (!_hasNavigatedToDashboard) {
          _hasNavigatedToDashboard = true;
          _navigateToDashboard();
        }
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncDeviceData();
    });
  }



  @override
  void dispose() {
    _syncTimer?.cancel();
    _bulkSendTimer?.cancel();

    _minuteSub?.cancel();
    _dailySub?.cancel();
    _syncStatusSub?.cancel();

    super.dispose();
  }

  // Future<void> _syncDeviceData() async {
  //   setState(() {
  //     notificationMessage = "Syncing data...";
  //     dailyData = null; // Reset UI before syncing
  //   });
  //
  //   try {
  //     await platform.invokeMethod('syncDeviceData');
  //   } on PlatformException catch (e) {
  //     setState(() {
  //       notificationMessage = "Failed to sync data: ${e.message}";
  //     });
  //   }
  // }

  Future<void> _syncDeviceData() async {
    setState(() {
      notificationMessage = "Syncing data...";
      dailyData = null;
    });

    try {
      if (Platform.isAndroid) {
        try {

          print("🚀 Calling loadDeviceData from Flutter");

          final result = await platform.invokeMethod("loadDeviceData");

          print("Sync started: $result");

          setState(() {
            notificationMessage = "Sync started...";
          });

        }
        catch (e) {

          print("Sync start failed: $e");

          setState(() {
            notificationMessage = "Sync failed to start";
          });

        }
      }

      if (Platform.isIOS) {
        print("🍎 iOS calling syncDeviceData()");
        await platform.invokeMethod('syncDeviceData');
      }
    } on PlatformException catch (e) {
      setState(() {
        notificationMessage = "Failed to sync data: ${e.message}";
      });
    } catch (e) {
      setState(() {
        notificationMessage = "Sync error: $e";
      });
    }
  }



  void _setupMethodChannelListener() {
    platform.setMethodCallHandler((call) async {
      print("Method call received: ${call.method}");

      bool dataHandled = false;

      if (call.method == "onDailyTotalReceived") {
        print("Method call received1: ${call.method}");
        setState(() {
          notificationMessage = "Received daily data";
          dailyData = Map<String, dynamic>.from(call.arguments);
        });

        print("Daily Data Map: $dailyData");
        print("Daily Data Keys: ${dailyData!.keys}");

        print("Raw heart rate value: ${dailyData!['heartRate']}");
        print("Raw totalSteps value: ${dailyData!['totalSteps']}");
        print("Raw systolicBP value: ${dailyData!['iBPHigh']}");
        print("Raw diastolicBP value: ${dailyData!['iBPLow']}");
        print("Raw totalSleep value: ${dailyData!['totalSleep']}");

        if (dailyData != null) {
          int heartRate = dailyData?['heartRate']?.toInt() ?? 0;
          int totalSteps = dailyData?['totalSteps']?.toInt() ?? 0;
          int systolicBP = dailyData?['iBPHigh']?.toInt() ?? 0;
          int diastolicBP = dailyData?['iBPLow']?.toInt() ?? 0;
          int totalSleep = dailyData?['totalSleep']?.toInt() ?? 0;

          await _sendHeartRateToAPI(heartRate, totalSteps, systolicBP, diastolicBP, totalSleep);
          if (!_hasNavigatedToDashboard) {
                      _hasNavigatedToDashboard = true;
                      _navigateToDashboard();
                    }

        } else {
          print("Heart rate key not found in dailyData!");
        }

      } if (call.method == "onSyncDataReceived") {
        print("Method call received: ${call.method}");

        setState(() {
          notificationMessage = "Received minute-level sync data";
        });

        try {
          var response = call.arguments;
          print("📦 Full onSyncDataReceived response: $response");

          List<Map<String, dynamic>> parsedDataList = [];

          if (response is List) {
            // Case: List of maps
            parsedDataList = response
                .map((item) => Map<String, dynamic>.from(item))
                .toList();
          } else if (response is Map) {
            Map<String, dynamic> entry = Map<String, dynamic>.from(response);
            _bulkMinuteBuffer.add(entry);

            // Delay sending to allow buffering multiple records
            _bulkSendTimer?.cancel();
            _bulkSendTimer = Timer(Duration(seconds: 3), () async {
              if (_bulkMinuteBuffer.isNotEmpty) {
                print("📤 Sending ${_bulkMinuteBuffer.length} minute records in bulk");
                await sendBulkMinuteDataToApi(_bulkMinuteBuffer);
                _bulkMinuteBuffer.clear();

                if (!_hasNavigatedToDashboard) {
                  _hasNavigatedToDashboard = true;
                  _navigateToDashboard();
                }
              }
            });
          }
          else {
            print("⚠️ Unknown response format in minute sync data.");
            return;
          }

          for (var entry in parsedDataList) {
            print("🕒 Minute Entry: $entry");
          }

          await sendBulkMinuteDataToApi(parsedDataList);

          if (!_hasNavigatedToDashboard) {
            _hasNavigatedToDashboard = true;
            _navigateToDashboard();
          }

        } catch (e) {
          print("⚠️ Error handling minute sync data: $e");
        }
      }

    });
  }


  Future<void> sendBulkMinuteDataToApi(List<Map<String, dynamic>> dataList) async {
    final url = Uri.parse('$root/minute_health_variable/add');

    print("📤 Sending raw bulk minute data to API");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id') ?? "";
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "user_id": user_id,
          "data": dataList,
        }),
      );

      print("📨 Raw Response Body: ${response.body}");
      print("📨 Status Code: ${response.statusCode}");
    } catch (e) {
      print("⚠️ Error sending bulk minute data: $e");
    }
  }

  Future<void> _sendHeartRateToAPI(int heartRate, int totalSteps, int systolicBP, int diastolicBP, int totalSleep) async {
    String formattedDate = DateFormat('yyyy-MM-dd hh:mm:ss a').format(DateTime.now());
    String formattedDate1 = DateFormat('yyyy-MM-dd').format(DateTime.now());
    print("Helooo123");
    print("heartRate${heartRate.toString()}");
    print("systolicBP${systolicBP.toString()}");
    print("diastolicBP${diastolicBP.toString()}");
    print("totalSteps${totalSteps.toString()}");
    print("totalSleep${totalSleep.toString()}");
    print("formattedDate1${formattedDate1}");
    print("formattedDate${formattedDate}");
    final url = Uri.parse("$root/health_variable/add");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id') ?? "";

    final body = {
      "heart_rate": heartRate.toString(),
      "user_id":user_id,
      "datetime": formattedDate,
      "blood_pressure_systolic": systolicBP.toString(),
      "blood_pressure_diastolic": diastolicBP.toString(),
      "no_of_steps": totalSteps.toString(),
      "sleep": totalSleep.toString(),
      "weight": "50",
      "datetime_now": formattedDate1,
    };

    print("health_data:$body");


    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded"
        },
        body: body, // Send as form-data
      );

      final responseData = jsonDecode(response.body);
      print("status code: ${response.statusCode}");
      print("responseData:1234 $responseData");

      if (response.statusCode == 201 && responseData['status'] == 'SUCCESS') {
        print("Heart rate sent successfully: $responseData");
      } else {
        print("API error: ${responseData['message']}");
      }
    } catch (e) {
      print("Error sending heart rate: $e");
    }
  }
  void _navigateToDashboard() {
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen(deviceID: widget.deviceID,)),
      );
    }
  }


  // @override
  // void dispose() {
  //   _syncTimer?.cancel(); // Stop the periodic timer when widget is disposed
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor:Colors.white,
        title: Text(AppText.sync_headings,
          style: Apptextstyle.s18wbap,),
        leading: IconButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => BluetoothPair()));
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _syncDeviceData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.others, // Button background color
                  foregroundColor: Colors.white, // Text (and icon) color
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                ),
                child: const Text("Sync Data"),
              ),
              SizedBox(height: 20),
              Text(notificationMessage,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              dailyData != null
                  ? Column(
                children: dailyData!.entries.map((entry) {
                  return Text("${entry.key}: ${entry.value}",
                      style: TextStyle(fontSize: 16));
                }).toList(),
              )
                  : CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}







// class _SyncDataScreenState extends State<SyncDataScreen> {
//   static const platform = MethodChannel('cling_sdk');
//   String notificationMessage = "Waiting for data...";
//   Map<String, dynamic>? dailyData;
//   Map<String, dynamic>? minuteDataList;
//   List<Map<String, dynamic>> _bulkMinuteBuffer = [];
//   Timer? _bulkSendTimer;
//   Timer? _syncTimer;
//   bool _hasNavigatedToDashboard = false; // Flag to track navigation
//
//
//   @override
//   void initState() {
//     super.initState();
//     _setupMethodChannelListener();
//     _syncDeviceData();
//     // Start periodic syncing every 30 seconds
//     _syncTimer = Timer.periodic(Duration(minutes: 2), (timer) {
//       _syncDeviceData();
//     });
//   }
//
//   Future<void> _syncDeviceData() async {
//     setState(() {
//       notificationMessage = "Syncing data...";
//       dailyData = null; // Reset UI before syncing
//     });
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
//   // void _setupMethodChannelListener() {
//   //   platform.setMethodCallHandler((call) async {
//   //     print("Method call received: ${call.method}");
//   //     if (call.method == "onDailyTotalReceived") {
//   //       print("Method call received1: ${call.method}");
//   //       setState(() {
//   //         notificationMessage = "Received daily data";
//   //         dailyData = Map<String, dynamic>.from(call.arguments);
//   //       });
//   //
//   //       print("Daily Data Map: $dailyData"); // Log full map to debug key names
//   //       print("Daily Data Keys: ${dailyData!.keys}"); // Debug keys
//   //       //print("Daily Data Keys: ${dailyData!.values}"); // Debug keys
//   //
//   //       print("Raw heart rate value: ${dailyData!['heartRate']}"); // Debug heart rate extraction
//   //       print("Raw totalSteps value: ${dailyData!['totalSteps']}"); // Debug heart rate extraction
//   //       print("Raw systolicBP value: ${dailyData!['iBPHigh']}"); // Debug heart rate extraction
//   //       print("Raw diastolicBP value: ${dailyData!['iBPLow']}"); // Debug heart rate extraction
//   //       print("Raw totalSleep value: ${dailyData!['totalSleep']}"); // Debug heart rate extraction
//   //
//   //       // Extract heart rate and send to API
//   //       if (dailyData != null) { // Ensure correct key
//   //         int heartRate = dailyData?['heartRate']?.toInt() ?? 0;
//   //         int totalSteps = dailyData?['totalSteps']?.toInt() ?? 0;
//   //         int systolicBP = dailyData?['iBPHigh']?.toInt() ?? 0;
//   //         int diastolicBP = dailyData?['iBPLow']?.toInt() ?? 0;
//   //         int totalSleep = dailyData?['totalSleep']?.toInt() ?? 0;
//   //         await _sendHeartRateToAPI(heartRate, totalSteps, systolicBP, diastolicBP, totalSleep);
//   //
//   //         // Navigate to DashboardScreen only once after first successful sync
//   //         if (!_hasNavigatedToDashboard) {
//   //           _hasNavigatedToDashboard = true;
//   //           _navigateToDashboard();
//   //         }
//   //       } else {
//   //         print("Heart rate key not found in dailyData!");
//   //       }
//   //     }
//   //     //minutedata
//   //     if (call.method == "onSyncDataReceived") {
//   //       print("Method call received: ${call.method}");
//   //
//   //       setState(() {
//   //         notificationMessage = "Received minute-level sync data";
//   //       });
//   //
//   //       try {
//   //         // Parse the data from the arguments
//   //         List<dynamic> rawDataList = call.arguments;
//   //         print("📦 Raw minute data received: $rawDataList");
//   //
//   //         // Convert to List<Map<String, dynamic>> for the API
//   //         List<Map<String, dynamic>> parsedDataList = rawDataList
//   //             .map((item) => Map<String, dynamic>.from(item))
//   //             .toList();
//   //
//   //         // Log parsed data
//   //         for (var entry in parsedDataList) {
//   //           print("🕒 Minute Entry: $entry");
//   //         }
//   //
//   //         // Send to API
//   //         await sendBulkMinuteDataToApi(parsedDataList);
//   //
//   //       } catch (e) {
//   //         print("⚠️ Error handling minute sync data: $e");
//   //       }
//   //     }
//   //   });
//   // }
//
//   void _setupMethodChannelListener() {
//     platform.setMethodCallHandler((call) async {
//       print("Method call received: ${call.method}");
//
//       bool dataHandled = false;
//
//       if (call.method == "onDailyTotalReceived") {
//         print("Method call received1: ${call.method}");
//         setState(() {
//           notificationMessage = "Received daily data";
//           dailyData = Map<String, dynamic>.from(call.arguments);
//         });
//
//         print("Daily Data Map: $dailyData");
//         print("Daily Data Keys: ${dailyData!.keys}");
//
//         print("Raw heart rate value: ${dailyData!['heartRate']}");
//         print("Raw totalSteps value: ${dailyData!['totalSteps']}");
//         print("Raw systolicBP value: ${dailyData!['iBPHigh']}");
//         print("Raw diastolicBP value: ${dailyData!['iBPLow']}");
//         print("Raw totalSleep value: ${dailyData!['totalSleep']}");
//
//         if (dailyData != null) {
//           int heartRate = dailyData?['heartRate']?.toInt() ?? 0;
//           int totalSteps = dailyData?['totalSteps']?.toInt() ?? 0;
//           int systolicBP = dailyData?['iBPHigh']?.toInt() ?? 0;
//           int diastolicBP = dailyData?['iBPLow']?.toInt() ?? 0;
//           int totalSleep = dailyData?['totalSleep']?.toInt() ?? 0;
//
//           await _sendHeartRateToAPI(heartRate, totalSteps, systolicBP, diastolicBP, totalSleep);
//           if (!_hasNavigatedToDashboard) {
//             _hasNavigatedToDashboard = true;
//             _navigateToDashboard();
//           }
//
//         } else {
//           print("Heart rate key not found in dailyData!");
//         }
//
//       } if (call.method == "onSyncDataReceived") {
//         print("Method call received: ${call.method}");
//
//         setState(() {
//           notificationMessage = "Received minute-level sync data";
//         });
//
//         try {
//           var response = call.arguments;
//           print("📦 Full onSyncDataReceived response: $response");
//
//           List<Map<String, dynamic>> parsedDataList = [];
//
//           if (response is List) {
//             // Case: List of maps
//             parsedDataList = response
//                 .map((item) => Map<String, dynamic>.from(item))
//                 .toList();
//           } else if (response is Map) {
//             Map<String, dynamic> entry = Map<String, dynamic>.from(response);
//             _bulkMinuteBuffer.add(entry);
//
//             // Delay sending to allow buffering multiple records
//             _bulkSendTimer?.cancel();
//             _bulkSendTimer = Timer(Duration(seconds: 3), () async {
//               if (_bulkMinuteBuffer.isNotEmpty) {
//                 print("📤 Sending ${_bulkMinuteBuffer.length} minute records in bulk");
//                 await sendBulkMinuteDataToApi(_bulkMinuteBuffer);
//                 _bulkMinuteBuffer.clear();
//
//                 if (!_hasNavigatedToDashboard) {
//                   _hasNavigatedToDashboard = true;
//                   _navigateToDashboard();
//                 }
//               }
//             });
//           }
//           else {
//             print("⚠️ Unknown response format in minute sync data.");
//             return;
//           }
//
//           for (var entry in parsedDataList) {
//             print("🕒 Minute Entry: $entry");
//           }
//
//           await sendBulkMinuteDataToApi(parsedDataList);
//
//           if (!_hasNavigatedToDashboard) {
//             _hasNavigatedToDashboard = true;
//             _navigateToDashboard();
//           }
//
//         } catch (e) {
//           print("⚠️ Error handling minute sync data: $e");
//         }
//       }
//
//     });
//   }
//
//
//   Future<void> sendBulkMinuteDataToApi(List<Map<String, dynamic>> dataList) async {
//     final url = Uri.parse('$root/minute_health_variable/add');
//
//     print("📤 Sending raw bulk minute data to API");
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     var user_id = prefs.getString('user_id') ?? "";
//     try {
//       final response = await http.post(
//         url,
//         headers: {
//           "Content-Type": "application/json",
//         },
//         body: jsonEncode({
//           "user_id": user_id,
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
//
//   Future<void> _sendHeartRateToAPI(int heartRate, int totalSteps, int systolicBP, int diastolicBP, int totalSleep) async {
//     String formattedDate = DateFormat('yyyy-MM-dd hh:mm:ss a').format(DateTime.now());
//     String formattedDate1 = DateFormat('yyyy-MM-dd').format(DateTime.now());
//     print("Helooo123");
//     print("heartRate${heartRate.toString()}");
//     print("systolicBP${systolicBP.toString()}");
//     print("diastolicBP${diastolicBP.toString()}");
//     print("totalSteps${totalSteps.toString()}");
//     print("totalSleep${totalSleep.toString()}");
//     print("formattedDate1${formattedDate1}");
//     print("formattedDate${formattedDate}");
//     final url = Uri.parse("$root/health_variable/add");
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     var user_id = prefs.getString('user_id') ?? "";
//
//     final body = {
//       "heart_rate": heartRate.toString(),
//       "user_id":user_id,
//       "datetime": formattedDate,
//       "blood_pressure_systolic": systolicBP.toString(),
//       "blood_pressure_diastolic": diastolicBP.toString(),
//       "no_of_steps": totalSteps.toString(),
//       "sleep": totalSleep.toString(),
//       "weight": "50",
//       "datetime_now": formattedDate1,
//     };
//
//
//
//     try {
//       final response = await http.post(
//         url,
//         headers: {
//           "Content-Type": "application/x-www-form-urlencoded"
//         },
//         body: body, // Send as form-data
//       );
//
//       final responseData = jsonDecode(response.body);
//       print("status code: ${response.statusCode}");
//       print("responseData:1234 $responseData");
//
//       if (response.statusCode == 201 && responseData['status'] == 'SUCCESS') {
//         print("Heart rate sent successfully: $responseData");
//       } else {
//         print("API error: ${responseData['message']}");
//       }
//     } catch (e) {
//       print("Error sending heart rate: $e");
//     }
//   }
//   void _navigateToDashboard() {
//     if (mounted) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => DashboardScreen(deviceID: widget.deviceID,)),
//       );
//     }
//   }
//
//
//   @override
//   void dispose() {
//     _syncTimer?.cancel(); // Stop the periodic timer when widget is disposed
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor:Colors.white,
//         title: Text(AppText.sync_headings,
//           style: Apptextstyle.s18wbap,),
//         leading: IconButton(
//           onPressed: () {
//             Navigator.push(context, MaterialPageRoute(builder: (context) => BluetoothPair()));
//           },
//           icon: Icon(Icons.arrow_back_ios),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ElevatedButton(
//                 onPressed: _syncDeviceData,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.others, // Button background color
//                   foregroundColor: Colors.white, // Text (and icon) color
//                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10), // Rounded corners
//                   ),
//                 ),
//                 child: const Text("Sync Data"),
//               ),
//               SizedBox(height: 20),
//               Text(notificationMessage,
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               SizedBox(height: 20),
//               dailyData != null
//                   ? Column(
//                 children: dailyData!.entries.map((entry) {
//                   return Text("${entry.key}: ${entry.value}",
//                       style: TextStyle(fontSize: 16));
//                 }).toList(),
//               )
//                   : CircularProgressIndicator(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

