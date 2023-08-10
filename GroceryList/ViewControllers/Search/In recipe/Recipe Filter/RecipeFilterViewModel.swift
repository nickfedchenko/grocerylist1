//
//  RecipeFilterViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 07.07.2023.
//

import UIKit

class RecipeFilterViewModel {
    
    var selectedFilters: (([Filter]) -> Void)?
    var isAllRecipe: Bool = true
    
    let allFilters: [RecipeFilter] = RecipeFilter.allCases
    let theme: Theme

    var borderCellColor: UIColor? {
        isAllRecipe ? R.color.primaryLight() : theme.medium
    }
    
    var selectCellColor: UIColor? {
        isAllRecipe ? R.color.darkGray() : theme.dark
    }
    
    private var exceptionFilter: [RecipeTag] = []
    private var dietFilter: [RecipeTag] = []
    private var typeOfDishFilter: [RecipeTag] = []
    private var cookingMethodFilter: [RecipeTag] = []
    private var caloriesPerServingFilter: [RecipeTag] = []
    private var cookingTimeFilter: [RecipeTag] = []
    private var quantityOfIngredientsFilter: [RecipeTag] = []
    
    init(theme: Theme?) {
        self.theme = theme ?? ColorManager.shared.getColorForRecipe()
    }
    
    func isSelectFilter(by index: IndexPath) -> Bool {
        guard let filter = RecipeFilter(rawValue: index.section),
              let tag = allFilters[safe: index.section]?.tags[safe: index.row] else {
            return false
        }
        
        switch filter {
        case .exception:                return exceptionFilter.contains { $0.id == tag.id }
        case .diet:                     return dietFilter.contains { $0.id == tag.id }
        case .typeOfDish:               return typeOfDishFilter.contains { $0.id == tag.id }
        case .cookingMethod:            return cookingMethodFilter.contains { $0.id == tag.id }
        case .caloriesPerServing:       return caloriesPerServingFilter.contains { $0.id == tag.id }
        case .cookingTime:              return cookingTimeFilter.contains { $0.id == tag.id }
        case .quantityOfIngredients:    return quantityOfIngredientsFilter.contains { $0.id == tag.id }
        }
    }
    
    func addFilter(by index: IndexPath) {
        guard let filter = RecipeFilter(rawValue: index.section),
              let tag = allFilters[safe: index.section]?.tags[safe: index.row] else {
            return
        }
        
        var editFilters = getEditFilters(filter: filter)
        
        if editFilters.contains(where: { $0.id == tag.id }) {
            editFilters.removeAll { $0.id == tag.id }
        } else {
            editFilters.append(tag)
        }
        
        switch filter {
        case .exception:                exceptionFilter = editFilters
        case .diet:                     dietFilter = editFilters
        case .typeOfDish:               typeOfDishFilter = editFilters
        case .cookingMethod:            cookingMethodFilter = editFilters
        case .caloriesPerServing:       caloriesPerServingFilter = editFilters
        case .cookingTime:              cookingTimeFilter = editFilters
        case .quantityOfIngredients:    quantityOfIngredientsFilter = editFilters
        }
    }
    
    func popController() {
        let filters = [Filter(filter: .exception, tags: exceptionFilter),
                       Filter(filter: .diet, tags: dietFilter),
                       Filter(filter: .typeOfDish, tags: typeOfDishFilter),
                       Filter(filter: .cookingMethod, tags: cookingMethodFilter),
                       Filter(filter: .caloriesPerServing, tags: caloriesPerServingFilter),
                       Filter(filter: .cookingTime, tags: cookingTimeFilter),
                       Filter(filter: .quantityOfIngredients, tags: quantityOfIngredientsFilter)]
        selectedFilters?(filters)
        
        filters.forEach {
            $0.tags.forEach { tag in
                AmplitudeManager.shared.logEvent(.recipeSelectFilter, properties: [.filterName: tag.title])
            }
        }
    }
    
    private func getEditFilters(filter: RecipeFilter) -> [RecipeTag] {
        var editFilters: [RecipeTag]
        switch filter {
        case .exception:                editFilters = exceptionFilter
        case .diet:                     editFilters = dietFilter
        case .typeOfDish:               editFilters = typeOfDishFilter
        case .cookingMethod:            editFilters = cookingMethodFilter
        case .caloriesPerServing:       editFilters = caloriesPerServingFilter
        case .cookingTime:              editFilters = cookingTimeFilter
        case .quantityOfIngredients:    editFilters = quantityOfIngredientsFilter
        }
        return editFilters
    }
}
