// import 'dart:async';
// import 'dart:io';
//
// import 'package:app_tracking_transparency/app_tracking_transparency.dart';
// import 'package:azpire_new/View/Dashboard_screen.dart';
// import 'package:azpire_new/View/login_Screen.dart';
// import 'package:azpire_new/cling_ble_service.dart';
// import 'package:azpire_new/minute_data_screen.dart';
// import 'package:azpire_new/utils/app_color.dart';
// import 'package:azpire_new/utils/apptext.dart';
// import 'package:azpire_new/utils/apptextstyle.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:permission_handler/permission_handler.dart';
//
//
//
//
// class BluetoothPair extends StatefulWidget {
//
//   @override
//   _BluetoothPairState createState() => _BluetoothPairState();
// }
//
// class _BluetoothPairState extends State<BluetoothPair> {
//   static const platform = MethodChannel('cling_sdk');
//   final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
//
//   List<String> _devices = [];
//   String? _registeredDevice;
//   String? _pairingDevice;
//   Map<String, String> _pairingStatus = {}; // Map to store pairing status
//   StreamSubscription? _scanSub;
//   StreamSubscription? _pairSub;
//   StreamSubscription? _minuteSub;
//   StreamSubscription? _syncSub;
//
//
//   @override
//   void initState() {
//     super.initState();
//
//     platform.setMethodCallHandler(_methodCallHandler);
//     _startScanning();
//     _listenForPairEvents();
//     // Android: listen to scan results and update _devices list
//     if (Platform.isAndroid) {
//       // _scanSub = ClingBleService.scanResults().listen((results) {
//       //   print("✅ Flutter received scan results: $results");
//       //
//       //   final devices = results.map((d) {
//       //     final name = (d['name'] ?? '').toString();
//       //     final mac = (d['mac'] ?? '').toString();
//       //     final rssi = d['rssi'];
//       //
//       //     print("📡 Device Found -> name: $name | mac: $mac | rssi: $rssi");
//       //     print("➡️ Selected deviceID for UI list: $name");
//       //
//       //     return name; // ✅ UI uses name only
//       //   }).toList();
//       //
//       //   setState(() {
//       //     _devices = devices;
//       //   });
//       _scanSub = ClingBleService.scanResults().listen((results) {
//         print("✅ Flutter received scan results: $results");
//         //final devices = results.map((d) => d['mac'].toString()).toList();
//         final devices = results.map((d) => d['name'].toString()).toList();
//
//
//         setState(() {
//           _devices = devices;
//         });
//       });
//     }
//
//   }
//
//   Future<void> _listenForPairEvents() async {
//     if (!Platform.isAndroid) return;
//
//     //await Future.delayed(Duration(milliseconds: 200));
//
//     // _pairSub = ClingBleService.pairStatusStream().listen((clingId) {
//     //   print("✅ Paired event from native: $clingId");
//     //
//     //   setState(() {
//     //     _registeredDevice = clingId;
//     //     _pairingStatus[clingId] = AppText.paired;
//     //     _pairingDevice = null;
//     //   });
//     //
//     //   _startSyncListeners(clingId);
//     //
//     //   _navigateToSyncScreen(); // ✅ move navigation here
//     // });
//     // _pairSub = ClingBleService.pairStatusStream().listen((clingId) {
//     //   print("✅ Paired event from native: $clingId");
//     //
//     //   _registeredDevice = clingId;
//     //
//     //   _startSyncListeners(clingId);
//     // });
//     _pairSub = ClingBleService.pairStatusStream().listen((clingId) {
//       print("🔥 PAIRED EVENT RECEIVED: $clingId");
//
//       if (!mounted) return;
//
//       setState(() {
//         _registeredDevice = clingId;
//         _pairingDevice = null;
//         _pairingStatus[clingId] = AppText.paired;
//       });
//
//       // Start sync listeners in background
//       _startSyncListeners(clingId);
//
//       // 🚀 NAVIGATE IMMEDIATELY
//       Future.delayed(const Duration(milliseconds: 300), () {
//         if (!mounted) return;
//         _navigateToSyncScreen();
//       });
//     });
//
//
//   }
//
//   void _startSyncListeners(String clingId) {
//
//     _minuteSub?.cancel();
//     _syncSub?.cancel();
//
//     // _minuteSub = ClingBleService.minuteDataStream().listen((data) {
//     //   if (data.isNotEmpty) {
//     //     print("✅ Data sync started: $clingId");
//     //     _minuteSub?.cancel();
//     //
//     //     //_navigateToSyncScreen();
//     //   }
//     // });
//     // _minuteSub = ClingBleService.minuteDataStream().listen((data) {
//     //   if (data.isNotEmpty) {
//     //     print("🔥 Device sending data → navigate");
//     //
//     //     _navigateToSyncScreen();
//     //   }
//     // });
//     _minuteSub = ClingBleService.minuteDataStream().listen((data) {
//       if (data.isNotEmpty) {
//         print("📊 Device sending data");
//       }
//     });
//
//
//
//     _syncSub = ClingBleService.syncStatusStream().listen((status) {
//       if (status['status'] == 'SYNC_COMPLETED') {
//         print("✅ Sync completed: $clingId");
//
//         _syncSub?.cancel();
//
//         //_navigateToSyncScreen();
//       }
//     });
//   }
//
//
//
//
//
//   void onDeviceConnected() async {
//     try {
//       await platform.invokeMethod("setDeviceConfig");
//       print("Device config updated successfully.");
//     } catch (e) {
//       print("Error setting device config: $e");
//     }
//   }
//
//   Future<void> _methodCallHandler(MethodCall call) async {
//     if (call.method == "onDevicesDiscovered") {
//       setState(() {
//         _devices = List<String>.from(call.arguments);
//       });
//     }
//   }
//
//
//
//   Future<void> _startScanning() async {
//     if (Platform.isAndroid) {
//       // Android scan
//       // final ok = await _requestBlePermissions();
//       // if (!ok) return;
//
//       ClingBleService.startScan();
//     } else if (Platform.isIOS) {
//       // iOS scan
//       try {
//         await platform.invokeMethod('startScanning');
//       } on PlatformException catch (e) {
//         print("Failed to start scanning: ${e.message}");
//       }
//     } else {
//       print("Scanning not supported on this platform");
//     }
//   }
//
//   Future<void> _registerDevice(String deviceID) async {
//
//     if (Platform.isAndroid) {
//
//       try{
//         setState(() {
//           _pairingDevice = deviceID; // Show loader for this device
//         });
//         // ANDROID = connect using NAME (GE 24D8)
//         print("📡 Device connecting (Android): $deviceID");
//
//         await ClingBleService.connectToDevice(deviceID);
//
//         // setState(() {
//         //   _registeredDevice = deviceID;
//         //   _pairingStatus[deviceID] = AppText.paired;
//         //   //_pairingDevice = null;
//         // });
//
//         _scaffoldMessengerKey.currentState?.showSnackBar(
//           SnackBar(content: Text("Device $deviceID connected successfully!")),
//         );
//
//         // Future.delayed(Duration(seconds: 1), () {
//         //   _navigateToSyncScreen();
//         // });
//
//       }
//       on PlatformException
//       catch (e) {
//         // setState(() {
//         //   _pairingStatus[deviceID] = AppText.failed;
//         // });
//         print("Failed to register device: ${e.message}");
//         _scaffoldMessengerKey.currentState?.showSnackBar(
//           SnackBar(content: Text("Failed to register device: ${e.message}")),
//         );
//       } finally {
//         setState(() {
//           _pairingDevice = null; // Hide loader after pairing
//         });
//       }
//     }
//
//     else if (Platform.isIOS) {
//       setState(() {
//         _pairingDevice = deviceID; // Show loader for this device
//       });
//
//       try {
//         await platform.invokeMethod('registerDevice', {"deviceID": deviceID});
//
//         setState(() {
//           _registeredDevice = deviceID;
//           _pairingStatus[deviceID] = AppText.paired;
//         });
//
//         _scaffoldMessengerKey.currentState?.showSnackBar(
//           SnackBar(content: Text("Device $deviceID registered successfully!")),
//         );
//
//         // Navigate to the Sync Screen after pairing
//         Future.delayed(Duration(seconds: 1), () {
//           _navigateToSyncScreen();
//         });
//
//       }
//       on PlatformException
//       catch (e) {
//         setState(() {
//           _pairingStatus[deviceID] = AppText.failed;
//         });
//         print("Failed to register device: ${e.message}");
//         _scaffoldMessengerKey.currentState?.showSnackBar(
//           SnackBar(content: Text("Failed to register device: ${e.message}")),
//         );
//       } finally {
//         setState(() {
//           _pairingDevice = null; // Hide loader after pairing
//         });
//       }
//     }
//
//   }
//
//
//
//
//
//
//
//   void _navigateToSyncScreen() {
//     if (_registeredDevice != null) {
//       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SyncDataScreen(deviceID: _registeredDevice!)));
//     }
//   }
//
//   void _navigateToSkip() {
//     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DashboardScreen(deviceID: '')));
//
//   }
//
//   @override
//   void dispose() {
//     _scanSub?.cancel();
//     _pairSub?.cancel();
//     _minuteSub?.cancel();
//     _syncSub?.cancel();
//     super.dispose();
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       scaffoldMessengerKey: _scaffoldMessengerKey,
//       home: WillPopScope(
//         onWillPop: () async {
//           bool shouldExit = await showExitConfirmationDialog(context);
//           return shouldExit;
//         },
//         child: Scaffold(
//           backgroundColor: Colors.white,
//           appBar: AppBar(
//             centerTitle: true,
//             title: Text(AppText.SDK_headings,
//               style:Apptextstyle.s18wbap,),
//             backgroundColor:Colors.white,
//             leading: IconButton(
//               onPressed: () {
//                 //Get.to(() => LoginScreen());
//                 // Navigator.pushReplacement(
//                 //   context,
//                 //   MaterialPageRoute(builder: (context) => LoginScreen()),
//                 // );
//                 //Navigator.pop(context);
//                 SystemNavigator.pop();
//               },
//               icon: Icon(Icons.arrow_back_ios),
//             ),
//           ),
//           body: Column(
//             children: [
//               SizedBox(height: 10,),
//               ElevatedButton(
//                 onPressed: _startScanning,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.others, // Button background color
//                   foregroundColor: Colors.white, // Text (and icon) color
//                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10), // Rounded corners
//                   ),
//                 ),
//                 child: const Text(AppText.scandevice),
//               ),
//               // ElevatedButton(
//               //   onPressed: () async {
//               //     await Future.delayed(const Duration(seconds: 3));
//               //     ClingBleService.startScan();
//               //   },
//               //   child: const Text('Start Scan'),
//               // ),
//               // StreamBuilder<List<Map<String, dynamic>>>(
//               //   stream: ClingBleService.scanResults(),
//               //   builder: (context, snapshot) {
//               //     if (!snapshot.hasData) return const Text('No devices');
//               //     return ListView(
//               //       shrinkWrap: true,
//               //       children: snapshot.data!.map((d) {
//               //         return ListTile(
//               //           title: Text(d['name'] ?? 'Unknown'),
//               //           subtitle: Text(d['mac']),
//               //           trailing: Text('RSSI ${d['rssi']}'),
//               //           onTap: () async {
//               //             // Start connecting
//               //             await ClingBleService.connectToDevice(d['mac']);
//               //
//               //             // Listen for minute data stream to confirm connection/sync
//               //             StreamSubscription? sub;
//               //             sub = ClingBleService.minuteDataStream().listen((data) {
//               //               if (data.isNotEmpty) {
//               //                 // Device is connected & sending data, navigate
//               //                 Navigator.pushReplacement(
//               //                   context,
//               //                   MaterialPageRoute(
//               //                     builder: (_) => SyncDataScreen(deviceID: d['mac']),
//               //                   ),
//               //                 );
//               //                 sub?.cancel(); // Stop listening once navigated
//               //               }
//               //             });
//               //           },
//               //         );
//               //       }).toList(),
//               //     );
//               //   },
//               // ),
//               SizedBox(height: 20,),
//               ElevatedButton(
//                 onPressed: _navigateToSkip,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.others, // Button background color
//                   foregroundColor: Colors.white, // Text (and icon) color
//                   padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10), // Rounded corners
//                   ),
//                 ),
//                 child: const Text(AppText.skip),
//               ),//
//               SizedBox(height: 20),
//               Expanded(
//                 child: _devices.isEmpty
//                     ? Center(child: Text(AppText.nodevices))
//                     : ListView.builder(
//                   itemCount: _devices.length,
//                   itemBuilder: (context, index) {
//                     String deviceID = _devices[index];
//                     return Column(
//                       children: [
//                         ListTile(
//                           title: Text(deviceID),
//                           subtitle: Text(
//                             _pairingStatus[deviceID] ?? AppText.notpaired,
//                             style: _pairingStatus[deviceID] == AppText.paired
//                                 ? Apptextstyle.s16wncGreen
//                                 : _pairingStatus[deviceID] == AppText.failed
//                                 ? Apptextstyle.s16wncR
//                                 : Apptextstyle.s16wncB,
//                           ),
//                           onTap: () => _registerDevice(deviceID),
//                           trailing: _pairingDevice == deviceID
//                               ? const SizedBox(
//                             width: 24,
//                             height: 24,
//                             child: CircularProgressIndicator(strokeWidth: 2),
//                           )
//                               : Icon(
//                             Icons.bluetooth,
//                             color: _pairingStatus[deviceID] == AppText.paired
//                                 ? AppColors.others
//                                 : _pairingStatus[deviceID] == AppText.failed
//                                 ? AppColors.Red
//                                 : AppColors.Grey,
//                           ),
//                         ),
//                         const Divider(height: 0.5, thickness: 0.5),
//                       ],
//                     );
//                   },
//                 ),
//               ),
//               if (_registeredDevice != null) ...[
//                 Divider(),
//                 Text(
//                   "Registered Device: $_registeredDevice",
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 ElevatedButton(
//                   onPressed: _navigateToSyncScreen,
//                   child: Text(AppText.syncdata),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//
//
// // class BluetoothPair extends StatefulWidget {
// //
// //   @override
// //   _BluetoothPairState createState() => _BluetoothPairState();
// // }
// //
// // class _BluetoothPairState extends State<BluetoothPair> {
// //   static const platform = MethodChannel('cling_sdk');
// //   final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
// //
// //   List<String> _devices = [];
// //   String? _registeredDevice;
// //   String? _pairingDevice;
// //   Map<String, String> _pairingStatus = {}; // Map to store pairing status
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     platform.setMethodCallHandler(_methodCallHandler);
// //     //_checkForPairedDevice();
// //     _startScanning();
// //     super.initState();
// //
// //
// //   }
// //
// //
// //   void onDeviceConnected() async {
// //     try {
// //       await platform.invokeMethod("setDeviceConfig");
// //       print("Device config updated successfully.");
// //     } catch (e) {
// //       print("Error setting device config: $e");
// //     }
// //   }
// //
// //   Future<void> _methodCallHandler(MethodCall call) async {
// //     if (call.method == "onDevicesDiscovered") {
// //       setState(() {
// //         _devices = List<String>.from(call.arguments);
// //       });
// //     }
// //   }
// //
// //   // Future<void> _checkForPairedDevice() async {
// //   //   try {
// //   //     final String? lastDeviceID = await platform.invokeMethod('getLastActiveDevice');
// //   //     if (lastDeviceID != null && lastDeviceID.isNotEmpty) {
// //   //       setState(() {
// //   //         _registeredDevice = lastDeviceID;
// //   //       });
// //   //
// //   //       // Navigate to Sync Screen immediately if a paired device is found
// //   //       Future.delayed(Duration(seconds: 1), () {
// //   //         _navigateToSyncScreen();
// //   //       });
// //   //     }
// //   //   } on PlatformException catch (e) {
// //   //     print("Failed to get last active device: ${e.message}");
// //   //   }
// //   // }
// //
// //   Future<void> _startScanning() async {
// //     try {
// //       await platform.invokeMethod('startScanning');
// //     } on PlatformException catch (e) {
// //       print("Failed to start scanning: ${e.message}");
// //     }
// //   }
// //
// //
// //   Future<void> _registerDevice(String deviceID) async {
// //     setState(() {
// //       _pairingDevice = deviceID; // Show loader for this device
// //     });
// //
// //     try {
// //       await platform.invokeMethod('registerDevice', {"deviceID": deviceID});
// //
// //       setState(() {
// //         _registeredDevice = deviceID;
// //         _pairingStatus[deviceID] = AppText.paired;
// //       });
// //
// //       _scaffoldMessengerKey.currentState?.showSnackBar(
// //         SnackBar(content: Text("Device $deviceID registered successfully!")),
// //       );
// //
// //       // Navigate to the Sync Screen after pairing
// //       Future.delayed(Duration(seconds: 1), () {
// //         _navigateToSyncScreen();
// //       });
// //
// //     } on PlatformException
// //     catch (e) {
// //       setState(() {
// //         _pairingStatus[deviceID] = AppText.failed;
// //       });
// //       print("Failed to register device: ${e.message}");
// //       _scaffoldMessengerKey.currentState?.showSnackBar(
// //         SnackBar(content: Text("Failed to register device: ${e.message}")),
// //       );
// //     } finally {
// //       setState(() {
// //         _pairingDevice = null; // Hide loader after pairing
// //       });
// //     }
// //   }
// //
// //   void _navigateToSyncScreen() {
// //     if (_registeredDevice != null) {
// //       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SyncDataScreen(deviceID: _registeredDevice!)));
// //     }
// //   }
// //
// //   void _navigateToSkip() {
// //     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DashboardScreen(deviceID: '')));
// //
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       debugShowCheckedModeBanner: false,
// //       scaffoldMessengerKey: _scaffoldMessengerKey,
// //       home: WillPopScope(
// //         onWillPop: () async {
// //           bool shouldExit = await showExitConfirmationDialog(context);
// //           return shouldExit;
// //         },
// //         child: Scaffold(
// //           backgroundColor: Colors.white,
// //           appBar: AppBar(
// //             centerTitle: true,
// //             title: Text(AppText.SDK_headings,
// //               style:Apptextstyle.s18wbap,),
// //             backgroundColor:Colors.white,
// //             leading: IconButton(
// //               onPressed: () {
// //                 //Get.to(() => LoginScreen());
// //                 // Navigator.pushReplacement(
// //                 //   context,
// //                 //   MaterialPageRoute(builder: (context) => LoginScreen()),
// //                 // );
// //                 //Navigator.pop(context);
// //                 SystemNavigator.pop();
// //               },
// //               icon: Icon(Icons.arrow_back_ios),
// //             ),
// //           ),
// //           body: Column(
// //             children: [
// //               SizedBox(height: 10,),
// //               ElevatedButton(
// //                 onPressed: _startScanning,
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: AppColors.others, // Button background color
// //                   foregroundColor: Colors.white, // Text (and icon) color
// //                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(10), // Rounded corners
// //                   ),
// //                 ),
// //                 child: const Text(AppText.scandevice),
// //               ),
// //               SizedBox(height: 20,),
// //               ElevatedButton(
// //                 onPressed: _navigateToSkip,
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: AppColors.others, // Button background color
// //                   foregroundColor: Colors.white, // Text (and icon) color
// //                   padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(10), // Rounded corners
// //                   ),
// //                 ),
// //                 child: const Text(AppText.skip),
// //               ),//
// //               SizedBox(height: 20),
// //               Expanded(
// //                 child: _devices.isEmpty
// //                     ? Center(child: Text(AppText.nodevices))
// //                     : ListView.builder(
// //                   itemCount: _devices.length,
// //                   itemBuilder: (context, index) {
// //                     String deviceID = _devices[index];
// //                     return Column(
// //                       children: [
// //                         ListTile(
// //                           title: Text(deviceID),
// //                           subtitle: Text(
// //                             _pairingStatus[deviceID] ?? AppText.notpaired,
// //                             style: _pairingStatus[deviceID] == AppText.paired
// //                                 ? Apptextstyle.s16wncGreen
// //                                 : _pairingStatus[deviceID] == AppText.failed
// //                                 ? Apptextstyle.s16wncR
// //                                 : Apptextstyle.s16wncB,
// //                           ),
// //                           onTap: () => _registerDevice(deviceID),
// //                           trailing: _pairingDevice == deviceID
// //                               ? const SizedBox(
// //                             width: 24,
// //                             height: 24,
// //                             child: CircularProgressIndicator(strokeWidth: 2),
// //                           )
// //                               : Icon(
// //                             Icons.bluetooth,
// //                             color: _pairingStatus[deviceID] == AppText.paired
// //                                 ? AppColors.others
// //                                 : _pairingStatus[deviceID] == AppText.failed
// //                                 ? AppColors.Red
// //                                 : AppColors.Grey,
// //                           ),
// //                         ),
// //                         const Divider(height: 0.5, thickness: 0.5),
// //                       ],
// //                     );
// //                   },
// //                 ),
// //               ),
// //               if (_registeredDevice != null) ...[
// //                 Divider(),
// //                 Text(
// //                   "Registered Device: $_registeredDevice",
// //                   style: TextStyle(fontWeight: FontWeight.bold),
// //                 ),
// //                 ElevatedButton(
// //                   onPressed: _navigateToSyncScreen,
// //                   child: Text(AppText.syncdata),
// //                 ),
// //               ],
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
//
//
// /// Shows a confirmation dialog when the user presses the back button.
// Future<bool> showExitConfirmationDialog(BuildContext context) async {
//   bool exit = false;
//   await showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         backgroundColor: Colors.white,
//         title: Text(AppText.exitapp, style: Apptextstyle.s15wbcothers,),
//         content: Text(AppText.sure_exit, style: Apptextstyle.s13wbcgrey,),
//         actions: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               InkWell(
//                 onTap: () {
//                   Navigator.of(context).pop(); // Dismiss dialog
//                 },
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.red,
//                     borderRadius: BorderRadius.circular(5.0),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
//                     child: Row(
//                       children: [
//                         Text(
//                             AppText.cancel,
//                             style: Apptextstyle.s15wbcW
//                         ),
//                         SizedBox(width: 5,),
//                         Icon(Icons.logout,color: Colors.white,)
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               InkWell(
//                 onTap: () {
//                   exit = true;
//                   SystemNavigator.pop();
//                   //Navigator.of(context).pop(); // Dismiss dialog
//                 },
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.red,
//                     borderRadius: BorderRadius.circular(5.0),
//                   ),
//                   child: const Padding(
//                     padding: EdgeInsets.fromLTRB(25, 4, 20, 4),
//                     child: Center(
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.center,// 👈 THIS is required
//                         mainAxisSize: MainAxisSize.max,
//                         children: [
//                           Center(
//                             child: Text(
//                               AppText.exit,
//                               style: Apptextstyle.s15wbcW,
//                             ),
//                           ),
//                           const SizedBox(width: 5),
//                           const Icon(
//                             Icons.arrow_right_alt_sharp,
//                             color: Colors.white,
//                           ),
//                         ],
//                       ),
//
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           )
//         ],
//       );
//     },
//   );
//   return exit;
// }
