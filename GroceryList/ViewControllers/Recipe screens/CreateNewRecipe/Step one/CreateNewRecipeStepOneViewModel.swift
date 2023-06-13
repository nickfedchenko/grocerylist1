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
    var competeRecipe: ((Recipe) -> Void)?
    
    private var recipe: CreateNewRecipeStepOne?
    private var collections: [CollectionModel]?
    func back() {
        router?.navigationPopViewController(animated: true)
    }
    
    func openCollection() {
        router?.goToShowCollection(state: .select, compl: { [weak self] selectedCollections in
            self?.collections = selectedCollections
            let collectionTitles = selectedCollections.compactMap { $0.title }
            self?.changeCollections?(collectionTitles)
        })
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
    
    func saveRecipe(title: String, servings: Int, photo: UIImage?) {
        if collections == nil || (collections?.isEmpty ?? true) {
            if let dbMiscellaneous = CoreDataManager.shared.getAllCollection()?
                .first(where: { $0.id == UserDefaultsManager.miscellaneousCollectionId }),
                let miscellaneous = CollectionModel(from: dbMiscellaneous) {
                collections = [miscellaneous]
            }
        }
        
        recipe = .init(title: title,
                       totalServings: servings,
                       collection: collections,
                       photo: photo)
    }
}
