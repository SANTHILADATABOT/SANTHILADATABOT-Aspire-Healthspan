////New code
//
//import  Flutter
//import UIKit
//import FirebaseCore
//import BackgroundTasks
//import ObjectiveC
//
//@main
//@objc class AppDelegate: FlutterAppDelegate {
//
//let bleModel = ClingBLEModel.sharedInstance()
//var methodChannel: FlutterMethodChannel?
//override func application(
//_ application: UIApplication,
//didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//) -> Bool {
//
//// Register Cling SDK
//self.registClingSDK()
//
//    
//// Abdd Bluetooth data observers
//self.addObservers()
//
//// Configure Firebase
//FirebaseApp.configure()
//
//
//
//if let controller = window?.rootViewController as? FlutterViewController {
//methodChannel = FlutterMethodChannel(name: "cling_sdk", binaryMessenger: controller.binaryMessenger)
//methodChannel?.setMethodCallHandler { [weak self] (call, result) in
//self?.handleMethodCall(call, result: result)
//}
//}
//
//
//// Start device discovery after a delay
//DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//print("Start discovering Cling devices")
//self.bleModel?.setClingDeviceStyle(.GE)
//self.bleModel?.startDiscoveryDevice()
////ClingBLEModel.reloadDeviceData()
//    
//self.activeLastDevice()
////print("Calling actionSetDeviceConfig...")
////self.actionSetDeviceConfig()
//self.actionBloodPressureCalibration()
// 
//
//}
//
//// Set up push notifications
//UNUserNotificationCenter.current().delegate = self
//let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in }
//application.registerForRemoteNotifications()
//
//// Register background tasks for iOS 13+
//if #available(iOS 13.0, *) {
//BGTaskScheduler.shared.register(
//forTaskWithIdentifier: "com.example.app.refresh",
//using: nil
//) { task in
//self.handleAppRefresh(task: task as! BGAppRefreshTask)
//}
//scheduleAppRefresh()
//}
//
//GeneratedPluginRegistrant.register(with: self)
//return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//}
//
//// MARK: - Flutter Method Channel Handler
//private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
//switch call.method {
//case "startScanning":
//self.startScanning()
//result(nil)
////case "registerDevice":
////if let args = call.arguments as? [String: Any],
////let deviceID = args["deviceID"] as? String {
////print("Device ID received from Flutter: \(deviceID)")
////
////// Extract the last 4 characters of the device ID
////let trimmedDeviceID = String(deviceID.suffix(4))
////
////print("Registering device: \(trimmedDeviceID)")
//////self.actionRegisterDevice(deviceID: trimmedDeviceID)
////    if let lastDeviceID = UserDefaults.standard.string(forKey: "clingid"),
////       lastDeviceID == trimmedDeviceID {
////
////        print("Device already registered → connecting instead")
////        self.connectDevice(deviceID: trimmedDeviceID)
////
////    } else {
////        print("New device → registering")
////        self.actionRegisterDevice(deviceID: trimmedDeviceID)
////    }
////result(nil)
////} else {
////result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
////}
//    
//case "registerDevice":
//
//    if let args = call.arguments as? [String: Any],
//       let deviceID = args["deviceID"] as? String {
//
//        print("Device ID received from Flutter: \(deviceID)")
//
//        // Always use last 4 chars for Cling
//        let trimmedDeviceID = String(deviceID.suffix(4))
//
//        print("Processed Cling Device ID: \(trimmedDeviceID)")
//
//        // Check previously paired device
//        if let lastDeviceID = UserDefaults.standard.string(forKey: "clingid"),
//           lastDeviceID == trimmedDeviceID {
//
//            print("Device already paired → reconnecting")
//
//            // Reconnect existing paired device
//           // self.connectDevice(deviceID: trimmedDeviceID)
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//
//                self.connectDevice(deviceID: trimmedDeviceID)
//            }
//
//            // Force sync after reconnect
////            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
////
////                if ClingBLEModel.isDConnected() {
////
////                    print("Reconnect successful → syncing data")
////
////                    ClingBLEModel.reloadDeviceData()
////                    self.actionSyncDeviceData()
////
////                } else {
////
////                    print("Reconnect failed")
////
////                }
////            }
//
//        } else {
//
//            print("New device → registering")
//
//            // First-time registration
//            self.actionRegisterDevice(deviceID: trimmedDeviceID)
//        }
//
//        result(nil)
//
//    } else {
//
//        result(
//            FlutterError(
//                code: "INVALID_ARGUMENTS",
//                message: "Invalid arguments",
//                details: nil
//            )
//        )
//    }
//
//case "connectDevice":
//if let args = call.arguments as? [String: Any],
//let deviceID = args["deviceID"] as? String {
//self.connectDevice(deviceID: deviceID)
//result(nil)
//} else {
//result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
//}
//case "syncDeviceData":
//self.actionSyncDeviceData()
//result(nil)
//case "calibrateBloodPressure":
//    if let args = call.arguments as? [String: Any],
//       let systolic = args["systolic"] as? Int,
//       let diastolic = args["diastolic"] as? Int {
//        self.actionBloodPressureCalibration()
//        result("BP Calibration Started")
//    } else {
//        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid blood pressure values", details: nil))
//    }
//case "setLastActiveDevice":
//if let args = call.arguments as? [String: Any],
//let deviceID = args["deviceID"] as? String {
//UserDefaults.standard.set(deviceID, forKey: "clingid")
//print("Set last active device: \(deviceID)")
//result(nil)
//} else {
//result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for setLastActiveDevice", details: nil))
//}
//case "getLastActiveDevice":
//    if let lastDeviceID = UserDefaults.standard.string(forKey: "clingid") {
//        result(lastDeviceID)
//    } else {
//        result(nil)
//    }
//case "deregisterDevice":
//    self.actionDeregisterDevice()
//    result(nil)
//case "setDeviceConfig":
//    self.actionSetDeviceConfig()
//    result("Device config updated")
//case "isBluetoothOn":
//    if let share = ClingBLEModel.sharedInstance() {
//        let state = share.getPhoneBLEState()
//        result(state == .poweredOn)
//    } else {
//        result(false)
//    }
//case "openBluetoothSettings":
//    // Try to open the iOS system Bluetooth settings page directly.
//    // App-Prefs:root=Bluetooth works on iOS 12+ (physical devices).
//    // Falls back to the app's own settings page if the scheme is blocked.
//    if let btUrl = URL(string: "App-Prefs:root=Bluetooth"),
//       UIApplication.shared.canOpenURL(btUrl) {
//        UIApplication.shared.open(btUrl, options: [:], completionHandler: nil)
//        result(nil)
//    } else if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
//        UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
//        result(nil)
//    } else {
//        result(FlutterError(code: "INVALID_URL", message: "Cannot open Bluetooth settings", details: nil))
//    }
//case "disconnectDevice":
//    self.disconnectDevice()
//    result(nil)
//default:
//result(FlutterMethodNotImplemented)
//}
//}
// 
//    @objc func disconnectDevice() {
//
//        print("Disconnecting Cling device...")
//
//        guard let bleModel = ClingBLEModel.sharedInstance() else {
//            print("BLE model unavailable")
//            return
//        }
//
//        // 1. Stop scanning
//        bleModel.stopDiscoveryDevice()
//
//        // 2. Disconnect current BLE connection
//        bleModel.disconnectDevice(false)
//
//        // IMPORTANT:
//        // DO NOT clear bond uid
//        // DO NOT remove clingid
//        // because device should reconnect after login
//
//        print("Device disconnected successfully")
//    }
//    
//    
//@objc func activeLastDevice() {
//if let cid = UserDefaults.standard.string(forKey: "clingid") {
//print("Found last connected device: \(cid), attempting to connect...")
//connectDevice(deviceID: cid)
//} else {
//print("No last device found, starting scan...")
//startScanning()
//}
//}
//// MARK: - Cling SDK Methods
//private func startScanning() {
//print("Start scanning...")
//self.bleModel?.setClingDeviceStyle(.GE)
//self.bleModel?.startDiscoveryDevice()
//}
//
//    private func actionRegisterDevice(deviceID: String) {
//
//        print("Registering device: \(deviceID)")
//
//        guard let bleModel = bleModel else {
//            print("BLE model is not available")
//            return
//        }
//
//        // ✅ Bind only once during registration
//        ClingBLEModel.updateBondUid(1001, clingID: deviceID)
//
//        if !bleModel.registerDevice(deviceID, bondUid: 1001, complete: {
//
//            print("✅ Device activation successful")
//
//            UserDefaults.standard.set(deviceID, forKey: "clingid")
//
//        }) {
//
//            print("❌ Device not found")
//        }
//    }
////private func actionRegisterDevice(deviceID: String) {
////print("Registering device: \(deviceID)")
////guard let bleModel = bleModel else {
////print("BLE model is not available")
////return
////}
////if !bleModel.registerDevice(deviceID, bondUid: 1001, complete: {
////print("Device activation successful")
////
////}) {
////print("Device not found")
////}
////}
////    @objc func actionSyncDeviceData() {
////    //print("Syncing device data...")
////    ClingBLEModel.reloadDeviceData()
////    //print("Synced device data successfully.")
////    }
//    
////    @objc func actionSyncDeviceData() {
////
////        print("Manual sync requested")
////
////        guard ClingBLEModel.isDConnected() else {
////
////            print("❌ Device not connected")
////            return
////        }
////
////        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
////
////            print("🚀 Reloading device data")
////
////            ClingBLEModel.reloadDeviceData()
////        }
////    }
//    
////    @objc func actionSyncDeviceData() {
////
////        print("Manual sync requested")
////
////        guard ClingBLEModel.isDConnected() else {
////
////            print("❌ Device not connected")
////            return
////        }
////
////        // Delay needed for stable BLE service
////        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
////
////            print("🚀 Reloading device data")
////
////            ClingBLEModel.reloadDeviceData()
////
////            print("✅ Sync command sent")
////        }
////    }
//    
//    @objc func actionSyncDeviceData() {
//
//        print("Manual sync requested")
//        
//        print("⌛ Device not ready yet")
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//
//            if ClingBLEModel.isDConnected() {
//
//                print("🚀 Retry sync")
//
//                ClingBLEModel.reloadDeviceData()
//            }
//        }
//
////        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
////
////            if ClingBLEModel.isDConnected() {
////
////                print("🚀 Reloading device data")
////
////                ClingBLEModel.reloadDeviceData()
////
////            } else {
////
////                print("⚠️ Device reconnecting, sync skipped")
////            }
////        }
//    }
//
// 
//
//@objc func actionSetDeviceConfig() {
//    guard let share = ClingBLEModel.sharedInstance(), bleAvaliable() else { return }
//    let cfg = ClingDeviceCfg()
//    
//    cfg.bFlipWrist = true;
//    cfg.bTap = false;
//    
//    cfg.bHold = true;
//    cfg.uint8Hold = 1;
//    
//    cfg.uint8ScreenOff = 5;
//    cfg.uint8HROff = 25;
//    cfg.uint8HRDay = 15;
//    cfg.uint8HRNight = 30;
//    cfg.uint8TempDay = 5;
//    cfg.uint8TempNight = 30;
//    cfg.bIdleAlert = false;
//    cfg.uint8IdleAlert = 30;
//    cfg.intIdleHourStart = 8;
//    cfg.intIdleHourEnd = 20;
//    cfg.uint8SleepSensitivity = 1;
//    cfg.intVocSampleRate = 1;
//    cfg.intAlcoholSensitivity = 2;
//    cfg.bWeekendAlarmDisabled = false;
//    
//
////        cfg.uint8Hold = 3;
//    cfg.bTouchEnable = true;
//    //Auto Blood Pressure Monitor
//    cfg.bBloodP = true;
//    //Auto SpO2 Monitor switch
//    cfg.bBloodO = true;
////        cfg.bIdleAlert = true;
//    share.setDeviceCfg(cfg)
//    print("setup device config")
//}
//
//
////    private func connectDevice(deviceID: String) {
////
////        print("Connecting to device: \(deviceID)")
////
////        // Rebind device every login/session
////      ClingBLEModel.updateBondUid(1001, clingID: deviceID)
////
////        // Start discovery again before connect
////        self.bleModel?.setClingDeviceStyle(.GE)
////        //self.bleModel?.startDiscoveryDevice()
////
////        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
////
////            ClingBLEModel.sharedInstance().tryConnectDevice()
////
////            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
////
////                if ClingBLEModel.isDConnected() {
////
////                    print("Device connected successfully")
////
////                    // Reconfigure device
////                    self.actionSetDeviceConfig()
////
////                    self.actionDeviceUpdateUserProfile()
////
////                    self.actionSetDeviceLanguage()
////
////                    // Recalibrate BP
////                    self.actionBloodPressureCalibration()
////
////                    // IMPORTANT:
////                    // Trigger sync manually after reconnect
////                    ClingBLEModel.reloadDeviceData()
////
////                    self.actionSyncDeviceData()
////
////                    print("Manual sync triggered")
////
////                } else {
////
////                    print("Device not connected")
////
////                }
////            }
////        }
////
////        methodChannel?.invokeMethod("onDeviceConnecting", arguments: deviceID)
////    }
//    
////    private func connectDevice(deviceID: String) {
////
////        print("Connecting to device: \(deviceID)")
////
////        guard let bleModel = self.bleModel else {
////            print("BLE model unavailable")
////            return
////        }
////
////        // Rebind existing paired device
////        ClingBLEModel.updateBondUid(1001, clingID: deviceID)
////
////        // Stop scanning before connect
////        bleModel.stopDiscoveryDevice()
////
////        // Set device type
////        bleModel.setClingDeviceStyle(.GE)
////
////        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
////
////            print("Trying BLE connection...")
////
////            bleModel.tryConnectDevice()
////
////            // Wait for stable connection
////            DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
////
////                if ClingBLEModel.isDConnected() {
////
////                    print("✅ Device connected successfully")
////
////                    // Configure device
////                    self.actionSetDeviceConfig()
////
////                    self.actionDeviceUpdateUserProfile()
////
////                    self.actionSetDeviceLanguage()
////
////                    self.actionBloodPressureCalibration()
////
////                    // START SYNC
////                    print("🚀 Starting sync")
////
////                    self.actionSyncDeviceData()
////
////                } else {
////
////                    print("❌ Device connection failed")
////                }
////            }
////        }
////
////        methodChannel?.invokeMethod("onDeviceConnecting", arguments: deviceID)
////    }
//    
////    private func connectDevice(deviceID: String) {
////
////        print("Connecting to device: \(deviceID)")
////
////        guard let bleModel = self.bleModel else {
////            print("BLE model unavailable")
////            return
////        }
////
////        ClingBLEModel.updateBondUid(1001, clingID: deviceID)
////
////        bleModel.stopDiscoveryDevice()
////
////        bleModel.setClingDeviceStyle(.GE)
////
////        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
////
////            print("Trying BLE connection...")
////
////            bleModel.tryConnectDevice()
////        }
////
////        methodChannel?.invokeMethod("onDeviceConnecting", arguments: deviceID)
////    }
//    
//    
//    
//    private var isConnecting = false
//
//    private func connectDevice(deviceID: String) {
//
//        if ClingBLEModel.isDConnected() {
//
//            print("✅ Device already connected")
//
//            // Force sync immediately
//            ClingBLEModel.reloadDeviceData()
//
//            return
//        }
//
//        if isConnecting {
//
//            print("Already connecting...")
//            return
//        }
//
//        isConnecting = true
//
//        print("Connecting to device: \(deviceID)")
//
//        guard let bleModel = self.bleModel else {
//
//            print("BLE model unavailable")
//
//            isConnecting = false
//            return
//        }
//
//        // IMPORTANT:
//        // Rebind existing paired watch
//        ClingBLEModel.updateBondUid(1001, clingID: deviceID)
//
//        bleModel.setClingDeviceStyle(.GE)
//
//        // IMPORTANT:
//        // Keep scanning active
//        bleModel.startDiscoveryDevice()
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//
//            print("Trying BLE connection...")
//
//            // REMOVE disconnectDevice(false)
//            // It breaks auto reconnect
//
//            bleModel.tryConnectDevice()
//        }
//
//        methodChannel?.invokeMethod("onDeviceConnecting", arguments: deviceID)
//    }
//    
//
//// MARK: - Background Tasks
//@available(iOS 13.0, *)
//func handleAppRefresh(task: BGAppRefreshTask) {
//scheduleAppRefresh()
//let queue = OperationQueue()
//queue.addOperation {
//let success = self.performBackgroundFetch()
//task.setTaskCompleted(success: success)
//}
//task.expirationHandler = {
//queue.cancelAllOperations()
//}
//}
//
//func performBackgroundFetch() -> Bool {
//print("Background fetch executed")
//return true
//}
//
//@available(iOS 13.0, *)
//func scheduleAppRefresh() {
//let request = BGAppRefreshTaskRequest(identifier: "com.example.app.refresh")
//request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
//do {
//try BGTaskScheduler.shared.submit(request)
//} catch {
//print("Could not schedule app refresh: \(error)")
//}
//}
//}
//
//
//
//// MARK: - Cling SDK Integration
//extension AppDelegate {
//    
//    
//func registClingSDK() {
//print("Registering ClingSDK")
//HttpModel.sharedInstance().registerClingAppid(
//    CLING_SDK_APPID,
//    withAppSecret: CLING_SDK_APPSECRET,
//enterprise: true
//)
//}
//    
//    func bleAvaliable() -> Bool{
//        guard let share = ClingBLEModel.sharedInstance() else { return false }
//        guard share.getPhoneBLEState() != .poweredOn else {return true}
//        print("蓝牙异常，请检查蓝牙状态(Bluetooth is abnormal, please check the Bluetooth status.)");
//        return false
//    }
//    
//  
//
//
//func addObservers() {
//print("Adding observers for ClingSDK")
//let nc = NotificationCenter.default
//
//    
//nc.addObserver(self, selector: #selector(syncing(_:)), name: .ClingDeviceDataSyncing, object: nil)
//nc.addObserver(self, selector: #selector(receiveMinuteData(_:)), name: .ClingDeviceMinuteDataUpdate, object: nil)
//nc.addObserver(self, selector: #selector(registerError(_:)), name: .ClingDeviceRegisterError, object: nil)
//nc.addObserver(self, selector: #selector(serviceChange(_:)), name: .ClingServiceDidChangeStatus, object: nil)
//nc.addObserver(self, selector: #selector(discoverRefresh(_:)), name: .ClingDiscoveryDidRefresh, object: nil)
//    nc.addObserver(self, selector: #selector(reciveDailyTotal(_:)), name: .ClingDeviceDayTotal, object: nil)
//    nc.addObserver(self, selector: #selector(bleDownloadPhoneSettings(_:)), name: .ClingDeviceInitCfg, object: nil)    // Added observer
//    nc.addObserver(self, selector: #selector(bleStateChange(_:)), name: .ClingBLEDidChangeStatus, object: nil)
//}
// 
//   
//    @objc func bleDownloadPhoneSettings(_ noti: Notification){
//       // print("settings...\(noti)")
//        actionSetDeviceConfig()
//        actionDeviceUpdateUserProfile()
//        actionSetDeviceLanguage()
//        ClingBLEModel.sharedInstance().downloadPhoneSettingFinished()
//    }
//    
//    @objc func bleStateChange(_ notification: Notification) {
//        print("Bluetooth state changed notification received")
//        guard let share = ClingBLEModel.sharedInstance() else { return }
//        let state = share.getPhoneBLEState()
//        print("Current phone BLE state: \(state.rawValue)")
//
//        // Dispatch on main thread so Flutter MethodChannel receives it even
//        // when the notification originally fired while the app was backgrounded.
//        DispatchQueue.main.async {
//            if state == .poweredOn {
//                self.methodChannel?.invokeMethod("bluetoothOn", arguments: nil)
//            } else if state == .poweredOff || state == .unauthorized || state == .unsupported {
//                self.methodChannel?.invokeMethod("bluetoothOff", arguments: nil)
//            }
//        }
//    }
//    
//    @objc func actionDeviceUpdateUserProfile(){
//        guard let share = ClingBLEModel.sharedInstance(), bleAvaliable() else { return }
//        let model = ClingPeripheralUserProfileModel()
//        model.touch_virbration = PERIPHERAL_PROFILE_TOUCH_VIRBRATION_OFF;
//        // 改变某一个属性，其余属性要全部重新赋值（上次的值）
//        model.height_in_cm = 170;
//        model.weight_in_kg = 65;
//        model.stride_length_in_cm = 75;
//        model.stride_length_run_in_cm = 107;
//        model.stepRateForRunLength = 172;
//        model.units_type = 0;
//        model.nickname = "Cling";
//        model.clock_orientation = PERIPHERAL_PROFILE_CLOCK_ORIENTATION_VERTICAL;
//        model.sleep_alarm_day_of_week = Int32(CLING_DEVICE_REMINDER_WEEKDAY.ALL.rawValue);
//        model.bed_hr = 18;
//        model.bed_min = 20;
//        model.wakeup_hr = 7;
//        model.wakeup_min = 40;
//        
//
//        // Ensure blood pressure display is enabled for automatic measurement
//        model.screen_display_option = Int32(SCREEN_DISPLAY_OPTION.defaultValue.rawValue) | Int32(SCREEN_DISPLAY_OPTION.bloodPressure.rawValue);
//        model.daily_goal = 0;
//        model.training_display_option = PERIPHERAL_PROFILE_TRAINING_DISPLAY_OPTION_DEFAULT_VALUE;
//        model.age = 30;
//        model.sex = 0;
//        model.stride_length_run_indoor_in_cm = 150;
//        model.hr_alarm_rate = PERIPHERAL_PROFILE_HEART_ALARM_DEFAULT_VALUE;
//        model.pace_alarm_zone = PERIPHERAL_PROFILE_PACE_ALARM_DEFAULT_VALUE;
////        print("\(model.screen_display_option),\(model.sleep_alarm_day_of_week),\(model.hr_alarm_rate),\(model.pace_alarm_zone)")
//        model.iTempAlarmValue = 373 // 37.3 * 10
//        model.iTempLowAlarmValue = 280 // 28.8 * 10;
//        model.caloryDisplayType = 1
//        model.iHealthInfoLevel = 0
//        model.bStepAlarm = true
//        model.iSAlarmValue = 13000
//        model.bCalAlarm = true
//        model.iCAlarmValue = 2300
//        share.updateUserProfile(model)
//        print("setup user profile")
//    }
//    
//    @objc func actionSetDeviceLanguage(){
//        guard let share = ClingBLEModel.sharedInstance(), bleAvaliable() else { return }
//        share.setDeviceLanguage(.english)
//        print("\nsetup user language")
//    }
//    
//    
//
//@objc func syncing(_ notification: Notification) {
//print("Syncing: \(notification.object ?? "")")
//}
//
//    @objc func actionBloodPressureCalibration(){
//        print("actionBloodPressureCalibration123")
//        guard let _ = ClingBLEModel.sharedInstance(), bleAvaliable() else { return }
//        ClingBLEModel.sendBPCMessage(130, lowPressure: 80)
//    }
//    
//    
//       @objc func receiveMinuteData(_ noti: Notification) {
//           
//           if let mimute = noti.object as? ClingMinuteData{
//               print("---------------------minutedata---------------------------------------")
//               print("接收到分钟数据通知(recive minute data)=\(mimute.intTimestamp)---\(mimute.shortHeartRate)")
//               let date = Date(timeIntervalSince1970: TimeInterval(mimute.intTimestamp))
//               let dateFormatter = DateFormatter()
//               dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//               dateFormatter.timeZone = TimeZone(identifier: "Asia/Kolkata")
//               let formattedIST = dateFormatter.string(from: date)
//               print("formattedIST: \(formattedIST)")
//               print("shortHeartRate: \(mimute.shortHeartRate)")
//               print("walk steps: \(mimute.shortWalkStep), run steps: \(mimute.shortRunStep)")
//               print("bp_low: \(mimute.bp_low), bp_high: \(mimute.bp_high), spo2: \(mimute.spo2)")
//               print("shortSleepState: \(mimute.shortSleepState)")
//               print("shortSleepSecond: \(mimute.shortSleepSecond)")
//               print("bWear: \(mimute.bWear)")
//               print("fspo2: \(mimute.fspo2)")
//        
//               
//               
//               
//               let shortSleepState = mimute.shortSleepState
//               let intTimestamp = mimute.intTimestamp
//               let shortHeartRate = mimute.shortHeartRate
//               let bp_low = mimute.bp_low
//               let bp_high = mimute.bp_high
//               let bWear = mimute.bWear
//               
//               switch shortSleepState {
//                          case 0:
//                              print("Sleep State: Default (No Value)")
//                          case 1:
//                              print("Sleep State: Awake")
//                          case 2:
//                              print("Sleep State: Light Sleep")
//                          case 3:
//                              print("Sleep State: Deep Sleep")
//                          case 4:
//                              print("Sleep State: Mid Sleep")
//                          case 5:
//                              print("Sleep State: Unknown Sleep")
//                          default:
//                              print("Unknown Sleep State: \(shortSleepState)")
//                          }
//              
//               
//               // Send data to Flutter
//                           if let controller = window?.rootViewController as? FlutterViewController {
//                               let methodChannel = FlutterMethodChannel(name: "cling_sdk", binaryMessenger: controller.binaryMessenger)
//
//                               let data: [String: Any] = [
//                                   "timestamp": intTimestamp,
//                                   "formattedIST": formattedIST,
//                                   "heartRate": shortHeartRate,
//                                   "walkSteps": mimute.shortWalkStep,
//                                   "runSteps": mimute.shortRunStep,
//                                   "bp_low": mimute.bp_low,
//                                   "bp_high": mimute.bp_high,
//                                   "spo2": mimute.spo2,
//                                   "sleepState": mimute.shortSleepState,
//                                   "sleepSeconds": mimute.shortSleepSecond,
//                                   "is_wear": mimute.bWear,
//                                   "fspo2" : mimute.fspo2
//                               ]
//
//                               methodChannel.invokeMethod("onSyncDataReceived", arguments: data)
//                           }
//               
//               
//                    
//           }
//       
//
//    }
//
//    @objc func reciveDailyTotal(_ notifacation: Notification){
//        guard let daily = notifacation.object as? ClingDailyData else { return }
//        print("daily total summary data:")
//#warning("Before obtaining and using blood pressure data")
////You need to call ClingBLEModel.sendBPCMessage(intHightVal, lowPressure: intLowVal) first to calibrate blood pressure
//        let date = Date(timeIntervalSince1970: TimeInterval(daily.daybeginTime))
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        dateFormatter.timeZone = TimeZone(identifier: "Asia/Kolkata")
//        let formattedISTDaily = dateFormatter.string(from: date)
//        print("Systolic Blood Pressure: \(daily.iBPHigh)")
//        print("Diastolic Blood Pressure: \(daily.iBPLow)")
//        print("daybeginTime: \(daily.daybeginTime)")
//        print("formattedISTDaily: \(formattedISTDaily)")
//        print("iBPTime: \(daily.iBPTime)")
//        print("Spo2: \(daily.spo2)")
//        print("total sleep seconds: \(daily.sleepTotal)")
//        print("walk steps: \(daily.wstepTotal), run steps: \(daily.rstepTotal), total steps: \(daily.stepTotal)")
//        print("total calories: \(daily.caloriesTotal)")
//        print("distance: \(daily.distanceTotal)")
//        print("heart rate: \(daily.heartRate)")
//        print("sleepLight: \(daily.sleepLight)")
//        print("sleepSound: \(daily.sleepSound)")
//        print("sleepEfficent: \(daily.sleepEfficent)")
//        print("heartRate: \(daily.heartRate)")
//        print("bWear: \(daily.bWear)")
//        print("weightkg: \(daily.weightkg)")
//        print("iWeightTime: \(daily.iWeightTime)")
//               let data: [String: Any] = [
//                   "daybeginTime" : daily.daybeginTime,
//                   "iBPHigh":daily.iBPHigh,
//                   "iBPLow":daily.iBPLow,
//                   "totalSleep": daily.sleepTotal,
//                   "walkSteps": daily.wstepTotal,
//                   "runSteps": daily.rstepTotal,
//                   "totalSteps": daily.stepTotal,
//                   "caloriesTotal": daily.caloriesTotal,
//                   "distanceTotal": daily.distanceTotal,
//                   "heartRate": daily.heartRate,
//                   "sleepEfficent": daily.sleepEfficent,
//                   "sleepLight": daily.sleepLight,
//                   "sleepSound": daily.sleepSound,
//                   "caloriesMetabolism": daily.caloriesMetabolism,
//                   "spo2" : daily.spo2,
//                   "stress": daily.stress,
//                   "is_wear": daily.bWear,
//                   "weightkg":daily.weightkg,
//                   "iWeightTime": daily.iWeightTime
//               ]
//        
//        //ClingBLEModel.reloadDeviceData()
//        
//        if let controller = window?.rootViewController as? FlutterViewController {
//                    let methodChannel = FlutterMethodChannel(name: "cling_sdk", binaryMessenger: controller.binaryMessenger)
//                    methodChannel.invokeMethod("onDailyTotalReceived", arguments: data)
//                }
//        
//        
//    }
//    
//    
//    
//    @objc func actionDeregisterDevice() {
//        print("Deregistering device...")
//        guard let bleModel = ClingBLEModel.sharedInstance() else {
//            print("BLE model is not available")
//            return
//        }
//
//        // Get the last connected device ID
//        if let lastDeviceID = UserDefaults.standard.string(forKey: "clingid") {
//            print("Attempting to deregister device: \(lastDeviceID)")
//            
//            // Clear bond UID to remove association
//            ClingBLEModel.updateBondUid(0, clingID: lastDeviceID)
//
//            // Attempt to deregister the device
//            bleModel.deregisterDevice()
//            
//            // Remove from UserDefaults
//            UserDefaults.standard.removeObject(forKey: "clingid")
//            UserDefaults.standard.synchronize()
//            
//            print("Device deregistered successfully.")
//        } else {
//            print("No device found to deregister")
//        }
//    }
//
//
//
//@objc func registerError(_ notification: Notification) {
//print("Register Error: \(String(describing: notification.object))")
//}
//    
////@objc func serviceChange(_ notification: Notification) {
////guard ClingBLEModel.isDConnected(), let bleModel = bleModel else { return }
////print("Service connection state changed: \(notification.object ?? -1), \(bleModel.getPhoneBLEState())")
////if let info = bleModel.getDeviceInfo(), !info.isEmpty {
////if let clingID = info["clingID"] {
////print("ClingID: \(clingID)")
////UserDefaults.standard.setValue(clingID, forKey: "clingid")
////} else {
////UserDefaults.standard.removeObject(forKey: "clingid")
////}
////UserDefaults.standard.synchronize()
////}
////}
//    
////    @objc func serviceChange(_ notification: Notification) {
////
////        guard let bleModel = bleModel else { return }
////
////        print("Service connection state changed: \(notification.object ?? -1)")
////
////        if ClingBLEModel.isDConnected() {
////
////            print("✅ Device connected")
////
////            if let info = bleModel.getDeviceInfo(),
////               let clingID = info["clingID"] {
////
////                print("Saving connected clingID: \(clingID)")
////
////                UserDefaults.standard.setValue(clingID, forKey: "clingid")
////                UserDefaults.standard.synchronize()
////            }
////
////        } else {
////
////            print("⚠️ Temporary BLE disconnect")
////
////            // IMPORTANT:
////            // DO NOT REMOVE clingid here
////            // otherwise app thinks device is unpaired
////
////        }
////    }
////
//    
////    @objc func serviceChange(_ notification: Notification) {
////
////        guard let bleModel = bleModel else { return }
////
////        let state = notification.object as? Int ?? -1
////
////        print("Service connection state changed: \(state)")
////
////        // CONNECTED
////        if ClingBLEModel.isDConnected() {
////
////            print("✅ Device connected and stable")
////
////            if let info = bleModel.getDeviceInfo(),
////               let clingID = info["clingID"] {
////
////                UserDefaults.standard.setValue(clingID, forKey: "clingid")
////                UserDefaults.standard.synchronize()
////            }
////
////            // Delay sync slightly after stable connection
////            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
////
////                if ClingBLEModel.isDConnected() {
////
////                    print("🚀 Starting FINAL sync")
////
////                    ClingBLEModel.reloadDeviceData()
////                }
////            }
////
////        } else {
////
////            print("⚠️ BLE temporary disconnect")
////
////            // DO NOTHING
////            // NEVER deregister
////            // NEVER remove clingid
////        }
////    }
//    
//    @objc func serviceChange(_ notification: Notification) {
//
//        guard let bleModel = bleModel else { return }
//
//        print("Service connection changed: \(notification.object ?? -1)")
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//
//            if ClingBLEModel.isDConnected() {
//
//                self.isConnecting = false
//
//                print("✅ Device fully connected")
//
//                    if let info = bleModel.getDeviceInfo(),
//                       let clingID = info["clingID"] {
//
//                        UserDefaults.standard.set(clingID, forKey: "clingid")
//                        UserDefaults.standard.synchronize()
//                    }
//
////                if let info = bleModel.getDeviceInfo(),
////                   let clingID = info["clingID"] {
////
////                    UserDefaults.standard.setValue(clingID, forKey: "clingid")
////                    UserDefaults.standard.synchronize()
////                }
//
//                // Configure AFTER stable connection
//                self.actionSetDeviceConfig()
//
//                self.actionDeviceUpdateUserProfile()
//
//                self.actionSetDeviceLanguage()
//
//                self.actionBloodPressureCalibration()
//
//                // FINAL sync
//                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//
//                    if ClingBLEModel.isDConnected() {
//
//                        print("🚀 FINAL DATA SYNC")
//
//                        ClingBLEModel.reloadDeviceData()
//
//                    } else {
//
//                        print("❌ Connection lost before sync")
//                    }
//                }
//
//            } else {
//
//                print("⚠️ Waiting for BLE stable connection...")
//
//                // DO NOTHING
//                // Do not deregister
//                // Do not remove clingid
//            }
//        }
//    }
//    
//    
//    
//    
//@objc func discoverRefresh(_ notification: Notification) {
//print("Device discovery refreshed: \(notification.object ?? "")")
//
//if let devices = notification.object as? [ClingDeviceDiscoveryModel] {
//let discoveredDeviceNames = devices.compactMap { $0.peripheral.name }
//
//if let controller = window?.rootViewController as? FlutterViewController {
//let methodChannel = FlutterMethodChannel(name: "cling_sdk", binaryMessenger: controller.binaryMessenger)
//methodChannel.invokeMethod("onDevicesDiscovered", arguments: discoveredDeviceNames)
//}
//}
//}
//}






////old code
//
//import  Flutter
//import UIKit
//import FirebaseCore
//import BackgroundTasks
//import ObjectiveC
//
//@main
//@objc class AppDelegate: FlutterAppDelegate {
//
//let bleModel = ClingBLEModel.sharedInstance()
//var methodChannel: FlutterMethodChannel?
//var isConnecting = false
//override func application(
//_ application: UIApplication,
//didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//) -> Bool {
//
//// Register Cling SDK
//self.registClingSDK()
//
//    
//// Abdd Bluetooth data observers
//self.addObservers()
//
//// Configure Firebase
//FirebaseApp.configure()
//
//
//
//if let controller = window?.rootViewController as? FlutterViewController {
//methodChannel = FlutterMethodChannel(name: "cling_sdk", binaryMessenger: controller.binaryMessenger)
//methodChannel?.setMethodCallHandler { [weak self] (call, result) in
//self?.handleMethodCall(call, result: result)
//}
//}
//
//
//// Start device discovery after a delay
//DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//print("Start discovering Cling devices")
//self.bleModel?.setClingDeviceStyle(.GE)
//self.bleModel?.startDiscoveryDevice()
//ClingBLEModel.reloadDeviceData()
//    
//self.activeLastDevice()
////print("Calling actionSetDeviceConfig...")
////self.actionSetDeviceConfig()
//self.actionBloodPressureCalibration()
// 
//
//}
//
//// Set up push notifications
//UNUserNotificationCenter.current().delegate = self
//let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in }
//application.registerForRemoteNotifications()
//
//// Register background tasks for iOS 13+
//if #available(iOS 13.0, *) {
//BGTaskScheduler.shared.register(
//forTaskWithIdentifier: "com.example.app.refresh",
//using: nil
//) { task in
//self.handleAppRefresh(task: task as! BGAppRefreshTask)
//}
//scheduleAppRefresh()
//}
//
//GeneratedPluginRegistrant.register(with: self)
//return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//}
//
//// MARK: - Flutter Method Channel Handler
//private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
//switch call.method {
//case "startScanning":
//self.startScanning()
//result(nil)
//case "stopScanning":
//self.stopScanning()
//result(nil)
////case "registerDevice":
////if let args = call.arguments as? [String: Any],
////let deviceID = args["deviceID"] as? String {
////print("Device ID received from Flutter: \(deviceID)")
////
////// Extract the last 4 characters of the device ID
////let trimmedDeviceID = String(deviceID.suffix(4))
////
////print("Registering device: \(trimmedDeviceID)")
//////self.actionRegisterDevice(deviceID: trimmedDeviceID)
////    if let lastDeviceID = UserDefaults.standard.string(forKey: "clingid"),
////       lastDeviceID == trimmedDeviceID {
////
////        print("Device already registered → connecting instead")
////        self.connectDevice(deviceID: trimmedDeviceID)
////
////    } else {
////        print("New device → registering")
////        self.actionRegisterDevice(deviceID: trimmedDeviceID)
////    }
////result(nil)
////} else {
////result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
////}
//    
//case "registerDevice":
//if let args = call.arguments as? [String: Any],
//let deviceID = args["deviceID"] as? String {
//print("Device ID received from Flutter: \(deviceID)")
//
//// Extract the last 4 characters of the device ID
//let trimmedDeviceID = String(deviceID.suffix(4))
//
//print("Registering device: \(trimmedDeviceID)")
//
//// Get stored device ID and trim to last 4 chars
//var storedDeviceID = UserDefaults.standard.string(forKey: "clingid") ?? ""
//if storedDeviceID.count > 4 {
//    storedDeviceID = String(storedDeviceID.suffix(4))
//}
//
//// ALWAYS call connectDevice for already paired devices (don't re-register)
//// This prevents the device from being deregistered
//if !storedDeviceID.isEmpty && storedDeviceID == trimmedDeviceID {
//    print("Device already registered → connecting instead (NO re-registration)")
//    self.connectDevice(deviceID: trimmedDeviceID)
//} else {
//    print("New device or no stored device → registering for first time")
//    self.actionRegisterDevice(deviceID: trimmedDeviceID)
//}
//result(nil)
//} else {
//result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
//}
//
//case "connectDevice":
//if let args = call.arguments as? [String: Any],
//let deviceID = args["deviceID"] as? String {
//self.connectDevice(deviceID: deviceID)
//result(nil)
//} else {
//result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
//}
//case "syncDeviceData":
//self.actionSyncDeviceData()
//result(nil)
//case "calibrateBloodPressure":
//    if let args = call.arguments as? [String: Any],
//       let systolic = args["systolic"] as? Int,
//       let diastolic = args["diastolic"] as? Int {
//        self.actionBloodPressureCalibration()
//        result("BP Calibration Started")
//    } else {
//        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid blood pressure values", details: nil))
//    }
//case "setLastActiveDevice":
//if let args = call.arguments as? [String: Any],
//let deviceID = args["deviceID"] as? String {
//UserDefaults.standard.set(deviceID, forKey: "clingid")
//print("Set last active device: \(deviceID)")
//result(nil)
//} else {
//result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for setLastActiveDevice", details: nil))
//}
//case "getLastActiveDevice":
//    if let lastDeviceID = UserDefaults.standard.string(forKey: "clingid") {
//        result(lastDeviceID)
//    } else {
//        result(nil)
//    }
//case "deregisterDevice":
//    self.actionDeregisterDevice()
//    result(nil)
//case "setDeviceConfig":
//    self.actionSetDeviceConfig()
//    result("Device config updated")
//case "isBluetoothOn":
//    if let share = ClingBLEModel.sharedInstance() {
//        let state = share.getPhoneBLEState()
//        result(state == .poweredOn)
//    } else {
//        result(false)
//    }
//case "openBluetoothSettings":
//    // Try to open the iOS system Bluetooth settings page directly.
//    // App-Prefs:root=Bluetooth works on iOS 12+ (physical devices).
//    // Falls back to the app's own settings page if the scheme is blocked.
//    if let btUrl = URL(string: "App-Prefs:root=Bluetooth"),
//       UIApplication.shared.canOpenURL(btUrl) {
//        UIApplication.shared.open(btUrl, options: [:], completionHandler: nil)
//        result(nil)
//    } else if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
//        UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
//        result(nil)
//    } else {
//        result(FlutterError(code: "INVALID_URL", message: "Cannot open Bluetooth settings", details: nil))
//    }
//case "disconnectDevice":
//    self.disconnectDevice()
//    result(nil)
//case "clearNativeCache":
//    self.clearNativeCache()
//    result(nil)
//default:
//result(FlutterMethodNotImplemented)
//}
//}
//@objc func activeLastDevice() {
//if let cid = UserDefaults.standard.string(forKey: "clingid") {
//print("Found last connected device: \(cid), attempting to connect...")
//connectDevice(deviceID: cid)
//} else {
//print("No last device found, starting scan...")
//startScanning()
//}
//}
//// MARK: - Cling SDK Methods
//private func startScanning() {
//print("Start scanning...")
//self.bleModel?.setClingDeviceStyle(.GE)
//self.bleModel?.startDiscoveryDevice()
//}
//
//private func stopScanning() {
//print("Stop scanning...")
//self.bleModel?.stopDiscoveryDevice()
//}
//
////private func actionRegisterDevice(deviceID: String) {
////print("Registering device: \(deviceID)")
////guard let bleModel = bleModel else {
////print("BLE model is not available")
////return
////}
////if !bleModel.registerDevice(deviceID, bondUid: 1001, complete: {
////print("Device activation successful")
////
////}) {
////print("Device not found")
////}
////}
//    private func actionRegisterDevice(deviceID: String) {
//        let finalDeviceID = deviceID.count > 4 ? String(deviceID.suffix(4)) : deviceID
//        print("Registering device: \(finalDeviceID)")
//        guard let bleModel = bleModel else {
//            print("BLE model is not available")
//            return
//        }
//        if !bleModel.registerDevice(finalDeviceID, bondUid: 1001, complete: {
//            print("Device activation successful")
//            // CRITICAL: Save the device ID immediately
//            UserDefaults.standard.set(finalDeviceID, forKey: "clingid")
//            UserDefaults.standard.synchronize()
//            print("Saved device ID to UserDefaults: \(finalDeviceID)")
//        }) {
//            print("Device not found")
//        }
//    }
//    
//    @objc func actionSyncDeviceData() {
//    //print("Syncing device data...")
//    ClingBLEModel.reloadDeviceData()
//    //print("Synced device data successfully.")
//    }
//    
//
//
//@objc func actionSetDeviceConfig() {
//    guard let share = ClingBLEModel.sharedInstance(), bleAvaliable() else { return }
//    let cfg = ClingDeviceCfg()
//    
//    cfg.bFlipWrist = true;
//    cfg.bTap = false;
//    
//    cfg.bHold = true;
//    cfg.uint8Hold = 1;
//    
//    cfg.uint8ScreenOff = 5;
//    cfg.uint8HROff = 25;
//    cfg.uint8HRDay = 15;
//    cfg.uint8HRNight = 30;
//    cfg.uint8TempDay = 5;
//    cfg.uint8TempNight = 30;
//    cfg.bIdleAlert = false;
//    cfg.uint8IdleAlert = 30;
//    cfg.intIdleHourStart = 8;
//    cfg.intIdleHourEnd = 20;
//    cfg.uint8SleepSensitivity = 1;
//    cfg.intVocSampleRate = 1;
//    cfg.intAlcoholSensitivity = 2;
//    cfg.bWeekendAlarmDisabled = false;
//    
//
////        cfg.uint8Hold = 3;
//    cfg.bTouchEnable = true;
//    //Auto Blood Pressure Monitor
//    cfg.bBloodP = true;
//    //Auto SpO2 Monitor switch
//    cfg.bBloodO = true;
////        cfg.bIdleAlert = true;
//    share.setDeviceCfg(cfg)
//    print("setup device config")
//}
//
//
////    private func connectDevice(deviceID: String) {
////        print("Connecting to device: \(deviceID)")
////
////        // Save device ID to UserDefaults for session persistence
////        UserDefaults.standard.set(deviceID, forKey: "clingid")
////        UserDefaults.standard.synchronize()
////
////        ClingBLEModel.updateBondUid(1001, clingID: deviceID)
////
////        // 🔍 Step 1: Start scanning to re-discover the peripheral.
////        // After clearNativeCache(), tryConnectDevice() alone fails silently
////        // because the SDK's internal peripheral reference was cleared.
////        // Re-scanning allows the SDK to find and cache the peripheral again.
////        self.bleModel?.setClingDeviceStyle(.GE)
////        self.bleModel?.startDiscoveryDevice()
////        print("🔍 Started scanning to re-discover device: \(deviceID)")
////
////        // 🔗 Step 2: After a 3-second scan window, stop scan and connect.
////        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
////            print("🔗 Scan window complete — stopping scan and calling tryConnectDevice()")
////            self.bleModel?.stopDiscoveryDevice()
////            ClingBLEModel.sharedInstance().tryConnectDevice()
////        }
////
////        methodChannel?.invokeMethod("onDeviceConnecting", arguments: deviceID)
////    }
//    
////    private func connectDevice(deviceID: String) {
////        print("Connecting to device: \(deviceID)")
////
////        // Save device ID to UserDefaults for session persistence
////        UserDefaults.standard.set(deviceID, forKey: "clingid")
////        UserDefaults.standard.synchronize()
////
////        ClingBLEModel.updateBondUid(1001, clingID: deviceID)
////
////        // 1. Start scanning to re-discover the peripheral
////        self.bleModel?.setClingDeviceStyle(.GE)
////        self.bleModel?.startDiscoveryDevice()
////        print("Started scanning to re-discover device: \(deviceID)")
////
////        // 2. After a short window to allow the peripheral to be discovered,
////        //    call tryConnectDevice(). The SDK will pick up the peripheral
////        //    it found during the scan and connect to it.
////        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
////            print("Attempting tryConnectDevice after scan window...")
////            self.bleModel?.stopDiscoveryDevice()
////            ClingBLEModel.sharedInstance().tryConnectDevice()
////        }
////
////        methodChannel?.invokeMethod("onDeviceConnecting", arguments: deviceID)
////    }
//    
//    
////    private func connectDevice(deviceID: String) {
////        print("Connecting to device: \(deviceID)")
////
////        // Save device ID to UserDefaults for session persistence
////        UserDefaults.standard.set(deviceID, forKey: "clingid")
////        UserDefaults.standard.synchronize()
////
////        ClingBLEModel.updateBondUid(1001, clingID: deviceID)
////
////        // 1. Start scanning to re-discover the peripheral
////        self.bleModel?.setClingDeviceStyle(.GE)
////        self.bleModel?.startDiscoveryDevice()
////        print("Started scanning to re-discover device: \(deviceID)")
////
////        // 2. After a longer scan window to ensure device is found
////        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {  // Changed from 3.0 to 5.0
////            print("Attempting tryConnectDevice after scan window...")
////            self.bleModel?.stopDiscoveryDevice()
////            
////            // Small delay after stopping scan
////            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
////                ClingBLEModel.sharedInstance().tryConnectDevice()
////                print("tryConnectDevice called")
////            }
////        }
////
////        methodChannel?.invokeMethod("onDeviceConnecting", arguments: deviceID)
////    }
//    
//    private func connectDevice(deviceID: String) {
//        if isConnecting {
//            print("Already connecting, skipping...")
//            return
//        }
//        isConnecting = true
//        
//        print("Connecting to device: \(deviceID)")
//
//        // Save device ID to UserDefaults for session persistence
//        UserDefaults.standard.set(deviceID, forKey: "clingid")
//        UserDefaults.standard.synchronize()
//
//        ClingBLEModel.updateBondUid(1001, clingID: deviceID)
//
//        // 1. Start scanning to re-discover the peripheral
//        self.bleModel?.setClingDeviceStyle(.GE)
//        self.bleModel?.startDiscoveryDevice()
//        print("Started scanning to re-discover device: \(deviceID)")
//
//        // 2. After a longer scan window to ensure device is found
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//            print("Attempting tryConnectDevice after scan window...")
//            self.bleModel?.stopDiscoveryDevice()
//            
//            // Small delay after stopping scan
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                ClingBLEModel.sharedInstance().tryConnectDevice()
//                print("tryConnectDevice called")
//                
//                // Reset connecting flag after connection attempt
//                DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
//                    self.isConnecting = false
//                }
//            }
//        }
//
//        methodChannel?.invokeMethod("onDeviceConnecting", arguments: deviceID)
//    }
//
//    @objc func disconnectDevice() {
//        print("Disconnecting Cling device...")
//        guard let bleModel = ClingBLEModel.sharedInstance() else {
//            print("BLE model unavailable")
//            return
//        }
//        // Stop scanning
//        bleModel.stopDiscoveryDevice()
//        // Disconnect gracefully without auto-reconnect
//        bleModel.disconnectDevice(false)
//        print("Device disconnected successfully")
//    }
//
////    @objc func clearNativeCache() {
////        print("🧹 Local Logout: Clearing native device maps and cache")
////        guard let bleModel = ClingBLEModel.sharedInstance() else {
////            print("BLE model unavailable")
////            return
////        }
////
////        // 1. Stop any ongoing scan
////        bleModel.stopDiscoveryDevice()
////
////        // 2. Disconnect without auto-reconnect
////        bleModel.disconnectDevice(false)
////
////        // ⚠️ Do NOT call removeAllFoundDevice() here.
////        // That clears the SDK's peripheral reference map, which causes
////        // tryConnectDevice() to fail silently on the next login because
////        // the SDK has no cached peripheral to reconnect to.
////
////        // 3. Clear only the local session key so the UI starts fresh
////        UserDefaults.standard.removeObject(forKey: "clingid")
////        UserDefaults.standard.synchronize()
////
////        print("🧹 Local Logout completed successfully.")
////    }
//    
//    @objc func clearNativeCache() {
//        print("🧹 Local Logout: Clearing native device maps and cache")
//        guard let bleModel = ClingBLEModel.sharedInstance() else {
//            print("BLE model unavailable")
//            return
//        }
//
//        // 1. Stop scanning
//        bleModel.stopDiscoveryDevice()
//
//        // 2. Disconnect without auto-reconnect
//        bleModel.disconnectDevice(false)
//
//        // ⚠️ DO NOT call removeAllFoundDevice() — it clears the peripheral
//        // reference the SDK needs to reconnect via tryConnectDevice() later.
//
//        // 3. Clear the local session key
//        UserDefaults.standard.removeObject(forKey: "clingid")
//        UserDefaults.standard.synchronize()
//
//        print("🧹 Local Logout completed successfully.")
//    }
//
//    
//
//// MARK: - Background Tasks
//@available(iOS 13.0, *)
//func handleAppRefresh(task: BGAppRefreshTask) {
//scheduleAppRefresh()
//let queue = OperationQueue()
//queue.addOperation {
//let success = self.performBackgroundFetch()
//task.setTaskCompleted(success: success)
//}
//task.expirationHandler = {
//queue.cancelAllOperations()
//}
//}
//
//func performBackgroundFetch() -> Bool {
//print("Background fetch executed")
//return true
//}
//
//@available(iOS 13.0, *)
//func scheduleAppRefresh() {
//let request = BGAppRefreshTaskRequest(identifier: "com.example.app.refresh")
//request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
//do {
//try BGTaskScheduler.shared.submit(request)
//} catch {
//print("Could not schedule app refresh: \(error)")
//}
//}
//}
//
//
//
//// MARK: - Cling SDK Integration
//extension AppDelegate {
//    
//    
//func registClingSDK() {
//print("Registering ClingSDK")
//HttpModel.sharedInstance().registerClingAppid(
//    CLING_SDK_APPID,
//    withAppSecret: CLING_SDK_APPSECRET,
//enterprise: true
//)
//}
//    
//    func bleAvaliable() -> Bool{
//        guard let share = ClingBLEModel.sharedInstance() else { return false }
//        guard share.getPhoneBLEState() != .poweredOn else {return true}
//        print("蓝牙异常，请检查蓝牙状态(Bluetooth is abnormal, please check the Bluetooth status.)");
//        return false
//    }
//    
//  
//
//
//func addObservers() {
//print("Adding observers for ClingSDK")
//let nc = NotificationCenter.default
//
//    
//nc.addObserver(self, selector: #selector(syncing(_:)), name: .ClingDeviceDataSyncing, object: nil)
//nc.addObserver(self, selector: #selector(receiveMinuteData(_:)), name: .ClingDeviceMinuteDataUpdate, object: nil)
//nc.addObserver(self, selector: #selector(registerError(_:)), name: .ClingDeviceRegisterError, object: nil)
//nc.addObserver(self, selector: #selector(serviceChange(_:)), name: .ClingServiceDidChangeStatus, object: nil)
//nc.addObserver(self, selector: #selector(discoverRefresh(_:)), name: .ClingDiscoveryDidRefresh, object: nil)
//    nc.addObserver(self, selector: #selector(reciveDailyTotal(_:)), name: .ClingDeviceDayTotal, object: nil)
//    nc.addObserver(self, selector: #selector(bleDownloadPhoneSettings(_:)), name: .ClingDeviceInitCfg, object: nil)    // Added observer
//    nc.addObserver(self, selector: #selector(bleStateChange(_:)), name: .ClingBLEDidChangeStatus, object: nil)
//}
// 
//   
//    @objc func bleDownloadPhoneSettings(_ noti: Notification){
//        print("📱 Device requested phone settings - configuring...")
//        actionSetDeviceConfig()
//        actionDeviceUpdateUserProfile()
//        actionSetDeviceLanguage()
//        ClingBLEModel.sharedInstance().downloadPhoneSettingFinished()
//        print("✅ downloadPhoneSettingFinished called from bleDownloadPhoneSettings")
//    }
//    
//    @objc func bleStateChange(_ notification: Notification) {
//        print("Bluetooth state changed notification received")
//        guard let share = ClingBLEModel.sharedInstance() else { return }
//        let state = share.getPhoneBLEState()
//        print("Current phone BLE state: \(state.rawValue)")
//
//        // Dispatch on main thread so Flutter MethodChannel receives it even
//        // when the notification originally fired while the app was backgrounded.
//        DispatchQueue.main.async {
//            if state == .poweredOn {
//                self.methodChannel?.invokeMethod("bluetoothOn", arguments: nil)
//            } else if state == .poweredOff || state == .unauthorized || state == .unsupported {
//                self.methodChannel?.invokeMethod("bluetoothOff", arguments: nil)
//            }
//        }
//    }
//    
//    @objc func actionDeviceUpdateUserProfile(){
//        guard let share = ClingBLEModel.sharedInstance(), bleAvaliable() else { return }
//        let model = ClingPeripheralUserProfileModel()
//        model.touch_virbration = PERIPHERAL_PROFILE_TOUCH_VIRBRATION_OFF;
//        // 改变某一个属性，其余属性要全部重新赋值（上次的值）
//        model.height_in_cm = 170;
//        model.weight_in_kg = 65;
//        model.stride_length_in_cm = 75;
//        model.stride_length_run_in_cm = 107;
//        model.stepRateForRunLength = 172;
//        model.units_type = 0;
//        model.nickname = "Cling";
//        model.clock_orientation = PERIPHERAL_PROFILE_CLOCK_ORIENTATION_VERTICAL;
//        model.sleep_alarm_day_of_week = Int32(CLING_DEVICE_REMINDER_WEEKDAY.ALL.rawValue);
//        model.bed_hr = 18;
//        model.bed_min = 20;
//        model.wakeup_hr = 7;
//        model.wakeup_min = 40;
//        
//
//        // Ensure blood pressure display is enabled for automatic measurement
//        model.screen_display_option = Int32(SCREEN_DISPLAY_OPTION.defaultValue.rawValue) | Int32(SCREEN_DISPLAY_OPTION.bloodPressure.rawValue);
//        model.daily_goal = 0;
//        model.training_display_option = PERIPHERAL_PROFILE_TRAINING_DISPLAY_OPTION_DEFAULT_VALUE;
//        model.age = 30;
//        model.sex = 0;
//        model.stride_length_run_indoor_in_cm = 150;
//        model.hr_alarm_rate = PERIPHERAL_PROFILE_HEART_ALARM_DEFAULT_VALUE;
//        model.pace_alarm_zone = PERIPHERAL_PROFILE_PACE_ALARM_DEFAULT_VALUE;
////        print("\(model.screen_display_option),\(model.sleep_alarm_day_of_week),\(model.hr_alarm_rate),\(model.pace_alarm_zone)")
//        model.iTempAlarmValue = 373 // 37.3 * 10
//        model.iTempLowAlarmValue = 280 // 28.8 * 10;
//        model.caloryDisplayType = 1
//        model.iHealthInfoLevel = 0
//        model.bStepAlarm = true
//        model.iSAlarmValue = 13000
//        model.bCalAlarm = true
//        model.iCAlarmValue = 2300
//        share.updateUserProfile(model)
//        print("setup user profile")
//    }
//    
//    @objc func actionSetDeviceLanguage(){
//        guard let share = ClingBLEModel.sharedInstance(), bleAvaliable() else { return }
//        share.setDeviceLanguage(.english)
//        print("\nsetup user language")
//    }
//    
//    
//
//@objc func syncing(_ notification: Notification) {
//print("Syncing: \(notification.object ?? "")")
//}
//
//    @objc func actionBloodPressureCalibration(){
//        print("actionBloodPressureCalibration123")
//        guard let _ = ClingBLEModel.sharedInstance(), bleAvaliable() else { return }
//        ClingBLEModel.sendBPCMessage(130, lowPressure: 80)
//    }
//    
//    
//       @objc func receiveMinuteData(_ noti: Notification) {
//           
//           if let mimute = noti.object as? ClingMinuteData{
//               print("---------------------minutedata---------------------------------------")
//               print("接收到分钟数据通知(recive minute data)=\(mimute.intTimestamp)---\(mimute.shortHeartRate)")
//               let date = Date(timeIntervalSince1970: TimeInterval(mimute.intTimestamp))
//               let dateFormatter = DateFormatter()
//               dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//               dateFormatter.timeZone = TimeZone(identifier: "Asia/Kolkata")
//               let formattedIST = dateFormatter.string(from: date)
//               print("formattedIST: \(formattedIST)")
//               print("shortHeartRate: \(mimute.shortHeartRate)")
//               print("walk steps: \(mimute.shortWalkStep), run steps: \(mimute.shortRunStep)")
//               print("bp_low: \(mimute.bp_low), bp_high: \(mimute.bp_high), spo2: \(mimute.spo2)")
//               print("shortSleepState: \(mimute.shortSleepState)")
//               print("shortSleepSecond: \(mimute.shortSleepSecond)")
//               print("bWear: \(mimute.bWear)")
//               print("fspo2: \(mimute.fspo2)")
//        
//               
//               
//               
//               let shortSleepState = mimute.shortSleepState
//               let intTimestamp = mimute.intTimestamp
//               let shortHeartRate = mimute.shortHeartRate
//               let bp_low = mimute.bp_low
//               let bp_high = mimute.bp_high
//               let bWear = mimute.bWear
//               
//               switch shortSleepState {
//                          case 0:
//                              print("Sleep State: Default (No Value)")
//                          case 1:
//                              print("Sleep State: Awake")
//                          case 2:
//                              print("Sleep State: Light Sleep")
//                          case 3:
//                              print("Sleep State: Deep Sleep")
//                          case 4:
//                              print("Sleep State: Mid Sleep")
//                          case 5:
//                              print("Sleep State: Unknown Sleep")
//                          default:
//                              print("Unknown Sleep State: \(shortSleepState)")
//                          }
//              
//               
//               // Send data to Flutter
//                           if let controller = window?.rootViewController as? FlutterViewController {
//                               let methodChannel = FlutterMethodChannel(name: "cling_sdk", binaryMessenger: controller.binaryMessenger)
//
//                               let data: [String: Any] = [
//                                   "timestamp": intTimestamp,
//                                   "formattedIST": formattedIST,
//                                   "heartRate": shortHeartRate,
//                                   "walkSteps": mimute.shortWalkStep,
//                                   "runSteps": mimute.shortRunStep,
//                                   "bp_low": mimute.bp_low,
//                                   "bp_high": mimute.bp_high,
//                                   "spo2": mimute.spo2,
//                                   "sleepState": mimute.shortSleepState,
//                                   "sleepSeconds": mimute.shortSleepSecond,
//                                   "is_wear": mimute.bWear,
//                                   "fspo2" : mimute.fspo2
//                               ]
//
//                               methodChannel.invokeMethod("onSyncDataReceived", arguments: data)
//                           }
//               
//               
//                    
//           }
//       
//
//    }
//
//    @objc func reciveDailyTotal(_ notifacation: Notification){
//        guard let daily = notifacation.object as? ClingDailyData else { return }
//        print("daily total summary data:")
//#warning("Before obtaining and using blood pressure data")
////You need to call ClingBLEModel.sendBPCMessage(intHightVal, lowPressure: intLowVal) first to calibrate blood pressure
//        let date = Date(timeIntervalSince1970: TimeInterval(daily.daybeginTime))
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        dateFormatter.timeZone = TimeZone(identifier: "Asia/Kolkata")
//        let formattedISTDaily = dateFormatter.string(from: date)
//        print("Systolic Blood Pressure: \(daily.iBPHigh)")
//        print("Diastolic Blood Pressure: \(daily.iBPLow)")
//        print("daybeginTime: \(daily.daybeginTime)")
//        print("formattedISTDaily: \(formattedISTDaily)")
//        print("iBPTime: \(daily.iBPTime)")
//        print("Spo2: \(daily.spo2)")
//        print("total sleep seconds: \(daily.sleepTotal)")
//        print("walk steps: \(daily.wstepTotal), run steps: \(daily.rstepTotal), total steps: \(daily.stepTotal)")
//        print("total calories: \(daily.caloriesTotal)")
//        print("distance: \(daily.distanceTotal)")
//        print("heart rate: \(daily.heartRate)")
//        print("sleepLight: \(daily.sleepLight)")
//        print("sleepSound: \(daily.sleepSound)")
//        print("sleepEfficent: \(daily.sleepEfficent)")
//        print("heartRate: \(daily.heartRate)")
//        print("bWear: \(daily.bWear)")
//        print("weightkg: \(daily.weightkg)")
//        print("iWeightTime: \(daily.iWeightTime)")
//               let data: [String: Any] = [
//                   "daybeginTime" : daily.daybeginTime,
//                   "iBPHigh":daily.iBPHigh,
//                   "iBPLow":daily.iBPLow,
//                   "totalSleep": daily.sleepTotal,
//                   "walkSteps": daily.wstepTotal,
//                   "runSteps": daily.rstepTotal,
//                   "totalSteps": daily.stepTotal,
//                   "caloriesTotal": daily.caloriesTotal,
//                   "distanceTotal": daily.distanceTotal,
//                   "heartRate": daily.heartRate,
//                   "sleepEfficent": daily.sleepEfficent,
//                   "sleepLight": daily.sleepLight,
//                   "sleepSound": daily.sleepSound,
//                   "caloriesMetabolism": daily.caloriesMetabolism,
//                   "spo2" : daily.spo2,
//                   "stress": daily.stress,
//                   "is_wear": daily.bWear,
//                   "weightkg":daily.weightkg,
//                   "iWeightTime": daily.iWeightTime
//               ]
//        
//        ClingBLEModel.reloadDeviceData()
//        
//        
//        if let controller = window?.rootViewController as? FlutterViewController {
//                    let methodChannel = FlutterMethodChannel(name: "cling_sdk", binaryMessenger: controller.binaryMessenger)
//                    methodChannel.invokeMethod("onDailyTotalReceived", arguments: data)
//                }
//        
//        
//    }
//    
//    
//    
//    @objc func actionDeregisterDevice() {
//        print("Deregistering device...")
//        guard let bleModel = ClingBLEModel.sharedInstance() else {
//            print("BLE model is not available")
//            return
//        }
//
//        // Get the last connected device ID
//        if let lastDeviceID = UserDefaults.standard.string(forKey: "clingid") {
//            print("Attempting to deregister device: \(lastDeviceID)")
//            
//            // Clear bond UID to remove association
//            ClingBLEModel.updateBondUid(0, clingID: lastDeviceID)
//
//            // Attempt to deregister the device
//            bleModel.deregisterDevice()
//            
//            // Remove from UserDefaults
//            UserDefaults.standard.removeObject(forKey: "clingid")
//            UserDefaults.standard.synchronize()
//            
//            print("Device deregistered successfully.")
//        } else {
//            print("No device found to deregister")
//        }
//    }
//
//
//
//@objc func registerError(_ notification: Notification) {
//print("Register Error: \(String(describing: notification.object))")
//}
//    
////@objc func serviceChange(_ notification: Notification) {
////    guard let bleModel = bleModel else { return }
////    print("Service connection state changed: \(notification.object ?? -1), \(bleModel.getPhoneBLEState())")
////
////    if ClingBLEModel.isDConnected() {
////        // Save clingID from device info if available
////        if let info = bleModel.getDeviceInfo(), !info.isEmpty {
////            if let clingID = info["clingID"] {
////                print("ClingID: \(clingID)")
////                UserDefaults.standard.setValue(clingID, forKey: "clingid")
////            }
////            UserDefaults.standard.synchronize()
////        }
////
////        // 🔑 CRITICAL FIX: Call downloadPhoneSettingFinished() on EVERY reconnect.
////        // ClingDeviceInitCfg fires only during initial pairing/activation.
////        // On subsequent reconnects (e.g. after logout), it is skipped.
////        // Without downloadPhoneSettingFinished(), the SDK data pipeline
////        // is locked — the watch connects at BLE level but sends NO data.
////        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
////            guard ClingBLEModel.isDConnected() else {
////                print("⚠️ Device disconnected before setup could complete.")
////                return
////            }
////            print("🔑 Calling downloadPhoneSettingFinished to unlock data pipeline...")
////            self.actionSetDeviceConfig()
////            self.actionDeviceUpdateUserProfile()
////            self.actionSetDeviceLanguage()
////            ClingBLEModel.sharedInstance().downloadPhoneSettingFinished()
////
////            // 🚀 Trigger data sync after setup is confirmed
////            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
////                guard ClingBLEModel.isDConnected() else { return }
////                print("🚀 Triggering reloadDeviceData after setup...")
////                ClingBLEModel.reloadDeviceData()
////
////                // ✅ Notify Flutter that device is connected and sync has started
////                self.methodChannel?.invokeMethod("onDeviceConnected", arguments: nil)
////            }
////        }
////    }
////}
//    
////    @objc func serviceChange(_ notification: Notification) {
////        guard let bleModel = bleModel else { return }
////        print("Service connection state changed: \(notification.object ?? -1), \(bleModel.getPhoneBLEState())")
////
////        if ClingBLEModel.isDConnected() {
////            // Save clingID if available
////            if let info = bleModel.getDeviceInfo(), !info.isEmpty {
////                if let clingID = info["clingID"] {
////                    print("ClingID: \(clingID)")
////                    UserDefaults.standard.setValue(clingID, forKey: "clingid")
////                }
////                UserDefaults.standard.synchronize()
////            }
////
////            // 🔑 CRITICAL: Must call downloadPhoneSettingFinished() on EVERY
////            // reconnect to unlock the SDK data pipeline.
////            // Without this, the watch connects but sends NO data.
////            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
////                guard ClingBLEModel.isDConnected() else { return }
////                print("🔑 Calling downloadPhoneSettingFinished to unlock data pipeline...")
////                self.actionSetDeviceConfig()
////                self.actionDeviceUpdateUserProfile()
////                self.actionSetDeviceLanguage()
////                ClingBLEModel.sharedInstance().downloadPhoneSettingFinished()
////
////                // Now trigger data sync
////                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
////                    if ClingBLEModel.isDConnected() {
////                        print("🚀 Triggering data sync after setup...")
////                        ClingBLEModel.reloadDeviceData()
////                        // Notify Flutter that device is connected and syncing
////                        self.methodChannel?.invokeMethod("onDeviceConnected", arguments: nil)
////                    }
////                }
////            }
////        }
////    }
//    
////    @objc func serviceChange(_ notification: Notification) {
////        guard let bleModel = bleModel else { return }
////        print("Service connection state changed: \(notification.object ?? -1), \(bleModel.getPhoneBLEState())")
////
////        if ClingBLEModel.isDConnected() {
////            // Save clingID if available
////            if let info = bleModel.getDeviceInfo(), !info.isEmpty {
////                if let clingID = info["clingID"] {
////                    print("ClingID: \(clingID)")
////                    UserDefaults.standard.setValue(clingID, forKey: "clingid")
////                }
////                UserDefaults.standard.synchronize()
////            }
////
////            // Wait a bit longer for connection to stabilize
////            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {  // Changed from 1.0 to 2.0
////                guard ClingBLEModel.isDConnected() else {
////                    print("⚠️ Device disconnected before setup")
////                    return
////                }
////                print("🔑 Calling downloadPhoneSettingFinished to unlock data pipeline...")
////                self.actionSetDeviceConfig()
////                self.actionDeviceUpdateUserProfile()
////                self.actionSetDeviceLanguage()
////                ClingBLEModel.sharedInstance().downloadPhoneSettingFinished()
////
////                // Wait longer before triggering sync
////                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {  // Changed from 2.0 to 3.0
////                    if ClingBLEModel.isDConnected() {
////                        print("🚀 Triggering data sync after setup...")
////                        ClingBLEModel.reloadDeviceData()
////                        // Notify Flutter that device is connected and syncing
////                        self.methodChannel?.invokeMethod("onDeviceConnected", arguments: nil)
////                    } else {
////                        print("⚠️ Device disconnected before sync could start")
////                        // Try to reconnect
////                        if let deviceID = UserDefaults.standard.string(forKey: "clingid") {
////                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
////                                self.connectDevice(deviceID: deviceID)
////                            }
////                        }
////                    }
////                }
////            }
////        }
////    }
//    
//    @objc func serviceChange(_ notification: Notification) {
//        guard let bleModel = bleModel else { return }
//        print("Service connection state changed: \(notification.object ?? -1), \(bleModel.getPhoneBLEState())")
//
//        if ClingBLEModel.isDConnected() {
//            print("✅ Device successfully connected!")
//            
//            // Save clingID if available
//            if let info = bleModel.getDeviceInfo(), !info.isEmpty {
//                if let clingID = info["clingID"] as? String {
//                    print("ClingID from device: \(clingID)")
//                    let last4Chars = String(clingID.suffix(4))
//                    UserDefaults.standard.setValue(last4Chars, forKey: "clingid")
//                    UserDefaults.standard.synchronize()
//                    print("Saved device ID: \(last4Chars)")
//                }
//            }
//
//            // CRITICAL: Call these IMMEDIATELY without delay
//            print("🔑 Unlocking data pipeline IMMEDIATELY...")
//            self.actionSetDeviceConfig()
//            self.actionDeviceUpdateUserProfile()
//            self.actionSetDeviceLanguage()
//            ClingBLEModel.sharedInstance().downloadPhoneSettingFinished()
//            print("✅ downloadPhoneSettingFinished called")
//
//            // Small delay before triggering sync
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//                if ClingBLEModel.isDConnected() {
//                    print("🚀 Triggering data sync...")
//                    ClingBLEModel.reloadDeviceData()
//                    self.methodChannel?.invokeMethod("onDeviceConnected", arguments: nil)
//                } else {
//                    print("⚠️ Device disconnected before sync, attempting reconnect...")
//                    if let deviceID = UserDefaults.standard.string(forKey: "clingid") {
//                        self.connectDevice(deviceID: deviceID)
//                    }
//                }
//            }
//        } else {
//            print("❌ Device not connected - state: \(ClingBLEModel.isDConnected())")
//        }
//    }
//    
//@objc func discoverRefresh(_ notification: Notification) {
//print("Device discovery refreshed: \(notification.object ?? "")")
//
//if let devices = notification.object as? [ClingDeviceDiscoveryModel] {
//let discoveredDeviceNames = devices.compactMap { $0.peripheral.name }
//
//if let controller = window?.rootViewController as? FlutterViewController {
//let methodChannel = FlutterMethodChannel(name: "cling_sdk", binaryMessenger: controller.binaryMessenger)
//methodChannel.invokeMethod("onDevicesDiscovered", arguments: discoveredDeviceNames)
//}
//}
//}
//}





//old code

import  Flutter
import UIKit
import FirebaseCore
import BackgroundTasks
import ObjectiveC

@main
@objc class AppDelegate: FlutterAppDelegate {

let bleModel = ClingBLEModel.sharedInstance()
var methodChannel: FlutterMethodChannel?
var isConnecting = false
override func application(
_ application: UIApplication,
didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
) -> Bool {

// Register Cling SDK
self.registClingSDK()

    
// Abdd Bluetooth data observers
self.addObservers()

// Configure Firebase
FirebaseApp.configure()



if let controller = window?.rootViewController as? FlutterViewController {
methodChannel = FlutterMethodChannel(name: "cling_sdk", binaryMessenger: controller.binaryMessenger)
methodChannel?.setMethodCallHandler { [weak self] (call, result) in
self?.handleMethodCall(call, result: result)
}
}


// Start device discovery after a delay
DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
print("Start discovering Cling devices")
self.bleModel?.setClingDeviceStyle(.GE)
self.bleModel?.startDiscoveryDevice()
ClingBLEModel.reloadDeviceData()
    
self.activeLastDevice()
//print("Calling actionSetDeviceConfig...")
//self.actionSetDeviceConfig()
self.actionBloodPressureCalibration()
 

}

// Set up push notifications
UNUserNotificationCenter.current().delegate = self
let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in }
application.registerForRemoteNotifications()

// Register background tasks for iOS 13+
if #available(iOS 13.0, *) {
BGTaskScheduler.shared.register(
forTaskWithIdentifier: "com.example.app.refresh",
using: nil
) { task in
self.handleAppRefresh(task: task as! BGAppRefreshTask)
}
scheduleAppRefresh()
}

GeneratedPluginRegistrant.register(with: self)
return super.application(application, didFinishLaunchingWithOptions: launchOptions)
}

// MARK: - Flutter Method Channel Handler
private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
switch call.method {
case "startScanning":
self.startScanning()
result(nil)
case "stopScanning":
self.stopScanning()
result(nil)
//case "registerDevice":
//if let args = call.arguments as? [String: Any],
//let deviceID = args["deviceID"] as? String {
//print("Device ID received from Flutter: \(deviceID)")
//
//// Extract the last 4 characters of the device ID
//let trimmedDeviceID = String(deviceID.suffix(4))
//
//print("Registering device: \(trimmedDeviceID)")
////self.actionRegisterDevice(deviceID: trimmedDeviceID)
//    if let lastDeviceID = UserDefaults.standard.string(forKey: "clingid"),
//       lastDeviceID == trimmedDeviceID {
//
//        print("Device already registered → connecting instead")
//        self.connectDevice(deviceID: trimmedDeviceID)
//
//    } else {
//        print("New device → registering")
//        self.actionRegisterDevice(deviceID: trimmedDeviceID)
//    }
//result(nil)
//} else {
//result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
//}
    
case "registerDevice":
if let args = call.arguments as? [String: Any],
let deviceID = args["deviceID"] as? String {
print("Device ID received from Flutter: \(deviceID)")

// Extract the last 4 characters of the device ID
let trimmedDeviceID = String(deviceID.suffix(4))

print("Registering device: \(trimmedDeviceID)")

// Get stored device ID and trim to last 4 chars
var storedDeviceID = UserDefaults.standard.string(forKey: "clingid") ?? ""
if storedDeviceID.count > 4 {
    storedDeviceID = String(storedDeviceID.suffix(4))
}

// ALWAYS call connectDevice for already paired devices (don't re-register)
// This prevents the device from being deregistered
if !storedDeviceID.isEmpty && storedDeviceID == trimmedDeviceID {
    print("Device already registered → connecting instead (NO re-registration)")
    self.connectDevice(deviceID: trimmedDeviceID)
} else {
    print("New device or no stored device → registering for first time")
    self.actionRegisterDevice(deviceID: trimmedDeviceID)
}
result(nil)
} else {
result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
}

case "connectDevice":
if let args = call.arguments as? [String: Any],
let deviceID = args["deviceID"] as? String {
self.connectDevice(deviceID: deviceID)
result(nil)
} else {
result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
}
case "syncDeviceData":
self.actionSyncDeviceData()
result(nil)
case "calibrateBloodPressure":
    if let args = call.arguments as? [String: Any],
       let systolic = args["systolic"] as? Int,
       let diastolic = args["diastolic"] as? Int {
        self.actionBloodPressureCalibration()
        result("BP Calibration Started")
    } else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid blood pressure values", details: nil))
    }
case "setLastActiveDevice":
if let args = call.arguments as? [String: Any],
let deviceID = args["deviceID"] as? String {
UserDefaults.standard.set(deviceID, forKey: "clingid")
print("Set last active device: \(deviceID)")
result(nil)
} else {
result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for setLastActiveDevice", details: nil))
}
case "getLastActiveDevice":
    if let lastDeviceID = UserDefaults.standard.string(forKey: "clingid") {
        result(lastDeviceID)
    } else {
        result(nil)
    }
case "deregisterDevice":
    self.actionDeregisterDevice()
    result(nil)
case "setDeviceConfig":
    self.actionSetDeviceConfig()
    result("Device config updated")
case "isBluetoothOn":
    if let share = ClingBLEModel.sharedInstance() {
        let state = share.getPhoneBLEState()
        result(state == .poweredOn)
    } else {
        result(false)
    }
case "openBluetoothSettings":
    // Try to open the iOS system Bluetooth settings page directly.
    // App-Prefs:root=Bluetooth works on iOS 12+ (physical devices).
    // Falls back to the app's own settings page if the scheme is blocked.
    if let btUrl = URL(string: "App-Prefs:root=Bluetooth"),
       UIApplication.shared.canOpenURL(btUrl) {
        UIApplication.shared.open(btUrl, options: [:], completionHandler: nil)
        result(nil)
    } else if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
        UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
        result(nil)
    } else {
        result(FlutterError(code: "INVALID_URL", message: "Cannot open Bluetooth settings", details: nil))
    }
case "disconnectDevice":
    self.disconnectDevice()
    result(nil)
case "clearNativeCache":
    self.clearNativeCache()
    result(nil)
default:
result(FlutterMethodNotImplemented)
}
}
@objc func activeLastDevice() {
if let cid = UserDefaults.standard.string(forKey: "clingid") {
print("Found last connected device: \(cid), attempting to connect...")
connectDevice(deviceID: cid)
} else {
print("No last device found, starting scan...")
startScanning()
}
}
// MARK: - Cling SDK Methods
private func startScanning() {
print("Start scanning...")
self.bleModel?.setClingDeviceStyle(.GE)
self.bleModel?.startDiscoveryDevice()
}

private func stopScanning() {
print("Stop scanning...")
self.bleModel?.stopDiscoveryDevice()
}

private func actionRegisterDevice(deviceID: String) {
print("Registering device: \(deviceID)")
guard let bleModel = bleModel else {
print("BLE model is not available")
return
}
if !bleModel.registerDevice(deviceID, bondUid: 1001, complete: {
print("Device activation successful")

}) {
print("Device not found")
}
}
    @objc func actionSyncDeviceData() {
    //print("Syncing device data...")
    ClingBLEModel.reloadDeviceData()
    //print("Synced device data successfully.")
    }
    

 

@objc func actionSetDeviceConfig() {
    guard let share = ClingBLEModel.sharedInstance(), bleAvaliable() else { return }
    let cfg = ClingDeviceCfg()
    
    cfg.bFlipWrist = true;
    cfg.bTap = false;
    
    cfg.bHold = true;
    cfg.uint8Hold = 1;
    
    cfg.uint8ScreenOff = 5;
    cfg.uint8HROff = 25;
    cfg.uint8HRDay = 15;
    cfg.uint8HRNight = 30;
    cfg.uint8TempDay = 5;
    cfg.uint8TempNight = 30;
    cfg.bIdleAlert = false;
    cfg.uint8IdleAlert = 30;
    cfg.intIdleHourStart = 8;
    cfg.intIdleHourEnd = 20;
    cfg.uint8SleepSensitivity = 1;
    cfg.intVocSampleRate = 1;
    cfg.intAlcoholSensitivity = 2;
    cfg.bWeekendAlarmDisabled = false;
    

//        cfg.uint8Hold = 3;
    cfg.bTouchEnable = true;
    //Auto Blood Pressure Monitor
    cfg.bBloodP = true;
    //Auto SpO2 Monitor switch
    cfg.bBloodO = true;
//        cfg.bIdleAlert = true;
    share.setDeviceCfg(cfg)
    print("setup device config")
}


//    private func connectDevice(deviceID: String) {
//        print("Connecting to device: \(deviceID)")
//
//        // Save device ID to UserDefaults for session persistence
//        UserDefaults.standard.set(deviceID, forKey: "clingid")
//        UserDefaults.standard.synchronize()
//
//        ClingBLEModel.updateBondUid(1001, clingID: deviceID)
//
//        // 🔍 Step 1: Start scanning to re-discover the peripheral.
//        // After clearNativeCache(), tryConnectDevice() alone fails silently
//        // because the SDK's internal peripheral reference was cleared.
//        // Re-scanning allows the SDK to find and cache the peripheral again.
//        self.bleModel?.setClingDeviceStyle(.GE)
//        self.bleModel?.startDiscoveryDevice()
//        print("🔍 Started scanning to re-discover device: \(deviceID)")
//
//        // 🔗 Step 2: After a 3-second scan window, stop scan and connect.
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
//            print("🔗 Scan window complete — stopping scan and calling tryConnectDevice()")
//            self.bleModel?.stopDiscoveryDevice()
//            ClingBLEModel.sharedInstance().tryConnectDevice()
//        }
//
//        methodChannel?.invokeMethod("onDeviceConnecting", arguments: deviceID)
//    }
    
//    private func connectDevice(deviceID: String) {
//        print("Connecting to device: \(deviceID)")
//
//        // Save device ID to UserDefaults for session persistence
//        UserDefaults.standard.set(deviceID, forKey: "clingid")
//        UserDefaults.standard.synchronize()
//
//        ClingBLEModel.updateBondUid(1001, clingID: deviceID)
//
//        // 1. Start scanning to re-discover the peripheral
//        self.bleModel?.setClingDeviceStyle(.GE)
//        self.bleModel?.startDiscoveryDevice()
//        print("Started scanning to re-discover device: \(deviceID)")
//
//        // 2. After a short window to allow the peripheral to be discovered,
//        //    call tryConnectDevice(). The SDK will pick up the peripheral
//        //    it found during the scan and connect to it.
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
//            print("Attempting tryConnectDevice after scan window...")
//            self.bleModel?.stopDiscoveryDevice()
//            ClingBLEModel.sharedInstance().tryConnectDevice()
//        }
//
//        methodChannel?.invokeMethod("onDeviceConnecting", arguments: deviceID)
//    }
    
    
//    private func connectDevice(deviceID: String) {
//        print("Connecting to device: \(deviceID)")
//
//        // Save device ID to UserDefaults for session persistence
//        UserDefaults.standard.set(deviceID, forKey: "clingid")
//        UserDefaults.standard.synchronize()
//
//        ClingBLEModel.updateBondUid(1001, clingID: deviceID)
//
//        // 1. Start scanning to re-discover the peripheral
//        self.bleModel?.setClingDeviceStyle(.GE)
//        self.bleModel?.startDiscoveryDevice()
//        print("Started scanning to re-discover device: \(deviceID)")
//
//        // 2. After a longer scan window to ensure device is found
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {  // Changed from 3.0 to 5.0
//            print("Attempting tryConnectDevice after scan window...")
//            self.bleModel?.stopDiscoveryDevice()
//
//            // Small delay after stopping scan
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                ClingBLEModel.sharedInstance().tryConnectDevice()
//                print("tryConnectDevice called")
//            }
//        }
//
//        methodChannel?.invokeMethod("onDeviceConnecting", arguments: deviceID)
//    }
    
    private func connectDevice(deviceID: String) {
        if isConnecting {
            print("Already connecting, skipping...")
            return
        }
        isConnecting = true
        
        print("Connecting to device: \(deviceID)")

        // Save device ID to UserDefaults for session persistence
        UserDefaults.standard.set(deviceID, forKey: "clingid")
        UserDefaults.standard.synchronize()

        ClingBLEModel.updateBondUid(1001, clingID: deviceID)

        // 1. Start scanning to re-discover the peripheral
        self.bleModel?.setClingDeviceStyle(.GE)
        self.bleModel?.startDiscoveryDevice()
        print("Started scanning to re-discover device: \(deviceID)")

        // 2. After a longer scan window to ensure device is found
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            print("Attempting tryConnectDevice after scan window...")
            self.bleModel?.stopDiscoveryDevice()
            
            // Small delay after stopping scan
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                ClingBLEModel.sharedInstance().tryConnectDevice()
                print("tryConnectDevice called")
                
                // Reset connecting flag after connection attempt
                DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                    self.isConnecting = false
                }
            }
        }

        methodChannel?.invokeMethod("onDeviceConnecting", arguments: deviceID)
    }

    @objc func disconnectDevice() {
        print("Disconnecting Cling device...")
        guard let bleModel = ClingBLEModel.sharedInstance() else {
            print("BLE model unavailable")
            return
        }
        // Stop scanning
        bleModel.stopDiscoveryDevice()
        // Disconnect gracefully without auto-reconnect
        bleModel.disconnectDevice(false)
        print("Device disconnected successfully")
    }

//    @objc func clearNativeCache() {
//        print("🧹 Local Logout: Clearing native device maps and cache")
//        guard let bleModel = ClingBLEModel.sharedInstance() else {
//            print("BLE model unavailable")
//            return
//        }
//
//        // 1. Stop any ongoing scan
//        bleModel.stopDiscoveryDevice()
//
//        // 2. Disconnect without auto-reconnect
//        bleModel.disconnectDevice(false)
//
//        // ⚠️ Do NOT call removeAllFoundDevice() here.
//        // That clears the SDK's peripheral reference map, which causes
//        // tryConnectDevice() to fail silently on the next login because
//        // the SDK has no cached peripheral to reconnect to.
//
//        // 3. Clear only the local session key so the UI starts fresh
//        UserDefaults.standard.removeObject(forKey: "clingid")
//        UserDefaults.standard.synchronize()
//
//        print("🧹 Local Logout completed successfully.")
//    }
    
    @objc func clearNativeCache() {
        print("🧹 Local Logout: Clearing native device maps and cache")
        guard let bleModel = ClingBLEModel.sharedInstance() else {
            print("BLE model unavailable")
            return
        }

        // 1. Stop scanning
        bleModel.stopDiscoveryDevice()

        // 2. Disconnect without auto-reconnect
        bleModel.disconnectDevice(false)

        // ⚠️ DO NOT call removeAllFoundDevice() — it clears the peripheral
        // reference the SDK needs to reconnect via tryConnectDevice() later.

        // 3. Clear the local session key
        UserDefaults.standard.removeObject(forKey: "clingid")
        UserDefaults.standard.synchronize()

        print("🧹 Local Logout completed successfully.")
    }

    

// MARK: - Background Tasks
@available(iOS 13.0, *)
func handleAppRefresh(task: BGAppRefreshTask) {
scheduleAppRefresh()
let queue = OperationQueue()
queue.addOperation {
let success = self.performBackgroundFetch()
task.setTaskCompleted(success: success)
}
task.expirationHandler = {
queue.cancelAllOperations()
}
}

func performBackgroundFetch() -> Bool {
print("Background fetch executed")
return true
}

@available(iOS 13.0, *)
func scheduleAppRefresh() {
let request = BGAppRefreshTaskRequest(identifier: "com.example.app.refresh")
request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
do {
try BGTaskScheduler.shared.submit(request)
} catch {
print("Could not schedule app refresh: \(error)")
}
}
}



// MARK: - Cling SDK Integration
extension AppDelegate {
    
    
func registClingSDK() {
print("Registering ClingSDK")
HttpModel.sharedInstance().registerClingAppid(
    CLING_SDK_APPID,
    withAppSecret: CLING_SDK_APPSECRET,
enterprise: true
)
}
    
    func bleAvaliable() -> Bool{
        guard let share = ClingBLEModel.sharedInstance() else { return false }
        guard share.getPhoneBLEState() != .poweredOn else {return true}
        print("蓝牙异常，请检查蓝牙状态(Bluetooth is abnormal, please check the Bluetooth status.)");
        return false
    }
    
  


func addObservers() {
print("Adding observers for ClingSDK")
let nc = NotificationCenter.default

    
nc.addObserver(self, selector: #selector(syncing(_:)), name: .ClingDeviceDataSyncing, object: nil)
nc.addObserver(self, selector: #selector(receiveMinuteData(_:)), name: .ClingDeviceMinuteDataUpdate, object: nil)
nc.addObserver(self, selector: #selector(registerError(_:)), name: .ClingDeviceRegisterError, object: nil)
nc.addObserver(self, selector: #selector(serviceChange(_:)), name: .ClingServiceDidChangeStatus, object: nil)
nc.addObserver(self, selector: #selector(discoverRefresh(_:)), name: .ClingDiscoveryDidRefresh, object: nil)
    nc.addObserver(self, selector: #selector(reciveDailyTotal(_:)), name: .ClingDeviceDayTotal, object: nil)
    nc.addObserver(self, selector: #selector(bleDownloadPhoneSettings(_:)), name: .ClingDeviceInitCfg, object: nil)    // Added observer
    nc.addObserver(self, selector: #selector(bleStateChange(_:)), name: .ClingBLEDidChangeStatus, object: nil)
}
 
   
    @objc func bleDownloadPhoneSettings(_ noti: Notification){
       // print("settings...\(noti)")
        actionSetDeviceConfig()
        actionDeviceUpdateUserProfile()
        actionSetDeviceLanguage()
        ClingBLEModel.sharedInstance().downloadPhoneSettingFinished()
    }
    
    @objc func bleStateChange(_ notification: Notification) {
        print("Bluetooth state changed notification received")
        guard let share = ClingBLEModel.sharedInstance() else { return }
        let state = share.getPhoneBLEState()
        print("Current phone BLE state: \(state.rawValue)")

        // Dispatch on main thread so Flutter MethodChannel receives it even
        // when the notification originally fired while the app was backgrounded.
        DispatchQueue.main.async {
            if state == .poweredOn {
                self.methodChannel?.invokeMethod("bluetoothOn", arguments: nil)
            } else if state == .poweredOff || state == .unauthorized || state == .unsupported {
                self.methodChannel?.invokeMethod("bluetoothOff", arguments: nil)
            }
        }
    }
    
    @objc func actionDeviceUpdateUserProfile(){
        guard let share = ClingBLEModel.sharedInstance(), bleAvaliable() else { return }
        let model = ClingPeripheralUserProfileModel()
        model.touch_virbration = PERIPHERAL_PROFILE_TOUCH_VIRBRATION_OFF;
        // 改变某一个属性，其余属性要全部重新赋值（上次的值）
        model.height_in_cm = 170;
        model.weight_in_kg = 65;
        model.stride_length_in_cm = 75;
        model.stride_length_run_in_cm = 107;
        model.stepRateForRunLength = 172;
        model.units_type = 0;
        model.nickname = "Cling";
        model.clock_orientation = PERIPHERAL_PROFILE_CLOCK_ORIENTATION_VERTICAL;
        model.sleep_alarm_day_of_week = Int32(CLING_DEVICE_REMINDER_WEEKDAY.ALL.rawValue);
        model.bed_hr = 18;
        model.bed_min = 20;
        model.wakeup_hr = 7;
        model.wakeup_min = 40;
        

        // Ensure blood pressure display is enabled for automatic measurement
        model.screen_display_option = Int32(SCREEN_DISPLAY_OPTION.defaultValue.rawValue) | Int32(SCREEN_DISPLAY_OPTION.bloodPressure.rawValue);
        model.daily_goal = 0;
        model.training_display_option = PERIPHERAL_PROFILE_TRAINING_DISPLAY_OPTION_DEFAULT_VALUE;
        model.age = 30;
        model.sex = 0;
        model.stride_length_run_indoor_in_cm = 150;
        model.hr_alarm_rate = PERIPHERAL_PROFILE_HEART_ALARM_DEFAULT_VALUE;
        model.pace_alarm_zone = PERIPHERAL_PROFILE_PACE_ALARM_DEFAULT_VALUE;
//        print("\(model.screen_display_option),\(model.sleep_alarm_day_of_week),\(model.hr_alarm_rate),\(model.pace_alarm_zone)")
        model.iTempAlarmValue = 373 // 37.3 * 10
        model.iTempLowAlarmValue = 280 // 28.8 * 10;
        model.caloryDisplayType = 1
        model.iHealthInfoLevel = 0
        model.bStepAlarm = true
        model.iSAlarmValue = 13000
        model.bCalAlarm = true
        model.iCAlarmValue = 2300
        share.updateUserProfile(model)
        print("setup user profile")
    }
    
    @objc func actionSetDeviceLanguage(){
        guard let share = ClingBLEModel.sharedInstance(), bleAvaliable() else { return }
        share.setDeviceLanguage(.english)
        print("\nsetup user language")
    }
    
    

@objc func syncing(_ notification: Notification) {
print("Syncing: \(notification.object ?? "")")
}

    @objc func actionBloodPressureCalibration(){
        print("actionBloodPressureCalibration123")
        guard let _ = ClingBLEModel.sharedInstance(), bleAvaliable() else { return }
        ClingBLEModel.sendBPCMessage(130, lowPressure: 80)
    }
    
    
       @objc func receiveMinuteData(_ noti: Notification) {
           
           if let mimute = noti.object as? ClingMinuteData{
               print("---------------------minutedata---------------------------------------")
               print("接收到分钟数据通知(recive minute data)=\(mimute.intTimestamp)---\(mimute.shortHeartRate)")
               let date = Date(timeIntervalSince1970: TimeInterval(mimute.intTimestamp))
               let dateFormatter = DateFormatter()
               dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
               dateFormatter.timeZone = TimeZone(identifier: "Asia/Kolkata")
               let formattedIST = dateFormatter.string(from: date)
               print("formattedIST: \(formattedIST)")
               print("shortHeartRate: \(mimute.shortHeartRate)")
               print("walk steps: \(mimute.shortWalkStep), run steps: \(mimute.shortRunStep)")
               print("bp_low: \(mimute.bp_low), bp_high: \(mimute.bp_high), spo2: \(mimute.spo2)")
               print("shortSleepState: \(mimute.shortSleepState)")
               print("shortSleepSecond: \(mimute.shortSleepSecond)")
               print("bWear: \(mimute.bWear)")
               print("fspo2: \(mimute.fspo2)")
        
               
               
               
               let shortSleepState = mimute.shortSleepState
               let intTimestamp = mimute.intTimestamp
               let shortHeartRate = mimute.shortHeartRate
               let bp_low = mimute.bp_low
               let bp_high = mimute.bp_high
               let bWear = mimute.bWear
               
               switch shortSleepState {
                          case 0:
                              print("Sleep State: Default (No Value)")
                          case 1:
                              print("Sleep State: Awake")
                          case 2:
                              print("Sleep State: Light Sleep")
                          case 3:
                              print("Sleep State: Deep Sleep")
                          case 4:
                              print("Sleep State: Mid Sleep")
                          case 5:
                              print("Sleep State: Unknown Sleep")
                          default:
                              print("Unknown Sleep State: \(shortSleepState)")
                          }
              
               
               // Send data to Flutter
                           if let controller = window?.rootViewController as? FlutterViewController {
                               let methodChannel = FlutterMethodChannel(name: "cling_sdk", binaryMessenger: controller.binaryMessenger)

                               let data: [String: Any] = [
                                   "timestamp": intTimestamp,
                                   "formattedIST": formattedIST,
                                   "heartRate": shortHeartRate,
                                   "walkSteps": mimute.shortWalkStep,
                                   "runSteps": mimute.shortRunStep,
                                   "bp_low": mimute.bp_low,
                                   "bp_high": mimute.bp_high,
                                   "spo2": mimute.spo2,
                                   "sleepState": mimute.shortSleepState,
                                   "sleepSeconds": mimute.shortSleepSecond,
                                   "is_wear": mimute.bWear,
                                   "fspo2" : mimute.fspo2
                               ]

                               methodChannel.invokeMethod("onSyncDataReceived", arguments: data)
                           }
               
               
                    
           }
       

    }

    @objc func reciveDailyTotal(_ notifacation: Notification){
        guard let daily = notifacation.object as? ClingDailyData else { return }
        print("daily total summary data:")
#warning("Before obtaining and using blood pressure data")
//You need to call ClingBLEModel.sendBPCMessage(intHightVal, lowPressure: intLowVal) first to calibrate blood pressure
        let date = Date(timeIntervalSince1970: TimeInterval(daily.daybeginTime))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Kolkata")
        let formattedISTDaily = dateFormatter.string(from: date)
        print("Systolic Blood Pressure: \(daily.iBPHigh)")
        print("Diastolic Blood Pressure: \(daily.iBPLow)")
        print("daybeginTime: \(daily.daybeginTime)")
        print("formattedISTDaily: \(formattedISTDaily)")
        print("iBPTime: \(daily.iBPTime)")
        print("Spo2: \(daily.spo2)")
        print("total sleep seconds: \(daily.sleepTotal)")
        print("walk steps: \(daily.wstepTotal), run steps: \(daily.rstepTotal), total steps: \(daily.stepTotal)")
        print("total calories: \(daily.caloriesTotal)")
        print("distance: \(daily.distanceTotal)")
        print("heart rate: \(daily.heartRate)")
        print("sleepLight: \(daily.sleepLight)")
        print("sleepSound: \(daily.sleepSound)")
        print("sleepEfficent: \(daily.sleepEfficent)")
        print("heartRate: \(daily.heartRate)")
        print("bWear: \(daily.bWear)")
        print("weightkg: \(daily.weightkg)")
        print("iWeightTime: \(daily.iWeightTime)")
               let data: [String: Any] = [
                   "daybeginTime" : daily.daybeginTime,
//                    "iBPHigh":daily.iBPHigh,
//                    "iBPLow":daily.iBPLow,
                   "totalSleep": daily.sleepTotal,
                   "walkSteps": daily.wstepTotal,
                   "runSteps": daily.rstepTotal,
                   "totalSteps": daily.stepTotal,
                   "caloriesTotal": daily.caloriesTotal,
                   "distanceTotal": daily.distanceTotal,
                   "heartRate": daily.heartRate,
                   "sleepEfficent": daily.sleepEfficent,
                   "sleepLight": daily.sleepLight,
                   "sleepSound": daily.sleepSound,
                   "caloriesMetabolism": daily.caloriesMetabolism,
//                    "spo2" : daily.spo2,
                   "stress": daily.stress,
                   "is_wear": daily.bWear,
                   "weightkg":daily.weightkg,
                   "iWeightTime": daily.iWeightTime
               ]
        
        ClingBLEModel.reloadDeviceData()
        
        
        if let controller = window?.rootViewController as? FlutterViewController {
                    let methodChannel = FlutterMethodChannel(name: "cling_sdk", binaryMessenger: controller.binaryMessenger)
                    methodChannel.invokeMethod("onDailyTotalReceived", arguments: data)
                }
        
        
    }
    
    
    
    @objc func actionDeregisterDevice() {
        print("Deregistering device...")
        guard let bleModel = ClingBLEModel.sharedInstance() else {
            print("BLE model is not available")
            return
        }

        // Get the last connected device ID
        if let lastDeviceID = UserDefaults.standard.string(forKey: "clingid") {
            print("Attempting to deregister device: \(lastDeviceID)")
            
            // Clear bond UID to remove association
            ClingBLEModel.updateBondUid(0, clingID: lastDeviceID)

            // Attempt to deregister the device
            bleModel.deregisterDevice()
            
            // Remove from UserDefaults
            UserDefaults.standard.removeObject(forKey: "clingid")
            UserDefaults.standard.synchronize()
            
            print("Device deregistered successfully.")
        } else {
            print("No device found to deregister")
        }
    }



@objc func registerError(_ notification: Notification) {
print("Register Error: \(String(describing: notification.object))")
}
    
//@objc func serviceChange(_ notification: Notification) {
//    guard let bleModel = bleModel else { return }
//    print("Service connection state changed: \(notification.object ?? -1), \(bleModel.getPhoneBLEState())")
//
//    if ClingBLEModel.isDConnected() {
//        // Save clingID from device info if available
//        if let info = bleModel.getDeviceInfo(), !info.isEmpty {
//            if let clingID = info["clingID"] {
//                print("ClingID: \(clingID)")
//                UserDefaults.standard.setValue(clingID, forKey: "clingid")
//            }
//            UserDefaults.standard.synchronize()
//        }
//
//        // 🔑 CRITICAL FIX: Call downloadPhoneSettingFinished() on EVERY reconnect.
//        // ClingDeviceInitCfg fires only during initial pairing/activation.
//        // On subsequent reconnects (e.g. after logout), it is skipped.
//        // Without downloadPhoneSettingFinished(), the SDK data pipeline
//        // is locked — the watch connects at BLE level but sends NO data.
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            guard ClingBLEModel.isDConnected() else {
//                print("⚠️ Device disconnected before setup could complete.")
//                return
//            }
//            print("🔑 Calling downloadPhoneSettingFinished to unlock data pipeline...")
//            self.actionSetDeviceConfig()
//            self.actionDeviceUpdateUserProfile()
//            self.actionSetDeviceLanguage()
//            ClingBLEModel.sharedInstance().downloadPhoneSettingFinished()
//
//            // 🚀 Trigger data sync after setup is confirmed
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//                guard ClingBLEModel.isDConnected() else { return }
//                print("🚀 Triggering reloadDeviceData after setup...")
//                ClingBLEModel.reloadDeviceData()
//
//                // ✅ Notify Flutter that device is connected and sync has started
//                self.methodChannel?.invokeMethod("onDeviceConnected", arguments: nil)
//            }
//        }
//    }
//}
    
//    @objc func serviceChange(_ notification: Notification) {
//        guard let bleModel = bleModel else { return }
//        print("Service connection state changed: \(notification.object ?? -1), \(bleModel.getPhoneBLEState())")
//
//        if ClingBLEModel.isDConnected() {
//            // Save clingID if available
//            if let info = bleModel.getDeviceInfo(), !info.isEmpty {
//                if let clingID = info["clingID"] {
//                    print("ClingID: \(clingID)")
//                    UserDefaults.standard.setValue(clingID, forKey: "clingid")
//                }
//                UserDefaults.standard.synchronize()
//            }
//
//            // 🔑 CRITICAL: Must call downloadPhoneSettingFinished() on EVERY
//            // reconnect to unlock the SDK data pipeline.
//            // Without this, the watch connects but sends NO data.
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                guard ClingBLEModel.isDConnected() else { return }
//                print("🔑 Calling downloadPhoneSettingFinished to unlock data pipeline...")
//                self.actionSetDeviceConfig()
//                self.actionDeviceUpdateUserProfile()
//                self.actionSetDeviceLanguage()
//                ClingBLEModel.sharedInstance().downloadPhoneSettingFinished()
//
//                // Now trigger data sync
//                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//                    if ClingBLEModel.isDConnected() {
//                        print("🚀 Triggering data sync after setup...")
//                        ClingBLEModel.reloadDeviceData()
//                        // Notify Flutter that device is connected and syncing
//                        self.methodChannel?.invokeMethod("onDeviceConnected", arguments: nil)
//                    }
//                }
//            }
//        }
//    }
    
    @objc func serviceChange(_ notification: Notification) {
        guard let bleModel = bleModel else { return }
        print("Service connection state changed: \(notification.object ?? -1), \(bleModel.getPhoneBLEState())")

        if ClingBLEModel.isDConnected() {
            // Save clingID if available
            if let info = bleModel.getDeviceInfo(), !info.isEmpty {
                if let clingID = info["clingID"] {
                    print("ClingID: \(clingID)")
                    UserDefaults.standard.setValue(clingID, forKey: "clingid")
                }
                UserDefaults.standard.synchronize()
            }

            // Wait a bit longer for connection to stabilize
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {  // Changed from 1.0 to 2.0
                guard ClingBLEModel.isDConnected() else {
                    print("⚠️ Device disconnected before setup")
                    return
                }
                print("🔑 Calling downloadPhoneSettingFinished to unlock data pipeline...")
                self.actionSetDeviceConfig()
                self.actionDeviceUpdateUserProfile()
                self.actionSetDeviceLanguage()
                ClingBLEModel.sharedInstance().downloadPhoneSettingFinished()

                // Wait longer before triggering sync
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {  // Changed from 2.0 to 3.0
                    if ClingBLEModel.isDConnected() {
                        print("🚀 Triggering data sync after setup...")
                        ClingBLEModel.reloadDeviceData()
                        // Notify Flutter that device is connected and syncing
                        self.methodChannel?.invokeMethod("onDeviceConnected", arguments: nil)
                    } else {
                        print("⚠️ Device disconnected before sync could start")
                        // Try to reconnect
                        if let deviceID = UserDefaults.standard.string(forKey: "clingid") {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                self.connectDevice(deviceID: deviceID)
                            }
                        }
                    }
                }
            }
        }
    }
    
@objc func discoverRefresh(_ notification: Notification) {
print("Device discovery refreshed: \(notification.object ?? "")")

if let devices = notification.object as? [ClingDeviceDiscoveryModel] {
let discoveredDeviceNames = devices.compactMap { $0.peripheral.name }

if let controller = window?.rootViewController as? FlutterViewController {
let methodChannel = FlutterMethodChannel(name: "cling_sdk", binaryMessenger: controller.binaryMessenger)
methodChannel.invokeMethod("onDevicesDiscovered", arguments: discoveredDeviceNames)
}
}
}
}
