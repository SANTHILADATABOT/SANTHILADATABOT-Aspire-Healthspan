import 'dart:async';
import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
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

import 'syncing data screen.dart';



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
    _pairSub = ClingBleService.pairStatusStream().listen((connectedId) {
      print("print11");
      print("✅ Paired event received: $connectedId");

      if (!mounted) return;

      setState(() {
        _pairingStatus[_pairingDevice ?? connectedId] = AppText.paired;
        _registeredDevice = _pairingDevice ?? connectedId;
        _pairingDevice = null;
        print("print12");
      });

      _navigateToSyncScreen();

    });

    // _pairSub = ClingBleService.pairStatusStream().listen((connectedId) {
    //
    //   print("✅ Paired event received: $connectedId");
    //
    //   if (!mounted) return;
    //
    //   setState(() {
    //     _registeredDevice = connectedId;   // 🔥 Always trust native
    //     _pairingStatus[connectedId] = AppText.paired;
    //     _pairingDevice = null;
    //   });
    //
    //   _navigateToSyncScreen();
    // });



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
    if (Platform.isAndroid) {
      ClingBleService.startScan();
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
      print("print2");
      try {
        print("print3");
        setState(() {
          _pairingDevice = deviceID;
          print("print4 $_pairingDevice");
          // 🔥 ADD THIS LINE
          //_pairingStatus[deviceID] = AppText.paired;
        });
        print("print5");
        print("register_device:$deviceID");
        await ClingBleService.connectToDevice(deviceID);
            _scaffoldMessengerKey.currentState?.showSnackBar(
              SnackBar(content: Text("Device $deviceID registered successfully!")),
            );
        print("print6");
      } catch (e) {
        print("print7");
        print("Connect failed: $e");

        setState(() {
          _pairingStatus[deviceID] = AppText.failed;
          _pairingDevice = null;
        });
      }
      finally {
        print("print8");
        setState(() {
          _pairingDevice = null; // Hide loader after pairing
        });
      }
    }


    else if (Platform.isIOS) {
        setState(() {
          _pairingDevice = deviceID; // Show loader for this device
        });

        try {
          await platform.invokeMethod('registerDevice', {"deviceID": deviceID});

          setState(() {
            _registeredDevice = deviceID;
            _pairingStatus[deviceID] = AppText.paired;
          });

          _scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(content: Text("Device $deviceID registered successfully!")),
          );

          // Navigate to the Sync Screen after pairing
          Future.delayed(Duration(seconds: 1), () {
            _navigateToSyncScreen();
          });

        }
        on PlatformException
        catch (e) {
          setState(() {
            _pairingStatus[deviceID] = AppText.failed;
          });
          print("Failed to register device: ${e.message}");
          _scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(content: Text("Failed to register device: ${e.message}")),
          );
        } finally {
          setState(() {
            _pairingDevice = null; // Hide loader after pairing
          });
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
          body: Column(
            children: [
              SizedBox(height: 10,),
              ElevatedButton(
                onPressed: _startScanning,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.others, // Button background color
                  foregroundColor: Colors.white, // Text (and icon) color
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                ),
                child: const Text(AppText.scandevice),
              ),
              SizedBox(height: 20,),
              ElevatedButton(
                onPressed: _navigateToSkip,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.others, // Button background color
                  foregroundColor: Colors.white, // Text (and icon) color
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                ),
                child: const Text(AppText.skip),
              ),//
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

                    // ✅ HANDLE ANDROID (Map)
                    if (Platform.isAndroid && device is Map<String, String>) {
                      deviceName = device['name'] ?? "";
                      deviceMac = device['mac'] ?? "";
                    }
                    // ✅ HANDLE IOS (String)
                    else if (Platform.isIOS && device is String) {
                      deviceName = device;
                    }
                    else {
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
                          onTap: () => _registerDevice(deviceName),
                          trailing: _pairingDevice == deviceName
                              ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                              : Icon(
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
              if (_registeredDevice != null) ...[
                Divider(),
                Text(
                  "Registered Device: $_registeredDevice",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: _navigateToSyncScreen,
                  child: Text(AppText.syncdata),
                ),
              ],
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
