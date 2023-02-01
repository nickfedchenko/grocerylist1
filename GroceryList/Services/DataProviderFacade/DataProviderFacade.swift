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
    
    private func saveRecipesInPersistentStore(recipes: [Recipe]) {
        domainSyncManager?.saveRecipes(recipes: recipes)
    }
    
    private func saveProductsInPersistentStore(products: [NetworkProductModel]) {
        domainSyncManager?.saveProducts(products: products)
    }
}

