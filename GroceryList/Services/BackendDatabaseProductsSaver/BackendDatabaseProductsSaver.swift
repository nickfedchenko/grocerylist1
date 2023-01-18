//
//  BackendDatabaseProductsSaver.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 01.12.2022.
//

import Foundation

class BackendDatabaseProductsSaver {
   
    var network: NetworkDataProvider = NetworkEngine()
    
    var arrayOfProducts: [NetworkProductModel] = [] {
        didSet {
            transformNetworkModelsToCoreData()
        }
    }
    
    init() {
        syncProducts()
        syncDishes()
    }
    
    private func syncProducts() {
        network.getAllProducts { post in
            switch post {
            case .failure(let error):
                print(error)
            case .success(let response):
                DispatchQueue.main.async {
                    self.arrayOfProducts = response.data
                }
            }
        }
    }
    
    private func syncDishes() {
        network.getAllRecipes { result  in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let recipesResponse):
            
                print(recipesResponse.data)
            }
        }
    }
    
    func transformNetworkModelsToCoreData() {
        DispatchQueue.main.async {
            self.arrayOfProducts.forEach({ CoreDataManager.shared.createNetworkProduct(product: $0) })
        }
    }
    
    
    
}
