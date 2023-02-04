//
//  AppDelegate.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 31.10.2022.
//

import ApphudSDK
import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    let syncService: DataSyncProtocol = DataProviderFacade()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Apphud.start(apiKey: "app_UumawTKYjWf9iUejoRkxntPLZQa7eq")
        AppDelegate.activateFonts(withExtension: "ttf")
        AppDelegate.activateFonts(withExtension: "otf")
        requestPushPermissions()
        syncService.updateProducts()
        syncService.updateRecipes()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    private func requestPushPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { isSuccessed, error in
            print("Pushes is allow - \(isSuccessed)")
            if let error = error {
                print("Error is \(error)")
            }
        }
    }
}

extension AppDelegate {
    private class func activateFonts(withExtension extention: String) {
        let fileNames = Bundle.main.urls(forResourcesWithExtension: extention, subdirectory: nil)
        fileNames?.forEach({ fileUrl in
            activateFont(url: fileUrl)
        })
    }
    
    private class func activateFont(url: URL) {
        var error: Unmanaged<CFError>?
        
        if !CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) {
            CFShow(error as CFTypeRef?)
        }
    }
}
