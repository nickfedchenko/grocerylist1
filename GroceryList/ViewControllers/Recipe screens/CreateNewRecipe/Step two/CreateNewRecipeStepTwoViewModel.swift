//
//  CreateNewRecipeStepTwoViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 03.03.2023.
//

import UIKit

final class CreateNewRecipeStepTwoViewModel {
    
    weak var router: RootRouter?
    var preparationStepChanged: ((String) -> Void)?
    var ingredientChanged: ((Ingredient) -> Void)?
    var compete: ((Recipe) -> Void)?
    var isDraftRecipe = false
    var backToOneStep: ((Bool, Recipe?) -> Void)?
    
    private var time: Int?
    private var servings: Int?
    private var kcal: Value?
    private var localImage: UIImage?
    private var collections: [CollectionModel] = []
    private var isSaveToFavorites = false
    private var draft: Recipe?
    private(set) var recipe: Recipe
    private(set) var currentRecipe: Recipe?
    
    init(currentRecipe: Recipe?, recipe: Recipe) {
        self.recipe = recipe
        self.currentRecipe = currentRecipe
        
        time = currentRecipe?.cookingTime
        servings = currentRecipe?.totalServings
        kcal = currentRecipe?.values?.serving ?? currentRecipe?.values?.dish
        if let imageData = currentRecipe?.localImage {
            localImage = UIImage(data: imageData)
        }
    }
    
    func setParameters(time: Int?, servings: Int?, image: UIImage?, kcal: Value?) {
        self.time = time
        self.servings = servings
        self.kcal = kcal
        localImage = image
    }
    
    func back() {
        router?.navigationPopViewController(animated: true)
        backToOneStep?(isDraftRecipe, Recipe(title: recipe.title,
                                             totalServings: servings ?? -1,
                                             localCollection: collections.isEmpty ? nil : collections,
                                             localImage: localImage?.pngData(),
                                             cookingTime: time,
                                             description: recipe.description,
                                             kcal: kcal,
                                             ingredients: recipe.ingredients,
                                             instructions: recipe.instructions))
    }
    
    func saveRecipeTo() {
        router?.goToShowCollection(state: .select, recipe: currentRecipe,
                                   compl: { [weak self] selectedCollections in
            if selectedCollections.isEmpty,
               let dbFavoritesCollectionCollection = CoreDataManager.shared.getAllCollection()?
                .first(where: { $0.id == EatingTime.favorites.rawValue }) {
                let favoritesCollection = CollectionModel(from: dbFavoritesCollectionCollection)
                self?.collections = [favoritesCollection]
                self?.isSaveToFavorites = true
            } else {
                self?.collections = selectedCollections
            }
            self?.saveRecipe()
            self?.updateRecipe()
        })
    }
    
    func savedToDrafts() {
        guard isDraftRecipe else {
            return
        }
        guard var draft else {
            draft = Recipe(title: recipe.title,
                           totalServings: servings ?? 1,
                           localCollection: collections.isEmpty ? nil : collections,
                           localImage: localImage?.pngData(),
                           cookingTime: time,
                           description: recipe.description,
                           kcal: kcal,
                           ingredients: recipe.ingredients,
                           instructions: recipe.instructions)
            if let dbDraftsCollection = CoreDataManager.shared.getAllCollection()?
                .first(where: { $0.id == EatingTime.drafts.rawValue }) {
                let draftsCollection = CollectionModel(from: dbDraftsCollection)
                draft?.localCollection = [draftsCollection]
            }
            savedToDrafts()
            return
        }

        draft.totalServings = servings ?? 1
        draft.localImage = localImage?.pngData()
        draft.cookingTime = time
        draft.values = Values(dish: kcal)
        
        CoreDataManager.shared.saveRecipes(recipes: [draft])
    }
    
    private func saveRecipe() {
        guard var currentRecipe else {
            saveNewRecipe()
            return
        }
        
        currentRecipe.totalServings = servings ?? 1
        currentRecipe.localCollection = collections.isEmpty ? nil : collections
        currentRecipe.localImage = localImage?.pngData()
        currentRecipe.cookingTime = time
        currentRecipe.values = Values(dish: kcal)
        
        recipe = currentRecipe
        CoreDataManager.shared.saveRecipes(recipes: [currentRecipe])
    }
    
    private func saveNewRecipe() {
        guard let recipe = Recipe(title: recipe.title,
                                  totalServings: servings ?? 1,
                                  localCollection: collections.isEmpty ? nil : collections,
                                  localImage: localImage?.pngData(),
                                  cookingTime: time,
                                  description: recipe.description,
                                  kcal: kcal,
                                  ingredients: recipe.ingredients,
                                  instructions: recipe.instructions) else {
            return
        }
        CoreDataManager.shared.saveRecipes(recipes: [recipe])
        if isSaveToFavorites {
            UserDefaultsManager.favoritesRecipeIds.append(recipe.id)
        }
        self.recipe = recipe
    }

    private func updateRecipe() {
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }
            self.compete?(self.recipe)
            self.router?.popToRoot()
            self.router?.popRecipeToRoot()
        }
    }
}
