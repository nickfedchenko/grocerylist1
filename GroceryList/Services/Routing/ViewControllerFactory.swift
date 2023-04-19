//
//  ViewControllerFactory.swift
//  LearnTrading
//
//  Created by Шамиль Моллачиев on 19.10.2022.
//

import UIKit

protocol ViewControllerFactoryProtocol {
    func createOnboardingController(router: RootRouter) -> UIViewController?
    func createMainController(router: RootRouter) -> UIViewController?
    func createCreateNewListController(
        model: GroceryListsModel?,
        router: RootRouter,
        compl: @escaping (GroceryListsModel, [Product]) -> Void
    ) -> UIViewController?
    func createProductsController(
        model: GroceryListsModel,
        router: RootRouter,
        compl: @escaping () -> Void
    ) -> UIViewController?
    func createProductsSettingsController(
        snapshot: UIImage?,
        listByText: String,
        model: GroceryListsModel,
        router: RootRouter,
        compl: @escaping (GroceryListsModel, [Product]) -> Void,
        editCompl: ((ProductsSettingsViewModel.TableViewContent) -> Void)?
    ) -> UIViewController?
    func createActivityController(image: [Any]) -> UIViewController?
    func createPrintController(image: UIImage) -> UIPrintInteractionController?
    func createAlertController(title: String, message: String) -> UIAlertController?
    func createSelectListController(
        height: Double,
        router: RootRouter,
        setOfSelectedProd: Set<Product>,
        compl: @escaping (Set<Product>) -> Void
    ) -> UIViewController?
    func createSelectProductsController(
        height: Double,
        model: GroceryListsModel,
        setOfSelectedProd: Set<Product>,
        router: RootRouter,
        compl: @escaping (Set<Product>) -> Void
    ) -> UIViewController?
    func createCreateNewProductController(
        model: GroceryListsModel?,
        product: Product?,
        router: RootRouter,
        compl: @escaping (Product) -> Void
    )
    -> UIViewController?
    func createSelectCategoryController(
        model: GroceryListsModel?,
        router: RootRouter,
        compl: @escaping (String) -> Void
    ) -> UIViewController?
    func createCreateNewCategoryController(
        model: GroceryListsModel?,
        newCategoryInd: Int,
        router: RootRouter,
        compl: @escaping (CategoryModel) -> Void
    ) -> UIViewController?
    func createSettingsController(router: RootRouter) -> UIViewController?
    func createPaywallController() -> UIViewController?
    func createAlternativePaywallController() -> UIViewController?
    func createRecipesListController(for section: RecipeSectionsModel, with router: RootRouter) -> UIViewController
    func createReviewsController(router: RootRouter) -> UIViewController
    func createReviewController(router: RootRouter) -> UIViewController?
    func createSignUpController(router: RootRouter, isFromResetPassword: Bool) -> UIViewController?
    func createPasswordResetController(router: RootRouter,
                                       email: String,
                                       passwordResetedCompl: (() -> Void)?) -> UIViewController?
    func createAccountController(router: RootRouter) -> UIViewController?
    func createPasswordExpiredController(router: RootRouter) -> UIViewController?
    func createEnterNewPasswordController(router: RootRouter) -> UIViewController?
    func createSharingPopUpController(router: RootRouter,
                                      compl: (() -> Void)?) -> UIViewController
    func createSharingListController(router: RootRouter,
                                     listToShare: GroceryListsModel,
                                     users: [User]) -> UIViewController
    func createCreateNewRecipeViewController(router: RootRouter,
                                             compl: @escaping (Recipe) -> Void) -> UIViewController
    func createCreateNewRecipeStepTwoViewController(router: RootRouter,
                                                    recipe: CreateNewRecipeStepOne,
                                                    compl: @escaping (Recipe) -> Void) -> UIViewController
    func createPreparationStepViewController(stepNumber: Int,
                                             compl: @escaping (String) -> Void) -> UIViewController
    func createCreateNewCollectionViewController(collections: [CollectionModel],
                                                 compl: @escaping ([CollectionModel]) -> Void) -> UIViewController
    func createShowCollectionViewController(router: RootRouter,
                                            state: ShowCollectionViewController.ShowCollectionState,
                                            recipe: Recipe?,
                                            updateUI: (() -> Void)?,
                                            compl: (([CollectionModel]) -> Void)?) -> UIViewController
    func createIngredientViewController(router: RootRouter,
                                        compl: @escaping (Ingredient) -> Void) -> UIViewController
    func createSearchInList(router: RootRouter) -> UIViewController
    func createSearchInRecipe(router: RootRouter, section: RecipeSectionsModel?) -> UIViewController
    func createRecipeScreen(router: RootRouter, recipe: Recipe) -> UIViewController
    func createEditSelectListController(router: RootRouter, products: [Product], contentViewHeigh: CGFloat,
                                        delegate: EditSelectListDelegate,
                                        state: EditSelectListViewController.State) -> UIViewController
    func createNewStoreController(router: RootRouter, model: GroceryListsModel?,
                                  compl: @escaping (Store?) -> Void) -> UIViewController
}

// MARK: - Factory

final class ViewControllerFactory: ViewControllerFactoryProtocol {
    
    func createOnboardingController(router: RootRouter) -> UIViewController? {
        let viewController = OnboardingViewController()
        viewController.router = router
        return viewController
    }
    
    func createMainController(router: RootRouter) -> UIViewController? {
        let viewController = MainScreenViewController()
        let dataSource = MainScreenDataManager()
        let viewModel = MainScreenViewModel(dataSource: dataSource)
        viewController.viewModel = viewModel
        viewModel.router = router
        return viewController
    }
    
    func createCreateNewListController(
        model: GroceryListsModel?, router: RootRouter,
        compl: @escaping (GroceryListsModel, [Product]
        ) -> Void) -> UIViewController? {
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
    
    func createRecipeListViewController(for: SectionModel) {
        
    }
    
    func createCreateNewProductController(
        model: GroceryListsModel?, product: Product? = nil,
        router: RootRouter,
        compl: @escaping (Product) -> Void
    ) -> UIViewController? {
//        let viewController = OldCreateNewProductViewController()
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
    
    func createCreateNewCategoryController(
        model: GroceryListsModel?, newCategoryInd: Int, router: RootRouter,
        compl: @escaping (CategoryModel) -> Void
    ) -> UIViewController? {
        let viewController = CreateNewCategoryViewController()
        let viewModel = CreateNewCategoryViewModel(model: model, newModelInd: newCategoryInd)
        viewModel.categoryCreatedCallBack = compl
        viewController.viewModel = viewModel
        viewModel.delegate = viewController
        viewModel.router = router
        return viewController
    }
    
    func createSelectListController(
        height: Double, router: RootRouter,
        setOfSelectedProd: Set<Product>, compl: @escaping (Set<Product>) -> Void
    ) -> UIViewController? {
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
    
    func createProductsController(
        model: GroceryListsModel, router: RootRouter,
        compl: @escaping () -> Void
    ) -> UIViewController? {
        let viewController = ProductsViewController()
        let dataSource = ProductsDataManager(products: model.products,
                                             typeOfSorting: SortingType(rawValue: model.typeOfSorting) ?? .category,
                                             groceryListId: model.id.uuidString)
        let viewModel = ProductsViewModel(model: model, dataSource: dataSource)
        viewModel.valueChangedCallback = compl
        viewModel.delegate = viewController
        viewController.viewModel = viewModel
        viewModel.router = router
        return viewController
    }
    
    func createSelectProductsController(
        height: Double, model: GroceryListsModel,
        setOfSelectedProd: Set<Product>,
        router: RootRouter,
        compl: @escaping (Set<Product>) -> Void
    ) -> UIViewController? {
        let viewController = SelectProductViewController()
        let viewModel = SelectProductViewModel(model: model, copiedProducts: setOfSelectedProd)
        viewController.viewModel = viewModel
        viewController.contentViewHeigh = height
        viewModel.router = router
        viewModel.delegate = viewController
        viewModel.productsSelectedCompl = compl
        return viewController
    }
    
    func createSelectCategoryController(
        model: GroceryListsModel?,
        router: RootRouter,
        compl: @escaping (String) -> Void
    ) -> UIViewController? {
        let viewController = SelectCategoryViewController()
        let viewModel = SelectCategoryViewModel(model: model)
        viewController.viewModel = viewModel
        viewModel.router = router
        viewModel.delegate = viewController
        viewModel.categorySelectedCallback = compl
        return viewController
    }
    
    func createProductsSettingsController(
        snapshot: UIImage?,
        listByText: String,
        model: GroceryListsModel,
        router: RootRouter,
        compl: @escaping (GroceryListsModel, [Product]) -> Void,
        editCompl: ((ProductsSettingsViewModel.TableViewContent) -> Void)?
    ) -> UIViewController? {
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
    
    func createPasswordResetController(router: RootRouter,
                                       email: String,
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
    
    func createPaywallController() -> UIViewController? {
        let viewController = PaywallViewController()
        return viewController
    }
    
    func createAlternativePaywallController() -> UIViewController? {
        let viewController = AlternativePaywallViewController()
        return viewController
    }
    
    func createReviewsController(router: RootRouter) -> UIViewController {
        let controller = OnboardingReviewController(router: router)
        return controller
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
    
    func createAlertController(title: String, message: String) -> UIAlertController? {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(alertAction)
        return alert
    }
    
    private func createNavigationViewController(controller: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.isNavigationBarHidden = true
        return navigationController
    }
    
    func createRecipesListController(for section: RecipeSectionsModel, with router: RootRouter) -> UIViewController {
        let recipeListVC = RecipesListViewController(with: section)
        recipeListVC.router = router
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
                                     listToShare: GroceryListsModel,
                                     users: [User]) -> UIViewController {
        let viewController = SharingListViewController()
        let networkManager = NetworkEngine()
        let viewModel = SharingListViewModel(network: networkManager, listToShare: listToShare, users: users)
        viewModel.router = router
        viewController.viewModel = viewModel
        viewModel.delegate = viewController
        return viewController
    }
    
    func createCreateNewRecipeViewController(router: RootRouter,
                                             compl: @escaping (Recipe) -> Void) -> UIViewController {
        let viewController = CreateNewRecipeStepOneViewController()
        let viewModel = CreateNewRecipeStepOneViewModel()
        viewModel.router = router
        viewModel.competeRecipe = compl
        viewController.viewModel = viewModel
        return viewController
    }
    
    func createCreateNewRecipeStepTwoViewController(router: RootRouter,
                                                    recipe: CreateNewRecipeStepOne,
                                                    compl: @escaping (Recipe) -> Void) -> UIViewController {
        let viewController = CreateNewRecipeStepTwoViewController()
        let viewModel = CreateNewRecipeStepTwoViewModel(recipe: recipe)
        viewModel.router = router
        viewModel.compete = compl
        viewController.viewModel = viewModel
        return viewController
    }
    
    func createPreparationStepViewController(stepNumber: Int,
                                             compl: @escaping (String) -> Void) -> UIViewController {
        let viewController = PreparationStepViewController()
        let viewModel = PreparationStepViewModel(stepNumber: stepNumber)
        viewModel.stepCallback = compl
        viewController.viewModel = viewModel
        return viewController
    }
    
    func createCreateNewCollectionViewController(collections: [CollectionModel] = [],
                                                 compl: @escaping ([CollectionModel]) -> Void) -> UIViewController {
        let viewController = CreateNewCollectionViewController()
        let viewModel = CreateNewCollectionViewModel()
        viewModel.updateUICallBack = compl
        viewModel.editCollections = collections
        viewController.viewModel = viewModel
        return viewController
    }
    
    func createShowCollectionViewController(router: RootRouter,
                                            state: ShowCollectionViewController.ShowCollectionState,
                                            recipe: Recipe?,
                                            updateUI: (() -> Void)?,
                                            compl: (([CollectionModel]) -> Void)?) -> UIViewController {
        let viewController = ShowCollectionViewController()
        let viewModel = ShowCollectionViewModel(state: state, recipe: recipe)
        viewModel.router = router
        viewModel.selectedCollection = compl
        viewModel.updateUI = updateUI
        viewController.viewModel = viewModel
        return viewController
    }
    
    func createIngredientViewController(router: RootRouter,
                                        compl: @escaping (Ingredient) -> Void) -> UIViewController {
        let viewController = IngredientViewController()
        let viewModel = IngredientViewModel()
        viewModel.router = router
        viewModel.ingredientCallback = compl
        viewController.viewModel = viewModel
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
    
    func createRecipeScreen(router: RootRouter, recipe: Recipe) -> UIViewController {
        let viewModel = RecipeScreenViewModel(recipe: recipe)
        viewModel.router = router
        let viewController = RecipeViewController(with: viewModel,
                                                  backButtonTitle: R.string.localizable.recipes())
        return viewController
    }
    
    func createEditSelectListController(router: RootRouter, products: [Product], contentViewHeigh: CGFloat,
                                        delegate: EditSelectListDelegate,
                                        state: EditSelectListViewController.State) -> UIViewController {
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
}

class MyNavigationController: UINavigationController {
    override var childForStatusBarStyle: UIViewController? {
        topViewController
    }
}
