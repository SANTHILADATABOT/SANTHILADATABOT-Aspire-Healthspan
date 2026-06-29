//
//import Flutter
//
//extension AppDelegate {
//    // MARK: - Flutter Method Channel Handler
//     func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
//        switch call.method {
//        case "startScanning":
//            self.startScanning()
//            result(nil)
//        case "registerDevice":
//            if let args = call.arguments as? [String: Any],
//               let deviceID = args["deviceID"] as? String {
//                print("Device ID received from Flutter: \(deviceID)")
//                let trimmedDeviceID = String(deviceID.suffix(4))
//                print("Registering device: \(trimmedDeviceID)")
//                self.actionRegisterDevice(deviceID: trimmedDeviceID)
//                result(nil)
//            } else {
//                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
//            }
//        case "connectDevice":
//            if let args = call.arguments as? [String: Any],
//               let deviceID = args["deviceID"] as? String {
//                self.connectDevice(deviceID: deviceID)
//                result(nil)
//            } else {
//                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
//            }
//        case "syncDeviceData":
//            self.actionSyncDeviceData()
//            result(nil)
//        case "setLastActiveDevice":
//            if let args = call.arguments as? [String: Any],
//               let deviceID = args["deviceID"] as? String {
//                UserDefaults.standard.set(deviceID, forKey: "clingid")
//                print("Set last active device: \(deviceID)")
//                result(nil)
//            } else {
//                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for setLastActiveDevice", details: nil))
//            }
//        case "getLastActiveDevice":
//            if let lastDeviceID = UserDefaults.standard.string(forKey: "clingid") {
//                result(lastDeviceID)
//            } else {
//                result(nil)
//            }
//        case "deregisterDevice":
//            self.actionDeregisterDevice()
//            result(nil)
//        case "setDeviceConfig":
//            self.actionSetDeviceConfig()
//            result("Device config updated")
//        default:
//            result(FlutterMethodNotImplemented)
//        }
//    }
//}
