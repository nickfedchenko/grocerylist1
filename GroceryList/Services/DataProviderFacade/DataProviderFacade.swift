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
    }
    
    private func saveProductsInPersistentStore(products: [NetworkProductModel]) {
        domainSyncManager?.saveProducts(products: products)
        let imageView = UIImageView()
        let size = CGSize(width: 100, height: 100)
        let cache = ImageCache.default
        cache.memoryStorage.config.totalCostLimit = 1024 * 1024 * 10
        cache.diskStorage.config.sizeLimit = 1024 * 1024 * 100
        DispatchQueue.main.async {
            products.forEach {
                if let url = URL(string: $0.photo) {
                    KingfisherManager.shared.retrieveImage(with: url) { _ in }
                    imageView.kf.setImage(with: url, placeholder: nil,
                                              options: [.processor(DownsamplingImageProcessor(size: size)),
                                                        .scaleFactor(UIScreen.main.scale),
                                                        .cacheOriginalImage])
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
        let collection = networkCollection.filter { $0.pos >= 41 && $0.pos <= 60 }
        CoreDataManager.shared.saveNetworkCollection(collections: collection)
    }
}
