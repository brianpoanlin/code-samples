//
//  AppDelegate.swift
//  Auxilium
//
//  Created by Brian Lin on 2/4/17.
//  Copyright © 2017 Brian Lin. All rights reserved.
//

import UIKit
import Firebase
import OneSignal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        OneSignal.initWithLaunchOptions(launchOptions, appId: "11c7b74d-c1bb-4826-afea-3b49d9f0f581", handleNotificationReceived: { (notification: OSNotification?) in
            self.reactToNotification(notification: notification!)
        }, handleNotificationAction: { (notificationResult: OSNotificationOpenedResult?) in
            self.reactToNotification(notification: notificationResult!.notification!)
        },settings: [kOSSettingsKeyInAppAlerts: OSNotificationDisplayType.none.rawValue])

        FIRApp.configure()
        return true
    }

    func reactToNotification(notification: OSNotification) {
        print("received push")
        let eventAdId = notification.payload.additionalData["eventID"] as! String
        print(eventAdId)
        if (eventAdId != nil) {
                print("got eventID for notification")

                let eventVC = self.topMostController().storyboard?.instantiateViewController(withIdentifier: "EventViewController") as! EventViewController
                eventVC.toPass = eventAdId
                self.window?.makeKeyAndVisible()
                self.topMostController().present(eventVC, animated: true, completion: nil)

        }
    }
    
    func topMostController() -> UIViewController {
        var topController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        while ((topController?.presentedViewController) != nil) {
            topController = topController?.presentedViewController
        }
        return topController!
    }
    


    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

