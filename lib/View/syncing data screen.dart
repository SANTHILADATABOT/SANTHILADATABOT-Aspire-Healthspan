import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:azpire_new/Cling%20Connections/clingchannelHandler.dart';
import 'package:azpire_new/View/bluetoothscreen.dart';
import 'package:azpire_new/cling_ble_service.dart';
import 'package:azpire_new/root/root.dart';
import 'package:azpire_new/utils/apptext.dart';
import 'package:azpire_new/utils/apptextstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
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

  late final MethodChannel platform;
  static const _minuteChannel = EventChannel('cling/minute_data');
  static const _dailyChannel = EventChannel('cling/daily_total');
  static const _syncStatusChannel = EventChannel('cling/sync_status');
  String notificationMessage = "Waiting for data...";
  Map<String, dynamic>? dailyData;
  Map<String, dynamic>? minuteDataList;
  List<Map<String, dynamic>> _bulkMinuteBuffer = [];
  Timer? _bulkSendTimer;
  Timer? _syncTimer;
  bool _hasNavigatedToDashboard = false; // Flag to track navigation
  static const MethodChannel androidChannel = MethodChannel('cling/methods');
  StreamSubscription? _minuteSub;
  StreamSubscription? _dailySub;
  StreamSubscription? _syncStatusSub;

  static const _pairStatusChannel = EventChannel('cling/pair_status');
  StreamSubscription? _pairSub;


  // @override
  // void initState() {
  //   super.initState();
  //
  //   if (Platform.isAndroid) {
  //     platform = const MethodChannel('cling/methods');
  //   } else if (Platform.isIOS) {
  //     platform = const MethodChannel('cling_sdk');
  //   }
  //
  //   print("🟢 Active MethodChannel: ${platform.name}");
  //
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //
  //     if (Platform.isAndroid) {
  //
  //       ClingChannelHandler().initialize();
  //
  //       // 1️⃣ First attach listeners
  //       _setupAndroidListeners();
  //
  //       // 2️⃣ Then call reconnect ONCE
  //       _syncDeviceData();
  //
  //     }
  //
  //     else if (Platform.isIOS) {
  //
  //       // ✅ Set up listener FIRST before any sync attempt.
  //       // The listener handles onDeviceConnected from native, which fires
  //       // inside serviceChange() after downloadPhoneSettingFinished() unlocks
  //       // the SDK data pipeline.
  //       _setupMethodChannelListener();
  //
  //       // ✅ Fallback: if onDeviceConnected is never received within 6s
  //       // (e.g. device was already connected before screen opened),
  //       // trigger sync manually.
  //       _syncTimer = Timer(const Duration(seconds: 6), () {
  //         if (!_hasNavigatedToDashboard && mounted) {
  //           print("⏱️ Fallback: triggering syncDeviceData after 6s timeout");
  //           _syncDeviceData();
  //         }
  //       });
  //     }
  //   });
  // }

  @override
  void initState() {
    super.initState();
    print("🔥 Sync Screen DeviceID = ${widget.deviceID}");
    if (Platform.isAndroid) {
      platform = const MethodChannel('cling/methods');
    } else if (Platform.isIOS) {
      platform = const MethodChannel('cling_sdk');
    }
    print("🟢 Active MethodChannel: ${platform.name}");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Platform.isAndroid) {
        ClingChannelHandler().initialize();
        _setupAndroidListeners();
        _syncDeviceData();
      } else if (Platform.isIOS) {
        // ✅ Set up listener FIRST, BEFORE any sync call
        _setupMethodChannelListener();
        // ✅ Wait for native "onDeviceConnected" signal.
        // If it doesn't arrive within 6 seconds, retry sync manually.
        _syncTimer = Timer(const Duration(seconds: 6), () {
          print("⏱️ Fallback: triggering syncDeviceData after 6s timeout");
          _syncDeviceData();
        });
      }
    });
  }

  // void _setupAndroidListeners() {
  //
  //   // 1️⃣ Listen for pair success
  //   _pairSub = _pairStatusChannel
  //       .receiveBroadcastStream()
  //       .listen((event) async {
  //
  //     print("🔥 Pair success received from native: $event");
  //
  //     // Now device is 100% connected
  //     print("🔥 Now calling loadDeviceData safely");
  //
  //     await androidChannel.invokeMethod("loadDeviceData");
  //   });
  //
  //   // 2️⃣ Listen for daily data
  //   _dailySub = _dailyChannel
  //       .receiveBroadcastStream()
  //       .listen((event) {
  //
  //     print("🟢 ANDROID DAILY TOTAL DATA RECEIVED");
  //     print(event);
  //
  //     if (event is! Map) return;
  //
  //     final map = Map<String, dynamic>.from(event);
  //
  //     setState(() {
  //       notificationMessage = "Sync completed";
  //       dailyData = map;
  //     });
  //
  //     if (!_hasNavigatedToDashboard) {
  //       _hasNavigatedToDashboard = true;
  //       _navigateToDashboard();
  //     }
  //   });
  // }



  @override
  void dispose() {
    _syncTimer?.cancel();
    _bulkSendTimer?.cancel();
    _pairSub?.cancel();
    _minuteSub?.cancel();
    _dailySub?.cancel();
    _syncStatusSub?.cancel();

    super.dispose();
  }

  Future<void> _syncDeviceData() async {
    // setState(() {
    //   notificationMessage = "Syncing data...";
    //   dailyData = null;
    // });

    try {
      if (Platform.isAndroid) {
        print("🔁 Connecting by clingId (Two-part process via Native)");

        setState(() {
          notificationMessage = "Syncing data...";
          dailyData = null;
        });

        await androidChannel.invokeMethod("autoReconnect", {
          "clingId": widget.deviceID
        });
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

  void _setupAndroidListeners() {

    // 1️⃣ Listen for pair success
    _pairSub = _pairStatusChannel
        .receiveBroadcastStream()
        .listen((event) async {

      print("🔥 Pair success received from native: $event");

      try {
        // Ensure device is fully ready before loading data
        // await Future.delayed(const Duration(milliseconds: 500));

        print("🔥 Calling loadDeviceData after pair success");

        await androidChannel.invokeMethod("loadDeviceData");

      } catch (e) {
        print("⚠️ Error calling loadDeviceData: $e");
      }
    });

    // 2️⃣ Listen for daily data
    _dailySub = _dailyChannel
        .receiveBroadcastStream()
        .listen((event) async {

      print("🟢 ANDROID DAILY TOTAL DATA RECEIVED");
      print(event);

      if (event is! Map) {
        print("⚠️ Invalid daily data format");
        return;
      }

      final map = Map<String, dynamic>.from(event);

      setState(() {
        notificationMessage = "Sync completed";
        dailyData = map;
      });

      try {
        // ✅ Extract values safely
        int heartRate = (map['heartRate'] ?? 0).toInt();
        int totalSteps = (map['totalSteps'] ?? 0).toInt();
        int systolicBP = (map['iBPHigh'] ?? 0).toInt();
        int diastolicBP = (map['iBPLow'] ?? 0).toInt();
        int totalSleep = (map['totalSleep'] ?? 0).toInt();
        int totalspo2 = (map['spo2']?? 0).toInt();

        print("🔥 CALLING API FROM EVENT CHANNEL");
        print("HR: $heartRate, Steps: $totalSteps, SYS: $systolicBP, DIA: $diastolicBP, Sleep: $totalSleep, spo2:$totalspo2", );

        // ✅ Call API (MAIN FIX)
        await _sendHeartRateToAPI(
            heartRate,
            totalSteps,
            systolicBP,
            diastolicBP,
            totalSleep,
            totalspo2
        );

      } catch (e) {
        print("⚠️ Error while sending daily data to API: $e");
      }

      // ✅ Navigate only once
      if (!_hasNavigatedToDashboard) {
        _hasNavigatedToDashboard = true;
        _navigateToDashboard();
      }
    }, onError: (error) {
      print("❌ Daily channel error: $error");
    });
  }



  void _setupMethodChannelListener() {
    platform.setMethodCallHandler((call) async {
      print("Method call received: ${call.method}");

      // ✅ Native confirms BLE service is stable and data pipeline is unlocked
      if (call.method == "onDeviceConnected") {
        print("✅ onDeviceConnected received — triggering sync now");
        _syncTimer?.cancel(); // Cancel the fallback timer
        await _syncDeviceData();
        return;
        // print("✅ onDeviceConnected received — cancelling fallback timer and triggering sync");
        // _syncTimer?.cancel();
        // if (!_hasNavigatedToDashboard && mounted) {
        //   await _syncDeviceData();
        // }
        // return;
      }

      bool dataHandled = false;

      if (call.method == "onDailyTotalReceived") {
        print("Method call received1: ${call.method}");
        if (!mounted) return;
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
        print("Raw totalSpo2 value: ${dailyData!['spo2']}");

        if (dailyData != null) {
          int heartRate = dailyData?['heartRate']?.toInt() ?? 0;
          int totalSteps = dailyData?['totalSteps']?.toInt() ?? 0;
          int systolicBP = dailyData?['iBPHigh']?.toInt() ?? 0;
          int diastolicBP = dailyData?['iBPLow']?.toInt() ?? 0;
          int totalSleep = dailyData?['totalSleep']?.toInt() ?? 0;
          int totalspo2 = dailyData?['spo2']?.toInt() ?? 0;

          await _sendHeartRateToAPI(heartRate, totalSteps, systolicBP, diastolicBP, totalSleep, totalspo2);
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

      print("dataList: ${dataList}");
      print("📨 Raw Response Body: ${response.body}");
      print("📨 Status Code: ${response.statusCode}");
    } catch (e) {
      print("⚠️ Error sending bulk minute data: $e");
    }
  }

  Future<void> _sendHeartRateToAPI(int heartRate, int totalSteps, int systolicBP, int diastolicBP, int totalSleep,  int totalspo2,) async {
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
    print("total_spo2${totalspo2.toString()}");
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
      "oxygen": totalspo2,
      "weight": "50",
      "datetime_now": formattedDate1,
    };

    print("health_data:$body");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json"
        },
        body: jsonEncode(body),// Send as form-data
      );

      final responseData = jsonDecode(response.body);
      print("status code: ${response.statusCode}");
      print("daily_response_data $responseData");

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
      Get.off(() => DashboardScreen(deviceID: widget.deviceID));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool shouldExit = await showExitConfirmationDialog(context);
        return shouldExit;
      },
      child: Scaffold(
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
                    : CircularProgressIndicator(color: AppColors.others,strokeWidth: 2,),
              ],
            ),
          ),
        ),
      ),
    );
  }


}

Future<bool> showExitConfirmationDialog(BuildContext context) async {
  bool exit = false;
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text(AppText.exitapp, style: Apptextstyle.s15wbcothers,),
        content: Text(AppText.sure_exit, style: Apptextstyle.s13wbcgrey,),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).pop(); // Dismiss dialog
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                    child: Row(
                      children: [
                        Text(
                            AppText.cancel,
                            style: Apptextstyle.s15wbcW
                        ),
                        SizedBox(width: 5,),
                        Icon(Icons.logout,color: Colors.white,)
                      ],
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  exit = true;
                  SystemNavigator.pop();
                  //Navigator.of(context).pop(); // Dismiss dialog
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(25, 4, 20, 4),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,// 👈 THIS is required
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Center(
                            child: Text(
                              AppText.exit,
                              style: Apptextstyle.s15wbcW,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.arrow_right_alt_sharp,
                            color: Colors.white,
                          ),
                        ],
                      ),

                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      );
    },
  );
  return exit;
}
