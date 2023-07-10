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
    
    func addFilter(by index: IndexPath) {
        guard let filter = RecipeFilter(rawValue: index.section),
              let tag = allFilters[safe: index.section]?.tags[safe: index.row] else {
            return
        }
        
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
        selectedFilters?([Filter(filter: .exception, tags: exceptionFilter),
                          Filter(filter: .diet, tags: dietFilter),
                          Filter(filter: .typeOfDish, tags: typeOfDishFilter),
                          Filter(filter: .cookingMethod, tags: cookingMethodFilter),
                          Filter(filter: .caloriesPerServing, tags: caloriesPerServingFilter),
                          Filter(filter: .cookingTime, tags: cookingTimeFilter),
                          Filter(filter: .quantityOfIngredients, tags: quantityOfIngredientsFilter)])
        
    }
}
