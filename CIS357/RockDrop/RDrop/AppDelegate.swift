//
//  AppDelegate.swift
//  RDrop
//
//  Created by Admin on 11/13/17.
//  Copyright © 2017 baileyth. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import GoogleMaps

let API_KEY = "AIzaSyB_AtxkzzEEK5yXHL_5EbEHe06s1wb6lkE"


let THEME_COLOR1 = UIColor.init(hex: "#88958D")

// Background color, Button text color
let THEME_COLOR2 = UIColor.init(hex: "#247BA0")

// Label text color, Button background color
let THEME_COLOR3 = UIColor.init(hex: "#50514F")

// Background of Koloda card
let THEME_COLOR4 = UIColor.init(hex: "#70C1B3")


let THEME_COLOR5 = UIColor.init(hex: "#DDF2EB")

let THEME_COLOR6 = UIColor.init(hex: "#444444", alpha: 1)

let THEME_COLOR7 = UIColor.init(hex: "#66FFFF")

let THEME_COLOR8 = UIColor.init(hex: "#333333")

let THEME_COLOR9 = UIColor.init(hex: "#BBBBBB")

enum defaultsKeys : String {
    case email = "email"
    case password = "password"
}

let loc = CLLocationManager()


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UIApplication.shared.statusBarStyle = .lightContent
        UINavigationBar.appearance().barStyle = .black
        UITabBar.appearance().barTintColor = THEME_COLOR8
        UITabBar.appearance().tintColor = THEME_COLOR4
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "DINPro", size: 10)!], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: THEME_COLOR9], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "DINPro", size: 10)!], for: .selected)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: THEME_COLOR4], for: .selected)
        
        let navAppearance = UINavigationBar.appearance()
        navAppearance.barTintColor = THEME_COLOR6
        navAppearance.tintColor = THEME_COLOR6
        navAppearance.isTranslucent = false
        navAppearance.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        
        GMSServices.provideAPIKey(API_KEY)
        
        FirebaseApp.configure()
        
        return true
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

