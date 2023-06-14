//
//  AppDelegate.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 31.10.2022.
//

import Amplitude
import ApphudSDK
import Firebase
import UIKit
import Kingfisher
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var rootRouter: RootRouter?
    let syncService: DataSyncProtocol = DataProviderFacade()
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Apphud.start(apiKey: "app_UumawTKYjWf9iUejoRkxntPLZQa7eq")
        _ = AmplitudeManager.shared
        let cache = ImageCache.default
        cache.memoryStorage.config.totalCostLimit = 1024 * 1024 * 10
        cache.diskStorage.config.sizeLimit = 1024 * 1024 * 100
        FirebaseApp.configure()
        FeatureManager.shared.activeFeatures()
        AppDelegate.activateFonts(withExtension: "ttf")
        AppDelegate.activateFonts(withExtension: "otf")
        registerForNotifications()
        syncService.updateProducts()
        syncService.updateRecipes()
        syncService.updateItems()
        syncService.updateCategories()
        SocketManager.shared.connect()
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        rootRouter = RootRouter(window: window)
        rootRouter?.presentRootNavigationControllerInWindow()
        SharedListManager.shared.router = rootRouter
        SharedPantryManager.shared.router = rootRouter
        
        self.window = window
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
      
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
              let host = components.host else {
            print("invalidUrl")
            return false
        }
        
        guard let deepLink = DeepLink(rawValue: host) else {
            print("deeplink not found")
            return false
        }
        
        guard let token = components.queryItems?.first?.value else { return false }
        
        switch deepLink {
        case .resetPassword:
            rootRouter?.openResetPassword(token: token)
        case .share:
            if components.scheme == "pantrylist" {
                SharedPantryManager.shared.gottenDeeplinkToken(token: token)
            } else {
                SharedListManager.shared.gottenDeeplinkToken(token: token)
            }
        }
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        AmplitudeManager.shared.logEvent(.listsChanged,
                                         properties: [.count: "\(idsOfChangedLists.count)"])
        AmplitudeManager.shared.logEvent(.itemsChanged,
                                         properties: [.count: "\(idsOfChangedProducts.count)"])
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

enum DeepLink: String {
    case resetPassword
    case share
}
