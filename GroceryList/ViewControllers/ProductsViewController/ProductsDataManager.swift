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
        
        var dictFavorite: [ String: [Product] ] = [:]
        dictFavorite["Favorite"] = []
        
        products.forEach({ product in
           
            guard !product.isPurchased else { dictPurchased["Purchased"]?.append(product); return }
            guard !product.isFavorite else { dictFavorite["Favorite"]?.append(product); return }

            if dict[product.category] != nil {
                dict[product.category]?.append(product)
            } else {
                dict[product.category] = [product]
            }
        })
        
        var newArray: [Category] = []
        
        // Избранное
        if products.contains(where: { $0.isFavorite && !$0.isPurchased }) {
            newArray.append(contentsOf: dictFavorite.map({ Category(name: $0.key, products: $0.value, typeOFCell: .sortedByAlphabet) }))
        }
        
        // Все что не избрано и не куплено
        newArray.append(contentsOf: dict.map({ Category(name: $0.key, products: $0.value, typeOFCell: .normal) }).sorted(by: { $0.name < $1.name }))
        
        // Все что куплено
        if products.contains(where: { $0.isPurchased }) {
            newArray.append(contentsOf: dictPurchased.map({ Category(name: $0.key, products: $0.value, typeOFCell: .purchased) }))
        }
        
        // Сохранение параметра свернутости развернутости списка
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
    
    func updatePurchasedStatus(for product: Product) {
        var newProduct = product
        newProduct.isPurchased = !product.isPurchased
        CoreDataManager.shared.createProduct(product: newProduct)
        if let index = products.firstIndex(of: product ) {
            products.remove(at: index)
            products.append(newProduct)
        }
        createArrayWithSections()
    }
    
    func updateFavoriteStatus(for product: Product) {
        var newProduct = product
        newProduct.isFavorite = !product.isFavorite
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
            if products.isEmpty { arrayWithSections = [] }
        }
        createArrayWithSections()
    }
        
}
