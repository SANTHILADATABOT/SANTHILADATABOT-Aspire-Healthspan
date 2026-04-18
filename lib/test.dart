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