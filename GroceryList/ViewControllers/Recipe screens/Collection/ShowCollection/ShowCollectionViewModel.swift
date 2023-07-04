//
//  ShowCollectionViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 07.03.2023.
//

import Foundation

final class ShowCollectionViewModel {
    
    weak var router: RootRouter?
    var selectedCollection: (([CollectionModel]) -> Void)?
    var updateUI: (() -> Void)?
    
    var necessaryHeight: Double {
        collections.isEmpty ? 0 : Double(collections.count * 64 + 64)
    }
    
    var collectionIsEmpty: Bool {
        collections.isEmpty
    }
    
    var editCollections: [CollectionModel] = []
    var viewState: ShowCollectionViewController.ShowCollectionState
    var updateData: (() -> Void)?
    
    private var collections: [ShowCollectionModel] = []
    private var recipe: Recipe?
    private var changedCollection = false
    
    init(state: ShowCollectionViewController.ShowCollectionState, recipe: Recipe?) {
        viewState = state
        self.recipe = recipe
        
        updateCollection()
    }
    
    deinit {
        print("ShowCollectionViewModel deinited")
    }
    
    func createCollectionTapped() {
        editCollections = collections.map { $0.collection }
        router?.goToCreateNewCollection(collections: editCollections,
                                        compl: { [weak self] updateCollections in
            self?.editCollections = updateCollections
            self?.updateCollection()
            self?.changedCollection = true
        })
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
        changedCollection = true
    }
    
    func deleteCollection(by index: Int) {
        let collection = collections[index].collection
        let recipeIds = collections[index].recipes
        CoreDataManager.shared.deleteCollection(by: collection.id)
        editCollections.removeAll { $0.id == collection.id }
        collections.remove(at: index)
        
        guard let miscellaneous = self.collections.first(where: {
            $0.collection.id == UserDefaultsManager.miscellaneousCollectionId })?.collection else {
            self.updateData?()
            return
        }
        
        DispatchQueue.main.async {
            var updateRecipes: [Recipe] = []
            recipeIds.forEach { recipeId in
                if let dbRecipe = CoreDataManager.shared.getRecipe(by: Int(recipeId.id)),
                   var updateRecipe = Recipe(from: dbRecipe) {
                    let hasDefaultRecipe = updateRecipe.hasDefaultCollection()
                    updateRecipe.localCollection?.removeAll(where: { $0.id == collection.id })
                    let remainingCollections = updateRecipe.localCollection?.filter({ !$0.isDefault }) ?? []
                    if remainingCollections.isEmpty && !hasDefaultRecipe {
                        updateRecipe.localCollection?.append(miscellaneous)
                        self.collections[self.collections.count - 1].recipes.append(recipeId)
                    }
                    updateRecipes.append(updateRecipe)
                }
            }
            CoreDataManager.shared.saveRecipes(recipes: updateRecipes)
        }
        
        self.updateData?()
        changedCollection = true
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
    
    func dismissView() {
        if changedCollection {
            updateUI?()
        }
        router?.navigationDismiss()
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
        changedCollection = true
    }
    
    private func saveEditCollections(color: Int = 0) {
        var updateCollections: [CollectionModel] = []
        let editCollections = collections.map { $0.collection }
        editCollections.enumerated().forEach { index, collection in
            if collection.index != index {
                updateCollections.append(CollectionModel(id: collection.id,
                                                         index: index,
                                                         title: collection.title,
                                                         color: color))
            }
        }
        if !updateCollections.isEmpty {
            changedCollection = true
            DispatchQueue.main.async {
                CoreDataManager.shared.saveCollection(collections: updateCollections)
            }
        }
    }
    
    @objc
    private func updateCollection() {
        var recipeIds: [ShowCollectionModel.Recipe] = []
        if editCollections.isEmpty {
            guard let dbCollections = CoreDataManager.shared.getAllCollection(),
                  let dbRecipes = CoreDataManager.shared.getAllRecipes() else { return }
            recipeIds = dbRecipes.compactMap { ShowCollectionModel.Recipe(from: $0) }
            editCollections = dbCollections.compactMap { CollectionModel(from: $0) }
        } else {
            recipeIds = Array(Set(collections.flatMap { $0.recipes }))
        }

        self.collections.removeAll()
        editCollections.sort { $0.index < $1.index }
        editCollections.forEach { collection in
            let collectionRecipes = recipeIds.filter {
                $0.localCollection?.contains(where: { collection.id == $0.id }) ?? false
            }
            let isSelect = recipe?.localCollection?.contains(where: { $0.id == collection.id }) ?? false
            self.collections.append(ShowCollectionModel(collection: collection,
                                                        recipes: collectionRecipes,
                                                        select: isSelect))
        }
        self.updateData?()
    }
}
