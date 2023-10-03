//
//  AddIngredientsToListModels.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 02.10.2023.
//

import Foundation

struct AddIngredientsToListHeaderModel: Hashable {
    let id = UUID()
    let title: String
    let date: Date
    let type: AddIngredientsToListType
    let products: [IngredientForMealPlan]
}

struct ShortRecipeForMealPlan {
    let mealPlanDate: Date
    let id: Int
    let title: String
    let createdAt: Date
    var ingredients: [IngredientForMealPlan]
}

struct IngredientForMealPlan: Hashable {
    let id = UUID()
    var ingredient: Ingredient
    var state: IngredientState
    var mealPlanId: UUID
    var stocksId: UUID?
    var listId: UUID?
    let recipeTitle: String
}

enum IngredientState {
    case unselect
    case select
    case purchase
    case inStock
}

enum AddIngredientsToListType {
    case category
    case recipe
}
