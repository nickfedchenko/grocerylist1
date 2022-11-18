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
    }
    
    var dataChangedCallBack: (() -> Void)?
    
    var arrayWithSections: [Category] = [] {
        didSet {
            dataChangedCallBack?()
        }
    }

    func createArrayWithSections() {
        guard !supplays.isEmpty else { return }
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
        
        if supplays.contains(where: { $0.isPurchased }) {
            newArray.append(contentsOf: dictPurchased.map({ Category(name: $0.key, supplays: $0.value) }))
        }
        
        for (ind, newValue) in newArray.enumerated() {
            arrayWithSections.forEach({ oldValue in
                if newValue.name == oldValue.name {
                    newArray[ind].isExpanded = oldValue.isExpanded
                    print(oldValue.isExpanded)
                }
            })
        }
    
        arrayWithSections = newArray
    }
    
    func updateFavoriteStatus(for product: Supplay) {
        var newProduct = product
        newProduct.isPurchased = !product.isPurchased
        CoreDataManager.shared.createSupplay(supplay: newProduct)
        if let index = supplays.firstIndex(of: product ) {
            supplays.remove(at: index)
            supplays.append(newProduct)
        }
        createArrayWithSections()
    }
    
    func delete(product: Supplay) {
        CoreDataManager.shared.removeSupplay(supplay: product)
        if let index = supplays.firstIndex(of: product ) {
            supplays.remove(at: index)
        }
        createArrayWithSections()
    }
        
}
