//
//  RecipeScreenViewModel.swift
//  GroceryList
//
//  Created by Vladimir Banushkin on 11.12.2022.
//

import Foundation
import Kingfisher

protocol RecipeScreenViewModelProtocol {
    var updateCollection: (() -> Void)? { get set }
    var recipe: Recipe { get }
    var theme: Theme { get set }
    var fromSearch: Bool { get set }
    
    func getNumberOfIngredients() -> Int
    func getRecipeTitle() -> String
    func getIngredientsSizeAccordingToServings(servings: Double) -> [String]
    func getContentInsetHeight() -> CGFloat
    func unit(unitID: Int?) -> UnitSystem?
    func convertValue() -> Double
    func haveCollections() -> Bool
    func showCollection()
    func updateFavoriteState(isSelected: Bool)
    func addToShoppingList(contentViewHeigh: CGFloat, photo: [Data?], delegate: AddProductsSelectionListDelegate)
    func addToCollection()
    func edit()
    func removeRecipe()
    func getStoreAndCost(by index: Int) -> (store: String?, cost: Double?)
    func showPaywall()
}

final class RecipeScreenViewModel {
    
    enum RecipeUnit: Int {
        case gram = 1
        case ozz = 2
        case millilitre = 14
    }
    
    weak var router: RootRouter?
    
    var updateCollection: (() -> Void)?
    var updateRecipeRemove: ((Recipe) -> Void)?
    var theme: Theme
    var fromSearch = false
    private(set) var recipe: Recipe
    private var isMetricSystem = UserDefaultsManager.shared.isMetricSystem
    private var recipeUnit: RecipeUnit?
    private var sectionColor: Theme?
    
    init(recipe: Recipe, sectionColor: Theme?) {
        self.recipe = recipe
        self.sectionColor = sectionColor
        theme = sectionColor ?? ColorManager.shared.getColorForRecipe()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateRecipe),
                                               name: .recipesDownloadedAndSaved,
                                               object: nil)
    }
}

extension RecipeScreenViewModel: RecipeScreenViewModelProtocol {
    func getNumberOfIngredients() -> Int {
        recipe.ingredients.count
    }
    
    func getRecipeTitle() -> String {
        recipe.title
    }
    
    func getContentInsetHeight() -> CGFloat {
        if recipe.title.count > 20 {
           return 166
        } else {
            return 136
        }
    }
    
    func getStoreAndCost(by index: Int) -> (store: String?, cost: Double?) {
        let product = recipe.ingredients[safe: index]?.product
        return (product?.store?.title, product?.cost)
    }
    
    func getIngredientsSizeAccordingToServings(servings: Double) -> [String] {
        var titles: [String] = []
        let totalServings = recipe.totalServings <= 0 ? 1 : Double(recipe.totalServings)
        for ingredient in recipe.ingredients {
            let defaultValue = ingredient.quantity / totalServings
            var targetValue = defaultValue * servings
            var unitTitle = ingredient.unit?.shortTitle ?? ""
            if let unit = unit(unitID: ingredient.unit?.id) {
                targetValue *= convertValue()
                unitTitle = unit.title
            }
            
            let unitName = unitTitle
            let title: String
            if targetValue != 0 {
                title = String(format: "%.\(targetValue.truncatingRemainder(dividingBy: 1) > 0 ? 1 : 0)f", targetValue) + " " + unitName
            } else {
                title = R.string.localizable.byTaste()
            }
            
            titles.append(title)
        }
        return titles
    }
    
    func unit(unitID: Int?) -> UnitSystem? {
        guard let unitID = unitID,
              let shouldSelectUnit: RecipeUnit = .init(rawValue: unitID) else {
            return nil
        }
        recipeUnit = shouldSelectUnit
        switch shouldSelectUnit {
        case .gram, .ozz:
            return isMetricSystem ? .gram : .ozz
        case .millilitre:
            return isMetricSystem ? .mililiter : .fluidOz
        }
    }
    
    func convertValue() -> Double {
        switch recipeUnit {
        case .gram:
            return isMetricSystem ? 1 : UnitSystem.gram.convertValue
        case .ozz:
            return isMetricSystem ? UnitSystem.ozz.convertValue : 1
        case .millilitre:
            return isMetricSystem ? 1 : UnitSystem.mililiter.convertValue
        case .none: return 0
        }
    }
    
    func haveCollections() -> Bool {
        guard let collection = CoreDataManager.shared.getAllCollection()?.compactMap({ CollectionModel(from: $0) }) else {
            return false
        }
        return recipe.localCollection?.contains(where: { recipeCollection in
            collection.contains(where: { $0.id == recipeCollection.id })
        }) ?? false
    }
    
    func showCollection() {
        router?.goToShowCollection(state: .select, recipe: recipe, updateUI: { [weak self] in
            self?.updateCollection?()
        })
    }
    
    func updateFavoriteState(isSelected: Bool) {
        guard let dbCollection = CoreDataManager.shared.getCollection(by: EatingTime.favorites.rawValue) else {
            return
        }
        let favoriteCollection = CollectionModel(from: dbCollection)
        
        if isSelected {
            AmplitudeManager.shared.logEvent(.recipeAddFavorites)
            UserDefaultsManager.shared.favoritesRecipeIds.append(recipe.id)
            CloudManager.shared.saveCloudSettings()
        } else {
            UserDefaultsManager.shared.favoritesRecipeIds.removeAll(where: { $0 == recipe.id })
            CloudManager.shared.saveCloudSettings()
        }

        if var localCollection = recipe.localCollection {
            if isSelected {
                localCollection.append(favoriteCollection)
            } else {
                localCollection.removeAll { $0.id == favoriteCollection.id }
            }
            recipe.localCollection = localCollection
        }
        
        CoreDataManager.shared.saveRecipes(recipes: [recipe])
        CloudManager.shared.saveCloudData(recipe: recipe)
    }
    
    @objc
    private func updateRecipe() {
        DispatchQueue.main.async {
            guard let dbRecipe = CoreDataManager.shared.getRecipe(by: self.recipe.id),
                  let updateRecipe = Recipe(from: dbRecipe) else {
                return
            }
            
            self.recipe = updateRecipe
        }
      
    }
    
    func addToShoppingList(contentViewHeigh: CGFloat, photo: [Data?], delegate: AddProductsSelectionListDelegate) {
        let recipeTitle = recipe.title
        let products: [Product] = recipe.ingredients.enumerated().map({ index, ingredient in
            let netProduct = ingredient.product
            let product = Product(
                name: netProduct.title,
                isPurchased: false,
                dateOfCreation: Date(),
                category: netProduct.marketCategory?.title ?? "",
                isFavorite: false,
                imageData: photo[index],
                description: "",
                fromRecipeTitle: recipeTitle
            )
            return product
        })
        router?.goToAddProductsSelectionList(products: products, contentViewHeigh: contentViewHeigh, delegate: delegate)
    }
    
    func addToCollection() {
        router?.goToShowCollection(state: .select, recipe: recipe, updateUI: {
//            self?.updateCollection?()
        })

    }
    
    func edit() {
        router?.goToCreateNewRecipe(currentRecipe: recipe, compl: { [weak self] recipe in
            self?.recipe = recipe
        })
    }
    
    func removeRecipe() {
        CoreDataManager.shared.deleteRecipe(by: recipe.id)
        CloudManager.shared.delete(recordType: .recipe, recordID: recipe.recordId)
        updateRecipeRemove?(recipe)
    }
    
    func showPaywall() {
        router?.showPaywallVC()
    }
}

private extension UnitSystem {
    var convertValue: Double {
        switch self {
        case .ozz: return 28.3495
        case .gram: return 0.035274
        case .mililiter: return 0.033814
        case .fluidOz: return 29.5735
        default: return 1
        }
    }
}
