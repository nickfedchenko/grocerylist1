//
//  RootRouter.swift
//  LearnTrading
//
//  Created by Шамиль Моллачиев on 19.10.2022.
//

import UIKit

protocol RootRouterProtocol: NavigationInterface {
    
    var window: UIWindow { get }
    
    init(window: UIWindow)
    
    func presentRootNavigationControllerInWindow()
}

// MARK: - Router

final class RootRouter: RootRouterProtocol {
    
    private var shouldShowOnboarding: Bool {
        get {
            guard let shouldShow = UserDefaults.standard.value(forKey: "shouldShowOnboarding") as? Bool else {
                return true
            }
            return shouldShow
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "shouldShowOnboarding")
        }
    }
    
    var navigationController: UINavigationController? {
        didSet {
            navigationController?.isNavigationBarHidden = true
        }
    }
    weak var viewController: UIViewController?
    
    let window: UIWindow
    
    let viewControllerFactory: ViewControllerFactoryProtocol
    
    init(window: UIWindow) {
        self.window = window
        
        viewControllerFactory = ViewControllerFactory()
    }
    
    func presentRootNavigationControllerInWindow() {
        
        if let rootViewController = viewControllerFactory.createMainController(router: self) {
            self.navigationController = UINavigationController(rootViewController: rootViewController)
        } else {
            self.navigationController = UINavigationController()
        }
        
        viewController = navigationController
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        goToOnboarding()
    }
    
    func goToOnboarding() {
        if shouldShowOnboarding {
            guard let onboardingController = viewControllerFactory.createOnboardingController(router: self) else { return }
            navigationPushViewController(onboardingController, animated: false)
        }
    }

    func pop() {
        navigationPopViewController(animated: true)
    }
    
    func popToRootFromOnboarding() {
        navigationPopToRootViewController(animated: true)
        shouldShowOnboarding = false
    }
    
    func goCreateNewList(compl: @escaping () -> Void) {
        guard let controller = viewControllerFactory.createCreateNewListController(router: self,
                                                                                   compl: compl) else { return }
        navigationPresent(controller, animated: false)
    }
    
    func popToRoot() {
        navigationPopToRootViewController(animated: true)
    }
    
    func popToController(at ind: Int, animated: Bool) {
        navigationPop(at: ind, animated: true)
    }
}
