//
//
//
//import UIKit
//
//extension AppDelegate {
//    // MARK: - Cling SDK Methods
//     func startScanning() {
//        print("Start scanning...")
//        self.bleModel?.setClingDeviceStyle(.GE)
//        self.bleModel?.startDiscoveryDevice()
//    }
//
//     func actionRegisterDevice(deviceID: String) {
//        print("Registering device: \(deviceID)")
//        guard let bleModel = bleModel else {
//            print("BLE model is not available")
//            return
//        }
//        if !bleModel.registerDevice(deviceID, bondUid: 1001, complete: {
//            print("Device activation successful")
//        }) {
//            print("Device not found")
//        }
//    }
//
//    @objc func actionSyncDeviceData() {
//        print("Syncing device data...")
//        ClingBLEModel.reloadDeviceData()
//        print("Synced device data successfully.")
//    }
//
//    @objc func actionSetDeviceConfig() {
//        guard let share = ClingBLEModel.sharedInstance(), bleAvaliable() else {
//            print("BLE not available or ClingBLEModel instance is nil")
//            return
//        }
//        let cfg = ClingDeviceCfg()
//        cfg.uint8Hold = 3
//        cfg.bIdleAlert = true
//        cfg.bTouchEnable = true
//        cfg.bTap = true
//        cfg.bBloodP = true
//        cfg.bFlipWrist = true
//        cfg.uint8SleepSensitivity = 2 // Set to high
//        share.setDeviceCfg(cfg)
//    }
//
//     func connectDevice(deviceID: String) {
//        print("Connecting to device: \(deviceID)")
//        ClingBLEModel.updateBondUid(1001, clingID: deviceID)
//        ClingBLEModel.sharedInstance().tryConnectDevice()
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            if ClingBLEModel.isDConnected() {
//                print("Device is connected, setting configuration...")
//                self.actionSetDeviceConfig()
//            } else {
//                print("Device not connected, cannot set configuration.")
//            }
//        }
//
//        methodChannel?.invokeMethod("onDeviceConnecting", arguments: deviceID)
//    }
//
//    @objc func actionDeregisterDevice() {
//        print("Deregistering device...")
//        guard let bleModel = ClingBLEModel.sharedInstance() else {
//            print("BLE model is not available")
//            return
//        }
//
//        if let lastDeviceID = UserDefaults.standard.string(forKey: "clingid") {
//            print("Attempting to deregister device: \(lastDeviceID)")
//            ClingBLEModel.updateBondUid(0, clingID: lastDeviceID)
//            bleModel.deregisterDevice()
//            UserDefaults.standard.removeObject(forKey: "clingid")
//            UserDefaults.standard.synchronize()
//            print("Device deregistered successfully.")
//        } else {
//            print("No device found to deregister")
//        }
//    }
//    
//    @objc func activeLastDevice() {
//        if let cid = UserDefaults.standard.string(forKey: "clingid") {
//            print("Found last connected device: \(cid), attempting to connect...")
//            connectDevice(deviceID: cid)
//        } else {
//            print("No last device found, starting scan...")
//            startScanning()
//        }
//    }
//}
//
//
