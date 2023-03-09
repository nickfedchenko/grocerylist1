//
//  CreateNewRecipeViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 01.03.2023.
//

import UIKit

final class CreateNewRecipeStepOneViewModel {
    
    weak var router: RootRouter?
    var changeCollections: (([String]) -> Void)?
    
    private var recipe: CreateNewRecipeStepOne?
    private var collections: [CollectionModel]?
    func back() {
        router?.navigationPopViewController(animated: true)
    }
    
    func openCollection() {
        router?.goToShowCollection(state: .select, compl: { [weak self] selectedCollections in
            let collectionTitles = selectedCollections.compactMap { $0.title }
            self?.changeCollections?(collectionTitles)
        })
    }
    
    func next() {
        guard let recipe else {
            return
        }
        router?.goToCreateNewRecipeStepTwo(recipe: recipe)
    }
    
    func saveRecipe(title: String, servings: Int, photo: UIImage?) {
        recipe = .init(title: title,
                       totalServings: servings,
                       collection: collections,
                       photo: photo)
    }
}
