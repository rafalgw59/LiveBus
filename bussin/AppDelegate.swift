//
//  AppDelegate.swift
//  bussin
//
//  Created by Rafał Gawlik on 19/12/2022.
//

import UIKit
import GoogleMaps
import BackgroundTasks
@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        registerBackgroundTasks()
        GMSServices.provideAPIKey("API_KEY")
        
        return true
    }
    func registerBackgroundTasks() {
      // Declared at the "Permitted background task scheduler identifiers" in info.plist
      let backgroundAppRefreshTaskSchedulerIdentifier = "rafalgawlik.bussin.fooBackgroundAppRefreshIdentifier"
      let backgroundProcessingTaskSchedulerIdentifier = "rafalgawlik.bussin.fooBackgroundProcessingIdentifier"

      // Use the identifier which represents your needs
    
      BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundAppRefreshTaskSchedulerIdentifier, using: nil) { (task) in
        
         print("BackgroundAppRefreshTaskScheduler is executed NOW!")
         print("Background time remaining: \(UIApplication.shared.backgroundTimeRemaining)s")
         task.expirationHandler = {
           task.setTaskCompleted(success: false)
         }

         // Do some data fetching and call setTaskCompleted(success:) asap!
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
      // Declared at the "Permitted background task scheduler identifiers" in info.plist
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
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

