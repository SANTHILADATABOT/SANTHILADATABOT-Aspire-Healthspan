//
//
//
//
//
//
// package com.eugene.aspire;
//
// import android.os.Handler;
// import android.os.Looper;
// import android.util.Log;
// import android.bluetooth.BluetoothDevice;
//
// import com.hicling.clingsdk.ClingSdk;
// import com.hicling.clingsdk.bleservice.BluetoothDeviceInfo;
// import com.hicling.clingsdk.listener.OnBleListener;
//
// import java.util.ArrayList;
// import java.util.HashMap;
// import java.util.List;
// import java.util.Map;
//
// import io.flutter.plugin.common.EventChannel;
// import android.content.Context;
//
// public class ClingBleManager {
//
//   private static final String TAG = "CLING_MANAGER";
//   private static final int USER_ID = 876355;
//
//   private static final Map<String, BluetoothDevice> deviceMap = new HashMap<>();
//   private static final Handler mainHandler = new Handler(Looper.getMainLooper());
//
//   private static EventChannel.EventSink scanSink;
//   private static EventChannel.EventSink minuteSink;
//   private static EventChannel.EventSink syncStatusSink;
//   private static EventChannel.EventSink pairStatusSink;
//
//   private static EventChannel.EventSink dailySink;
//
//   // ================== SINK SETTERS ==================
//
//   public static void setEventSink(EventChannel.EventSink sink) {
//     scanSink = sink;
//   }
//
//
//   public static void setMinuteEventSink(EventChannel.EventSink sink) {
//     minuteSink = sink;
//   }
//
//   public static void setSyncStatusSink(EventChannel.EventSink sink) {
//     syncStatusSink = sink;
//   }
//
//   public static void setPairStatusSink(EventChannel.EventSink sink) {
//     pairStatusSink = sink;
//   }
//
//   public static EventChannel.EventSink getMinuteEventSink() {
//     return minuteSink;
//   }
//
//   public static EventChannel.EventSink getSyncStatusSink() {
//     return syncStatusSink;
//   }
//
//   public static void setDailyEventSink(EventChannel.EventSink sink) {
//     dailySink = sink;
//   }
//
//   public static EventChannel.EventSink getDailyEventSink() {
//     return dailySink;
//   }
//
//   // ================== SCAN ==================
//
//   public static void startScan() {
//
//     Log.i(TAG, "🔍 Starting scan...");
//
//     ClingSdk.stopScan();
//     ClingSdk.setUserId(USER_ID);
//     ClingSdk.setClingDeviceType(ClingSdk.CLING_DEVICE_TYPE_TRONL);
//
//     ClingSdk.startScan(60 * 1000,
//         new OnBleListener.OnScanDeviceListener() {
//
//         @Override
//         public void onBleScanUpdated(Object o) {
//
//         if (o == null) return;
//
//         ArrayList<BluetoothDeviceInfo> devices =
//         (ArrayList<BluetoothDeviceInfo>) o;
//
//         List<Map<String, Object>> result = new ArrayList<>();
//
//         for (BluetoothDeviceInfo d : devices) {
//
//         BluetoothDevice device = d.getmBleDevice();
//         if (device == null) continue;
//
//         String mac = device.getAddress();
//         String name = device.getName();
//
//         deviceMap.put(name, device);
//
//         Map<String, Object> map = new HashMap<>();
//         map.put("name", name);
//         map.put("mac", mac);
//         map.put("rssi", d.getmRssi());
//
//         result.add(map);
//         }
//
//         if (scanSink != null) {
//         mainHandler.post(() -> scanSink.success(result));
//         }
//         }
//         });
//   }
//
//   public static void stopScan() {
//     ClingSdk.stopScan();
//   }
//
//   // ================== CONNECT ==================
//
//
//
// //    public static void connect(String name) {
// //
// //        Log.e(TAG, "==============================");
// //        Log.e(TAG, "🔗 CONNECT CALLED with name → " + name);
// //
// //        ClingSdk.stopScan();
// //        ClingSdk.setUserId(USER_ID);
// //
// //        BluetoothDevice device = deviceMap.get(name);
// //
// //        if (device == null) {
// //            Log.e(TAG, "❌ Device not found in deviceMap");
// //            return;
// //        }
// //
// //        if (ClingSdk.isAccountBondWithCling()) {
// //
// //            Log.e(TAG, "⚠ Device already bonded → forcing clean reset");
// //
// //            ClingSdk.deregisterDevice(new OnBleListener.OnDeregisterDeviceListener() {
// //
// //                @Override
// //                public void onDeregisterDeviceSucceed() {
// //
// //                    Log.e(TAG, "✅ Deregister success → registering again");
// //
// //                    new Handler(Looper.getMainLooper()).postDelayed(() -> {
// //
// //                        ClingSdk.registerDevice(
// //                                USER_ID,
// //                                device,
// //                                new OnBleListener.OnRegisterDeviceListener() {
// //
// //                                    @Override
// //                                    public void onRegisterDeviceSucceed() {
// //                                        Log.e(TAG, "✅ Re-register success");
// //                                    }
// //
// //                                    @Override
// //                                    public void onRegisterDeviceFailed(int code, String msg) {
// //                                        Log.e(TAG, "❌ Re-register failed: " + msg);
// //                                    }
// //                                }
// //                        );
// //
// //                    }, 1000); // small delay to let SDK reset fully
// //                }
// //
// //                @Override
// //                public void onDeregisterDeviceFailed(int code, String msg) {
// //                    Log.e(TAG, "❌ Deregister failed: " + msg);
// //                }
// //            });
// //
// //            return;
// //        }
// //
// //        Log.e(TAG, "🆕 No bonded device → calling registerDevice()");
// //
// //        ClingSdk.registerDevice(
// //                USER_ID,
// //                device,
// //                new OnBleListener.OnRegisterDeviceListener() {
// //
// //                    @Override
// //                    public void onRegisterDeviceSucceed() {
// //                        Log.e(TAG, "✅ Register success");
// //                    }
// //
// //                    @Override
// //                    public void onRegisterDeviceFailed(int code, String msg) {
// //                        Log.e(TAG, "❌ Register failed: " + code + " " + msg);
// //                    }
// //                }
// //        );
// //    }
//
// //    public static void connect(String name) {
// //
// //        Log.e(TAG, "🔗 CONNECT CALLED with name → " + name);
// //
// //        ClingSdk.stopScan();
// //        ClingSdk.setUserId(USER_ID);
// //
// //        BluetoothDevice device = deviceMap.get(name);
// //
// //        if (device == null) {
// //            Log.e(TAG, "❌ Device not found");
// //            return;
// //        }
// //
// //        boolean bonded = ClingSdk.isAccountBondWithCling();
// //        Log.e(TAG, "Bonded status → " + bonded);
// //
// //        if (bonded) {
// //
// //            Log.e(TAG, "⚠ Bond exists → FIRST TAP → Only Deregister");
// //
// //            ClingSdk.deregisterDevice(new OnBleListener.OnDeregisterDeviceListener() {
// //
// //                @Override
// //                public void onDeregisterDeviceSucceed() {
// //                    Log.e(TAG, "✅ Deregister success. Tap again to connect.");
// //                }
// //
// //                @Override
// //                public void onDeregisterDeviceFailed(int code, String msg) {
// //                    Log.e(TAG, "❌ Deregister failed: " + msg);
// //                }
// //            });
// //
// //            return; // 🔥 STOP HERE
// //        }
// //
// //        // SECOND TAP FLOW
// //        Log.e(TAG, "🆕 No bond → SECOND TAP → Registering");
// //
// //        ClingSdk.registerDevice(
// //                USER_ID,
// //                device,
// //                new OnBleListener.OnRegisterDeviceListener() {
// //
// //                    @Override
// //                    public void onRegisterDeviceSucceed() {
// //                        Log.e(TAG, "✅ Register success");
// //                    }
// //
// //                    @Override
// //                    public void onRegisterDeviceFailed(int code, String msg) {
// //                        Log.e(TAG, "❌ Register failed: " + msg);
// //                    }
// //                }
// //        );
// //    }
//
// //    public static void connect(String name, Context context) {
// //
// //        Log.e(TAG, "🔗 CONNECT CALLED with name → " + name);
// //
// //        ClingSdk.stopScan();
// //        ClingSdk.setUserId(USER_ID);
// //
// //        BluetoothDevice device = deviceMap.get(name);
// //
// //        if (device == null) {
// //            Log.e(TAG, "❌ Device not found");
// //            return;
// //        }
// //
// //        // 🔥 CHECK SAVED CLING ID INSTEAD OF SDK BOND
// //        String savedClingId = context
// //                .getSharedPreferences("CLING_PREF", Context.MODE_PRIVATE)
// //                .getString("CLING_ID", null);
// //
// //        Log.e(TAG, "Saved ClingId → " + savedClingId);
// //
// //        if (savedClingId != null) {
// //
// //            // FIRST TAP → ONLY DEREGISTER
// //            Log.e(TAG, "⚠ First Tap → Deregistering old device");
// //
// //            ClingSdk.deregisterDevice(new OnBleListener.OnDeregisterDeviceListener() {
// //
// //                @Override
// //                public void onDeregisterDeviceSucceed() {
// //
// //                    Log.e(TAG, "✅ Deregister success");
// //
// //                    // 🔥 CLEAR SAVED CLING ID
// //                    context.getSharedPreferences("CLING_PREF", Context.MODE_PRIVATE)
// //                            .edit()
// //                            .remove("CLING_ID")
// //                            .apply();
// //                }
// //
// //                @Override
// //                public void onDeregisterDeviceFailed(int code, String msg) {
// //                    Log.e(TAG, "❌ Deregister failed: " + msg);
// //                }
// //            });
// //
// //            return; // STOP HERE
// //        }
// //
// //        // SECOND TAP → REGISTER + CONNECT
// //        Log.e(TAG, "🆕 Second Tap → Registering device");
// //
// //        ClingSdk.registerDevice(
// //                USER_ID,
// //                device,
// //                new OnBleListener.OnRegisterDeviceListener() {
// //
// //                    @Override
// //                    public void onRegisterDeviceSucceed() {
// //                        Log.e(TAG, "✅ Register success");
// //                    }
// //
// //                    @Override
// //                    public void onRegisterDeviceFailed(int code, String msg) {
// //                        Log.e(TAG, "❌ Register failed: " + msg);
// //                    }
// //                }
// //        );
// //    }
//
//   public static void connect(String name, Context context) {
//
//     Log.e(TAG, "🔗 CONNECT CALLED → " + name);
//
//     ClingSdk.stopScan();
//     ClingSdk.setUserId(USER_ID);
//
//     BluetoothDevice device = deviceMap.get(name);
//
//     if (device == null) {
//       Log.e(TAG, "❌ Device not found");
//       return;
//     }
//
//     String savedClingId = context
//         .getSharedPreferences("CLING_PREF", Context.MODE_PRIVATE)
//         .getString("CLING_ID", null);
//
//     String sdkBondClingId = ClingSdk.getBondClingDeviceName();
//
//     Log.e(TAG, "Saved ClingId → " + savedClingId);
//     Log.e(TAG, "SDK Bond ClingId → " + sdkBondClingId);
//
//     // ================================
//     // 🎯 SCENARIO 3 DETECTION
//     // ================================
//     if (savedClingId == null && sdkBondClingId != null) {
//
//       Log.e(TAG, "⚠ Reinstall detected → First tap deregister only");
//
//       ClingSdk.deregisterDevice(new OnBleListener.OnDeregisterDeviceListener() {
//
//       @Override
//       public void onDeregisterDeviceSucceed() {
//       Log.e(TAG, "✅ Deregister success. Tap again to connect.");
//       }
//
//       @Override
//       public void onDeregisterDeviceFailed(int code, String msg) {
//       Log.e(TAG, "❌ Deregister failed: " + msg);
//       }
//       });
//
//       return;
//     }
//
//     // ================================
//     // NORMAL FLOW
//     // ================================
//     Log.e(TAG, "🆕 Registering device");
//
//     ClingSdk.registerDevice(
//         USER_ID,
//         device,
//         new OnBleListener.OnRegisterDeviceListener() {
//
//     @Override
//     public void onRegisterDeviceSucceed() {
//     Log.e(TAG, "✅ Register success");
//     }
//
//     @Override
//     public void onRegisterDeviceFailed(int code, String msg) {
//     Log.e(TAG, "❌ Register failed: " + msg);
//     }
//     }
//     );
//   }
//
//   // ================== PAIR EVENT ==================
//
//   public static void notifyPaired(String clingId) {
//
//     if (clingId == null || clingId.isEmpty()) return;
//
//     Log.i(TAG, "🔥 Pair success → " + clingId);
//
//     if (pairStatusSink != null) {
//       mainHandler.post(() -> pairStatusSink.success(clingId));
//     } else {
//     Log.w(TAG, "PairStatusSink is NULL");
//     }
//   }
//
//   // ================== DEREGISTER ==================
//
//   public static void deregisterDevice() {
//
//     //ClingSdk.disconnectDevice(true);
//
//     ClingSdk.deregisterDevice(
//         new OnBleListener.OnDeregisterDeviceListener() {
//
//
//     @Override
//     public void onDeregisterDeviceSucceed() {
//
//     Log.i(TAG, "Device deregistered");
//     //ClingSdk.disconnectDevice(true);
//     //deviceMap.clear();
//     ClingSdk.stopScan();
//     }
//
//     @Override
//     public void onDeregisterDeviceFailed(int code, String msg) {
//     Log.e(TAG, "Deregister failed: " + code + " " + msg);
//     }
//     }
//     );
//   }
// }











// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       title: 'Aspire Healthspan',
//       debugShowCheckedModeBanner: false,
//       // home: kIsWeb
//       //     ? (LoginScreen())
//       //     : SplashPage(),
//       home:  SplashPage(),
//     );
//   }
// }
//
// class SplashPage extends StatefulWidget {
//   @override
//   _SplashPageState createState() => _SplashPageState();
// }
//
// class _SplashPageState extends State<SplashPage> {
//   bool isLoggedIn = false;
//   bool isLoading = true;
//   static const MethodChannel iosChannel =
//   MethodChannel('cling_sdk');
//
//   static const MethodChannel androidChannel =
//   MethodChannel('cling/methods');
//
//   String? _registeredDevice;
//   String? _lastdeviceId;
//   final FirebaseMessaging messaging = FirebaseMessaging.instance;
//
//   @override
//   void initState() {
//     super.initState();
//     initializeNotifications();
//
//     if (!kIsWeb && isIOS) {
//       Future.delayed(const Duration(seconds: 1), () async {
//         if (!mounted) return;
//         final status = await AppTrackingTransparency.trackingAuthorizationStatus;
//         print("Current ATT status: $status");
//
//         if (status == TrackingStatus.notDetermined) {
//           if (!mounted) return;
//           final newStatus = await AppTrackingTransparency.requestTrackingAuthorization();
//           print("ATT prompt shown. New status: $newStatus");
//         } else {
//           print("ATT already determined: $status");
//         }
//       });
//     }
//
//     // Future.delayed(const Duration(seconds: 2), () {
//     //   Get.offAll(() => BluetoothPair());
//     // });
//
//     //checkSession();
//
//     _registerdevice();
//   }
//
//   Future<void>_registerdevice()async{
//
//     if (Platform.isAndroid) {
//       try {
//
//         final String? clingId =
//         await androidChannel.invokeMethod("getSavedClingId");
//
//         print("🔥 Android Saved clingId → $clingId");
//
//         if (clingId != null && clingId.isNotEmpty) {
//
//
//           Get.offAll(() =>
//               SyncDataScreen(deviceID: clingId));
//           // Get.offAll(() =>
//           //     DashboardScreen(deviceID: clingId));
//
//         } else {
//
//           Get.offAll(() => BluetoothPair());
//         }
//
//       } catch (e) {
//         print("Android session error: $e");
//         //Get.offAll(() => BluetoothPair());
//       }
//     }
//
//     if (Platform.isIOS) {
//       try {
//
//         final String? lastDeviceID =
//         await iosChannel.invokeMethod('getLastActiveDevice');
//
//         print("🍎 iOS Last Device → $lastDeviceID");
//
//         if (lastDeviceID != null && lastDeviceID.isNotEmpty) {
//
//           _registeredDevice = lastDeviceID;
//
//           Get.offAll(() =>
//               DashboardScreen(deviceID: lastDeviceID));
//
//         } else {
//
//           Get.offAll(() => BluetoothPair());
//         }
//
//       } catch (e) {
//         print("iOS session error: $e");
//         Get.offAll(() => BluetoothPair());
//       }
//     }
//   }
//
//
//
//   Future<void> initializeNotifications() async {
//     NotificationSettings settings = await messaging.requestPermission();
//     print('Permission status: ${settings.authorizationStatus}');
//
//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       print("✅ Notification permission granted");
//
//       final prefs = await SharedPreferences.getInstance();
//
//       if (kIsWeb) {
//         final token = await messaging.getToken(
//           vapidKey: "BBDchPDDIaVe_9T10UA-yxAzZfhWN68KuYExqsvwdOwZxcKItXJhj93VYGgyoaAaoafelKRzcfJWggC2ftMRXuA",
//         );
//         print("Web FCM Token: $token");
//         await prefs.setString('token', token ?? "");
//       } else {
//         final token = await messaging.getToken();
//         print("FCM Token: ${token ?? 'null'}");
//         await prefs.setString('token', token ?? "");
//
//         FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//           print("Foreground Notification Received");
//           showNotification(message.notification?.title, message.notification?.body);
//         });
//       }
//     } else {
//       print("Notification permission denied");
//     }
//   }
//
//
//
//   Future<void> checkSession() async {
//     final prefs = await SharedPreferences.getInstance();
//     bool loggedIn = prefs.getBool('isLoggedIn') ?? false;
//
//     if (!mounted) return;
//
//     setState(() {
//       isLoggedIn = loggedIn;
//       isLoading = false;
//     });
//
//     if (!loggedIn || kIsWeb) return;
//
//     if (Platform.isAndroid) {
//       try {
//
//         final String? clingId =
//         await androidChannel.invokeMethod("getSavedClingId");
//
//         print("🔥 Android Saved clingId → $clingId");
//
//         if (clingId != null && clingId.isNotEmpty) {
//
//
//           Get.offAll(() =>
//               SyncDataScreen(deviceID: clingId));
//           // Get.offAll(() =>
//           //     DashboardScreen(deviceID: clingId));
//
//         } else {
//
//           Get.offAll(() => BluetoothPair());
//         }
//
//       } catch (e) {
//         print("Android session error: $e");
//         //Get.offAll(() => BluetoothPair());
//       }
//     }
//
//     if (Platform.isIOS) {
//       try {
//
//         final String? lastDeviceID =
//         await iosChannel.invokeMethod('getLastActiveDevice');
//
//         print("🍎 iOS Last Device → $lastDeviceID");
//
//         if (lastDeviceID != null && lastDeviceID.isNotEmpty) {
//
//           _registeredDevice = lastDeviceID;
//
//           Get.offAll(() =>
//               DashboardScreen(deviceID: lastDeviceID));
//
//         } else {
//
//           Get.offAll(() => BluetoothPair());
//         }
//
//       } catch (e) {
//         print("iOS session error: $e");
//         Get.offAll(() => BluetoothPair());
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     precacheImage(const AssetImage("assets/gif/logo.gif"), context);
//     return Scaffold(
//       body: Center(
//         child: CircularProgressIndicator(),
//       ),
//     );
//     // if (isLoading) {
//     //   return Scaffold(
//     //     body: Center(child: CircularProgressIndicator()),
//     //   );
//     // }
//
//     return EasySplashScreen(
//       logo: Image.asset(Appimages.applogo),
//       title: Text(
//         AppText.splashAppname,
//         style: Apptextstyle.s16wbcothers,
//       ),
//       logoWidth: 75,
//       backgroundColor: Colors.white,
//       showLoader: true,
//       navigator: BluetoothPair(),
//       // navigator: isLoggedIn
//       //     ? (kIsWeb
//       //     ? BluetoothPair()
//       //     : (_registeredDevice != null &&
//       //     _registeredDevice!.isNotEmpty
//       //     ? (Platform.isIOS
//       //     ? DashboardScreen(deviceID: _registeredDevice!)
//       //     : SyncDataScreen(deviceID: _registeredDevice!))
//       //     : BluetoothPair()))
//       //     : LoginScreen(),
//     );
//   }
// }







//bluetoothscreen

// class _BluetoothPairState extends State<BluetoothPair>  with WidgetsBindingObserver {
//   //static const platform = MethodChannel('cling_sdk');
//   //final String METHOD_CHANNEL = "cling/methods";
//   final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
//
//   //List<String> _devices = [];
//   //List<Map<String, String>> _devices = [];
//   List<dynamic> _devices = [];
//   String? _registeredDevice;
//   String? _pairingDevice;
//   Map<String, String> _pairingStatus = {}; // Map to store pairing status
//   StreamSubscription? _scanSub;
//   StreamSubscription? _pairSub;
//   StreamSubscription? _minuteSub;
//   StreamSubscription? _syncSub;
//   bool _hasNavigated = false;
//   bool isLoading = false;
//   bool _isDialogOpen = false;
//   late final MethodChannel platform;
//   Timer? _btStateTimer;
//   bool _lastBtState = true;
//
//   @override
//   void initState() {
//     super.initState();
//     if (Platform.isAndroid) {
//       platform = const MethodChannel('cling/methods');
//
//     } else if (Platform.isIOS) {
//       platform = const MethodChannel('cling_sdk');
//     }
//     _hasNavigated = false;
//     platform.setMethodCallHandler(_methodCallHandler);
//     _listenForPairEvents();
//     _checkBluetoothOnEntry();
//     _startBluetoothMonitoring();
//     // Future.delayed(const Duration(milliseconds: 1200), () {
//     //   //_startScanning();
//     // });
//     WidgetsBinding.instance.addObserver(this);
//     // Android: listen to scan results and update _devices list
//     _scanSub?.cancel();
//     if (Platform.isAndroid) {
//       _scanSub = ClingBleService.scanResults().listen((results) {
//
//         final devices = results.map((d) {
//           return {
//             "name": d['name'].toString(),
//             "mac": d['mac'].toString(),
//           };
//         }).toList();
//
//         setState(() {
//           _devices = devices;
//         });
//       });
//     }
//
//   }
//
//
//
//   void _startBluetoothMonitoring() {
//     _btStateTimer?.cancel();
//
//     _btStateTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
//       final isOn = await platform.invokeMethod("isBluetoothOn");
//
//       // 🔴 Bluetooth turned OFF
//       if (_lastBtState == true && isOn == false) {
//         await ClingBleService.stopScan();
//
//         if (mounted) {
//           setState(() {
//             _devices.clear();
//           });
//         }
//
//         _showBluetoothPopup();
//       }
//
//       // 🟢 Bluetooth turned ON
//       if (_lastBtState == false && isOn == true) {
//
//         // ✅ CLOSE POPUP
//         if (_isDialogOpen && mounted) {
//           Navigator.of(context, rootNavigator: true).pop();
//           _isDialogOpen = false;
//         }
//
//         // ✅ Start scanning again
//         await Future.delayed(const Duration(milliseconds: 300));
//         _startScanning();
//       }
//
//       _lastBtState = isOn;
//     });
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       _onReturnFromSettings();
//     }
//   }
//
//   Future<void> _onReturnFromSettings() async {
//     // On iOS the CBCentralManager state is asynchronous.
//     // Give it a moment to settle before querying.
//     if (Platform.isIOS) {
//       await Future.delayed(const Duration(milliseconds: 600));
//     }
//
//     final isOn = await platform.invokeMethod("isBluetoothOn");
//
//     if (isOn == true) {
//       // Sync state tracker so the periodic timer doesn't get confused.
//       _lastBtState = true;
//
//       // Dismiss the popup if it is showing.
//       if (_isDialogOpen && mounted) {
//         Navigator.of(context, rootNavigator: true).pop();
//         _isDialogOpen = false;
//       }
//
//       // Start scanning here in case the native bluetoothOn event was fired
//       // while the app was in the background and was never received by Flutter.
//       await Future.delayed(const Duration(milliseconds: 300));
//       _startScanning();
//     } else {
//       _lastBtState = false;
//       _showBluetoothPopup();
//     }
//   }
//
//   Future<void> _checkBluetoothOnEntry() async {
//     try {
//       // On iOS, CBCentralManager initializes asynchronously and starts in
//       // .unknown state for ~300-800ms. Querying too early returns false even
//       // when Bluetooth is actually ON, which causes a false-positive popup.
//       if (Platform.isIOS) {
//         await Future.delayed(const Duration(milliseconds: 800));
//       }
//
//       final isOn = await platform.invokeMethod("isBluetoothOn");
//
//       _lastBtState = isOn; // 👈 track initial state
//
//       if (isOn == false) {
//         _showBluetoothPopup();
//       } else {
//         _startScanning();
//       }
//     } catch (e) {
//       print("BT check error: $e");
//     }
//   }
//
//   void _showBluetoothPopup() {
//     if (!mounted) return;
//     if (_isDialogOpen) return;
//
//     _isDialogOpen = true;
//
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) {
//         return AlertDialog(
//           backgroundColor: Colors.white,
//           title: const Text("Turn on Bluetooth"),
//           content: const Text(
//               "Bluetooth is required to scan for and connect to nearby devices. Please enable Bluetooth to continue"
//           ),
//           actionsAlignment: MainAxisAlignment.center,
//           actions: [
//             Center(
//               child: TextButton(
//                 onPressed: () async {
//                   Navigator.pop(context);
//                   _isDialogOpen = false;
//
//                   if (Platform.isAndroid) {
//                     try {
//                       await const MethodChannel('cling/methods')
//                           .invokeMethod("openBluetoothSettings");
//                     } catch (e) {
//                       print("Error opening Bluetooth: $e");
//                     }
//                   } else if (Platform.isIOS) {
//                     try {
//                       await platform.invokeMethod("openBluetoothSettings");
//                     } catch (e) {
//                       print("Error opening Bluetooth settings: $e");
//                     }
//                   }
//                 },
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                   decoration: BoxDecoration(
//                     color: AppColors.others,
//                     borderRadius: BorderRadius.circular(5.0),
//                   ),
//                   child: const Text(
//                     "OK",
//                     style: Apptextstyle.s15wbcW,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     ).then((_) {
//       // ✅ Ensures state resets even if dialog dismissed unexpectedly
//       _isDialogOpen = false;
//     });
//   }
//
//   Future<void> _listenForPairEvents() async {
//     print("print9");
//     if (!Platform.isAndroid) return;
//     print("print10");
//
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     var user_id = prefs.getString('user_id') ?? "";
//     print("user_id:$user_id");
//
//     _pairSub = ClingBleService.pairStatusStream().listen((connectedId) {
//
//       if (!mounted) return;
//
//       // ✅ ALWAYS use the tapped device (UI key)
//       // final deviceName = _pairingDevice;
//       //
//       // if (deviceName == null) return;
//
//       final deviceName = _pairingDevice ?? connectedId;
//
//
//       setState(() {
//         _pairingStatus[deviceName] = AppText.paired; // ✅ correct key
//         _registeredDevice = deviceName;
//       });
//
//       // show paired UI briefly
//       Future.delayed(const Duration(milliseconds: 800), () {
//         if (!mounted) return;
//
//         setState(() {
//           isLoading = false;
//           _pairingDevice = null;
//         });
//
//         _navigateToSyncScreen();
//       });
//     });
//
//   }
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
//     } else if (call.method == "bluetoothOff") {
//       if (Platform.isAndroid) {
//         await ClingBleService.stopScan();
//       }
//       if (mounted) {
//         setState(() {
//           _devices.clear();
//         });
//       }
//       _showBluetoothPopup();
//     } else if (call.method == "bluetoothOn") {
//       if (_isDialogOpen && mounted) {
//         Navigator.of(context, rootNavigator: true).pop();
//         _isDialogOpen = false;
//       }
//       await Future.delayed(const Duration(milliseconds: 300));
//       _startScanning();
//     }
//   }
//
//   Future<void> _startScanning() async {
//     // if (Platform.isAndroid) {
//     //   ClingBleService.startScan();
//     // }
//     if (Platform.isAndroid) {
//
//       final isOn = await platform.invokeMethod("isBluetoothOn");
//
//       if (isOn == false) {
//         _showBluetoothPopup();
//         return;
//       }
//
//
//       await ClingBleService.stopScan(); // 🔥 IMPORTANT
//       await Future.delayed(Duration(milliseconds: 300));
//
//       // setState(() {
//       //   _devices.clear(); // 🔥 clear old devices
//       // });
//
//       try {
//         await ClingBleService.startScan();
//       } on PlatformException catch (e) {
//         if (e.code == "NO_PERMISSION") {
//           _scaffoldMessengerKey.currentState?.showSnackBar(
//             SnackBar(content: Text("Bluetooth/Location permission is required to scan.")),
//           );
//         } else if (e.code == "LOCATION_DISABLED") {
//           _scaffoldMessengerKey.currentState?.showSnackBar(
//             SnackBar(content: Text("Please turn on your phone's Location (GPS) to find nearby devices.")),
//           );
//         }
//       }
//     }
//     else if (Platform.isIOS) {
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
//     print("print1");
//
//
//     if (Platform.isAndroid) {
//       try {
//         setState(() {
//           _pairingDevice = deviceID;
//           _pairingStatus[deviceID] = "Pairing...";
//           isLoading = true;
//         });
//
//         final prefs = await SharedPreferences.getInstance();
//         var user_id = prefs.getString('user_id') ?? "";
//         await prefs.setString('DeviceId', deviceID);
//         print("DEVICE_ID:$deviceID");
//
//         final response = await pairDevice(user_id, deviceID);
//
//         if (response == null) {
//           throw Exception("No response from API");
//         }
//
//         int statusCode = response['statusCode'] ?? 0;
//         String status = response['status'] ?? "";
//         String message = response['message'] ?? "";
//         String apiDeviceId =
//         (response['device_id'] ?? "").toString().trim();
//
//         // ✅ ADDED (user_id from API)
//         String apiUserId =
//         (response['user_id'] ?? "").toString().trim();
//
//         print("HTTP: $statusCode | API: $status | Msg: $message");
//         print("Local Device: $deviceID | API Device: $apiDeviceId");
//
//         // ❌ FAILED (HTTP fail OR API fail OR Device mismatch)
//         if (statusCode != 200 ||
//             status != "SUCCESS" ||
//             apiDeviceId != deviceID.trim()) {
//
//           // _scaffoldMessengerKey.currentState?.showSnackBar(
//           //   SnackBar(content: Text(message)),
//           // );
//           showCustomToast(message);
//
//
//           setState(() {
//             _pairingStatus[deviceID] = AppText.failed;
//             _pairingDevice = null;
//             isLoading = false;
//           });
//
//           return;
//         }
//
//         // _scaffoldMessengerKey.currentState?.showSnackBar(
//         //   SnackBar(content: Text(message)),
//         // );
//         showCustomToast(message);
//
//         setState(() {
//           _pairingStatus[deviceID] = AppText.paired;
//         });
//
//         // 🔥 Connect only on TRUE success
//         // await ClingBleService.connectToDevice(deviceID);
//         await ClingBleService.connectToDevice(deviceID);
//
// // wait for BLE readiness
//         await Future.delayed(const Duration(seconds: 2));
//
//         _registeredDevice = deviceID;
//
//         if (!_hasNavigated && mounted) {
//           _hasNavigated = true;
//           _navigateToSyncScreen();
//         }
//
//         if (mounted) {
//           setState(() {
//             _pairingDevice = null;
//             isLoading = false;
//           });
//         }
//
//       } catch (e) {
//         print("Error: $e");
//
//         setState(() {
//           _pairingStatus[deviceID] = AppText.failed;
//           _pairingDevice = null;
//           isLoading = false;
//         });
//
//         // _scaffoldMessengerKey.currentState?.showSnackBar(
//         //   const SnackBar(content: Text("Something went wrong")),
//         // );
//         showCustomToast("Something went wrong");
//       }
//     }
//
//     else if (Platform.isIOS) {
//       try {
//         setState(() {
//           _pairingDevice = deviceID;
//           _pairingStatus[deviceID] = "Pairing...";
//           isLoading = true;
//         });
//
//         print("Ble_DeviceId:$deviceID");
//
//         //🔥 Call native method
//         await platform.invokeMethod('registerDevice', {
//           "deviceID": deviceID
//         });
//
//         // if (_registeredDevice == deviceID) {
//         //   // 🔥 Already paired → just connect
//         //   await platform.invokeMethod('connectDevice', {
//         //     "deviceID": deviceID
//         //   });
//         // } else {
//         //   // 🔥 First time → register
//         //   await platform.invokeMethod('registerDevice', {
//         //     "deviceID": deviceID
//         //   });
//         // }
//
//         await Future.delayed(const Duration(seconds: 2));
//
//         final prefs = await SharedPreferences.getInstance();
//         var user_id = prefs.getString('user_id') ?? "";
//         await prefs.setString('DeviceId', deviceID);
//
//         print("DEVICE_ID (iOS): $deviceID");
//
//         // ✅ CALL API FIRST
//         final response = await pairDevice(user_id, deviceID);
//
//         if (response == null) {
//           throw Exception("No response from API");
//         }
//
//         int statusCode = response['statusCode'] ?? 0;
//         String status = response['status'] ?? "";
//         String message = response['message'] ?? "";
//         String apiDeviceId =
//         (response['device_id'] ?? "").toString().trim();
//
//         // ❌ FAIL CASE
//         if (statusCode != 200 ||
//             status != "SUCCESS" ||
//             apiDeviceId != deviceID.trim()) {
//
//           // _scaffoldMessengerKey.currentState?.showSnackBar(
//           //   SnackBar(content: Text(message)),
//           // );
//           showCustomToast(message);
//
//
//           setState(() {
//             _pairingStatus[deviceID] = AppText.failed;
//             _pairingDevice = null;
//             isLoading = false;
//           });
//
//           return; // 🚫 STOP HERE (NO NAVIGATION)
//         }
//
//         // ✅ SUCCESS CASE
//         // _scaffoldMessengerKey.currentState?.showSnackBar(
//         //   SnackBar(content: Text(message)),
//         // );
//         showCustomToast(message);
//
//         setState(() {
//           _pairingStatus[deviceID] = AppText.paired;
//           _registeredDevice = deviceID;
//           _pairingDevice = null;
//           isLoading = false;
//         });
//
//         // 🚀 NAVIGATE ONLY AFTER SUCCESS
//         if (!_hasNavigated && mounted) {
//           _hasNavigated = true;
//           await Future.delayed(const Duration(milliseconds: 800));
//           _navigateToSyncScreen();
//         }
//
//       } catch (e) {
//         print("iOS Error: $e");
//
//         setState(() {
//           _pairingStatus[deviceID] = AppText.failed;
//           _pairingDevice = null;
//           isLoading = false;
//         });
//
//         // _scaffoldMessengerKey.currentState?.showSnackBar(
//         //   const SnackBar(content: Text("Something went wrong")),
//         // );
//         showCustomToast("Something went wrong");
//       }
//     }
//
//   }
//
//   void _navigateToSyncScreen() {
//     if (_registeredDevice != null) {
//       print("print12");
//       Navigator.pushReplacement(context,
//           MaterialPageRoute(builder: (context) => SyncDataScreen(deviceID: _registeredDevice!,)));
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
//     _btStateTimer?.cancel();
//     WidgetsBinding.instance.removeObserver(this);
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
//                 SystemNavigator.pop();
//               },
//               icon: Icon(Icons.arrow_back_ios),
//             ),
//           ),
//           body: Stack(
//             children: [
//
//               // 🔹 YOUR ORIGINAL UI
//               Column(
//                 children: [
//                   SizedBox(height: 10,),
//                   ElevatedButton(
//                     onPressed: _startScanning,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.others,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     child: const Text(AppText.scandevice),
//                   ),
//                   SizedBox(height: 20,),
//                   ElevatedButton(
//                     onPressed: _navigateToSkip,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.others,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     child: const Text(AppText.demo_mode),
//                   ),
//                   SizedBox(height: 20),
//
//                   Expanded(
//                     child: _devices.isEmpty
//                         ? Center(child: Text(AppText.nodevices))
//                         : ListView.builder(
//                       itemCount: _devices.length,
//                       itemBuilder: (context, index) {
//
//                         String deviceName;
//                         String deviceMac = "";
//
//                         final device = _devices[index];
//
//                         if (Platform.isAndroid && device is Map<String, String>) {
//                           deviceName = device['name'] ?? "";
//                           deviceMac = device['mac'] ?? "";
//                         } else if (Platform.isIOS && device is String) {
//                           deviceName = device;
//                         } else {
//                           deviceName = "";
//                         }
//
//                         return Column(
//                           children: [
//                             ListTile(
//                               title: Text(deviceName),
//                               subtitle: Text(
//                                 _pairingStatus[deviceName] ?? AppText.notpaired,
//                                 style: _pairingStatus[deviceName] == AppText.paired
//                                     ? Apptextstyle.s16wncGreen
//                                     : _pairingStatus[deviceName] == AppText.failed
//                                     ? Apptextstyle.s16wncR
//                                     : Apptextstyle.s16wncB,
//                               ),
//                               onTap: isLoading
//                                   ? null
//                                   : () => _registerDevice(deviceName),
//                               trailing: Icon(
//                                 Icons.bluetooth,
//                                 color: _pairingStatus[deviceName] == AppText.paired
//                                     ? AppColors.others
//                                     : _pairingStatus[deviceName] == AppText.failed
//                                     ? AppColors.Red
//                                     : AppColors.Grey,
//                               ),
//                             ),
//                             const Divider(height: 0.5, thickness: 0.5),
//                           ],
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//
//               // 🔥 FULL SCREEN CENTER LOADER
//               if (isLoading)
//                 Positioned.fill(
//                   child: IgnorePointer(
//                     child: Container(// optional dim
//                       child: Center(
//                         child: CircularProgressIndicator(
//                           color: AppColors.others,
//                           strokeWidth: 3,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }