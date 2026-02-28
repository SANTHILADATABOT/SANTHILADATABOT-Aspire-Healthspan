//
//import UIKit
//
//extension AppDelegate {
//    // MARK: - Cling SDK Integration
//    func registClingSDK() {
//        print("Registering ClingSDK")
//        HttpModel.sharedInstance().registerClingAppid(
//            "HCa3f4b08b799e28af",
//            withAppSecret: "7978e5e9477d07dd5d7dc79fd1bc00d7",
//            enterprise: true
//        )
//    }
//
//    func bleAvaliable() -> Bool {
//        guard let share = ClingBLEModel.sharedInstance() else { return false }
//        guard share.getPhoneBLEState() != .poweredOn else { return true }
//        print("蓝牙异常，请检查蓝牙状态(Bluetooth is abnormal, please check the Bluetooth status.)")
//        return false
//    }
//    
//    func addObservers() {
//        print("Adding observers for ClingSDK")
//        let nc = NotificationCenter.default
//
//        nc.addObserver(self, selector: #selector(syncing(_:)), name: .ClingDeviceDataSyncing, object: nil)
//        nc.addObserver(self, selector: #selector(receiveMinuteData(_:)), name: .ClingDeviceMinuteDataUpdate, object: nil)
//        nc.addObserver(self, selector: #selector(registerError(_:)), name: .ClingDeviceRegisterError, object: nil)
//        nc.addObserver(self, selector: #selector(serviceChange(_:)), name: .ClingServiceDidChangeStatus, object: nil)
//        nc.addObserver(self, selector: #selector(discoverRefresh(_:)), name: .ClingDiscoveryDidRefresh, object: nil)
//        nc.addObserver(self, selector: #selector(receiveDailyTotal(_:)), name: .ClingDeviceDayTotal, object: nil)
//        nc.addObserver(self, selector: #selector(bleDownloadPhoneSettings(_:)), name: .ClingDeviceInitCfg, object: nil)
//    }
//
//    @objc func bleDownloadPhoneSettings(_ noti: Notification) {
//        print("settings...\(noti)")
//        ClingBLEModel.sharedInstance().downloadPhoneSettingFinished()
//    }
//
//    @objc func syncing(_ notification: Notification) {
//        print("Syncing: \(notification.object ?? "")")
//    }
//
//    @objc func receiveMinuteData(_ notification: Notification) {
//        if let minuteData = notification.object as? ClingMinuteData {
//            let intTimestamp = minuteData.intTimestamp
//            let shortHeartRate = minuteData.shortHeartRate
//            let shortWalkStep = minuteData.shortWalkStep
//            let shortRunStep = minuteData.shortRunStep
//            let shortDistance = minuteData.shortDistance
//            let shortSleepState = minuteData.shortSleepState
//            let shortSleepSecond = minuteData.shortSleepSecond
//            let bp_low = minuteData.bp_low
//            let bp_high = minuteData.bp_high
//            let fCalories = minuteData.fCalories
//            let bWear = minuteData.bWear
//            let fSweatSugar = minuteData.fSweatSugar
//            let fLacticAcid = minuteData.fLacticAcid
//            let fAtmPressure = minuteData.fAtmPressure
//            let spo2 = minuteData.spo2
//            let fspo2 = minuteData.fspo2
//            let fSkinTemperature = minuteData.fSkinTemperature
//            let fBodyTemperature = minuteData.fBodyTemperature
//            let ClingMinuteActTypeacttype  = minuteData.acttype
//            let iAlcohol  = minuteData.iAlcohol
//            let stress  = minuteData.stress
//            let glucose  = minuteData.glucose
//            
//            print("------------------------------------------------------------");
//
//            let date = Date(timeIntervalSince1970: TimeInterval(intTimestamp))
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//            dateFormatter.timeZone = TimeZone(identifier: "Asia/Kolkata")
//            let formattedIST = dateFormatter.string(from: date)
//
//            print("shortSleepState: \(shortSleepState)")
//            print("shortSleepSecond: \(shortSleepSecond)")
//            print("intTimestamp: \(intTimestamp)")
//            print("formattedIST: \(formattedIST)")
//            print("shortWalkStep: \(shortWalkStep)")
//            print("shortRunStep: \(shortRunStep)")
//            print("shortHeartRate: \(shortHeartRate)")
//            print("fCalories: \(fCalories)")
//            print("bWear: \(bWear)")
//            print("fSweatSugar: \(fSweatSugar)")
//            print("shortDistance: \(shortDistance)")
//            print("fLacticAcid: \(fLacticAcid)")
//            print("fAtmPressure: \(fAtmPressure)")
//            print("spo2: \(spo2)")
//            print("fspo2: \(fspo2)")
//            print("fSkinTemperature: \(fSkinTemperature)")
//            print("fBodyTemperature: \(fBodyTemperature)")
//            print("ClingMinuteActTypeacttype: \(ClingMinuteActTypeacttype)")
//            print("iAlcohol: \(iAlcohol)")
//            print("stress: \(stress)")
//            print("glucose: \(glucose)")
//            print("bp_low: \(bp_low)");
//            print("bp_high: \(bp_high)");
//            print("formattedIST: \(formattedIST)")
//
////            switch shortSleepState {
////            case 0:
////                print("shortSleepState: Default")
////            case 1:
////                print("shortSleepState: Awake")
////            case 2:
////                print("shortSleepState: Light")
////            case 3:
////                print("shortSleepState: Deep")
////            default:
////                print("Unknown shortSleepState: \(shortSleepState)")
////            }
//
//            let bpHighUInt8 = UInt8(bp_high & 0xFF)
//            let bpLowUInt8 = UInt8(bp_low & 0xFF)
//
//            ClingBLEModel.sendBPCMessage(bpHighUInt8, lowPressure: bpLowUInt8)
//            //print("Sent BP data to ClingBLEModel: High = \(bpHighUInt8), Low = \(bpLowUInt8)")
//
//            if let controller = window?.rootViewController as? FlutterViewController {
//                let methodChannel = FlutterMethodChannel(name: "cling_sdk", binaryMessenger: controller.binaryMessenger)
//                let data: [String: Any] = [
//                    "timestamp": intTimestamp,
//                    "formattedIST": formattedIST,
//                    "heartRate": shortHeartRate,
//                    "sleepDuration": shortSleepState,
//                    "bp_low": bp_low,
//                    "bp_high": bp_high
//                ]
//               
//
//                methodChannel.invokeMethod("onSyncDataReceived", arguments: data)
//            }
//            print("bleReceiveMinuteDataEnd");
//        }
//    }
//
//    @objc func receiveDailyTotal(_ notification: Notification) {
//        guard let daily = notification.object as? ClingDailyData else {
//            print("Error: Daily total data is missing.")
//            return
//        }
//
//       // print("Raw ClingDailyData: \(daily)")
//        print("----------------------reciveDailyTotalStart----------------------");
//
//        let iBPHigh = daily.iBPHigh
//        let iBPLow = daily.iBPLow
//        let bpHighUInt8 = UInt8(clamping: iBPHigh)
//        let bpLowUInt8 = UInt8(clamping: iBPLow)
//        ClingBLEModel.sendBPCMessage(bpHighUInt8, lowPressure: bpLowUInt8)
//
//        let data: [String: Any] = [
//            "daybeginTime" : daily.daybeginTime,
//            "iBPHigh": daily.iBPHigh,
//            "iBPLow": daily.iBPLow,
//            "sleepTotal": daily.sleepTotal,
//            "wstepTotal": daily.wstepTotal,
//            "rstepTotal": daily.rstepTotal,
//            "stepTotal": daily.stepTotal,
//            "caloriesTotal": daily.caloriesTotal,
//            "distanceTotal": daily.distanceTotal,
//            "heartRate": daily.heartRate,
//            "sleepEfficent": daily.sleepEfficent,
//            "sleepLight": daily.sleepLight,
//            "sleepSound": daily.sleepSound,
//            "skinTemperature": daily.skinTemperature,
//            "caloriesSport" : daily.caloriesSport,
//            "caloriesMetabolism": daily.caloriesMetabolism,
//            "sportsTimeTotal" : daily.sportsTimeTotal,
//            "iVoc" : daily.iVoc,
//            "iAlcohol":daily.iAlcohol,
//            "bWear": daily.bWear,
//            "iBPTime": daily.iBPTime,
//            "iMeasureCount" : daily.iMeasureCount,
//            "glucose":daily.glucose,
//            "shortUv":daily.shortUv,
//            "shortActtype":daily.shortActtype,
//            "bodyfat" : daily.bodyfat,
//            "fSweatSugar": daily.fSweatSugar,
//            "fLacticAcid" : daily.fLacticAcid,
//            "fAtmPressure" : daily.fAtmPressure,
//            "spo2" : daily.spo2,
//            "stress": daily.stress
//            
//            
//            
//        ]
//
//        //print("reciveDailyTotal: \(data)")
//        
//        print("daybeginTime: \(daily.daybeginTime)")
//        print("iBPHigh: \(daily.iBPHigh)")
//        print("iBPLow: \(daily.iBPLow)")
//        
//        print("sleepTotal: \(daily.sleepTotal)")
//        
//        print("wstepTotal: \(daily.wstepTotal), rstepTotal: \(daily.rstepTotal), stepTotal: \(daily.stepTotal)")
//        
//        print("caloriesTotal: \(daily.caloriesTotal)")
//        
//        print("distanceTotal: \(daily.distanceTotal)")
//        
//        print("heartRate: \(daily.heartRate)")
//        print("sleepEfficent: \(daily.sleepEfficent)")
//        print("sleepLight: \(daily.sleepLight)")
//        print("sleepSound: \(daily.sleepSound)")
//        print("skinTemperature: \(daily.skinTemperature)")
//        print("caloriesSport: \(daily.caloriesSport)")
//        print("caloriesMetabolism: \(daily.caloriesMetabolism)")
//        print("sportsTimeTotal: \(daily.sportsTimeTotal)")
//        print("iVoc: \(daily.iVoc)")
//        print("iAlcohol: \(daily.iAlcohol)")
//        print("glucose: \(daily.glucose)")
//        print("shortUv: \(daily.shortUv)")
//        print("shortActtype: \(daily.shortActtype)")
//        print("bWear: \(daily.bWear)")
//        print("iBPTime: \(daily.iBPTime)")
//        print("iMeasureCount: \(daily.iMeasureCount)")
//        print("bodyfat: \(daily.bodyfat)")
//        print("fSweatSugar: \(daily.fSweatSugar)")
//        print("fLacticAcid: \(daily.fLacticAcid)")
//        print("fAtmPressure: \(daily.fAtmPressure)")
//        print("spo2: \(daily.spo2)")
//        print("stress: \(daily.stress)")
//        ClingBLEModel.reloadDeviceData()
//        
//        if let controller = window?.rootViewController as? FlutterViewController {
//            let methodChannel = FlutterMethodChannel(name: "cling_sdk", binaryMessenger: controller.binaryMessenger)
//            methodChannel.invokeMethod("onDailyTotalReceived", arguments: data)
//        }
//       
//    }
//
//    @objc func registerError(_ notification: Notification) {
//        print("Register Error: \(String(describing: notification.object))")
//    }
//
//    @objc func serviceChange(_ notification: Notification) {
//        guard ClingBLEModel.isDConnected(), let bleModel = bleModel else { return }
//        print("Service connection state changed: \(notification.object ?? -1), \(bleModel.getPhoneBLEState())")
//        if let info = bleModel.getDeviceInfo(), !info.isEmpty {
//            if let clingID = info["clingID"] {
//                print("ClingID: \(clingID)")
//                UserDefaults.standard.setValue(clingID, forKey: "clingid")
//            } else {
//                UserDefaults.standard.removeObject(forKey: "clingid")
//            }
//            UserDefaults.standard.synchronize()
//        }
//    }
//
//    @objc func discoverRefresh(_ notification: Notification) {
//        print("Device discovery refreshed: \(notification.object ?? "")")
//
//        if let devices = notification.object as? [ClingDeviceDiscoveryModel] {
//            let discoveredDeviceNames = devices.compactMap { $0.peripheral.name }
//
//            if let controller = window?.rootViewController as? FlutterViewController {
//                let methodChannel = FlutterMethodChannel(name: "cling_sdk", binaryMessenger: controller.binaryMessenger)
//                methodChannel.invokeMethod("onDevicesDiscovered", arguments: discoveredDeviceNames)
//            }
//        }
//    }
//    
//    
//    
//}
