//
//  RecipeScreenViewModel.swift
//  GroceryList
//
//  Created by Vladimir Banushkin on 11.12.2022.
//

import Foundation

protocol RecipeScreenViewModelProtocol {
    func getNumberOfIngredients() -> Int
    func getRecipeTitle() -> String
    func getIngredientsSizeAccordingToServings(servings: Double) -> [String]
    func getContentInsetHeight() -> CGFloat
    func unit(unitID: Int?) -> UnitSystem?
    func convertValue() -> Double
    func haveCollections() -> Bool
    func showCollection()
    var recipe: Recipe { get }
}

final class RecipeScreenViewModel {
    
    enum RecipeUnit: Int {
        case gram = 1
        case ozz = 2
        case millilitre = 14
    }
    
    weak var router: RootRouter?
    
    private(set) var recipe: Recipe
    private var isMetricSystem = UserDefaultsManager.isMetricSystem
    private var recipeUnit: RecipeUnit?
    
    init(recipe: Recipe) {
        self.recipe = recipe
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateRecipe),
                                               name: .recieptsDownladedAnsSaved,
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
    
    func getIngredientsSizeAccordingToServings(servings: Double) -> [String] {
        var titles: [String] = []
        for ingredient in recipe.ingredients {
            let defaultValue = ingredient.quantity / Double(recipe.totalServings)
            var targetValue = defaultValue * servings
            var unitTitle = ingredient.unit?.shortTitle ?? ""
            if let unit = unit(unitID: ingredient.unit?.id) {
                targetValue *= convertValue()
                unitTitle = unit.rawValue.localized
            }
            
            let unitName = unitTitle
            let title = String(format: "%.\(targetValue.truncatingRemainder(dividingBy: 1) > 0 ? 1 : 0)f", targetValue) + " " + unitName
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
        router?.goToShowCollection(state: .select, recipe: recipe)
    }
    
    @objc
    private func updateRecipe() {
        guard let dbRecipe = CoreDataManager.shared.getRecipe(by: self.recipe.id),
              let updateRecipe = Recipe(from: dbRecipe) else {
            return
        }
        
        self.recipe = updateRecipe
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
