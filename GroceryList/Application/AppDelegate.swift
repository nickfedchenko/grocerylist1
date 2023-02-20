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
    var window: UIWindow?
    var rootRouter: RootRouter?
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
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        rootRouter = RootRouter(window: window)
        rootRouter?.presentRootNavigationControllerInWindow()
        
        self.window = window

//        NetworkEngine().groceryListRelease(userToken: "3aSrA1Wr61susBGd3CIc",
//                                           sharingToken: "c240d441-983a-4701-9e56-a0841d136cb4") { result in
//            switch result {
//            case .failure(let error):
//                print(error)
//            case .success(let result):
//                print(result)
//            }
//        }
//        
//        NetworkEngine().groceryListDelete(userToken: "GA7FUOEoRcSqIT58QLEM",
//                                          listId: "420965bf-4bc1-4dce-b627-87a23e20d075") { result in
//            switch result {
//            case .failure(let error):
//                print(error)
//            case .success(let result):
//                print(result)
//            }
//        }
        
//        NetworkEngine().fetchMyGroceryLists(userToken: UserAccountManager.shared.getUser()!.token) { result in
//            switch result {
//            case .failure(let error):
//                print(error)
//            case .success(let result):
//                print(result)
//            }
//        }
        
//                NetworkEngine().fetchGroceryListUsers(userToken: "GA7FUOEoRcSqIT58QLEM",
//                                                      listId: "11a53f50-8f5f-4e73-a316-b859ee40f0b7") { result in
//                    switch result {
//                    case .failure(let error):
//                        print(error)
//                    case .success(let result):
//                        print(result)
//                    }
//                }
        
//                        NetworkEngine().groceryListUserDelete(userToken: "IXAduhtfpFq2JfABfoDx",
//                                                              listId: "11a53f50-8f5f-4e73-a316-b859ee40f0b7") { result in
//                            switch result {
//                            case .failure(let error):
//                                print(error)
//                            case .success(let result):
//                                print(result)
//                            }
//                        }
        
//        NetworkEngine().updateGroceryList(userToken: "IXAduhtfpFq2JfABfoDx",
//                                              listId: "2d8b1764-0df5-45fa-abdf-42e6e0d48088", listModel: model) { result in
//            switch result {
//            case .failure(let error):
//                print(error)
//            case .success(let result):
//                print(result)
//            }
//        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
      
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true), let host = components.host else {
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
            
        }
        return true
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
