//
//  CreateNewRecipeViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 01.03.2023.
//

import UIKit

final class CreateNewRecipeStepOneViewModel {
    
    weak var router: RootRouter?
    var competeRecipe: ((Recipe) -> Void)?
    var preparationStepChanged: ((String) -> Void)?
    var ingredientChanged: ((Ingredient) -> Void)?
    var isDraftRecipe = false
    
    private(set) var currentRecipe: Recipe?
    private var recipe: Recipe?
    private var draft: Recipe?
    private var ingredients: [Ingredient] = []
    private var steps: [String]? = []
    private var isShowCost = false

    init(currentRecipe: Recipe? = nil) {
        self.currentRecipe = currentRecipe
        if let currentRecipe {
            ingredients = currentRecipe.ingredients
            steps = currentRecipe.instructions
        }
    }
    
    func setIsShowCost(_ isShow: Bool) {
        isShowCost = isShow
    }
    
    func updateIngredients(originalIndexes: [Int]) {
        let updatedIngredients = originalIndexes.map { ingredients[$0] }
        ingredients = updatedIngredients
    }
    
    func updateSteps(updatedSteps: [String]) {
        steps = updatedSteps
    }
    
    func removeIngredient(by index: Int) {
        ingredients.remove(at: index)
    }
    
    func back() {
        router?.navigationPopViewController(animated: true)
    }

    func presentIngredient() {
        router?.goToIngredient(isShowCost: isShowCost, compl: { [weak self] ingredient in
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
    
    func next() {
        guard let recipe else {
            return
        }
        router?.goToCreateNewRecipeStepTwo(recipe: recipe,
                                           compl: { [weak self] recipe in
            self?.competeRecipe?(recipe)
        })
    }
    
    func saveRecipe(title: String, description: String?) {
        guard var currentRecipe else {
            recipe = .init(title: title, description: description,
                           ingredients: ingredients, instructions: steps,
                           isShowCost: isShowCost)
            return
        }
        
        if let description {
            currentRecipe.description = description
        }
        
        currentRecipe.title = title
        currentRecipe.ingredients = ingredients
        currentRecipe.instructions = steps
        currentRecipe.isShowCost = isShowCost
        
        recipe = currentRecipe
    }
    
    func savedToDrafts(title: String?, description: String?) {
        guard isDraftRecipe, let title else {
            return
        }
        guard var draft else {
            draft = Recipe(title: title, description: description)
            if let dbDraftsCollection = CoreDataManager.shared.getAllCollection()?
                .first(where: { $0.id == EatingTime.drafts.rawValue }) {
                let draftsCollection = CollectionModel(from: dbDraftsCollection)
                draft?.localCollection = [draftsCollection]
            }
            savedToDrafts(title: title, description: description)
            return
        }

        if let description {
            draft.description = description
        }
        draft.title = title
        draft.ingredients = ingredients
        draft.instructions = steps
        draft.isShowCost = isShowCost
        
        CoreDataManager.shared.saveRecipes(recipes: [draft])
    }
    
    private func saveCurrentRecipe(title: String?, description: String?) {
        guard var currentRecipe else {
            return
        }
        
        if let title {
            currentRecipe.title = title
        }
        
        if let description {
            currentRecipe.description = description
        }
        
        currentRecipe.ingredients = ingredients
        currentRecipe.instructions = steps
        currentRecipe.isShowCost = isShowCost
    }

}
