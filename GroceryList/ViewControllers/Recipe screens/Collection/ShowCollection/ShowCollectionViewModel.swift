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
        
        newUpdateCollection()
    }
    
    deinit {
        print("ShowCollectionViewModel deinited")
    }
    
    func createCollectionTapped() {
        editCollections = collections.map { $0.collection }
        router?.goToCreateNewCollection(collections: editCollections,
                                        compl: { [weak self] newCollection in
            AmplitudeManager.shared.logEvent(.recipeCreateCollection)
            self?.editCollections.append(newCollection)
            self?.newUpdateCollection()
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
            self?.editCollections.removeAll(where: { $0.id == updateCollection.id })
            self?.editCollections.append(updateCollection)
            self?.newUpdateCollection()
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
        return colorManager.getGradient(index: collection.color ?? 0)
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
        var collection = collections[index].collection
        
        if collection.isDefault {
            collection.isDeleteDefault = true
            CoreDataManager.shared.saveCollection(collections: [collection])
            CloudManager.shared.saveCloudData(collectionModel: collection)
        } else {
            CoreDataManager.shared.deleteCollection(by: collection.id)
            CloudManager.shared.delete(recordType: .collectionModel, recordID: collection.recordId)
        }
        
        editCollections.removeAll { $0.id == collection.id }
        collections.remove(at: index)
        
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
    
    func showPaywall() {
        router?.showPaywallVC()
    }
    
    func showPaywallOnTopController() {
        router?.showPaywallVCOnTopController()
    }
    
    private func saveSelectCollections() {
        var selectCollections = collections.filter({ $0.select }).map({ $0.collection })
        guard let recipe else {
            selectedCollection?(selectCollections)
            return
        }
        selectCollections.enumerated().forEach { index, collection in
            var dishes = Set(collection.dishes ?? [])
            dishes.insert(recipe.id)
            selectCollections[index].dishes = Array(dishes)
        }
        CoreDataManager.shared.saveCollection(collections: selectCollections)
        selectCollections.forEach { collectionModel in
            CloudManager.shared.saveCloudData(collectionModel: collectionModel)
        }
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
                                                         color: collection.color ?? 0,
                                                         dishes: collection.dishes))
            }
        }
        if !updateCollections.isEmpty {
            changedCollection = true
            DispatchQueue.main.async {
                CoreDataManager.shared.saveCollection(collections: updateCollections)
                updateCollections.forEach { collectionModel in
                    CloudManager.shared.saveCloudData(collectionModel: collectionModel)
                }
            }
        }
    }
    
    @objc
    private func newUpdateCollection() {
        if editCollections.isEmpty {
            guard var dbCollections = CoreDataManager.shared.getAllCollection() else {
                return
            }
            dbCollections.removeAll { $0.isDelete == true }
            editCollections = dbCollections.compactMap { CollectionModel(from: $0) }
        }

        self.collections.removeAll()
        
        editCollections.sort { $0.index < $1.index }
        editCollections.forEach { collection in
            var recipes: [ShowCollectionModel.Recipe] = []
            collection.dishes?.forEach({
                if let recipe = CoreDataManager.shared.getRecipe(by: $0) {
                    recipes.append(ShowCollectionModel.Recipe(from: recipe))
                }
            })
            let isSelect = collection.dishes?.contains(where: { recipe?.id == $0 })
            self.collections.append(ShowCollectionModel(collection: collection,
                                                        recipes: recipes,
                                                        select: isSelect ?? false))
        }
        
        // папки will cook и inbox еще не реализованы, пока что их удаляем из списка коллекций
        self.collections.removeAll {
            $0.collection.id == EatingTime.inbox.rawValue ||
            $0.collection.id == EatingTime.willCook.rawValue
        }
        
        self.updateData?()
    }
}
