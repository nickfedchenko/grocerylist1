//
//  AppDelegate.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 31.10.2022.
//

import Amplitude
import ApphudSDK
import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    let syncService: DataSyncProtocol = DataProviderFacade()
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Apphud.start(apiKey: "app_UumawTKYjWf9iUejoRkxntPLZQa7eq")
        _ = AmplitudeManager.shared
        AppDelegate.activateFonts(withExtension: "ttf")
        AppDelegate.activateFonts(withExtension: "otf")
        registerForNotifications()
        syncService.updateProducts()
        syncService.updateRecipes()
        SocketManager.shared.connect()
//        NetworkEngine().registerUser(email: "ffdfd", password: "dfdf3") { result in
//            switch result {
//            case .failure(let error):
//                print(error)
//            case .success(let response):
//                print(response)
//            }
//        }
//
//        NetworkEngine().logIn(email: "rusbear28@yandex.ru", password: "123456") { result in
//            switch result {
//            case .failure(let error):
//                print(error)
//            case .success(let response):
//                print(response)
//            }
//        }
//
//        NetworkEngine().updateUserName(userToken: "Fdfd", newName: "Fdfdf") { result in
//            switch result {
//            case .failure(let error):
//                print(error)
//            case .success(let response):
//                print(response)
//            }
//        }
//
//        NetworkEngine().uploadAvatar(userToken: "Fdf", imageData: (UIImage(systemName: "trash")?.jpegData(compressionQuality: 1)!)! ) { result in
//            switch result {
//            case .failure(let error):
//                print(error)
//            case .success(let response):
//                print(response)
//            }
//        }
//
//        NetworkEngine().checkEmail(email: "ddsd") { result in
//            switch result {
//            case .failure(let error):
//                print(error)
//            case .success(let response):
//                print(response)
//            }
//        }
        
        NetworkEngine().resendVerificationCode(email: "ddsd") { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let response):
                print(response)
            }
        }
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
    
    func registerForNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in
            // handle if needed
        }
        UIApplication.shared.registerForRemoteNotifications()
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Apphud.submitPushNotificationsToken(token: deviceToken, callback: nil)
        Amplitude.instance().logEvent("Successfully registered for remote notifications")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for push notifications")
        Amplitude.instance().logEvent("Failed to register remote notifications")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if Apphud.handlePushNotification(apsInfo: response.notification.request.content.userInfo) {
            // Push Notification was handled by Apphud, probably do nothing
            print("Handled succesfully")
        } else {
            // Handle other types of push notifications
            print("Need to manually handle push notification")
        }
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if Apphud.handlePushNotification(apsInfo: notification.request.content.userInfo) {
            // Push Notification was handled by Apphud, probably do nothing
            print("Handled succesfully")
        } else {
            // Handle other types of push notifications
            print("Need to manually handle push notification")
        }
        completionHandler([]) // return empty array to skip showing notification banner
    }
}
