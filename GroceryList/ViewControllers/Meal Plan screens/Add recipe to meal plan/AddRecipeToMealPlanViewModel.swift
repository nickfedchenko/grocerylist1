//
//  AddRecipeToMealPlanViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 15.09.2023.
//

import Foundation

class AddRecipeToMealPlanViewModel {
    
    weak var router: RootRouter?
    
    let recipe: Recipe
    let mealPlan: MealPlan?
    var theme: Theme {
        colorManager.colorMealPlan
    }
    
    private let colorManager = ColorManager.shared
    private(set) var labels: [MealPlanLabel] = []
    
    init(recipe: Recipe, mealPlan: MealPlan? = nil) {
        self.recipe = recipe
        self.mealPlan = mealPlan
        
        setDefaultLabels()
    }
    
    func getListName() -> String? {
        guard let listId = mealPlan?.destinationListId,
              let dbList = CoreDataManager.shared.getList(list: listId.uuidString),
              let list = GroceryListsModel(from: dbList) else {
            return nil
        }
        return list.name
    }
    
    private func setDefaultLabels() {
        DefaultLabel.allCases.forEach {
            labels.append(MealPlanLabel(defaultLabel: $0))
        }
    }
}
