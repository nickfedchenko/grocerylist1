//
//  BackendDatabaseProductsSaver.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 01.12.2022.
//

import Foundation

class BackendDatabaseProductsSaver {
   
    var network: NetworkDataProvider?
    
    var arrayOfProducts: [NetworkProductModel] = [] {
        didSet {
            transformNetworkModelsToCoreData()
        }
    }
 
    init() {
        network = NetworkEngine()
        network?.getAllProducts { post in
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
    
    func transformNetworkModelsToCoreData() {
        DispatchQueue.main.async {
            self.arrayOfProducts.forEach({ CoreDataManager.shared.createNetworkProduct(product: $0) })
        }
    }
}
