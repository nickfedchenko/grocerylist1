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
    func getIngredientsSizeAccordingToServings(servings: Int) -> [String]
    func getContentInsetHeight() -> CGFloat
    var recipe: Recipe { get }
}

final class RecipeScreenViewModel {
    private(set) var recipe: Recipe
    
    init(recipe: Recipe) {
        self.recipe = recipe
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
    
    func getIngredientsSizeAccordingToServings(servings: Int) -> [String] {
        var titles: [String] = []
        for ingredient in recipe.ingredients {
            let defaultValue = ingredient.quantity / Double(recipe.totalServings)
            let targetValue = defaultValue * Double(servings)
            let unitName = ingredient.unit?.title ?? ""
            let title = String(format: "%.\(targetValue.truncatingRemainder(dividingBy: 1) > 0 ? 1 : 0)f", targetValue) + " " + unitName
            titles.append(title)
        }
        return titles
    }
}
