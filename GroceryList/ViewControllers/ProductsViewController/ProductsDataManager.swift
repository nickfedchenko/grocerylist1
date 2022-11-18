//
//  ProductsDataManager.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 11.11.2022.
//

import UIKit

class ProductsDataManager {
    
    var products: [Product]

    init ( products: [Product] ) {
        self.products = products
    }
    
    var dataChangedCallBack: (() -> Void)?
    
    var arrayWithSections: [Category] = [] {
        didSet {
            dataChangedCallBack?()
        }
    }

    func createArrayWithSections() {
        guard !products.isEmpty else { return }
        var dict: [ String: [Product] ] = [:]
        
        var dictPurchased: [ String: [Product] ] = [:]
        dictPurchased["Purchased".localized] = []
        
        products.forEach({ product in
            guard !product.isPurchased else { dictPurchased["Purchased"]?.append(product); return }
            if dict[product.category] != nil {
                dict[product.category]?.append(product)
            } else {
                dict[product.category] = [product]
            }
        })
        
        var newArray = dict.map({ Category(name: $0.key, products: $0.value) }).sorted(by: { $0.name < $1.name })
        
        if products.contains(where: { $0.isPurchased }) {
            newArray.append(contentsOf: dictPurchased.map({ Category(name: $0.key, products: $0.value) }))
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
    
    func updateFavoriteStatus(for product: Product) {
        var newProduct = product
        newProduct.isPurchased = !product.isPurchased
        CoreDataManager.shared.createProduct(product: newProduct)
        if let index = products.firstIndex(of: product ) {
            products.remove(at: index)
            products.append(newProduct)
        }
        createArrayWithSections()
    }
    
    func delete(product: Product) {
        CoreDataManager.shared.removeProduct(product: product)
        if let index = products.firstIndex(of: product ) {
            products.remove(at: index)
        }
        createArrayWithSections()
    }
        
}
