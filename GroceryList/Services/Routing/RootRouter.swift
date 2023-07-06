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
        
        goToOnboarding()
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
    
    func goToOnboarding() {
        if UserDefaultsManager.shouldShowOnboarding {
            guard let onboardingController = viewControllerFactory.createOnboardingController(router: self) else { return }
            navigationPushViewController(onboardingController, animated: false)
            UserDefaultsManager.firstLaunchDate = Date()
            FeatureManager.shared.activeFeaturesOnFirstLaunch()
        }
    }

    func pop(animated: Bool = true) {
        navigationPopViewController(animated: animated)
    }
    
    func popToRootFromOnboarding() {
        UserDefaultsManager.coldStartState = 0
        navigationPopToRootViewController(animated: true)
        UserDefaultsManager.shouldShowOnboarding = false
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
        guard !UserDefaultsManager.isReviewShowedAfterSharing else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            guard let controller = self.viewControllerFactory.createReviewController(router: self) else { return }
            self.navigationPresent(controller, animated: false)
        }
        UserDefaultsManager.isReviewShowedAfterSharing = true
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
                                    compl: @escaping (Recipe) -> Void) {
        let controller = viewControllerFactory.createCreateNewRecipeStepTwoViewController(
            router: self, isDraftRecipe: isDraftRecipe,
            currentRecipe: currentRecipe, recipe: recipe,
            compl: compl)
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
    
    func goToIngredient(isShowCost: Bool, compl: @escaping (Ingredient) -> Void) {
        let controller = viewControllerFactory.createIngredientViewController(isShowCost: isShowCost,
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
        navigationPresent(controller, animated: true)
    }
    
    func goToRecipe(recipe: Recipe, sectionColor: Theme?) {
        let controller = viewControllerFactory.createRecipeScreen(router: self, recipe: recipe,
                                                                  sectionColor: sectionColor)
        recipeNavController.pushViewController(controller, animated: true)
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
            UIViewController.currentController()?.present(controller, animated: true)
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
        guard !Apphud.hasActiveSubscription() else { return }
        showAlternativePaywallVC()
    }
    
    func showDefaultPaywallVC() {
        guard let controller = viewControllerFactory.createPaywallController() else { return }
        guard !Apphud.hasActiveSubscription() else { return }
        navigationPresent(controller, animated: true)
    }
    
    func showAlternativePaywallVC() {
        guard let controller = viewControllerFactory.createAlternativePaywallController() else { return }
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
