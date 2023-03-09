//
//  IngredientViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 09.03.2023.
//

import Foundation

final class IngredientViewModel {
    
    var ingredientCallback: ((Ingredient) -> Void)?
    
    func save(ingredient: Ingredient) {
        ingredientCallback?(ingredient)
    }
    
}
