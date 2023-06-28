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
    
    private let colorManager = ColorManager.shared
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
                                        compl: { [weak self] newCollection in
            self?.editCollections.append(newCollection)
            self?.updateCollection()
            self?.changedCollection = true
        })
    }
    
    func editCollection(by index: Int) {
        guard let collection = collections[safe: index] else {
            return
        }
        editCollections = collections.map { $0.collection }
        router?.goToCreateNewCollection(currentCollection: collection.collection,
                                        collections: editCollections,
                                        compl: { [weak self] updateCollection in
            self?.editCollections.removeAll(where: { $0.id == updateCollection.id})
            self?.editCollections.append(updateCollection)
            self?.updateCollection()
            self?.changedCollection = true
        })
    }
    
    func getNumberOfRows() -> Int {
        return collections.count + 1
    }
    
    func getCollectionTitle(by index: Int) -> String? {
        return collections[safe: index]?.collection.title.localized
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
    
    func getColor(by index: Int) -> Theme {
        let collection = collections[index].collection
        return colorManager.getGradient(index: collection.color)
    }
    
    func isTechnicalCollection(by index: Int) -> Bool {
        guard let collectionId = collections[safe: index]?.collection.id,
              let defaultCollection = EatingTime(rawValue: collectionId) else {
            return false
        }
        return defaultCollection.isTechnicalCollection
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
        
        DispatchQueue.main.async {
            var updateRecipes: [Recipe] = []
            recipeIds.forEach { recipeId in
                if let dbRecipe = CoreDataManager.shared.getRecipe(by: Int(recipeId.id)),
                   var updateRecipe = Recipe(from: dbRecipe) {
                    let hasDefaultRecipe = updateRecipe.hasDefaultCollection()
                    updateRecipe.localCollection?.removeAll(where: { $0.id == collection.id })
                    updateRecipes.append(updateRecipe)
                }
            }
            CoreDataManager.shared.saveRecipes(recipes: updateRecipes)
        }
        
        self.updateData?()
        changedCollection = true
    }
    
    func canMove(by indexPath: IndexPath) -> Bool {
        return indexPath.row == 0
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
        var selectCollections = collections.filter({ $0.select }).map({ $0.collection })
        guard var recipe else {
            selectedCollection?(selectCollections)
            return
        }
        updateRecipeFavorite(olds: recipe.localCollection ?? [], updates: selectCollections)
        updateRecipeDrafts(updates: selectCollections)
        
        if recipe.isDefaultRecipe &&
            selectCollections.contains(where: { $0.id == EatingTime.drafts.rawValue }) {
            selectCollections.removeAll { $0.id == EatingTime.drafts.rawValue }
        }
        recipe.localCollection = selectCollections
        CoreDataManager.shared.saveRecipes(recipes: [recipe])
        selectedCollection?(selectCollections)
        changedCollection = true
    }
    
    private func saveEditCollections() {
        var updateCollections: [CollectionModel] = []
        let editCollections = collections.map { $0.collection }
        editCollections.enumerated().forEach { index, collection in
            if collection.index != index {
                updateCollections.append(CollectionModel(id: collection.id,
                                                         index: index,
                                                         title: collection.title,
                                                         color: collection.color))
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
        
        // папки will cook и inbox еще не реализованы, пока что их удаляем из списка коллекций
        self.collections.removeAll {
            $0.collection.id == EatingTime.inbox.rawValue ||
            $0.collection.id == EatingTime.willCook.rawValue
        }
        
        self.updateData?()
    }
    
    private func updateRecipeFavorite(olds: [CollectionModel], updates: [CollectionModel]) {
        guard let recipe else {
            return
        }
        let favoritesId = EatingTime.favorites.rawValue
        
        if olds.contains(where: { $0.id == favoritesId }) && !updates.contains(where: { $0.id == favoritesId }) {
            UserDefaultsManager.favoritesRecipeIds.removeAll { $0 == recipe.id }
        }
        
        if !olds.contains(where: { $0.id == favoritesId }) && updates.contains(where: { $0.id == favoritesId }) {
            UserDefaultsManager.favoritesRecipeIds.append(recipe.id)
        }
        
    }
    
    private func updateRecipeDrafts(updates: [CollectionModel]) {
        guard let recipe, recipe.isDefaultRecipe,
              let drafts = updates.first(where: { $0.id == EatingTime.drafts.rawValue }),
              var draft = Recipe(title: recipe.title,
                                 totalServings: recipe.totalServings,
                                 localCollection: [drafts],
                                 localImage: recipe.localImage,
                                 cookingTime: recipe.cookingTime,
                                 description: recipe.description,
                                 ingredients: recipe.ingredients,
                                 instructions: recipe.instructions) else {
            return
        }
        draft.photo = recipe.photo
        draft.values = recipe.values
        
        CoreDataManager.shared.saveRecipes(recipes: [draft])
    }
    
}
