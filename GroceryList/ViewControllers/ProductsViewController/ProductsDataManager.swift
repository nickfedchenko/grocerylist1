//
//  ProductsDataManager.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 11.11.2022.
//

import UIKit

class ProductsDataManager {
    
    var supplays: [Supplay]

    init ( supplays: [Supplay] ) {
        self.supplays = supplays
        self.supplays = [
            Supplay(name: "dsds", isPurchased: true, dateOfCreation: Date(), category: "wfe3"),
            Supplay(name: "cxx", isPurchased: false, dateOfCreation: Date(), category: "2"),
            Supplay(name: "d", isPurchased: false, dateOfCreation: Date(), category: "2"),
            Supplay(name: "ffrv", isPurchased: false, dateOfCreation: Date(), category: "23"),
            Supplay(name: "ffev4f", isPurchased: false, dateOfCreation: Date(), category: "2")
        ]

    }
    
    var dataChangedCallBack: (() -> Void)?
    
    var arrayWithSections: [Category] = [] {
        didSet {
            dataChangedCallBack?()
        }
    }

    func createArrayWithSections() {
        var dict: [ String: [Supplay] ] = [:]
        
        var dictPurchased: [ String: [Supplay] ] = [:]
        dictPurchased["Purchased".localized] = []
        
        supplays.forEach({ supplay in
            guard !supplay.isPurchased else { dictPurchased["Purchased"]?.append(supplay); return }
            if dict[supplay.category] != nil {
                dict[supplay.category]?.append(supplay)
            } else {
                dict[supplay.category] = [supplay]
            }
        })
        
        var newArray = dict.map({ Category(name: $0.key, supplays: $0.value) }).sorted(by: { $0.name < $1.name })

        newArray.append(contentsOf: dictPurchased.map({ Category(name: $0.key, supplays: $0.value) }))
         
        arrayWithSections = newArray
        print(arrayWithSections.count)
    }
    
    func updateFavoriteStatus(for product: Supplay) {

        var newProduct = product
        newProduct.isPurchased = !product.isPurchased
        if let index = supplays.firstIndex(of: product ) {
            supplays.remove(at: index)
            supplays.append(newProduct)
        }
        createArrayWithSections()
    }
        
}
