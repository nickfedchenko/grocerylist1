//
//  ViewControllerFactoryProtocol.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 18.05.2023.
//

import UIKit

protocol ViewControllerFactoryProtocol {
    func createOnboardingController(router: RootRouter) -> UIViewController?
    func createPaywallController() -> UIViewController?
    func createAlternativePaywallController() -> UIViewController?
    
    func createMainTabBarController(router: RootRouter, controllers: [UIViewController]) -> UITabBarController
    func createListController(router: RootRouter) -> UIViewController
    func createPantryController(router: RootRouter) -> UIViewController
    func createRecipeController(router: RootRouter) -> UIViewController
    
    func createCreateNewListController(model: GroceryListsModel?, router: RootRouter,
                                       compl: @escaping (GroceryListsModel, [Product]) -> Void) -> UIViewController?
    func createProductsController(model: GroceryListsModel, router: RootRouter,
                                  compl: @escaping () -> Void) -> UIViewController?
    func createProductsSettingsController(snapshot: UIImage?, listByText: String,
                                          model: GroceryListsModel, router: RootRouter,
                                          compl: @escaping (GroceryListsModel, [Product]) -> Void,
                                          editCompl: ((ProductsSettingsViewModel.TableViewContent) -> Void)?) -> UIViewController?
    
    func createActivityController(image: [Any]) -> UIViewController?
    func createPrintController(image: UIImage) -> UIPrintInteractionController?
    func createAlertController(title: String, message: String, _ completion: (() -> Void)?) -> UIAlertController?
    func createSelectListController(height: Double, router: RootRouter, setOfSelectedProd: Set<Product>,
                                    compl: @escaping (Set<Product>) -> Void) -> UIViewController?
    func createSelectProductsController(height: Double, model: GroceryListsModel,
                                        setOfSelectedProd: Set<Product>, router: RootRouter,
                                        compl: @escaping (Set<Product>) -> Void) -> UIViewController?
    func createCreateNewProductController(model: GroceryListsModel?, product: Product?,
                                          router: RootRouter, compl: @escaping (Product) -> Void) -> UIViewController?
    func createSelectCategoryController(model: GroceryListsModel?, router: RootRouter,
                                        compl: @escaping (String) -> Void) -> UIViewController?
    func createCreateNewCategoryController(model: GroceryListsModel?, newCategoryInd: Int,
                                           router: RootRouter, compl: @escaping (CategoryModel) -> Void) -> UIViewController?
    func createSettingsController(router: RootRouter) -> UIViewController?

    func createRecipesListController(for section: RecipeSectionsModel, with router: RootRouter) -> UIViewController
    func createReviewsController(router: RootRouter) -> UIViewController
    func createReviewController(router: RootRouter) -> UIViewController?
    func createSignUpController(router: RootRouter, isFromResetPassword: Bool) -> UIViewController?
    func createPasswordResetController(router: RootRouter, email: String,
                                       passwordResetedCompl: (() -> Void)?) -> UIViewController?
    func createAccountController(router: RootRouter) -> UIViewController?
    func createPasswordExpiredController(router: RootRouter) -> UIViewController?
    func createEnterNewPasswordController(router: RootRouter) -> UIViewController?
    func createSharingPopUpController(router: RootRouter, compl: (() -> Void)?) -> UIViewController
    func createSharingListController(router: RootRouter,
                                     pantryToShare: PantryModel?,
                                     listToShare: GroceryListsModel?,
                                     users: [User]) -> UIViewController
    func createCreateNewRecipeViewController(currentRecipe: Recipe?,
                                             router: RootRouter,
                                             compl: @escaping (Recipe) -> Void) -> UIViewController
    func createCreateNewRecipeStepTwoViewController(router: RootRouter, recipe: Recipe,
                                                    compl: @escaping (Recipe) -> Void) -> UIViewController
    func createPreparationStepViewController(stepNumber: Int, compl: @escaping (String) -> Void) -> UIViewController
    func createCreateNewCollectionViewController(currentCollection: CollectionModel?,
                                                 collections: [CollectionModel],
                                                 compl: @escaping (CollectionModel) -> Void) -> UIViewController
    func createShowCollectionViewController(router: RootRouter, state: ShowCollectionViewController.ShowCollectionState,
                                            recipe: Recipe?, updateUI: (() -> Void)?,
                                            compl: (([CollectionModel]) -> Void)?) -> UIViewController
    func createIngredientViewController(router: RootRouter, compl: @escaping (Ingredient) -> Void) -> UIViewController
    func createSearchInList(router: RootRouter) -> UIViewController
    func createSearchInRecipe(router: RootRouter, section: RecipeSectionsModel?) -> UIViewController
    func createRecipeScreen(router: RootRouter, recipe: Recipe) -> UIViewController
    func createEditSelectListController(router: RootRouter, products: [Product], contentViewHeigh: CGFloat,
                                        delegate: EditSelectListDelegate,
                                        state: EditListState) -> UIViewController
    func createNewStoreController(router: RootRouter, model: GroceryListsModel?,
                                  compl: @escaping (Store?) -> Void) -> UIViewController
    func createProductsSortController(model: GroceryListsModel, productType: ProductsSortViewModel.ProductType,
                                      updateModel: ((GroceryListsModel) -> Void)?, router: RootRouter) -> UIViewController
    func createFeedbackController(router: RootRouter) -> UIViewController
    func createPantryStarterPackController() -> UIViewController
    func createCreateNewPantryController(currentPantry: PantryModel?, updateUI: @escaping ((PantryModel?) -> Void),
                                         router: RootRouter) -> UIViewController
    func createAllIcons(icon: UIImage?,
                        selectedTheme: Theme,
                        selectedIcon: ((UIImage?) -> Void)?) -> UIViewController
    func createSelectList(contentViewHeigh: Double,
                          synchronizedLists: [UUID],
                          updateUI: (([UUID]) -> Void)?) -> UIViewController
    func createStocksController(pantry: PantryModel, router: RootRouter) -> UIViewController
    func createPantryListOptionsController(pantry: PantryModel, snapshot: UIImage?, listByText: String,
                                           updateUI: ((PantryModel) -> Void)?,
                                           editCallback: ((ProductsSettingsViewModel.TableViewContent) -> Void)?,
                                           router: RootRouter) -> UIViewController
    func createCreateNewStockController(pantry: PantryModel, stock: Stock?,
                                        compl: @escaping (Stock) -> Void,
                                        router: RootRouter) -> UIViewController
    func createEditSelectPantryListController(router: RootRouter, stocks: [Stock], contentViewHeigh: CGFloat,
                                              delegate: EditSelectListDelegate,
                                              state: EditListState) -> UIViewController
    func createStockReminderController(outOfStocks: [Stock], updateUI: (() -> Void)?,
                                       router: RootRouter) -> UIViewController
}
