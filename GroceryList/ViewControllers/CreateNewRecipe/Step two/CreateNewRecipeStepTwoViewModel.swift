//
//  CreateNewRecipeStepTwoViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 03.03.2023.
//

import Foundation

final class CreateNewRecipeStepTwoViewModel {
    
    weak var router: RootRouter?
    private var recipe: CreateNewRecipeStepOne
    
    init(recipe: CreateNewRecipeStepOne) {
        self.recipe = recipe
    }
    
    var recipeTitle: String {
        recipe.title
    }
    
    func back() {
        router?.navigationPopViewController(animated: true)
    }

    func next() {
        
    }
}
