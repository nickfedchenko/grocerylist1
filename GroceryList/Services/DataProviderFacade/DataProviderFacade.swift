//
//  DataProviderFacade.swift
//  GroceryList
//
//  Created by Vladimir Banushkin on 03.12.2022.
//

import Foundation
import Kingfisher

protocol DataSyncProtocol {
    func updateProducts()
    func updateRecipes()
    func updateItems()
    func updateCategories()
    func updateCollections()
    var  domainSyncManager: CoredataSyncProtocol? { get }
}

final class DataProviderFacade {
    let domainManager = CoreDataManager.shared
    let networkManager = NetworkEngine()
}

extension DataProviderFacade: DataSyncProtocol {
    var domainSyncManager: CoredataSyncProtocol? {
        domainManager
    }
    
    func updateProducts() {
        networkManager.getAllProducts { [weak self] result in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(productsResponse):
                self?.saveProductsInPersistentStore(products: productsResponse.data)
            }
        }
    }
    
    func updateRecipes() {
        networkManager.fetchArchiveList(type: "dish") { [weak self] result in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(fetchArchiveListResponse):
                self?.getRecipe(fetchArchiveListResponse: fetchArchiveListResponse)
            }
        }
    }
    
    func updateItems() {
        networkManager.getAllItems { [weak self] result in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(itemsResponse):
                self?.saveProductsInPersistentStore(products: itemsResponse.data)
            }
        }
    }
    
    func updateCategories() {
        networkManager.getProductCategories { [weak self] result in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(categoriesResponse):
                self?.saveCategoriesPersistentStore(type: "Product ", categories: categoriesResponse.data)
            }
        }
        
        networkManager.getItemCategories { [weak self] result in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(categoriesResponse):
                self?.saveCategoriesPersistentStore(type: "Item ", categories: categoriesResponse.data)
            }
        }
    }
    
    func updateCollections() {
        networkManager.fetchCollections { [weak self] result in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(collectionResponse):
                self?.saveCollection(networkCollection: collectionResponse.data)
            }
        }
    }
    
    private func getRecipe(fetchArchiveListResponse: FetchArchiveListResponse) {
        let url = fetchArchiveListResponse.links.first?.url ?? ""
        networkManager.getArchiveRecipe(url: url, completion: { [weak self] result in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(recipesResponse):
                self?.saveRecipesInPersistentStore(recipes: recipesResponse)
            }
        })
    }
    
    private func saveRecipesInPersistentStore(recipes: [Recipe]) {
        domainSyncManager?.saveRecipes(recipes: recipes)
        DispatchQueue.global().async {
            recipes.forEach {
                if let url = URL(string: $0.photo) {
                    _ = ImageResource(downloadURL: url, cacheKey: url.absoluteString)
                }
            }
        }
    }
    
    private func saveProductsInPersistentStore(products: [NetworkProductModel]) {
        domainSyncManager?.saveProducts(products: products)
        DispatchQueue.global().async {
            products.forEach {
                if let url = URL(string: $0.photo) {
                    _ = ImageResource(downloadURL: url, cacheKey: url.absoluteString)
                }
            }
        }
    }
    
    private func saveCategoriesPersistentStore(type: String, categories: [NetworkCategory]) {
        let updatedCategories = categories.map {
            NetworkCategory(id: $0.id, title: $0.title, netId: type + "\($0.id)")
        }
        
        CoreDataManager.shared.saveCategories(categories: updatedCategories)
    }
    
    private func saveCollection(networkCollection: [NetworkCollection]) {
        let collections = networkCollection.filter { $0.pos >= 41 && $0.pos <= 60 }
                                           .map { CollectionModel(networkCollection: $0) }
        var saveCollection: [CollectionModel] = []
        collections.forEach { collection in
            if let localCollection = CoreDataManager.shared.getCollection(by: collection.id) {
                let localDishes = (try? JSONDecoder().decode([Int].self, from: localCollection.dishes ?? Data())) ?? []
                var dishes = Set(localDishes)
                collection.dishes?.forEach({ recipeId in
                    dishes.insert(recipeId)
                })
                
                saveCollection.append(CollectionModel(id: collection.id,
                                                      index: Int(localCollection.index),
                                                      title: localCollection.title ?? "",
                                                      color: Int(localCollection.color),
                                                      isDefault: true,
                                                      localImage: localCollection.localImage,
                                                      dishes: Array(dishes),
                                                      isDeleteDefault: localCollection.isDelete))
            } else {
                saveCollection.append(collection)
            }
        }
        
        CoreDataManager.shared.saveNetworkCollection(collections: saveCollection)
    }
}
