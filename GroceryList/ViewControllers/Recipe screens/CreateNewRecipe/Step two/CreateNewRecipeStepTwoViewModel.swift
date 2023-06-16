//
//  CreateNewRecipeStepTwoViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 03.03.2023.
//

import Foundation

final class CreateNewRecipeStepTwoViewModel {
    
    weak var router: RootRouter?
    var preparationStepChanged: ((String) -> Void)?
    var ingredientChanged: ((Ingredient) -> Void)?
    var compete: ((Recipe) -> Void)?
    
    private var recipeStepOne: CreateNewRecipeStepOne
    private var ingredients: [Ingredient] = []
    private var steps: [String]? = []
    private var recipe: Recipe?
    
    init(recipe: CreateNewRecipeStepOne) {
        self.recipeStepOne = recipe
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateRecipe),
                                               name: .recieptsDownladedAnsSaved,
                                               object: nil)
    }
    
    var recipeTitle: String {
        recipeStepOne.title
    }
    
    func back() {
        router?.navigationPopViewController(animated: true)
    }

    func presentIngredient() {
        router?.goToIngredient(compl: { [weak self] ingredient in
            self?.ingredients.append(ingredient)
            self?.ingredientChanged?(ingredient)
        })
    }
    
    func presentPreparationStep(stepNumber: Int) {
        router?.goToPreparationStep(stepNumber: stepNumber) { [weak self] step in
            self?.steps?.append(step)
            self?.preparationStepChanged?(step)
        }
    }
    
    func saveRecipe(time: Int?, description: String?) {
        guard let recipe = Recipe(title: recipeStepOne.title,
                                  totalServings: recipeStepOne.totalServings,
                                  localCollection: recipeStepOne.collection,
                                  localImage: recipeStepOne.photo?.pngData(),
                                  cookingTime: time,
                                  description: description,
                                  ingredients: ingredients,
                                  instructions: steps) else {
            return
        }
        CoreDataManager.shared.saveRecipes(recipes: [recipe])
        self.recipe = recipe
    }
    
    @objc
    private func updateRecipe() {
        guard let recipe else { return }
        DispatchQueue.main.async { [weak self] in
            self?.compete?(recipe)
            self?.router?.popToRoot()
        }
    }
}
