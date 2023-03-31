//
//  DataProviderFacade.swift
//  GroceryList
//
//  Created by Vladimir Banushkin on 03.12.2022.
//

import Foundation

protocol DataSyncProtocol {
    func updateProducts()
    func updateRecipes()
    func updateItems()
    func updateCategories()
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
                self?.saveProductsInPersistentStore(products: productsResponse)
                
            }
        }
    }
    
    func updateRecipes() {
        networkManager.getAllRecipes { [weak self] result in
            switch result {
            case let .failure(error):
                print(error)
            case let .success(recipesResponse):
                self?.saveRecipesInPersistentStore(recipes: recipesResponse)
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
    
    private func saveRecipesInPersistentStore(recipes: [Recipe]) {
        domainSyncManager?.saveRecipes(recipes: recipes)
    }
    
    private func saveProductsInPersistentStore(products: [NetworkProductModel]) {
        domainSyncManager?.saveProducts(products: products)
    }
    
    private func saveCategoriesPersistentStore(type: String, categories: [NetworkCategory]) {
        let updatedCategories = categories.map {
            NetworkCategory(id: $0.id, title: $0.title, netId: type + "\($0.id)")
        }
        
        CoreDataManager.shared.saveCategories(categories: updatedCategories)
    }
}
