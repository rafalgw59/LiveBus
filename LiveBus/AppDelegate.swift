import UIKit
import GoogleMaps
import BackgroundTasks
@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        registerBackgroundTasks()
        GMSServices.provideAPIKey("API_KEY")
        
        return true
    }
    func registerBackgroundTasks() {

      let backgroundAppRefreshTaskSchedulerIdentifier = "rafalgawlik.bussin.fooBackgroundAppRefreshIdentifier"
      let backgroundProcessingTaskSchedulerIdentifier = "rafalgawlik.bussin.fooBackgroundProcessingIdentifier"

    
      BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundAppRefreshTaskSchedulerIdentifier, using: nil) { (task) in
        
         print("BackgroundAppRefreshTaskScheduler is executed NOW!")
         print("Background time remaining: \(UIApplication.shared.backgroundTimeRemaining)s")
         task.expirationHandler = {
           task.setTaskCompleted(success: false)
         }

         let isFetchingSuccess = true
         task.setTaskCompleted(success: isFetchingSuccess)
       }
     }
    
//    func applicationDidEnterBackground(_ application: UIApplication) {
//      submitBackgroundTasks()
//
//
//    }
    
    func submitBackgroundTasks() {

      let backgroundAppRefreshTaskSchedulerIdentifier = "com.example.fooBackgroundAppRefreshIdentifier"
      let timeDelay = 10.0

      do {
        let backgroundAppRefreshTaskRequest = BGAppRefreshTaskRequest(identifier: backgroundAppRefreshTaskSchedulerIdentifier)
        backgroundAppRefreshTaskRequest.earliestBeginDate = Date(timeIntervalSinceNow: timeDelay)
        try BGTaskScheduler.shared.submit(backgroundAppRefreshTaskRequest)
        print("Submitted task request")
      } catch {
        print("Failed to submit BGTask")
      }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {

        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {

    }


}

