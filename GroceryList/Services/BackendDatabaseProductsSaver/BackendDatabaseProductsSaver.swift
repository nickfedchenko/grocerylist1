//
//  BackendDatabaseProductsSaver.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 01.12.2022.
//

import Foundation

class BackendDatabaseProductsSaver {
   
    static var shared = BackendDatabaseProductsSaver()
    
    var network: NetworkDataProvider?
    
    var arrayOfProducts: [NetworkProductModel] = [] {
        didSet {
            transformNetworkModelsToCoreData()
        }
    }
 
    init() {
        network = NetworkEngine()
    }
    
    func fetchAllProducts() {
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
    
    deinit {
        print("backend deinited")
    }
    
    func transformNetworkModelsToCoreData() {
        DispatchQueue.main.async {
            self.arrayOfProducts.forEach({ CoreDataManager.shared.createNetworkProduct(product: $0) })
        }
    }
}
