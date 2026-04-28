import 'dart:async';
import 'dart:io';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:azpire_new/Controller/pairedevice_controller.dart';
import 'package:azpire_new/View/Dashboard_screen.dart';
import 'package:azpire_new/View/login_Screen.dart';
import 'package:azpire_new/cling_ble_service.dart';
import 'package:azpire_new/minute_data_screen.dart';
import 'package:azpire_new/utils/app_color.dart';
import 'package:azpire_new/utils/apptext.dart';
import 'package:azpire_new/utils/apptextstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'syncing data screen.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb


class BluetoothPair extends StatefulWidget {

  @override
  _BluetoothPairState createState() => _BluetoothPairState();
}

class _BluetoothPairState extends State<BluetoothPair> {
  static const platform = MethodChannel('cling_sdk');
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  //List<String> _devices = [];
  //List<Map<String, String>> _devices = [];
  List<dynamic> _devices = [];
  String? _registeredDevice;
  String? _pairingDevice;
  Map<String, String> _pairingStatus = {}; // Map to store pairing status
  StreamSubscription? _scanSub;
  StreamSubscription? _pairSub;
  StreamSubscription? _minuteSub;
  StreamSubscription? _syncSub;
  bool _hasNavigated = false;
  bool isLoading = false;


  @override
  void initState() {
    super.initState();
    _hasNavigated = false;
    platform.setMethodCallHandler(_methodCallHandler);
    _listenForPairEvents();
    Future.delayed(const Duration(milliseconds: 1200), () {
      _startScanning();
    });
    // Android: listen to scan results and update _devices list
    _scanSub?.cancel();
    if (Platform.isAndroid) {
      _scanSub = ClingBleService.scanResults().listen((results) {

        final devices = results.map((d) {
          return {
            "name": d['name'].toString(),
            "mac": d['mac'].toString(),
          };
        }).toList();

        setState(() {
          _devices = devices;
        });
      });
    }

  }

  Future<void> _listenForPairEvents() async {
    print("print9");
    if (!Platform.isAndroid) return;
    print("print10");

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id') ?? "";
    print("user_id:$user_id");

    _pairSub = ClingBleService.pairStatusStream().listen((connectedId) {

      if (!mounted) return;

      // ✅ ALWAYS use the tapped device (UI key)
      // final deviceName = _pairingDevice;
      //
      // if (deviceName == null) return;

      final deviceName = _pairingDevice ?? connectedId;


      setState(() {
        _pairingStatus[deviceName] = AppText.paired; // ✅ correct key
        _registeredDevice = deviceName;
      });

      // show paired UI briefly
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;

        setState(() {
          isLoading = false;
          _pairingDevice = null;
        });

        _navigateToSyncScreen();
      });
    });

  }


  void onDeviceConnected() async {
    try {
      await platform.invokeMethod("setDeviceConfig");
      print("Device config updated successfully.");
    } catch (e) {
      print("Error setting device config: $e");
    }
  }

  Future<void> _methodCallHandler(MethodCall call) async {
    if (call.method == "onDevicesDiscovered") {
      setState(() {
        _devices = List<String>.from(call.arguments);

      });
    }
  }

  Future<void> _startScanning() async {
    // if (Platform.isAndroid) {
    //   ClingBleService.startScan();
    // }
    if (Platform.isAndroid) {
      await ClingBleService.stopScan(); // 🔥 IMPORTANT
      await Future.delayed(Duration(milliseconds: 300));

      setState(() {
        _devices.clear(); // 🔥 clear old devices
      });

      try {
        await ClingBleService.startScan();
      } on PlatformException catch (e) {
        if (e.code == "NO_PERMISSION") {
          _scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(content: Text("Bluetooth/Location permission is required to scan.")),
          );
        } else if (e.code == "LOCATION_DISABLED") {
          _scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(content: Text("Please turn on your phone's Location (GPS) to find nearby devices.")),
          );
        }
      }
    }
    else if (Platform.isIOS) {
      // iOS scan
      try {
        await platform.invokeMethod('startScanning');
      } on PlatformException catch (e) {
        print("Failed to start scanning: ${e.message}");
      }
    } else {
      print("Scanning not supported on this platform");
    }
  }

  Future<void> _registerDevice(String deviceID) async {
    print("print1");


    if (Platform.isAndroid) {
      try {
        setState(() {
          _pairingDevice = deviceID;
          _pairingStatus[deviceID] = "Pairing...";
          isLoading = true;
        });

        final prefs = await SharedPreferences.getInstance();
        var user_id = prefs.getString('user_id') ?? "";
        await prefs.setString('DeviceId', deviceID);
        print("DEVICE_ID:$deviceID");

        final response = await pairDevice(user_id, deviceID);

        if (response == null) {
          throw Exception("No response from API");
        }

        int statusCode = response['statusCode'] ?? 0;
        String status = response['status'] ?? "";
        String message = response['message'] ?? "";
        String apiDeviceId =
        (response['device_id'] ?? "").toString().trim();

        // ✅ ADDED (user_id from API)
        String apiUserId =
        (response['user_id'] ?? "").toString().trim();

        print("HTTP: $statusCode | API: $status | Msg: $message");
        print("Local Device: $deviceID | API Device: $apiDeviceId");

        // ❌ FAILED (HTTP fail OR API fail OR Device mismatch)
        if (statusCode != 200 ||
            status != "SUCCESS" ||
            apiDeviceId != deviceID.trim()) {

          // _scaffoldMessengerKey.currentState?.showSnackBar(
          //   SnackBar(content: Text(message)),
          // );
          showCustomToast(message);


          setState(() {
            _pairingStatus[deviceID] = AppText.failed;
            _pairingDevice = null;
            isLoading = false;
          });

          return;
        }

        // _scaffoldMessengerKey.currentState?.showSnackBar(
        //   SnackBar(content: Text(message)),
        // );
        showCustomToast(message);

        setState(() {
          _pairingStatus[deviceID] = AppText.paired;
        });

        // 🔥 Connect only on TRUE success
        // await ClingBleService.connectToDevice(deviceID);
        await ClingBleService.connectToDevice(deviceID);

// wait for BLE readiness
        await Future.delayed(const Duration(seconds: 2));

        _registeredDevice = deviceID;

        if (!_hasNavigated && mounted) {
          _hasNavigated = true;
          _navigateToSyncScreen();
        }

        if (mounted) {
          setState(() {
            _pairingDevice = null;
            isLoading = false;
          });
        }

      } catch (e) {
        print("Error: $e");

        setState(() {
          _pairingStatus[deviceID] = AppText.failed;
          _pairingDevice = null;
          isLoading = false;
        });

        // _scaffoldMessengerKey.currentState?.showSnackBar(
        //   const SnackBar(content: Text("Something went wrong")),
        // );
        showCustomToast("Something went wrong");
      }
    }
    // else if (Platform.isIOS) {
    //   setState(() {
    //     _pairingDevice = deviceID; // Show loader for this device
    //   });
    //
    //   try {
    //     await platform.invokeMethod('registerDevice', {"deviceID": deviceID});
    //
    //     setState(() {
    //       _registeredDevice = deviceID;
    //       _pairingStatus[deviceID] = AppText.paired;
    //     });
    //
    //     _scaffoldMessengerKey.currentState?.showSnackBar(
    //       SnackBar(content: Text("Device $deviceID registered successfully!")),
    //     );
    //
    //     // Navigate to the Sync Screen after pairing
    //     Future.delayed(Duration(seconds: 1), () {
    //       _navigateToSyncScreen();
    //     });
    //
    //   }
    //   on PlatformException
    //   catch (e) {
    //     setState(() {
    //       _pairingStatus[deviceID] = AppText.failed;
    //       // _pairingDevice = null;
    //       // isLoading = false; // ✅ stop loader on failure
    //     });
    //     print("Failed to register device: ${e.message}");
    //     _scaffoldMessengerKey.currentState?.showSnackBar(
    //       SnackBar(content: Text("Failed to register device: ${e.message}")),
    //     );
    //     }
    //   // } finally {
    //   //   setState(() {
    //   //     _pairingDevice = null; // Hide loader after pairing
    //   //   });
    //   // }
    // }
    else if (Platform.isIOS) {
      try {
        setState(() {
          _pairingDevice = deviceID;
          _pairingStatus[deviceID] = "Pairing...";
          isLoading = true;
        });

        // //🔥 Call native method
        // await platform.invokeMethod('registerDevice', {
        //   "deviceID": deviceID
        // });

        if (_registeredDevice == deviceID) {
          // 🔥 Already paired → just connect
          await platform.invokeMethod('connectDevice', {
            "deviceID": deviceID
          });
        } else {
          // 🔥 First time → register
          await platform.invokeMethod('registerDevice', {
            "deviceID": deviceID
          });
        }

        await Future.delayed(const Duration(seconds: 2));

        final prefs = await SharedPreferences.getInstance();
        var user_id = prefs.getString('user_id') ?? "";
        await prefs.setString('DeviceId', deviceID);

        print("DEVICE_ID (iOS): $deviceID");

        // ✅ CALL API FIRST
        final response = await pairDevice(user_id, deviceID);

        if (response == null) {
          throw Exception("No response from API");
        }

        int statusCode = response['statusCode'] ?? 0;
        String status = response['status'] ?? "";
        String message = response['message'] ?? "";
        String apiDeviceId =
        (response['device_id'] ?? "").toString().trim();

        // ❌ FAIL CASE
        if (statusCode != 200 ||
            status != "SUCCESS" ||
            apiDeviceId != deviceID.trim()) {

          // _scaffoldMessengerKey.currentState?.showSnackBar(
          //   SnackBar(content: Text(message)),
          // );
          showCustomToast(message);


          setState(() {
            _pairingStatus[deviceID] = AppText.failed;
            _pairingDevice = null;
            isLoading = false;
          });

          return; // 🚫 STOP HERE (NO NAVIGATION)
        }

        // ✅ SUCCESS CASE
        // _scaffoldMessengerKey.currentState?.showSnackBar(
        //   SnackBar(content: Text(message)),
        // );
        showCustomToast(message);

        setState(() {
          _pairingStatus[deviceID] = AppText.paired;
          _pairingDevice = null;
          isLoading = false;
        });

        // 🚀 NAVIGATE ONLY AFTER SUCCESS
        if (!_hasNavigated && mounted) {
          _hasNavigated = true;
          _navigateToSyncScreen();
        }

      } catch (e) {
        print("iOS Error: $e");

        setState(() {
          _pairingStatus[deviceID] = AppText.failed;
          _pairingDevice = null;
          isLoading = false;
        });

        // _scaffoldMessengerKey.currentState?.showSnackBar(
        //   const SnackBar(content: Text("Something went wrong")),
        // );
        showCustomToast("Something went wrong");
      }
    }

  }

  void _navigateToSyncScreen() {
    if (_registeredDevice != null) {
      print("print12");
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => SyncDataScreen(deviceID: _registeredDevice!,)));
    }
  }

  void _navigateToSkip() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DashboardScreen(deviceID: '')));

  }

  @override
  void dispose() {
    _scanSub?.cancel();
    _pairSub?.cancel();
    _minuteSub?.cancel();
    _syncSub?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      home: WillPopScope(
        onWillPop: () async {
          bool shouldExit = await showExitConfirmationDialog(context);
          return shouldExit;
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            centerTitle: true,
            title: Text(AppText.SDK_headings,
              style:Apptextstyle.s18wbap,),
            backgroundColor:Colors.white,
            leading: IconButton(
              onPressed: () {
                SystemNavigator.pop();
              },
              icon: Icon(Icons.arrow_back_ios),
            ),
          ),
          body: Stack(
            children: [

              // 🔹 YOUR ORIGINAL UI
              Column(
                children: [
                  SizedBox(height: 10,),
                  ElevatedButton(
                    onPressed: _startScanning,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.others,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(AppText.scandevice),
                  ),
                  SizedBox(height: 20,),
                  ElevatedButton(
                    onPressed: _navigateToSkip,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.others,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(AppText.demo_mode),
                  ),
                  SizedBox(height: 20),

                  Expanded(
                    child: _devices.isEmpty
                        ? Center(child: Text(AppText.nodevices))
                        : ListView.builder(
                      itemCount: _devices.length,
                      itemBuilder: (context, index) {

                        String deviceName;
                        String deviceMac = "";

                        final device = _devices[index];

                        if (Platform.isAndroid && device is Map<String, String>) {
                          deviceName = device['name'] ?? "";
                          deviceMac = device['mac'] ?? "";
                        } else if (Platform.isIOS && device is String) {
                          deviceName = device;
                        } else {
                          deviceName = "";
                        }

                        return Column(
                          children: [
                            ListTile(
                              title: Text(deviceName),
                              subtitle: Text(
                                _pairingStatus[deviceName] ?? AppText.notpaired,
                                style: _pairingStatus[deviceName] == AppText.paired
                                    ? Apptextstyle.s16wncGreen
                                    : _pairingStatus[deviceName] == AppText.failed
                                    ? Apptextstyle.s16wncR
                                    : Apptextstyle.s16wncB,
                              ),
                              onTap: isLoading
                                  ? null
                                  : () => _registerDevice(deviceName),
                              trailing: Icon(
                                Icons.bluetooth,
                                color: _pairingStatus[deviceName] == AppText.paired
                                    ? AppColors.others
                                    : _pairingStatus[deviceName] == AppText.failed
                                    ? AppColors.Red
                                    : AppColors.Grey,
                              ),
                            ),
                            const Divider(height: 0.5, thickness: 0.5),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),

              // 🔥 FULL SCREEN CENTER LOADER
              if (isLoading)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(// optional dim
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.others,
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}



/// Shows a confirmation dialog when the user presses the back button.
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

void showCustomToast(String msg) {
  showToast(
    msg,
    duration: Duration(seconds: 2),
    position: kIsWeb ? ToastPosition.top : ToastPosition.bottom,
    backgroundColor: Colors.black,
    radius: 8.0,
    textPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
    textStyle: TextStyle(
      fontSize: 16.0,
      color: Colors.white,
    ),
    textAlign: TextAlign.center,
    animationCurve: kIsWeb ? Curves.easeInOut : Curves.easeIn,
    animationDuration: const Duration(milliseconds: 400),
    animationBuilder: kIsWeb ? _slideFromRight : null,
  );
}

Widget _slideFromRight(
    BuildContext context,
    Widget child,
    AnimationController controller,
    double percent,
    ) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: Offset(1.2, 0.0), // far right
      end: Offset(-1.2, 0.0),  // f // Slide to original position
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    )),
    child: child,
  );
}
