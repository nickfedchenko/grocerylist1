//
//  AppDelegate.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 31.10.2022.
//

import Amplitude
import ApphudSDK
import CloudKit
import Firebase
import Kingfisher
import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var rootRouter: RootRouter?
    let syncService: DataSyncProtocol = DataProviderFacade()
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        application.registerForRemoteNotifications()
        _ = AmplitudeManager.shared
        
        Apphud.start(apiKey: "app_UumawTKYjWf9iUejoRkxntPLZQa7eq")
        FirebaseApp.configure()
        FeatureManager.shared.activeFeatures()
        FeatureManager.shared.activeFAQFeature()
        AppDelegate.activateFonts(withExtension: "ttf")
        AppDelegate.activateFonts(withExtension: "otf")
        registerForNotifications()
        syncService.updateProducts()
        syncService.updateRecipes()
        syncService.updateItems()
        syncService.updateCategories()
        syncService.updateCollections()
        SocketManager.shared.connect()

        ImageCache.default.memoryStorage.config.totalCostLimit = 1024 * 1024 * 10
        ImageCache.default.diskStorage.config.sizeLimit = 1024 * 1024 * 100
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        rootRouter = RootRouter(window: window)
        rootRouter?.presentRootNavigationControllerInWindow()
        SharedListManager.shared.router = rootRouter
        SharedPantryManager.shared.router = rootRouter
        CloudManager.shared.router = rootRouter
        
        self.window = window
        return true
    }

    // MARK: UISceneSession Lifecycle

    /// deeplinks (для теста)
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        guard let urlString = url.absoluteString.decodeUrl(),
              let url = URL(string: urlString) else {
            return false
        }
        
        guard let param = url.valueOf("link") else {
            return false
        }

        guard let url = URL(string: param) else {
            return false
        }
        
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
            if components.scheme == "pantryList" {
                SharedPantryManager.shared.gottenDeeplinkToken(token: token)
            } else if components.scheme == "mealList" {
                SharedMealPlanManager.shared.gottenDeeplinkToken(token: token)
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
    
    /// universal links
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL else {
            return false
        }
        
        guard let urlString = url.absoluteString.decodeUrl(),
              let url = URL(string: urlString) else {
            return false
        }
        
        guard let param = url.valueOf("link") else {
            return false
        }

        guard let url = URL(string: param) else {
            return false
        }
        
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
            if components.scheme == "pantryList" {
                SharedPantryManager.shared.gottenDeeplinkToken(token: token)
            } else if components.scheme == "mealList" {
                SharedMealPlanManager.shared.gottenDeeplinkToken(token: token)
            } else {
                SharedListManager.shared.gottenDeeplinkToken(token: token)
            }
        }
        
        return true
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let stringObjectUserInfo = userInfo as? [String: NSObject] {
            let notification = CKNotification(fromRemoteNotificationDictionary: stringObjectUserInfo)
            
            if notification?.subscriptionID == CloudManager.shared.privateSubscriptionID {
                CloudManager.shared.fetchChanges()
                completionHandler(.newData)
            }
        } else {
            completionHandler(.noData)
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

extension URL {
    func valueOf(_ queryParameterName: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParameterName })?.value
    }
}

extension String {
    func encodeUrl() -> String? {
        return self.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
    }
    
    func decodeUrl() -> String? {
        return self.removingPercentEncoding
    }
}
