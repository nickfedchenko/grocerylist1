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
// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
final class RootRouter: RootRouterProtocol {
    
    var navigationController: UINavigationController? {
        didSet { navigationController?.isNavigationBarHidden = true }
    }
    weak var viewController: UIViewController?
    
    let window: UIWindow
    
    let viewControllerFactory: ViewControllerFactoryProtocol
    
    private(set) var listNavController: UINavigationController {
        didSet { listNavController.isNavigationBarHidden = true }
    }
    
    private(set) var pantryNavController: UINavigationController {
        didSet { pantryNavController.isNavigationBarHidden = true }
    }
    
    private(set) var recipeNavController: UINavigationController {
        didSet { recipeNavController.isNavigationBarHidden = true }
    }
    
    init(window: UIWindow) {
        self.window = window
        listNavController = UINavigationController()
        pantryNavController = UINavigationController()
        recipeNavController = UINavigationController()
        
        viewControllerFactory = ViewControllerFactory()
    }
    
    func presentRootNavigationControllerInWindow() {
        setupTabBarController()

        viewController = navigationController
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        showTestOnboarding()
    }
    
    func openResetPassword(token: String) {
        guard let resetModel = ResetPasswordModelManager.shared.getResetPasswordModel() else { return }
        if resetModel.resetToken == token && Date() < (resetModel.dateOfExpiration + 3600) {
            goToSettingsController(animated: false)
            goToEnterNewPasswordController()
        } else {
            goToSettingsController(animated: false)
            goToPasswordExpiredController()
        }
    }
    
    func presentSignInController() {
        pop(animated: false)
        goToSignUpController(animated: false, isFromResetPassword: true)
    }
    
    func showTestOnboarding() {
        if !InternetConnection.isConnected() {
            if let testOnboardingValue = UserDefaultsManager.shared.testOnboardingValue,
               testOnboardingValue.lowercased() == "new" {
                goToNewOnboarding()
            } else {
                goToOnboarding()
            }
            return
        }
        
        Apphud.paywallsDidLoadCallback { [weak self] paywalls in
            guard let paywall = paywalls.first(where: { $0.experimentName != nil }) else {
                self?.goToOnboarding()
                return
            }
            
            if let targetOnboarding = paywall.json?["onboarding"] as? String {
                UserDefaultsManager.shared.testOnboardingValue = targetOnboarding
                if targetOnboarding.lowercased() == "new" {
                    self?.goToNewOnboarding()
                } else {
                    self?.goToOnboarding()
                }
            } else {
                self?.goToOnboarding()
            }
        }
    }
    
    func goToNewOnboarding() {
        if !UserDefaultsManager.shared.isFirstLaunch {
            UserDefaultsManager.shared.firstLaunchDate = Date()
            FeatureManager.shared.activeFeaturesOnFirstLaunch()
            UserDefaultsManager.shared.isFirstLaunch = true
        }
        
        if Apphud.hasActiveSubscription(),
           UserDefaultsManager.shared.shouldShowOnboarding {
            return
        }
        let onboardingController = viewControllerFactory.createNewOnboardingController(router: self)
        navigationPushViewController(onboardingController, animated: false)
    }
    
    func goToOnboarding() {
        if UserDefaultsManager.shared.shouldShowOnboarding {
            let onboardingController = viewControllerFactory.createOnboardingController(router: self)
            navigationPushViewController(onboardingController, animated: false)
            UserDefaultsManager.shared.firstLaunchDate = Date()
            FeatureManager.shared.activeFeaturesOnFirstLaunch()
        }
    }

    func pop(animated: Bool = true) {
        navigationPopViewController(animated: animated)
    }
    
    func popToRootFromOnboarding() {
        UserDefaultsManager.shared.coldStartState = 0
        navigationPopToRootViewController(animated: true)
        UserDefaultsManager.shared.shouldShowOnboarding = false
    }
    
    func goCreateNewList(compl: @escaping (GroceryListsModel, [Product]) -> Void) {
        guard let controller = viewControllerFactory.createCreateNewListController(model: nil, router: self,
                                                                                   compl: compl) else { return }
        navigationPresent(controller, animated: false)
    }
    
    func presentCreateNewList(model: GroceryListsModel,
                              compl: @escaping (GroceryListsModel, [Product]) -> Void) {
        guard let controller = viewControllerFactory.createCreateNewListController(model: model, router: self,
                                                                                   compl: compl) else { return }
        controller.modalPresentationStyle = .overCurrentContext
        listNavController.visibleViewController?.present(controller, animated: true)
    }
    
    func goReviewController() {
        guard !UserDefaultsManager.shared.isReviewShowedAfterSharing else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            guard let controller = self.viewControllerFactory.createReviewController(router: self) else { return }
            self.navigationPresent(controller, animated: false)
        }
        UserDefaultsManager.shared.isReviewShowedAfterSharing = true
    }
    
    func goProductsVC(model: GroceryListsModel, compl: @escaping () -> Void) {
        guard let controller = viewControllerFactory.createProductsController(model: model, router: self,
                                                                                   compl: compl) else { return }
        listNavController.pushViewController(controller, animated: true)
    }
    
    func goProductsSettingsVC(snapshot: UIImage?, listByText: String, model: GroceryListsModel,
                              compl: @escaping (GroceryListsModel, [Product]) -> Void,
                              editCompl: ((ProductsSettingsViewModel.TableViewContent) -> Void)?) {
        guard let controller = viewControllerFactory.createProductsSettingsController(
            snapshot: snapshot, listByText: listByText, model: model, router: self, compl: compl, editCompl: editCompl) else { return }
        navigationPresent(controller, animated: false)
    }
    
    func goCreateNewProductController(model: GroceryListsModel?, product: Product? = nil,
                                      compl: @escaping (Product) -> Void) {
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
        navigationPushViewController(controller, animated: false)
    }
    
    func goToEnterNewPasswordController() {
        guard let controller = viewControllerFactory.createEnterNewPasswordController(router: self) else { return }
        navigationPushViewController(controller, animated: false)
    }
    
    func goToPaswordResetController(email: String, passwordResetedCompl: @escaping (() -> Void)) {
        guard let controller = viewControllerFactory.createPasswordResetController(router: self,
                                                                                   email: email, passwordResetedCompl: passwordResetedCompl) else { return }
        navigationPresent(controller, animated: false)
    }
    
    func goToSharingPopUp(compl: (() -> Void)? = nil) {
        let controller = viewControllerFactory.createSharingPopUpController(router: self, compl: compl)
        controller.modalTransitionStyle = .crossDissolve
        navigationPresent(controller, animated: true)
    }
    
    func goToSharingList(listToShare: GroceryListsModel? = nil,
                         pantryToShare: PantryModel? = nil, users: [User]) {
        let controller = viewControllerFactory.createSharingListController(router: self,
                                                                           pantryToShare: pantryToShare,
                                                                           listToShare: listToShare,
                                                                           users: users)
        navigationPresent(controller, animated: true)
    }
    
    func goToCreateNewRecipe(currentRecipe: Recipe? = nil, compl: @escaping (Recipe) -> Void) {
        let controller = viewControllerFactory.createCreateNewRecipeViewController(
            currentRecipe: currentRecipe,
            router: self,
            compl: compl)
        navigationPushViewController(controller, animated: true)
    }
    
    func goToCreateNewRecipeStepTwo(isDraftRecipe: Bool,
                                    currentRecipe: Recipe?, recipe: Recipe,
                                    compl: @escaping (Recipe) -> Void,
                                    backToOneStep: ((Bool, Recipe?) -> Void)?) {
        let controller = viewControllerFactory.createCreateNewRecipeStepTwoViewController(
            router: self, isDraftRecipe: isDraftRecipe,
            currentRecipe: currentRecipe, recipe: recipe,
            compl: compl, backToOneStep: backToOneStep)
        navigationPushViewController(controller, animated: true)
    }
    
    func goToPreparationStep(stepNumber: Int, compl: @escaping (String) -> Void) {
        let controller = viewControllerFactory.createPreparationStepViewController(stepNumber: stepNumber,
                                                                                   compl: compl)
        controller.modalTransitionStyle = .crossDissolve
        navigationPresent(controller, animated: true)
    }
    
    func goToCreateNewCollection(currentCollection: CollectionModel? = nil,
                                 collections: [CollectionModel] = [],
                                 compl: @escaping (CollectionModel) -> Void) {
        let controller = viewControllerFactory.createCreateNewCollectionViewController(currentCollection: currentCollection,
                                                                                       collections: collections,
                                                                                       compl: compl)
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .overFullScreen
        UIViewController.currentController()?.present(controller, animated: true)
    }
    
    func goToShowCollection(state: ShowCollectionViewController.ShowCollectionState,
                            recipe: Recipe? = nil,
                            updateUI: (() -> Void)? = nil,
                            compl: (([CollectionModel]) -> Void)? = nil) {
        let controller = viewControllerFactory.createShowCollectionViewController(router: self,
                                                                                  state: state,
                                                                                  recipe: recipe,
                                                                                  updateUI: updateUI,
                                                                                  compl: compl)
        if state == .edit {
            controller.modalTransitionStyle = .crossDissolve
        }
        navigationPresent(controller, style: state == .select ? .automatic : .overCurrentContext, animated: true)
    }
    
    func goToIngredient(isShowCost: Bool, currentIngredient: Ingredient? = nil, compl: @escaping (Ingredient) -> Void) {
        let controller = viewControllerFactory.createIngredientViewController(isShowCost: isShowCost,
                                                                              currentIngredient: currentIngredient,
                                                                              router: self,
                                                                              compl: compl)
        controller.modalTransitionStyle = .crossDissolve
        navigationPresent(controller, animated: true)
    }
    
    func goToSearchInList() {
        let controller = viewControllerFactory.createSearchInList(router: self)
        controller.modalTransitionStyle = .crossDissolve
        navigationPresent(controller, animated: true)
    }
    
    func goToSearchInRecipe(section: RecipeSectionsModel? = nil) {
        let controller = viewControllerFactory.createSearchInRecipe(router: self, section: section)
        controller.modalTransitionStyle = .crossDissolve
        navigationPushViewController(controller, animated: true)
    }
    
    func goToRecipe(recipe: Recipe, sectionColor: Theme?, fromSearch: Bool = false,
                    removeRecipe: ((Recipe) -> Void)?) {
        let controller = viewControllerFactory.createRecipeScreen(router: self, recipe: recipe,
                                                                  sectionColor: sectionColor, fromSearch: fromSearch,
                                                                  removeRecipe: removeRecipe)
        if fromSearch {
            navigationPushViewController(controller, animated: true)
        } else {
            recipeNavController.pushViewController(controller, animated: true)
        }
    }
    
    func goToEditSelectList(products: [Product], contentViewHeigh: CGFloat,
                            delegate: EditSelectListDelegate, state: EditListState) {
        let controller = viewControllerFactory.createEditSelectListController(
            router: self, products: products, contentViewHeigh: contentViewHeigh,
            delegate: delegate, state: state)
        navigationPresent(controller, style: .automatic, animated: true)
    }
    
    func goToAddProductsSelectionList(products: [Product], contentViewHeigh: CGFloat,
                                      delegate: AddProductsSelectionListDelegate) {
        let dataSource = SelectListDataManager()
        let viewModel = SelectListViewModel(dataSource: dataSource)
        viewModel.router = self
        let addProductsVC = AddProductsSelectionListController(with: products)
        addProductsVC.contentViewHeigh = contentViewHeigh
        addProductsVC.viewModel = viewModel
        addProductsVC.delegate = delegate
//        addProductsVC.modalPresentationStyle = .overCurrentContext
        UIViewController.currentController()?.present(addProductsVC, animated: true)
    }
    
    func goToCreateStore(model: GroceryListsModel?,
                         compl: @escaping (Store?) -> Void) {
        let controller = viewControllerFactory.createNewStoreController(router: self,
                                                                        model: model,
                                                                        compl: compl)
        controller.modalPresentationStyle = .overCurrentContext
        UIViewController.currentController()?.present(controller, animated: true)
    }
    
    func goToProductSort(model: GroceryListsModel, productType: ProductsSortViewModel.ProductType,
                         compl: ((GroceryListsModel) -> Void)?) {
        let controller = viewControllerFactory.createProductsSortController(model: model, productType: productType,
                                                                            updateModel: compl, router: self)
        navigationPresent(controller, animated: false)
    }
    
    func goToFeedback() {
        let controller = viewControllerFactory.createFeedbackController(router: self)
        controller.modalTransitionStyle = .crossDissolve
        navigationPresent(controller, animated: true)
    }
    
    func goToPantryStarterPack() {
        let controller = viewControllerFactory.createPantryStarterPackController()
        controller.modalTransitionStyle = .crossDissolve
        navigationPresent(controller, animated: true)
    }
    
    func goToCreateNewPantry(presentedController: UIViewController,
                             currentPantry: PantryModel?,
                             updateUI: @escaping ((PantryModel?) -> Void)) {
        let controller = viewControllerFactory.createCreateNewPantryController(currentPantry: currentPantry,
                                                                               updateUI: updateUI, router: self)
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .overCurrentContext
        presentedController.present(controller, animated: true)
    }
    
    func showAllIcons(icon: UIImage?, selectedTheme: Theme, selectedIcon: ((UIImage?) -> Void)?) {
        let controller = viewControllerFactory.createAllIcons(icon: icon,
                                                              selectedTheme: selectedTheme,
                                                              selectedIcon: selectedIcon)
        controller.modalPresentationStyle = .overCurrentContext
        controller.modalTransitionStyle = .crossDissolve

        UIViewController.currentController()?.present(controller, animated: true)
    }
    
    func showSelectList(presentedController: UIViewController? = nil,
                        contentViewHeigh: Double,
                        synchronizedLists: [UUID],
                        updateUI: (([UUID]) -> Void)?) {
        let controller = viewControllerFactory.createSelectList(contentViewHeigh: contentViewHeigh,
                                                                synchronizedLists: synchronizedLists,
                                                                updateUI: updateUI)
        controller.modalPresentationStyle = .overCurrentContext
        controller.modalTransitionStyle = .crossDissolve
        
        if presentedController == nil {
            navigationPresent(controller, animated: true)
        } else {
            presentedController?.present(controller, animated: true)
        }
    }
    
    func goToStocks(navController: UIViewController, pantry: PantryModel) {
        let controller = viewControllerFactory.createStocksController(pantry: pantry,
                                                                      router: self)
        navController.navigationController?.pushViewController(controller, animated: true)
    }
    
    func goToCreateNewStockController(pantry: PantryModel, stock: Stock? = nil,
                                      compl: @escaping (Stock) -> Void) {
        let controller = viewControllerFactory.createCreateNewStockController(
            pantry: pantry, stock: stock, compl: compl, router: self
        )
        navigationPresent(controller, animated: false)
    }
    
    func goToPantryListOption(pantry: PantryModel, snapshot: UIImage?, listByText: String,
                              updateUI: ((PantryModel) -> Void)?,
                              editCallback: ((ProductsSettingsViewModel.TableViewContent) -> Void)?) {
        let controller = viewControllerFactory.createPantryListOptionsController(
            pantry: pantry, snapshot: snapshot, listByText: listByText,
            updateUI: updateUI, editCallback: editCallback, router: self)
        controller.modalTransitionStyle = .crossDissolve
        navigationPresent(controller, animated: true)
    }
    
    func goToEditSelectPantryList(stocks: [Stock], contentViewHeigh: CGFloat,
                                  delegate: EditSelectListDelegate, state: EditListState) {
        let controller = viewControllerFactory.createEditSelectPantryListController(
            router: self, stocks: stocks, contentViewHeigh: contentViewHeigh,
            delegate: delegate, state: state
        )
        navigationPresent(controller, style: .automatic, animated: true)
    }
    
    func goToStockReminder(outOfStocks: [Stock], updateUI: (() -> Void)?) {
        let controller = viewControllerFactory.createStockReminderController(outOfStocks: outOfStocks,
                                                                             updateUI: updateUI,
                                                                             router: self)
        controller.modalTransitionStyle = .crossDissolve
        navigationPresent(controller, animated: true)
    }
    
    func goToPhotosFromRecipe(allPhotos: [UIImage], collectionId: Int,
                              updateUI: ((UIImage) -> Void)?) {
        let viewModel = PhotoFromRecipesViewModel(photos: allPhotos,
                                                  collectionId: collectionId)
        viewModel.updateUI = updateUI
        let controller = PhotoFromRecipesViewController(viewModel: viewModel)
        
        controller.modalTransitionStyle = .crossDissolve
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
    
    func showAlertVC(title: String, message: String, completion: (() -> Void)? = nil) {
        guard let controller = viewControllerFactory.createAlertController(title: title, message: message,
                                                                           completion) else { return }
        topViewController?.present(controller, animated: true, completion: nil)
    }
    
    func showPaywallVC() {
        Apphud.paywallsDidLoadCallback { [weak self] paywalls in
            guard let paywall = paywalls.first(where: { $0.experimentName != nil }) else {
                if let paywall = paywalls.first(where: { $0.isDefault }),
                   let targetPaywallName = paywall.json?["name"] as? String {
                    let isHard = (paywall.json?["onboarding"] as? String) ?? ""
                    self?.showPaywall(by: targetPaywallName, isHard: isHard == "new")
                    return
                }

                self?.showAlternativePaywallVC(isHard: false)
                return
            }

            if let targetPaywallName = paywall.json?["name"] as? String {
                let isHard = (paywall.json?["onboarding"] as? String) ?? ""
                self?.showPaywall(by: targetPaywallName, isHard: isHard == "new")
            } else {
                self?.showAlternativePaywallVC(isHard: false)
            }
        }
    }
    
    func showPaywallVCOnTopController() {
        guard !Apphud.hasActiveSubscription() else { return }
        Apphud.paywallsDidLoadCallback { [weak self] paywalls in
            var controller: UIViewController
            guard let self else {
                return
            }
            controller = self.viewControllerFactory.createAlternativePaywallController(isHard: false)
            guard let paywall = paywalls.first(where: { $0.experimentName != nil }) else {

                if let paywall = paywalls.first(where: { $0.isDefault }),
                   let targetPaywallName = paywall.json?["name"] as? String {
                    controller = self.getPaywall(by: targetPaywallName, isHard: false)
                }
                
                controller.modalPresentationStyle = .overCurrentContext
                UIViewController.currentController()?.present(controller, animated: true)
                return
            }

            if let targetPaywallName = paywall.json?["name"] as? String {
                controller = self.getPaywall(by: targetPaywallName, isHard: false)
            }

            controller.modalPresentationStyle = .overCurrentContext
            UIViewController.currentController()?.present(controller, animated: true)
        }
    }
    
    private func showPaywall(by name: String, isHard: Bool) {
        if name == "VaninPaywall" {
            showUpdatedPaywall(isHard: isHard)
        } else if name == "IvanTrialPaywall" {
            showNewPaywall(isTrial: true, isHard: isHard)
        } else if name == "IvanNoTrialPaywall" {
            showNewPaywall(isTrial: false, isHard: isHard)
        } else if name == "AlternativePaywall" {
            showAlternativePaywallVC(isHard: isHard)
        } else {
            showAlternativePaywallVC(isHard: isHard)
        }
    }
    
    private func getPaywall(by name: String, isHard: Bool) -> UIViewController {
        if name == "VaninPaywall" {
            return viewControllerFactory.createUpdatedPaywallController(isHard: isHard)
        } else if name == "IvanTrialPaywall" {
            return viewControllerFactory.createNewPaywallController(isTrial: true, isHard: isHard)
        } else if name == "IvanNoTrialPaywall" {
            return viewControllerFactory.createNewPaywallController(isTrial: false, isHard: isHard)
        } else if name == "AlternativePaywall" {
            return viewControllerFactory.createAlternativePaywallController(isHard: isHard)
        } else {
            return viewControllerFactory.createAlternativePaywallController(isHard: isHard)
        }
    }
    
    func showDefaultPaywallVC() {
        let controller = viewControllerFactory.createPaywallController()
        guard !Apphud.hasActiveSubscription() else { return }
        navigationPresent(controller, animated: true)
    }
    
    func showAlternativePaywallVC(isHard: Bool) {
        let controller = viewControllerFactory.createAlternativePaywallController(isHard: isHard)
        guard !Apphud.hasActiveSubscription() else { return }
        navigationPresent(controller, animated: true)
    }
    
    func showUpdatedPaywall(isHard: Bool) {
        let controller = viewControllerFactory.createUpdatedPaywallController(isHard: isHard)
        guard !Apphud.hasActiveSubscription() else { return }
        navigationPresent(controller, animated: true)
    }
    
    func showNewPaywall(isTrial: Bool, isHard: Bool) {
        let controller = viewControllerFactory.createNewPaywallController(isTrial: isTrial, isHard: isHard)
        guard !Apphud.hasActiveSubscription() else { return }
        navigationPresent(controller, animated: true)
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
    
    func prepareSelectCategoryController(model: GroceryListsModel?, compl: @escaping (String) -> Void) -> UIViewController {
        guard let controller = viewControllerFactory.createSelectCategoryController(
            model: model,
            router: self,
            compl: compl
        ) else { return UIViewController() }
        return controller
    }
    
    func prepareCreateNewCategoryController(
        model: GroceryListsModel?,
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
        recipeNavController.pushViewController(recipeVC, animated: true)
    }
    
    func goToImportWebRecipe(animated: Bool = true) {
        let controller = viewControllerFactory.createImportWebRecipeController(router: self)
        navigationPushViewController(controller, animated: animated)
    }
    
    // pop
    func popToRoot() {
        navigationPopToRootViewController(animated: true)
    }
    
    func popToController(at ind: Int, animated: Bool) {
        navigationPop(at: ind, animated: true)
    }
    
    func popListToRoot(animated: Bool = true) {
        listNavController.popToRootViewController(animated: animated)
    }
    
    func popPantryToRoot(animated: Bool = true) {
        pantryNavController.popToRootViewController(animated: animated)
    }
    
    func popRecipeToRoot(animated: Bool = true) {
        recipeNavController.popToRootViewController(animated: animated)
    }
    
    func popList(animated: Bool = true) {
        listNavController.popViewController(animated: animated)
    }
    
    func popPantry(animated: Bool = true) {
        pantryNavController.popViewController(animated: animated)
    }
    
    private func setupTabBarController() {
        let listController = viewControllerFactory.createListController(router: self)
        let pantryController = viewControllerFactory.createPantryController(router: self)
        let recipeController = viewControllerFactory.createRecipeController(router: self)
        listNavController = UINavigationController(rootViewController: listController)
        pantryNavController = UINavigationController(rootViewController: pantryController)
        recipeNavController = UINavigationController(rootViewController: recipeController)
        
        var controllers: [UIViewController] = [listNavController, pantryNavController, recipeNavController]

        let rootTabBarController = viewControllerFactory.createMainTabBarController(
            router: self, controllers: controllers
        )
        self.navigationController = BlackNavigationController(rootViewController: rootTabBarController)
    }
}

class BlackNavigationController: UINavigationController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
}
