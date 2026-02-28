import  Flutter
import UIKit
import FirebaseCore
import BackgroundTasks
import ObjectiveC

@main
@objc class AppDelegate: FlutterAppDelegate {

let bleModel = ClingBLEModel.sharedInstance()
var methodChannel: FlutterMethodChannel?
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
case "registerDevice":
if let args = call.arguments as? [String: Any],
let deviceID = args["deviceID"] as? String {
print("Device ID received from Flutter: \(deviceID)")

// Extract the last 4 characters of the device ID
let trimmedDeviceID = String(deviceID.suffix(4))

print("Registering device: \(trimmedDeviceID)")
self.actionRegisterDevice(deviceID: trimmedDeviceID)
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
    
//    @objc func actionSyncDeviceData() {
//        if let controller = window?.rootViewController as? FlutterViewController {
//            let methodChannel = FlutterMethodChannel(name: "cling_sdk", binaryMessenger: controller.binaryMessenger)
//
//            // Simulated progress in intervals (10% → 100%)
//            DispatchQueue.global().async {
//                for i in stride(from: 10, through: 100, by: 10) {
//                    usleep(300_000) // 300ms delay per step (adjust as needed)
//                    DispatchQueue.main.async {
//                        methodChannel.invokeMethod("onDailyTotalReceived", arguments: ["progress": "Sync \(i)%"])
//                    }
//                }
//
//                // Call actual sync once "progress" has been sent
//                DispatchQueue.main.async {
//                    ClingBLEModel.reloadDeviceData()
//                }
//            }
//        }
//    }

 

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


    private func connectDevice(deviceID: String) {
        print("Connecting to device: \(deviceID)")
        ClingBLEModel.updateBondUid(1001, clingID: deviceID)
        ClingBLEModel.sharedInstance().tryConnectDevice()

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if ClingBLEModel.isDConnected() {
                print("Device is connected, setting configuration...")
                //self.actionSetDeviceConfig()
//                self.caculateSleep() // 🔹 Call sleep calculation after connection
            } else {
                print("Device not connected, cannot set configuration.")
            }
        }

        methodChannel?.invokeMethod("onDeviceConnecting", arguments: deviceID)
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
}
 
   
    @objc func bleDownloadPhoneSettings(_ noti: Notification){
       // print("settings...\(noti)")
        actionSetDeviceConfig()
        actionDeviceUpdateUserProfile()
        actionSetDeviceLanguage()
        ClingBLEModel.sharedInstance().downloadPhoneSettingFinished()
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
//                               let data: [String: Any] = [
//                                   "timestamp": intTimestamp,
//                                   "formattedIST": formattedIST,
//                                   "heartRate": shortHeartRate,
//                                   "sleepDuration": shortSleepState,
//                                   "bp_low": bp_low,
//                                   "bp_high": bp_high
//                               ]
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
                   "iBPHigh":daily.iBPHigh,
                   "iBPLow":daily.iBPLow,
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
                   "spo2" : daily.spo2,
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
    
@objc func serviceChange(_ notification: Notification) {
guard ClingBLEModel.isDConnected(), let bleModel = bleModel else { return }
print("Service connection state changed: \(notification.object ?? -1), \(bleModel.getPhoneBLEState())")
if let info = bleModel.getDeviceInfo(), !info.isEmpty {
if let clingID = info["clingID"] {
print("ClingID: \(clingID)")
UserDefaults.standard.setValue(clingID, forKey: "clingid")
} else {
UserDefaults.standard.removeObject(forKey: "clingid")
}
UserDefaults.standard.synchronize()
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













//import Flutter
//import UIKit
//import FirebaseCore
//import BackgroundTasks
//
//@main
//@objc class AppDelegate: FlutterAppDelegate {
//
//    let bleModel = ClingBLEModel.sharedInstance()
//    var methodChannel: FlutterMethodChannel?
//
//    override func application(
//        _ application: UIApplication,
//        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//    ) -> Bool {
//
//        // Register Cling SDK
//        self.registClingSDK()
//
//        // Add Bluetooth data observers
//        self.addObservers()
//
//        // Configure Firebase
//        FirebaseApp.configure()
//
//        // Set up Flutter method channel
//        if let controller = window?.rootViewController as? FlutterViewController {
//            methodChannel = FlutterMethodChannel(name: "cling_sdk", binaryMessenger: controller.binaryMessenger)
//            methodChannel?.setMethodCallHandler { [weak self] (call, result) in
//                self?.handleMethodCall(call, result: result)
//            }
//        }
//
//        // Start device discovery after a delay
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//            print("Start discovering Cling devices")
//            self.bleModel?.setClingDeviceStyle(.GE)
//            self.bleModel?.startDiscoveryDevice()
//            ClingBLEModel.reloadDeviceData()
//            self.activeLastDevice()
//            print("Calling actionSetDeviceConfig...")
//            self.actionSetDeviceConfig()
//        }
//
//        // Set up push notifications
//        UNUserNotificationCenter.current().delegate = self
//        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in }
//        application.registerForRemoteNotifications()
//
//        // Register background tasks for iOS 13+
//        if #available(iOS 13.0, *) {
//            BGTaskScheduler.shared.register(
//                forTaskWithIdentifier: "com.example.app.refresh",
//                using: nil
//            ) { task in
//                self.handleAppRefresh(task: task as! BGAppRefreshTask)
//            }
//            scheduleAppRefresh()
//        }
//
//        GeneratedPluginRegistrant.register(with: self)
//        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//    }
//    
//   
//}
