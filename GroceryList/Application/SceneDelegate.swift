//
//  SceneDelegate.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 31.10.2022.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var rootRouter: RootRouter?
    var window: UIWindow? {
        didSet {
            window?.overrideUserInterfaceStyle = .dark
        }
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        self.rootRouter = RootRouter(window: window)
        rootRouter?.presentRootNavigationControllerInWindow()
    }
}
