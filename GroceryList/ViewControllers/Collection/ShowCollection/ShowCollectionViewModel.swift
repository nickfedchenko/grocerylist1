//
//  ShowCollectionViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 07.03.2023.
//

import Foundation

struct ShowCollectionModel {
    var collection: CollectionModel
    var recipes: [Recipe]
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
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateCollection),
                                               name: .collectionsSaved,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateCollection),
                                               name: .recieptsDownladedAnsSaved,
                                               object: nil)
    }
    
    func createCollectionTapped() {
        saveChanges()
        router?.goToCreateNewCollection { }
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
        return collection.recipes.count
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
    
    func deleteCollection(by index: Int) {
        let collection = collections[index].collection
        let recipes = collections[index].recipes
        CoreDataManager.shared.deleteCollection(by: collection.id)
        
        guard let miscellaneous = self.collections.first(where: {
            $0.collection.id == UserDefaultsManager.miscellaneousCollectionId })?.collection else {
            return
        }
        
        var updateRecipes: [Recipe] = []
        recipes.forEach { recipe in
            var updateRecipe = recipe
            let hasDefaultRecipe = updateRecipe.hasDefaultCollection()
            updateRecipe.localCollection?.removeAll(where: { $0.id == collection.id })
            let remainingCollections = updateRecipe.localCollection?.filter({ !$0.isDefault }) ?? []
            if remainingCollections.isEmpty && !hasDefaultRecipe {
                updateRecipe.localCollection?.append(miscellaneous)
            }
            updateRecipes.append(updateRecipe)
        }
        
        CoreDataManager.shared.saveRecipes(recipes: updateRecipes)
        self.collections.remove(at: index)
        self.updateData?()
    }
    
    func canMove(by indexPath: IndexPath) -> Bool {
        return indexPath.row == 0 || indexPath.row == getNumberOfRows() - 1
    }
    
    func swapCategories(from firstIndex: Int, to secondIndex: Int) {
        let swapItem = collections.remove(at: firstIndex)
        collections.insert(swapItem, at: secondIndex)
    }
    
    func saveChanges() {
        guard viewState == .select else {
            saveEditCollections()
            return
        }
        saveSelectCollections()
    }
    
    private func saveSelectCollections() {
        let selectCollections = collections.filter({ $0.select }).map({ $0.collection })
        guard var recipe else {
            selectedCollection?(selectCollections)
            return
        }
        recipe.localCollection = selectCollections
        CoreDataManager.shared.saveRecipes(recipes: [recipe])
        selectedCollection?(selectCollections)
    }
    
    private func saveEditCollections() {
        var updateCollections: [CollectionModel] = []
        let editCollections = collections.map { $0.collection }
        editCollections.enumerated().forEach { index, collection in
            if collection.index != index {
                updateCollections.append(CollectionModel(id: collection.id,
                                                         index: index,
                                                         title: collection.title))
            }
        }
        if !updateCollections.isEmpty {
            CoreDataManager.shared.saveCollection(collections: updateCollections)
        }
    }
    
    @objc
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
                                    recipes: collectionRecipes,
                                    select: recipe?.localCollection?.contains(where: { $0.id == collection.id }) ?? false))
        }
        self.updateData?()
    }
}
