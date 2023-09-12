//
//  MealPlanDataSource.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 09.09.2023.
//

import Foundation

class MealPlanDataSource {
    
    private var mealPlan: [MealPlan] = []
    private var labels: [MealPlanLabel] = []
    private var dates: [Date] = []
    
    init() {
        // mock
        let allDBRecipes = CoreDataManager.shared.getAllRecipes() ?? []
        let recipes = allDBRecipes.compactMap { Recipe(from: $0) }
        
        dates = [Date().after(dayCount: -2), Date().after(dayCount: -2), Date(),
                 Date().after(dayCount: 3), Date().after(dayCount: 3), Date().after(dayCount: 3)]
        setDefaultLabels()
        
        dates.forEach {
            if let recipe = recipes.randomElement(),
               let label = labels.randomElement() {
                mealPlan.append(MealPlan(recipeId: recipe.id, date: $0, label: label))
            }
        }
    }
    
    private func setDefaultLabels() {
        DefaultLabel.allCases.forEach {
            labels.append(MealPlanLabel(defaultLabel: $0))
        }
    }
}

enum DefaultLabel: Int, CaseIterable {
    case none
    case breakfast
    case lunch
    case dinner
    case snack
    
    var id: UUID {
        self.rawValue.asUUID
    }
    
    var title: String {
        switch self {
        case .none:         return "none"
        case .breakfast:    return "breakfast"
        case .lunch:        return "lunch"
        case .dinner:       return "dinner"
        case .snack:        return "snack"
        }
    }
    
    var color: Int {
        switch self {
        case .none:         return 0
        case .breakfast:    return 8
        case .lunch:        return 9
        case .dinner:       return 12
        case .snack:        return 1
        }
    }
}
