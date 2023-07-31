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
    var ingredientChanged: ((Ingredient, Int?) -> Void)?
    var updateSaveToDraftButton: (() -> Void)?
    var isDraftRecipe = false
    
    private(set) var currentRecipe: Recipe?
    private(set) var isShowCost = false
    private var recipe: Recipe?
    private var draft: Recipe?
    private var ingredients: [Ingredient] = []
    private var steps: [String]? = []
    private var isReturn = false

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
    
    func getStoreAndCost(by index: Int) -> (store: String?, cost: Double?) {
        let product = ingredients[safe: index]?.product
        return (product?.store?.title, product?.cost)
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
    
    func showIngredient(by index: Int) {
        let oldIngredient = ingredients[index]
        router?.goToIngredient(isShowCost: isShowCost, currentIngredient: oldIngredient,
                               compl: { [weak self] ingredient in
            self?.ingredients.removeAll(where: { $0.id == oldIngredient.id })
            self?.ingredients.insert(ingredient, at: index)
            self?.ingredientChanged?(ingredient, index)
        })
    }
    
    func back() {
        router?.navigationPopViewController(animated: true)
    }

    func presentIngredient() {
        router?.goToIngredient(isShowCost: isShowCost, compl: { [weak self] ingredient in
            self?.ingredients.append(ingredient)
            self?.ingredientChanged?(ingredient, nil)
        })
    }
    
    func presentPreparationStep(stepNumber: Int) {
        router?.goToPreparationStep(stepNumber: stepNumber) { [weak self] step in
            self?.steps?.append(step)
            self?.preparationStepChanged?(step)
        }
    }
    
    func next() {
        AmplitudeManager.shared.logEvent(.recipeCreateStep2)
        guard let recipe else {
            return
        }
        router?.goToCreateNewRecipeStepTwo(isDraftRecipe: isDraftRecipe,
                                           currentRecipe: currentRecipe,
                                           recipe: recipe, compl: { [weak self] recipe in
            self?.competeRecipe?(recipe)
        }, backToOneStep: { [weak self] isDraftRecipe, recipe in
            self?.isReturn = true
            self?.isDraftRecipe = isDraftRecipe
            if isDraftRecipe {
                self?.updateSaveToDraftButton?()
            }
            self?.recipe = recipe
        })
        
    }
    
    func saveRecipe(title: String, description: String?) {
        guard var currentRecipe else {
            if !isReturn {
                recipe = .init(title: title, description: description,
                               ingredients: ingredients, instructions: steps,
                               isShowCost: isShowCost)
            } else {
                recipe?.title = title
                recipe?.description = description ?? ""
                recipe?.ingredients = ingredients
                recipe?.instructions = steps
                recipe?.isShowCost = isShowCost
            }
            
            return
        }
        
        if let description {
            currentRecipe.description = description
        }
        
        currentRecipe.title = title
        currentRecipe.ingredients = ingredients
        currentRecipe.instructions = steps
        currentRecipe.isShowCost = isShowCost
        
        self.currentRecipe = currentRecipe
        recipe = currentRecipe
    }
    
    func savedToDrafts(title: String?, description: String?) {
        guard isDraftRecipe, let title else {
            return
        }
        AmplitudeManager.shared.logEvent(.recipeSaveToDrafts)
        
        guard var draft else {
            draft = Recipe(title: title, description: description)
            if let dbDraftsCollection = CoreDataManager.shared.getAllCollection()?
                .first(where: { $0.id == EatingTime.drafts.rawValue }),
               let draft {
                var draftsCollection = CollectionModel(from: dbDraftsCollection)
                var dishes = Set(draftsCollection.dishes ?? [])
                dishes.insert(draft.id)
                draftsCollection.dishes = Array(dishes)
                CoreDataManager.shared.saveCollection(collections: [draftsCollection])
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
