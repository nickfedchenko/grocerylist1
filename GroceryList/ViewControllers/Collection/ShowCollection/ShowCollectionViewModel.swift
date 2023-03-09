//
//  ShowCollectionViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 07.03.2023.
//

import Foundation

struct ShowCollectionModel {
    var collection: CollectionModel
    var recipeCount: Int
    var select: Bool
}

final class ShowCollectionViewModel {
    
    weak var router: RootRouter?
    var selectedCollection: (([CollectionModel]) -> Void)?
    
    var necessaryHeight: Double {
        collections.isEmpty ? 0 : Double(collections.count * 64 + 64)
    }
    
    var collectionIsEmpty: Bool {
        collections.isEmpty
    }
    
    var viewState: ShowCollectionViewController.ShowCollectionState
    var updateData: (() -> Void)?
    
    private var collections: [ShowCollectionModel] = []
    private var recipe: Recipe?
    
    init(state: ShowCollectionViewController.ShowCollectionState, recipe: Recipe?) {
        viewState = state
        self.recipe = recipe
        
        updateCollection()
    }
    
    func createCollectionTapped() {
        router?.goToCreateNewCollection { [weak self] in
            self?.updateCollection()
            self?.updateData?()
        }
    }
    
    func getNumberOfRows() -> Int {
        return collections.count + 1
    }
    
    func getCollectionTitle(by index: Int) -> String? {
        return collections[safe: index]?.collection.title
    }
    
    func getRecipeCount(by index: Int) -> Int {
        guard let collection = collections[safe: index] else {
            return 0
        }
        return collection.recipeCount
    }
    
    func isSelect(by index: Int) -> Bool {
        guard let collection = collections[safe: index] else {
            return false
        }
        return collection.select
    }
    
    func updateSelect(by index: Int) {
        collections[index].select.toggle()
        updateData?()
    }
    
    func saveChanges() {
        let selectCollections = collections.filter({ $0.select }).map({ $0.collection })
        guard var recipe else {
            selectedCollection?(selectCollections)
            return
        }
        recipe.localCollection = selectCollections
        CoreDataManager.shared.saveRecipes(recipes: [recipe])
        selectedCollection?(selectCollections)
    }
    
    private func updateCollection() {
        self.collections.removeAll()
        guard let dbCollections = CoreDataManager.shared.getAllCollection(),
              let dbRecipes = CoreDataManager.shared.getAllRecipes() else { return }
        let recipes = dbRecipes.compactMap { Recipe(from: $0) }
        let collections = dbCollections.compactMap { CollectionModel(from: $0) }
        collections.forEach { collection in
            let collectionRecipes = recipes.filter {
                $0.localCollection?.contains(where: { collection.id == $0.id }) ?? false
            }
            self.collections.append(
                ShowCollectionModel(collection: collection,
                                    recipeCount: collectionRecipes.count,
                                    select: recipe?.localCollection?.contains(where: { $0.id == collection.id }) ?? false))
        }
        
        guard let miscellaneousIndex = self.collections.firstIndex(where: {
            $0.collection.id == UserDefaultsManager.miscellaneousCollectionId }) else {
            return
        }
        
        self.collections.append(self.collections.remove(at: miscellaneousIndex))
    }
}
