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
    var preparationStepChanged: ((String) -> Void)?
    var ingredientChanged: ((Ingredient) -> Void)?
    
    init(recipe: CreateNewRecipeStepOne) {
        self.recipe = recipe
    }
    
    var recipeTitle: String {
        recipe.title
    }
    
    func back() {
        router?.navigationPopViewController(animated: true)
    }

    func presentIngredient() {
        router?.goToIngredient()
    }
    
    func presentPreparationStep(stepNumber: Int) {
        router?.goToPreparationStep(stepNumber: stepNumber) { [weak self] step in
            self?.preparationStepChanged?(step)
        }
    }
    
    func next() {
        
    }
}
