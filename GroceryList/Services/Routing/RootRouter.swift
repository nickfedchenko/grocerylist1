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
    
    func goCreateNewList(compl: @escaping (GroceryListsModel) -> Void) {
        guard let controller = viewControllerFactory.createCreateNewListController(model: nil, router: self,
                                                                                   compl: compl) else { return }
        navigationPresent(controller, animated: true)
    }
    
    func presentCreateNewList(model: GroceryListsModel,compl: @escaping (GroceryListsModel) -> Void) {
        guard let controller = viewControllerFactory.createCreateNewListController(model: model, router: self,
                                                                                   compl: compl) else { return }
        topViewController?.present(controller, animated: true, completion: nil)
    }
    
    func goProductsVC(model: GroceryListsModel, compl: @escaping () -> Void) {
        guard let controller = viewControllerFactory.createProductsController(model: model, router: self,
                                                                                   compl: compl) else { return }
        navigationPushViewController(controller, animated: true)
    }
    
    func goProductsSettingsVC(snapshot: UIImage?, model: GroceryListsModel, compl: @escaping (GroceryListsModel) -> Void) {
        guard let controller = viewControllerFactory.createProductsSettingsController(snapshot: snapshot, model: model, router: self,
                                                                                   compl: compl) else { return }
        navigationPresent(controller, animated: true)
    }
    
    func showActivityVC(image: [Any]) {
        guard let controller = viewControllerFactory.createActivityController(image: image) else { return }
        topViewController?.present(controller, animated: true, completion: nil)
    }
    
    func showPrintVC(image: UIImage) {
        guard let controller = viewControllerFactory.createPrintController(image: image) else { return }
        controller.present(animated: true, completionHandler: nil)
    }
    
    func showAlertVC(title: String, message: String) {
        guard let controller = viewControllerFactory.createAlertController(title: title, message: message ) else { return }
        topViewController?.present(controller, animated: true, completion: nil)
    }
    
    func presentSelectList(height: Double) {
        guard let controller = viewControllerFactory.createSelectListController(height: height, router: self) else { return }
        controller.modalPresentationStyle = .overCurrentContext
        topViewController?.present(controller, animated: true, completion: nil)
    }
    
    func presentSelectProduct(height: Double, model: GroceryListsModel) -> UIViewController {
        guard let controller = viewControllerFactory.createSelectProductsController(height: height, model: model, router: self) else { return UIViewController()}
        return controller
    }
    
    func popToRoot() {
        navigationPopToRootViewController(animated: true)
    }
    
    func popToController(at ind: Int, animated: Bool) {
        navigationPop(at: ind, animated: true)
    }
}
