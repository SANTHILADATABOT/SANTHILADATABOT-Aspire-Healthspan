//
//import Flutter
//import UIKit
//import FirebaseCore
//import BackgroundTasks
//
//@main
//@objc class AppDelegate: FlutterAppDelegate {
//  override func application(
//    _ application: UIApplication,
//    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//  ) -> Bool {
//      FirebaseApp.configure()
//      
//      UNUserNotificationCenter.current().delegate = self
//      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//      UNUserNotificationCenter.current().requestAuthorization(
//        options: authOptions,
//        completionHandler: { _, _ in }
//      )
//      application.registerForRemoteNotifications()
//      
//      if #available(iOS 13.0, *) {
//          BGTaskScheduler.shared.register(
//              forTaskWithIdentifier: "com.example.app.refresh",
//              using: nil
//          ) { task in
//              self.handleAppRefresh(task: task as! BGAppRefreshTask)
//          }
//          
//          scheduleAppRefresh()
//      }
//
//      GeneratedPluginRegistrant.register(with: self)
//      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//  }
//
//  @available(iOS 13.0, *)
//  func handleAppRefresh(task: BGAppRefreshTask) {
//      scheduleAppRefresh()
//      let queue = OperationQueue()
//      queue.addOperation {
//          let success = self.performBackgroundFetch()
//          task.setTaskCompleted(success: success)
//      }
//      task.expirationHandler = {
//          queue.cancelAllOperations()
//      }
//  }
//
//  func performBackgroundFetch() -> Bool {
//      print("Background fetch executed")
//      return true
//  }
//
//  @available(iOS 13.0, *)
//  func scheduleAppRefresh() {
//      let request = BGAppRefreshTaskRequest(identifier: "com.example.app.refresh")
//      request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
//      do {
//          try BGTaskScheduler.shared.submit(request)
//      } catch {
//          print("Could not schedule app refresh: \(error)")
//      }
//  }
//}
//
//
//


import Flutter
import UIKit
import FirebaseCore
import BackgroundTasks
import HealthKit   // ✅ Added for Apple Watch via HealthKit

@main
@objc class AppDelegate: FlutterAppDelegate {

    // MARK: - HealthKit Bridge
    let healthStore = HKHealthStore()
    let healthChannel = "com.eugene.aspire.healthkit"   // Change to your bundle if needed

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // -----------------------------------------------------------
        // Firebase & Notifications (Your Existing Code)
        // -----------------------------------------------------------
        FirebaseApp.configure()
        
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        application.registerForRemoteNotifications()

        // -----------------------------------------------------------
        // Background Task (Your Existing Code)
        // -----------------------------------------------------------
        if #available(iOS 13.0, *) {
            BGTaskScheduler.shared.register(
                forTaskWithIdentifier: "com.eugene.aspire.refresh",
                using: nil
            ) { task in
                self.handleAppRefresh(task: task as! BGAppRefreshTask)
            }
            scheduleAppRefresh()
        }

        // -----------------------------------------------------------
        // Flutter Method Channel for HealthKit
        // -----------------------------------------------------------
        let controller = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(
            name: healthChannel,
            binaryMessenger: controller.binaryMessenger
        )

        channel.setMethodCallHandler { (call, result) in
            switch call.method {

            case "requestAuthorization":
                self.requestHealthKitAuthorization { success, error in
                    if success { result(true) }
                    else {
                        result(FlutterError(
                            code: "HK_AUTH_FAILED",
                            message: error?.localizedDescription,
                            details: nil
                        ))
                    }
                }

            case "fetchHeartRate":
                self.fetchRecentHeartRate { samples, error in
                    if let error = error {
                        result(FlutterError(
                            code: "HK_QUERY_ERROR",
                            message: error.localizedDescription,
                            details: nil
                        ))
                        return
                    }
                    result(samples)
                }

            default:
                result(FlutterMethodNotImplemented)
            }
        }

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // MARK: - HealthKit Authorization
    func requestHealthKitAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        if !HKHealthStore.isHealthDataAvailable() {
            completion(false, nil)
            return
        }

        let readTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!
        ]

        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            completion(success, error)
        }
    }

    // MARK: - Fetch heart rate samples
    func fetchRecentHeartRate(completion: @escaping ([[String: Any]]?, Error?) -> Void) {
        guard let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            completion(nil, nil)
            return
        }

        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(
            sampleType: hrType,
            predicate: nil,
            limit: 20,
            sortDescriptors: [sort]
        ) { (_, samplesOrNil, error) in
            
            guard let samples = samplesOrNil as? [HKQuantitySample] else {
                completion(nil, error)
                return
            }

            let results = samples.map {
                [
                    "bpm": $0.quantity.doubleValue(for: HKUnit(from: "count/min")),
                    "timestamp": $0.startDate.timeIntervalSince1970
                ]
            }

            completion(results, nil)
        }

        healthStore.execute(query)
    }

    // MARK: - Background Tasks (Your Existing Code)
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
        let request = BGAppRefreshTaskRequest(identifier: "com.eugene.aspire.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
}
