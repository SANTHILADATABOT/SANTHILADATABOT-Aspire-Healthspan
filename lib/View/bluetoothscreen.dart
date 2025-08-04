import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:azpire_new/View/Dashboard_screen.dart';
import 'package:azpire_new/View/login_Screen.dart';
import 'package:azpire_new/utils/app_color.dart';
import 'package:azpire_new/utils/apptext.dart';
import 'package:azpire_new/utils/apptextstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'syncing data screen.dart';



class BluetoothPair extends StatefulWidget {

  @override
  _BluetoothPairState createState() => _BluetoothPairState();
}

class _BluetoothPairState extends State<BluetoothPair> {
  static const platform = MethodChannel('cling_sdk');
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  List<String> _devices = [];
  String? _registeredDevice;
  String? _pairingDevice;
  Map<String, String> _pairingStatus = {}; // Map to store pairing status

  @override
  void initState() {
    super.initState();
    platform.setMethodCallHandler(_methodCallHandler);
    //_checkForPairedDevice();
    _startScanning();
    super.initState();


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

  // Future<void> _checkForPairedDevice() async {
  //   try {
  //     final String? lastDeviceID = await platform.invokeMethod('getLastActiveDevice');
  //     if (lastDeviceID != null && lastDeviceID.isNotEmpty) {
  //       setState(() {
  //         _registeredDevice = lastDeviceID;
  //       });
  //
  //       // Navigate to Sync Screen immediately if a paired device is found
  //       Future.delayed(Duration(seconds: 1), () {
  //         _navigateToSyncScreen();
  //       });
  //     }
  //   } on PlatformException catch (e) {
  //     print("Failed to get last active device: ${e.message}");
  //   }
  // }

  Future<void> _startScanning() async {
    try {
      await platform.invokeMethod('startScanning');
    } on PlatformException catch (e) {
      print("Failed to start scanning: ${e.message}");
    }
  }


  Future<void> _registerDevice(String deviceID) async {
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

    } on PlatformException
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

  void _navigateToSyncScreen() {
    if (_registeredDevice != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SyncDataScreen(deviceID: _registeredDevice!)));
    }
  }

  void _navigateToSkip() {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DashboardScreen(deviceID: '')));

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          title: Text(AppText.SDK_headings,
            style:Apptextstyle.s18wbap,),
          backgroundColor:Colors.white,
          leading: IconButton(
            onPressed: () {
              //Get.to(() => LoginScreen());
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
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
                  String deviceID = _devices[index];
                  return Column(
                    children: [
                      ListTile(
                        title: Text(deviceID),
                        subtitle: Text(
                          _pairingStatus[deviceID] ?? AppText.notpaired,
                          style: _pairingStatus[deviceID] == AppText.paired
                        ? Apptextstyle.s16wncGreen
                            : _pairingStatus[deviceID] == AppText.failed
                          ? Apptextstyle.s16wncR
                          : Apptextstyle.s16wncB,
                        ),
                        onTap: () => _registerDevice(deviceID),
                        trailing: _pairingDevice == deviceID
                            ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : Icon(
                          Icons.bluetooth,
                          color: _pairingStatus[deviceID] == AppText.paired
                              ? AppColors.others
                              : _pairingStatus[deviceID] == AppText.failed
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
    );
  }
}
