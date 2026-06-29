import 'dart:async';
import 'package:azpire_new/Controller/pairedevice_controller.dart';
import 'package:azpire_new/View/Dashboard_screen.dart';
import 'package:azpire_new/cling_ble_service.dart';
import 'package:azpire_new/utils/app_color.dart';
import 'package:azpire_new/utils/apptext.dart';
import 'package:azpire_new/utils/apptextstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../web_app/platform_utils_io.dart';
import 'syncing data screen.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb


class BluetoothPair extends StatefulWidget {

  @override
  _BluetoothPairState createState() => _BluetoothPairState();
}

class _BluetoothPairState extends State<BluetoothPair>  with WidgetsBindingObserver {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
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
  bool _isDialogOpen = false;
  late final MethodChannel platform;
  Timer? _btStateTimer;
  bool _lastBtState = true;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      print("Running on Web - Bluetooth logic skipped");
      return;
    }


    if (isAndroid) {
      platform = const MethodChannel('cling/methods');

    } else if (isIOS) {
      platform = const MethodChannel('cling_sdk');
    }
    _hasNavigated = false;
    platform.setMethodCallHandler(_methodCallHandler);
    _listenForPairEvents();
    _checkBluetoothOnEntry();
    _startBluetoothMonitoring();
    WidgetsBinding.instance.addObserver(this);
    _scanSub?.cancel();
    if (isAndroid) {
      _scanSub = ClingBleService.scanResults().listen((results) {

        final devices = results.map((d) {
          return {
            "name": d['name'].toString(),
            "mac": d['mac'].toString(),
          };
        }).toList();
        print("📱 Final Devices List: $devices");

        setState(() {
          _devices = devices;
        });
      });
    }

  }



  void _startBluetoothMonitoring() {

    if (kIsWeb) return;


    _btStateTimer?.cancel();

    _btStateTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final isOn = await platform.invokeMethod("isBluetoothOn");

      // 🔴 Bluetooth turned OFF
      if (_lastBtState == true && isOn == false) {
        await ClingBleService.stopScan();

        if (mounted) {
          setState(() {
            _devices.clear();
          });
        }

        _showBluetoothPopup();
      }

      // 🟢 Bluetooth turned ON
      if (_lastBtState == false && isOn == true) {

        // ✅ CLOSE POPUP
        if (_isDialogOpen && mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          _isDialogOpen = false;
        }

        // ✅ Start scanning again
        await Future.delayed(const Duration(milliseconds: 300));
        _startScanning();
      }

      _lastBtState = isOn;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _onReturnFromSettings();
    }
  }

  Future<void> _onReturnFromSettings() async {
    // On iOS the CBCentralManager state is asynchronous.
    // Give it a moment to settle before querying.
    if (isIOS) {
      await Future.delayed(const Duration(milliseconds: 600));
    }

    final isOn = await platform.invokeMethod("isBluetoothOn");

    if (isOn == true) {
      // Sync state tracker so the periodic timer doesn't get confused.
      _lastBtState = true;

      // Dismiss the popup if it is showing.
      if (_isDialogOpen && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        _isDialogOpen = false;
      }

      // Start scanning here in case the native bluetoothOn event was fired
      // while the app was in the background and was never received by Flutter.
      await Future.delayed(const Duration(milliseconds: 300));
      _startScanning();
    } else {
      _lastBtState = false;
      _showBluetoothPopup();
    }
  }

  Future<void> _checkBluetoothOnEntry() async {

    if (kIsWeb) return;

    try {
      if (isIOS) {
        await Future.delayed(const Duration(milliseconds: 800));
      }

      final isOn = await platform.invokeMethod("isBluetoothOn");

      _lastBtState = isOn; // 👈 track initial state

      if (isOn == false) {
        _showBluetoothPopup();
      } else {
        _startScanning();
      }
    } catch (e) {
      print("BT check error: $e");
    }
  }

  void _showBluetoothPopup() {

    if (kIsWeb) return;

    if (!mounted) return;
    if (_isDialogOpen) return;

    _isDialogOpen = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("Turn on Bluetooth"),
          content: const Text(
              "Bluetooth is required to scan for and connect to nearby devices. Please enable Bluetooth to continue"
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            Center(
              child: TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  _isDialogOpen = false;

                  if (isAndroid) {
                    try {
                      await const MethodChannel('cling/methods')
                          .invokeMethod("openBluetoothSettings");
                    } catch (e) {
                      print("Error opening Bluetooth: $e");
                    }
                  } else if (isIOS) {
                    try {
                      await platform.invokeMethod("openBluetoothSettings");
                    } catch (e) {
                      print("Error opening Bluetooth settings: $e");
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.others,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: const Text(
                    "OK",
                    style: Apptextstyle.s15wbcW,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ).then((_) {
      // ✅ Ensures state resets even if dialog dismissed unexpectedly
      _isDialogOpen = false;
    });
  }

  Future<void> _listenForPairEvents() async {
    print("print9");
    if (isAndroid) return;
    print("print10");

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id') ?? "";
    print("user_id:$user_id");

    _pairSub = ClingBleService.pairStatusStream().listen((connectedId) {

      if (!mounted) return;

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
    } else if (call.method == "bluetoothOff") {
      if (isAndroid) {
        await ClingBleService.stopScan();
      }
      if (mounted) {
        setState(() {
          _devices.clear();
        });
      }
      _showBluetoothPopup();
    } else if (call.method == "bluetoothOn") {
      if (_isDialogOpen && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        _isDialogOpen = false;
      }
      await Future.delayed(const Duration(milliseconds: 300));
      _startScanning();
    }
  }

  Future<void>  _startScanning() async {

    if (kIsWeb) {
      print("Web does not support Cling BLE scanning");
      return;
    }

    if (isAndroid) {

      final isOn = await platform.invokeMethod("isBluetoothOn");

      if (isOn == false) {
        _showBluetoothPopup();
        return;
      }


      await ClingBleService.stopScan(); // 🔥 IMPORTANT
      await Future.delayed(Duration(milliseconds: 300));


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
    else if (isIOS) {
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


    if (isAndroid) {
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

          showCustomToast(message);


          setState(() {
            _pairingStatus[deviceID] = AppText.failed;
            _pairingDevice = null;
            isLoading = false;
          });

          return;
        }

        showCustomToast(message);

        setState(() {
          _pairingStatus[deviceID] = AppText.paired;
        });

        await ClingBleService.connectToDevice(deviceID);
        print("Android_Deviceid:$deviceID");

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

        showCustomToast("Something went wrong");
      }
    }

    else if (isIOS) {
      try {
        setState(() {
          _pairingDevice = deviceID;
          _pairingStatus[deviceID] = "Pairing...";
          isLoading = true;
        });

        print("Ble_DeviceId:$deviceID");

        final prefs = await SharedPreferences.getInstance();
        var user_id = prefs.getString('user_id') ?? "";
        await prefs.setString('DeviceId', deviceID);

        print("DEVICE_ID (iOS): $deviceID");

        final response = await pairDevice(user_id, deviceID);

        if (response == null) {
          throw Exception("No response from API");
        }

        int statusCode = response['statusCode'] ?? 0;
        String status = response['status'] ?? "";
        String message = response['message'] ?? "";
        String apiDeviceId =
        (response['device_id'] ?? "").toString().trim();
        if (statusCode != 200 ||
            status != "SUCCESS" ||
            apiDeviceId != deviceID.trim()) {

          showCustomToast(message);

          setState(() {
            _pairingStatus[deviceID] = AppText.failed;
            _pairingDevice = null;
            isLoading = false;
          });

          return;
        }
        print("iOS → calling registerDevice (handles both new and already-paired devices correctly)");
        await platform.invokeMethod('registerDevice', {
          "deviceID": deviceID
        });

        await Future.delayed(const Duration(seconds: 2));
        // ✅ SUCCESS CASE UI UPDATE
        showCustomToast(message);

        setState(() {
          _pairingStatus[deviceID] = AppText.paired;
          _registeredDevice = deviceID;
          _pairingDevice = null;
          isLoading = false;
        });

        // 🚀 NAVIGATE ONLY AFTER SUCCESS
        if (!_hasNavigated && mounted) {
          _hasNavigated = true;
          await Future.delayed(const Duration(milliseconds: 800));
          _navigateToSyncScreen();
        }

      } catch (e) {
        print("iOS Error: $e");

        setState(() {
          _pairingStatus[deviceID] = AppText.failed;
          _pairingDevice = null;
          isLoading = false;
        });

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
    _btStateTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
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

                        if( (!kIsWeb && isAndroid && device is Map<String, String>)){
                          deviceName = device['name'] ?? "";
                          deviceMac = device['mac'] ?? "";
                        }
                        else if (!kIsWeb && isIOS && device is String){
                          deviceName = device;
                        }
                        else{
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
