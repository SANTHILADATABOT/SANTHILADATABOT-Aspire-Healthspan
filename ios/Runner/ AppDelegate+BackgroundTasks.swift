//
//import BackgroundTasks
//
//extension AppDelegate {
//    // MARK: - Background Tasks
//    @available(iOS 13.0, *)
//    func handleAppRefresh(task: BGAppRefreshTask) {
//        scheduleAppRefresh()
//        let queue = OperationQueue()
//        queue.addOperation {
//            let success = self.performBackgroundFetch()
//            task.setTaskCompleted(success: success)
//        }
//        task.expirationHandler = {
//            queue.cancelAllOperations()
//        }
//    }
//
//    func performBackgroundFetch() -> Bool {
//        print("Background fetch executed")
//        return true
//    }
//
//    @available(iOS 13.0, *)
//    func scheduleAppRefresh() {
//        let request = BGAppRefreshTaskRequest(identifier: "com.example.app.refresh")
//        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
//        do {
//            try BGTaskScheduler.shared.submit(request)
//        } catch {
//            print("Could not schedule app refresh: \(error)")
//        }
//    }
//}
//
