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
    
    private var time: Int?
    private var servings: Int?
    private var kcal: Value?
    private var localImage: UIImage?
    private var recipe: Recipe
    private var collections: [CollectionModel] = []
    
    init(recipe: Recipe) {
        self.recipe = recipe
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateRecipe),
                                               name: .recieptsDownladedAnsSaved,
                                               object: nil)
    }
    
    func back() {
        router?.navigationPopViewController(animated: true)
    }
    
    func saveRecipeTo(time: Int?, servings: Int?, image: UIImage?, kcal: Value?) {
        router?.goToShowCollection(state: .select, compl: { [weak self] selectedCollections in
            if selectedCollections.isEmpty,
               let dbDraftsCollection = CoreDataManager.shared.getAllCollection()?
                .first(where: { $0.id == EatingTime.drafts.rawValue }) {
                let draftsCollection = CollectionModel(from: dbDraftsCollection)
                self?.collections = [draftsCollection]
            } else {
                self?.collections = selectedCollections
            }
            self?.save()
        })
        self.time = time
        self.servings = servings
        self.kcal = kcal
        localImage = image
    }
    
    private func save() {
        guard let recipe = Recipe(title: recipe.title,
                                  totalServings: servings ?? -1,
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
        self.recipe = recipe
    }
    
    @objc
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
