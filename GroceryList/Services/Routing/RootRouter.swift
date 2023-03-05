//
//  RootRouter.swift
//  LearnTrading
//
//  Created by Шамиль Моллачиев on 19.10.2022.
//

import ApphudSDK
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
            self.navigationController = BlackNavigationController(rootViewController: rootViewController)
        } else {
            self.navigationController = BlackNavigationController()
        }
        
        viewController = navigationController
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        goToOnboarding()
    }
    
    func openResetPassword(token: String) {
        guard let resetModel = ResetPasswordModelManager.shared.getResetPasswordModel() else { return }
        if resetModel.resetToken == token && Date() < (resetModel.dateOfExpiration + 3600) {
            goToSettingsController()
            goToEnterNewPasswordController()
        } else {
            goToSettingsController()
            goToPasswordExpiredController()
        }
    }
    
    func presentSignInController() {
        pop(animated: false)
        goToSignUpController(animated: false, isFromResetPassword: true)
    }
    
    func goToOnboarding() {
        if shouldShowOnboarding {
            guard let onboardingController = viewControllerFactory.createOnboardingController(router: self) else { return }
            navigationPushViewController(onboardingController, animated: false)
        }
    }

    func pop(animated: Bool = true) {
        navigationPopViewController(animated: animated)
    }
    
    func popToRootFromOnboarding() {
        navigationPopToRootViewController(animated: true)
        shouldShowOnboarding = false
    }
    
    func goCreateNewList(compl: @escaping (GroceryListsModel, [Product]) -> Void) {
        guard let controller = viewControllerFactory.createCreateNewListController(model: nil, router: self,
                                                                                   compl: compl) else { return }
        navigationPresent(controller, animated: false)
    }
    
    func presentCreateNewList(model: GroceryListsModel,compl: @escaping (GroceryListsModel, [Product]) -> Void) {
        guard let controller = viewControllerFactory.createCreateNewListController(model: model, router: self,
                                                                                   compl: compl) else { return }
        controller.modalPresentationStyle = .overCurrentContext
        topViewController?.present(controller, animated: true)
    }
    
    func goReviewController() {
        guard !UserDefaultsManager.isReviewShowed, UserDefaultsManager.isFirstListCreated else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            guard let controller = self.viewControllerFactory.createReviewController(router: self) else { return }
            self.navigationPresent(controller, animated: false)
        }
        UserDefaultsManager.isReviewShowed = true
    }
    
    func goProductsVC(model: GroceryListsModel, compl: @escaping () -> Void) {
        guard let controller = viewControllerFactory.createProductsController(model: model, router: self,
                                                                                   compl: compl) else { return }
        navigationPushViewController(controller, animated: true)
    }
    
    func goProductsSettingsVC(snapshot: UIImage?, model: GroceryListsModel, compl: @escaping (GroceryListsModel, [Product]) -> Void) {
        guard let controller = viewControllerFactory.createProductsSettingsController(snapshot: snapshot, model: model, router: self,
                                                                                   compl: compl) else { return }
        navigationPresent(controller, animated: false)
    }
    
    func goCreateNewProductController(model: GroceryListsModel, product: Product? = nil, compl: @escaping (Product) -> Void) {
        guard let controller = viewControllerFactory.createCreateNewProductController(model: model, product: product,
                                                                                      router: self,
                                                                                      compl: compl) else { return }
        navigationPresent(controller, animated: false)
    }
    
    func goToSettingsController(animated: Bool = true) {
        guard let controller = viewControllerFactory.createSettingsController(router: self) else { return }
        navigationPushViewController(controller, animated: animated)
    }
    
    func goToSignUpController(animated: Bool = true, isFromResetPassword: Bool = false) {
        guard let controller = viewControllerFactory.createSignUpController(router: self,
                                                                            isFromResetPassword: isFromResetPassword) else { return }
        navigationPushViewController(controller, animated: animated)
    }
    
    func goToAccountController() {
        guard let controller = viewControllerFactory.createAccountController(router: self) else { return }
        navigationPushViewController(controller, animated: true)
    }
    
    func goToPasswordExpiredController() {
        guard let controller = viewControllerFactory.createPasswordExpiredController(router: self) else { return }
        navigationPushViewController(controller, animated: true)
    }
    
    func goToEnterNewPasswordController() {
        guard let controller = viewControllerFactory.createEnterNewPasswordController(router: self) else { return }
        navigationPushViewController(controller, animated: true)
    }
    
    func goToPaswordResetController(email: String, passwordResetedCompl: @escaping (() -> Void)) {
        guard let controller = viewControllerFactory.createPasswordResetController(router: self,
                                                                                   email: email, passwordResetedCompl: passwordResetedCompl) else { return }
        navigationPresent(controller, animated: false)
    }
    
    func goToSharingPopUp() {
        let controller = viewControllerFactory.createSharingPopUpController(router: self)
        controller.modalTransitionStyle = .crossDissolve
        navigationPresent(controller, animated: true)
    }
    
    func goToSharingList(listToShare: GroceryListsModel, users: [User]) {
        let controller = viewControllerFactory.createSharingListController(router: self,
                                                                           listToShare: listToShare,
                                                                           users: users)
        navigationPresent(controller, animated: true)
    }
    
    // алерты / активити и принтер
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
    
    func showPaywallVC() {
        guard !Apphud.hasActiveSubscription() else { return }
        showAlternativePaywallVC()
    }
    
    func showDefaultPaywallVC() {
        guard let controller = viewControllerFactory.createPaywallController() else { return }
        guard !Apphud.hasActiveSubscription() else { return }
        navigationPresent(controller, style: .fullScreen, animated: true)
    }
    
    func showAlternativePaywallVC() {
        guard let controller = viewControllerFactory.createAlternativePaywallController() else { return }
        guard !Apphud.hasActiveSubscription() else { return }
        navigationPresent(controller, style: .fullScreen, animated: true)
    }
    
    func showReviewRequestController() {
       let controller = viewControllerFactory.createReviewsController(router: self)
        navigationPushViewController(controller, animated: true)
    }
    
    // просто создание вью - контролер сам будет презентить их, т.к топ контролер уже презентит вью и эти не получается так запрезентить
    func prepareSelectProductController(height: Double, model: GroceryListsModel,
                                        setOfSelectedProd: Set<Product>, compl: @escaping ((Set<Product>) -> Void)) -> UIViewController {
        guard let controller = viewControllerFactory.createSelectProductsController(height: height, model: model, setOfSelectedProd: setOfSelectedProd, router: self, compl: compl) else { return UIViewController()}
        return controller
    }
    
    func prepareSelectListController(
        height: Double,
        setOfSelectedProd: Set<Product>,
        compl: @escaping ((Set<Product>) -> Void)
    ) -> UIViewController {
        guard let controller = viewControllerFactory.createSelectListController(
            height: height,
            router: self,
            setOfSelectedProd: setOfSelectedProd,
            compl: compl
        ) else { return UIViewController()}
        controller.modalPresentationStyle = .overCurrentContext
        return controller
    }
    
    func prepareSelectCategoryController(model: GroceryListsModel, compl: @escaping (String) -> Void) -> UIViewController {
        guard let controller = viewControllerFactory.createSelectCategoryController(
            model: model,
            router: self,
            compl: compl
        ) else { return UIViewController() }
        return controller
    }
    
    func prepareCreateNewCategoryController(
        model: GroceryListsModel,
        newCategoryInd: Int,
        compl: @escaping (CategoryModel) -> Void
    ) -> UIViewController {
        guard let controller = viewControllerFactory.createCreateNewCategoryController(
            model: model,
            newCategoryInd: newCategoryInd,
            router: self,
            compl: compl
        ) else { return UIViewController() }
        controller.modalPresentationStyle = .overCurrentContext
        return controller
    }
    
    func goToRecipes(for section: RecipeSectionsModel) {
        let recipeVC = viewControllerFactory.createRecipesListController(for: section, with: self)
        navigationPushViewController(recipeVC, animated: true)
    }
    
    // pop
    func popToRoot() {
        navigationPopToRootViewController(animated: true)
    }
    
    func popToController(at ind: Int, animated: Bool) {
        navigationPop(at: ind, animated: true)
    }
}

class BlackNavigationController: UINavigationController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
}
