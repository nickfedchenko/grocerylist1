//
//  ViewControllerFactory.swift
//  LearnTrading
//
//  Created by Шамиль Моллачиев on 19.10.2022.
//

import UIKit

// swiftlint:disable:next type_body_length
final class ViewControllerFactory: ViewControllerFactoryProtocol {
    
    func createOnboardingController(router: RootRouter) -> UIViewController {
        let viewController = OnboardingViewController()
        viewController.router = router
        return viewController
    }
    
    func createNewOnboardingController(router: RootRouter) -> UIViewController {
        let viewController = NewOnboardingViewController()
        viewController.router = router
        return viewController
    }
    
    func createMainTabBarController(router: RootRouter, controllers: [UIViewController]) -> UITabBarController {
        let isRightHanded = true
        let viewModel = MainTabBarViewModel(isRightHanded: isRightHanded, viewControllers: controllers)
        viewModel.router = router
        
        let tabBarController = MainTabBarController(viewModel: viewModel)

        return tabBarController
    }
    
    func createListController(router: RootRouter) -> UIViewController {
        let dataSource = ListDataSource()
        let viewModel = ListViewModel(dataSource: dataSource)
        viewModel.router = router
        let viewController = ListViewController(viewModel: viewModel)
        return viewController
    }
    
    func createPantryController(router: RootRouter) -> UIViewController {
        let dataSource = PantryDataSource()
        let viewModel = PantryViewModel(dataSource: dataSource)
        viewModel.router = router
        
        let viewController = PantryViewController(viewModel: viewModel)
        return viewController
    }
    
    func createRecipeController(router: RootRouter) -> UIViewController {
        let dataSource = MainRecipeDataSource()
        let viewModel = MainRecipeViewModel(dataSource: dataSource)
        viewModel.router = router
        
        let viewController = MainRecipeViewController(viewModel: viewModel)
        return viewController
    }
    
    func createFeatureViewController(router: RootRouter) -> UIViewController {
        let viewModel = NewFeatureViewModel()
        viewModel.router = router
        
        let viewController = NewFeatureViewController(viewModel: viewModel)
        return viewController
    }
    
    func createCreateNewListController(model: GroceryListsModel?, router: RootRouter,
                                       compl: @escaping (GroceryListsModel, [Product]) -> Void) -> UIViewController? {
        let viewController = CreateNewListViewController()
        let viewModel = CreateNewListViewModel()
        viewModel.valueChangedCallback = compl
        viewController.viewModel = viewModel
        viewModel.delegate = viewController
        viewModel.router = router
        viewModel.model = model
        return viewController
    }
    
    func createReviewController(router: RootRouter) -> UIViewController? {
        let viewController = WriteReviewViewController()
        let viewModel = WriteReviewViewModel()
        viewController.viewModel = viewModel
        viewModel.delegate = viewController
        viewModel.router = router
        return viewController
    }
    
    func createCreateNewProductController(model: GroceryListsModel?, product: Product? = nil,
                                          router: RootRouter, compl: @escaping (Product) -> Void) -> UIViewController? {
        let viewController = CreateNewProductViewController()
        let viewModel = CreateNewProductViewModel()
        viewModel.valueChangedCallback = compl
        viewController.viewModel = viewModel
        viewModel.delegate = viewController
        viewModel.router = router
        viewModel.model = model
        viewModel.currentProduct = product
        let navController = MyNavigationController(rootViewController: viewController)
        navController.navigationBar.isHidden = true
        return navController
    }
    
    func createCreateNewCategoryController(model: GroceryListsModel?, newCategoryInd: Int, router: RootRouter,
                                           compl: @escaping (CategoryModel) -> Void) -> UIViewController? {
        let viewController = CreateNewCategoryViewController()
        let viewModel = CreateNewCategoryViewModel(model: model, newModelInd: newCategoryInd)
        viewModel.categoryCreatedCallBack = compl
        viewController.viewModel = viewModel
        viewModel.delegate = viewController
        viewModel.router = router
        return viewController
    }
    
    func createSelectListController(height: Double, router: RootRouter, setOfSelectedProd: Set<Product>,
                                    compl: @escaping (Set<Product>) -> Void) -> UIViewController? {
        let viewController = SelectListViewController()
        let dataSource = SelectListDataManager()
        let viewModel = SelectListViewModel(dataSource: dataSource)
        viewController.viewModel = viewModel
        viewController.contentViewHeigh = height
        viewModel.selectedProductsCompl = compl
        viewModel.router = router
        viewModel.delegate = viewController
        viewModel.copiedProducts = setOfSelectedProd
        return viewController
    }
    
    func createProductsController(model: GroceryListsModel, router: RootRouter,
                                  compl: @escaping () -> Void) -> UIViewController? {
        let viewController = ProductsViewController()
        let dataSource = ProductsDataManager(products: model.products,
                                             typeOfSorting: SortingType(rawValue: model.typeOfSorting) ?? .category,
                                             groceryListId: model.id)
        let viewModel = ProductsViewModel(model: model, dataSource: dataSource)
        viewModel.valueChangedCallback = compl
        viewModel.delegate = viewController
        viewController.viewModel = viewModel
        viewModel.router = router
        return viewController
    }
    
    func createSelectProductsController(height: Double, model: GroceryListsModel,
                                        setOfSelectedProd: Set<Product>, router: RootRouter,
                                        compl: @escaping (Set<Product>) -> Void) -> UIViewController? {
        let viewController = SelectProductViewController()
        let viewModel = SelectProductViewModel(model: model, copiedProducts: setOfSelectedProd)
        viewController.viewModel = viewModel
        viewController.contentViewHeigh = height
        viewModel.router = router
        viewModel.delegate = viewController
        viewModel.productsSelectedCompl = compl
        return viewController
    }
    
    func createSelectCategoryController(model: GroceryListsModel?, router: RootRouter,
                                        compl: @escaping (String) -> Void) -> UIViewController? {
        let viewController = SelectCategoryViewController()
        let viewModel = SelectCategoryViewModel(model: model)
        viewController.viewModel = viewModel
        viewModel.router = router
        viewModel.delegate = viewController
        viewModel.categorySelectedCallback = compl
        return viewController
    }
    
    func createProductsSettingsController(snapshot: UIImage?, listByText: String,
                                          model: GroceryListsModel, router: RootRouter,
                                          compl: @escaping (GroceryListsModel, [Product]) -> Void,
                                          editCompl: ((ProductsSettingsViewModel.TableViewContent) -> Void)?) -> UIViewController? {
        let viewController = ProductsSettingsViewController()
        let viewModel = ProductsSettingsViewModel(model: model, snapshot: snapshot, listByText: listByText)
        viewModel.delegate = viewController
        viewModel.valueChangedCallback = compl
        viewModel.editCallback = editCompl
        viewController.viewModel = viewModel
        viewModel.router = router
        return viewController
    }
    
    func createSettingsController(router: RootRouter) -> UIViewController? {
        let viewController = SettingsViewController()
        let networkManager = NetworkEngine()
        let viewModel = SettingsViewModel(network: networkManager)
        viewModel.delegate = viewController
        viewController.viewModel = viewModel
        viewModel.router = router
        return viewController
    }
    
    func createSignUpController(router: RootRouter, isFromResetPassword: Bool) -> UIViewController? {
        let viewController = SignUpViewController()
        let networkManager = NetworkEngine()
        let viewModel = SignUpViewModel(network: networkManager)
        viewModel.delegate = viewController
        viewController.viewModel = viewModel
        viewModel.router = router
        viewModel.setup(state: .signUp)
        if isFromResetPassword {
            viewModel.setupResetPasswordState()
        }
        return viewController
    }
    
    func createPasswordResetController(router: RootRouter, email: String,
                                       passwordResetedCompl: (() -> Void)?) -> UIViewController? {
        let viewController = PasswordResetViewController()
        let networkManager = NetworkEngine()
        let viewModel = PasswordResetViewModel(network: networkManager)
        viewModel.delegate = viewController
        viewController.viewModel = viewModel
        viewModel.router = router
        viewModel.email = email
        viewModel.passwordResetedCompl = passwordResetedCompl
        return viewController
    }
    
    func createAccountController(router: RootRouter) -> UIViewController? {
        let viewController = AccountViewController()
        let networkManager = NetworkEngine()
        let viewModel = AccountViewModel(network: networkManager)
        viewModel.delegate = viewController
        viewController.viewModel = viewModel
        viewModel.router = router
        return viewController
    }
    
    func createPasswordExpiredController(router: RootRouter) -> UIViewController? {
        let viewController = PasswordExpiredViewController()
        let viewModel = PasswordExpiredViewModel()
        viewModel.delegate = viewController
        viewController.viewModel = viewModel
        viewModel.router = router
        return viewController
    }
    
    func createEnterNewPasswordController(router: RootRouter) -> UIViewController? {
        let viewController = EnterNewPasswordViewController()
        let networkManager = NetworkEngine()
        let viewModel = EnterNewPasswordViewModel(network: networkManager)
        viewModel.delegate = viewController
        viewController.viewModel = viewModel
        viewModel.router = router
        return viewController
    }
    
    func createPaywallController() -> UIViewController {
        return PaywallViewController()
    }
    
    func createAlternativePaywallController(isHard: Bool) -> UIViewController {
        let controller = AlternativePaywallViewController()
        controller.isHardPaywall = isHard
        return controller
    }
    
    func createUpdatedPaywallController(isHard: Bool) -> UIViewController {
        let controller = UpdatedPaywallViewController()
        controller.isHardPaywall = isHard
        return controller
    }
    
    func createNewPaywallController(isTrial: Bool, isHard: Bool) -> UIViewController {
        let controller = NewPaywallViewController(isTrial: isTrial)
        controller.isHardPaywall = isHard
        return controller
    }
    
    func createReviewsController(router: RootRouter) -> UIViewController {
        return OnboardingReviewController(router: router)
    }
    
    func createActivityController(image: [Any]) -> UIViewController? {
        let viewController = UIActivityViewController(activityItems: image, applicationActivities: nil)
        return viewController
    }
    
    func createPrintController(image: UIImage) -> UIPrintInteractionController? {
        let information = UIPrintInfo(dictionary: nil)
        information.outputType = UIPrintInfo.OutputType.general
        information.jobName = "Grocery List".localized
       
        let viewController = UIPrintInteractionController.shared
        viewController.printInfo = information
        viewController.printingItem = image
        return viewController
    }
    
    func createAlertController(title: String, message: String,
                               _ completion: (() -> Void)? = nil) -> UIAlertController? {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ok", style: .default) { _ in
            completion?()
        }
        
        alert.addAction(alertAction)
        return alert
    }
    
    private func createNavigationViewController(controller: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.isNavigationBarHidden = true
        return navigationController
    }
    
    func createRecipesListController(for section: RecipeSectionsModel, with router: RootRouter) -> UIViewController {
        let viewModel = RecipesListViewModel(with: section)
        viewModel.router = router
        let recipeListVC = RecipesListViewController(viewModel: viewModel)
        return recipeListVC
    }
    
    func createSharingPopUpController(router: RootRouter,
                                      compl: (() -> Void)? = nil) -> UIViewController {
        let viewController = SharingPopUpViewController()
        viewController.router = router
        viewController.registerComp = compl
        return viewController
    }
    
    func createSharingListController(router: RootRouter,
                                     pantryToShare: PantryModel? = nil,
                                     listToShare: GroceryListsModel? = nil,
                                     users: [User]) -> UIViewController {
        let viewController = SharingListViewController()
        let networkManager = NetworkEngine()
        let viewModel = SharingListViewModel(network: networkManager, users: users)
        viewModel.router = router
        viewModel.listToShareModel = listToShare
        viewModel.pantryToShareModel = pantryToShare
        viewModel.delegate = viewController
        viewController.viewModel = viewModel
        return viewController
    }
    
    func createCreateNewRecipeViewController(currentRecipe: Recipe?, router: RootRouter,
                                             compl: @escaping (Recipe) -> Void) -> UIViewController {
        let viewController = CreateNewRecipeStepOneViewController()
        let viewModel = CreateNewRecipeStepOneViewModel(currentRecipe: currentRecipe)
        viewModel.router = router
        viewModel.competeRecipe = compl
        viewController.viewModel = viewModel
        return viewController
    }
    
    func createCreateNewRecipeStepTwoViewController(router: RootRouter, isDraftRecipe: Bool,
                                                    currentRecipe: Recipe?, recipe: Recipe,
                                                    compl: @escaping (Recipe) -> Void,
                                                    backToOneStep: ((Bool, Recipe?) -> Void)?) -> UIViewController {
        let viewController = CreateNewRecipeStepTwoViewController()
        let viewModel = CreateNewRecipeStepTwoViewModel(currentRecipe: currentRecipe, recipe: recipe)
        viewModel.router = router
        viewModel.compete = compl
        viewModel.isDraftRecipe = isDraftRecipe
        viewModel.backToOneStep = backToOneStep
        viewController.viewModel = viewModel
        return viewController
    }
    
    func createPreparationStepViewController(stepNumber: Int, compl: @escaping (String) -> Void) -> UIViewController {
        let viewController = PreparationStepViewController()
        let viewModel = PreparationStepViewModel(stepNumber: stepNumber)
        viewModel.stepCallback = compl
        viewController.viewModel = viewModel
        return viewController
    }
    
    func createCreateNewCollectionViewController(currentCollection: CollectionModel?,
                                                 collections: [CollectionModel] = [],
                                                 compl: @escaping (CollectionModel) -> Void) -> UIViewController {
        let viewController = CreateNewCollectionViewController()
        let viewModel = CreateNewCollectionViewModel(currentCollection: currentCollection)
        viewModel.updateUICallBack = compl
        viewModel.editCollections = collections
        viewController.viewModel = viewModel
        return viewController
    }
    
    func createShowCollectionViewController(router: RootRouter,
                                            state: ShowCollectionViewController.ShowCollectionState,
                                            recipe: Recipe?, updateUI: (() -> Void)?,
                                            compl: (([CollectionModel]) -> Void)?) -> UIViewController {
        let viewController = ShowCollectionViewController()
        let viewModel = ShowCollectionViewModel(state: state, recipe: recipe)
        viewModel.router = router
        viewModel.selectedCollection = compl
        viewModel.updateUI = updateUI
        viewController.viewModel = viewModel
        return viewController
    }
    
    func createIngredientViewController(isShowCost: Bool, currentIngredient: Ingredient?, router: RootRouter,
                                        compl: @escaping (Ingredient) -> Void) -> UIViewController {
        let viewModel = IngredientViewModel()
        viewModel.router = router
        viewModel.ingredientCallback = compl
        viewModel.isShowCost = isShowCost
        viewModel.currentIngredient = currentIngredient
        let viewController = IngredientViewController(viewModel: viewModel)
        return viewController
    }
    
    func createSearchInList(router: RootRouter) -> UIViewController {
        let viewController = SearchInListViewController()
        let viewModel = SearchInListViewModel()
        viewModel.router = router
        viewController.viewModel = viewModel
        return viewController
    }
    
    func createSearchInRecipe(router: RootRouter, section: RecipeSectionsModel?) -> UIViewController {
        let viewController = SearchInRecipeViewController()
        let viewModel = SearchInRecipeViewModel(section: section)
        viewModel.router = router
        viewController.viewModel = viewModel
        return viewController
    }
    
    func createRecipeScreen(router: RootRouter, recipe: Recipe,
                            sectionColor: Theme?, fromSearch: Bool,
                            removeRecipe: ((Recipe) -> Void)?) -> UIViewController {
        let viewModel = RecipeScreenViewModel(recipe: recipe, sectionColor: sectionColor)
        viewModel.router = router
        viewModel.updateRecipeRemove = removeRecipe
        viewModel.fromSearch = fromSearch
        let backButtonTitle = sectionColor != nil ? R.string.localizable.back() : R.string.localizable.search()
        let viewController = RecipeViewController(with: viewModel,
                                                  backButtonTitle: backButtonTitle)
        return viewController
    }
    
    func createEditSelectListController(router: RootRouter, products: [Product], contentViewHeigh: CGFloat,
                                        delegate: EditSelectListDelegate,
                                        state: EditListState) -> UIViewController {
        let viewController = EditSelectListViewController(with: products, state: state)
        let dataSource = SelectListDataManager()
        let viewModel = SelectListViewModel(dataSource: dataSource)
        viewModel.router = router
        viewController.contentViewHeigh = contentViewHeigh
        viewController.viewModel = viewModel
        viewController.delegate = delegate
        return viewController
    }
    
    func createNewStoreController(router: RootRouter, model: GroceryListsModel?,
                                  compl: @escaping (Store?) -> Void) -> UIViewController {
        let viewController = CreateNewStoreViewController()
        let viewModel = CreateNewStoreViewModel(model: model, newModelInd: -1)
        viewModel.storeCreatedCallBack = compl
        viewController.viewModel = viewModel
        viewController.storeViewModel = viewModel
        viewModel.delegate = viewController
        viewModel.router = router
        return viewController
    }
    
    func createProductsSortController(model: GroceryListsModel, productType: ProductsSortViewModel.ProductType,
                                      updateModel: ((GroceryListsModel) -> Void)?,
                                      router: RootRouter) -> UIViewController {
        let viewController = ProductsSortViewController()
        let viewModel = ProductsSortViewModel(model: model, productType: productType)
        viewModel.router = router
        viewModel.delegate = viewController
        viewModel.updateModel = updateModel
        viewController.viewModel = viewModel
        return viewController
    }
    
    func createFeedbackController(router: RootRouter) -> UIViewController {
        let viewController = FeedbackViewController()
        let viewModel = FeedbackViewModel()
        viewModel.router = router
        viewController.viewModel = viewModel
        return viewController
    }
    
    func createPantryStarterPackController() -> UIViewController {
        return PantryStarterPackViewController()
    }
    
    func createCreateNewPantryController(currentPantry: PantryModel?, updateUI: @escaping ((PantryModel?) -> Void),
                                         router: RootRouter) -> UIViewController {
        let viewModel = CreateNewPantryViewModel(currentPantry: currentPantry)
        viewModel.router = router
        viewModel.updateUI = updateUI
        let viewController = CreateNewPantryViewController(viewModel: viewModel)
        return viewController
    }
    
    func createAllIcons(icon: UIImage?,
                        selectedTheme: Theme,
                        selectedIcon: ((UIImage?) -> Void)?) -> UIViewController {
        let selectIconViewController = SelectIconViewController()
        selectIconViewController.icon = icon
        selectIconViewController.updateColor(theme: selectedTheme)
        selectIconViewController.selectedIcon = selectedIcon
        
        selectIconViewController.modalPresentationStyle = .overCurrentContext
        selectIconViewController.modalTransitionStyle = .crossDissolve
        return selectIconViewController
    }
    
    func createSelectList(contentViewHeigh: Double,
                          synchronizedLists: [UUID],
                          updateUI: (([UUID]) -> Void)?) -> UIViewController {
        let dataSource = SelectListDataManager()
        let viewModel = SelectListViewModel(dataSource: dataSource)
        let selectListToSynchronize = SelectListToSynchronizeViewController()
        selectListToSynchronize.viewModel = viewModel
        selectListToSynchronize.contentViewHeigh = contentViewHeigh
        selectListToSynchronize.selectedModelIds = Set(synchronizedLists)
        selectListToSynchronize.updateUI = updateUI
        
        return selectListToSynchronize
    }
    
    func createStocksController(pantry: PantryModel, router: RootRouter) -> UIViewController {
        let dataSource = StocksDataSource(pantryId: pantry.id)
        let viewModel = StocksViewModel(dataSource: dataSource, pantry: pantry)
        viewModel.router = router
        let viewController = StocksViewController(viewModel: viewModel)
        return viewController
    }
    
    func createPantryListOptionsController(pantry: PantryModel, snapshot: UIImage?, listByText: String,
                                           updateUI: ((PantryModel) -> Void)?,
                                           editCallback: ((ProductsSettingsViewModel.TableViewContent) -> Void)?,
                                           router: RootRouter) -> UIViewController {
        let viewModel = PantryListOptionViewModel(pantry: pantry, snapshot: snapshot, listByText: listByText)
        viewModel.router = router
        viewModel.updateUI = updateUI
        viewModel.editCallback = editCallback
        let controller = PantryListOptionViewController(viewModel: viewModel)
        
        return controller
    }
    
    func createCreateNewStockController(pantry: PantryModel, stock: Stock? = nil,
                                        compl: @escaping (Stock) -> Void,
                                        router: RootRouter) -> UIViewController {
        let viewModel = CreateNewStockViewModel(pantry: pantry)
        viewModel.updateUI = compl
        viewModel.router = router
        viewModel.currentStock = stock
        
        let viewController = CreateNewStockViewController(viewModel: viewModel)
        return viewController
    }
    
    func createEditSelectPantryListController(router: RootRouter, stocks: [Stock], contentViewHeigh: CGFloat,
                                              delegate: EditSelectListDelegate,
                                              state: EditListState) -> UIViewController {
        let dataSource = PantryDataSource()
        let viewModel = SelectPantryListViewModel(dataSource: dataSource, copiedStocks: stocks, state: state)
        viewModel.router = router
        let viewController = SelectPantryListViewController(viewModel: viewModel, contentViewHeigh: contentViewHeigh)
        viewController.delegate = delegate
        return viewController
    }
    
    func createStockReminderController(outOfStocks: [Stock], updateUI: (() -> Void)?,
                                       router: RootRouter) -> UIViewController {
        let dataSource = StockReminderDataSource(outOfStocks: outOfStocks)
        let viewModel = StockReminderViewModel(dataSource: dataSource)
        viewModel.router = router
        viewModel.updateUI = updateUI
        let viewController = StockReminderViewController(viewModel: viewModel)
        return viewController
    }
    
    func createImportWebRecipeController(router: RootRouter) -> UIViewController {
        let viewModel = ImportWebRecipesViewModel()
        viewModel.router = router
        let controller = ImportWebRecipesViewController(viewModel: viewModel)
        return controller
    }
}

class MyNavigationController: UINavigationController {
    override var childForStatusBarStyle: UIViewController? {
        topViewController
    }
}
