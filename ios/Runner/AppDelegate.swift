
import Flutter
import UIKit
import FirebaseCore
import BackgroundTasks

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      FirebaseApp.configure()
      
      UNUserNotificationCenter.current().delegate = self
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: { _, _ in }
      )
      application.registerForRemoteNotifications()
      
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



