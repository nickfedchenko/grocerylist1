//
//  ProductsDataManager.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 11.11.2022.
//

import UIKit

class ProductsDataManager {
    
    private var shouldSaveExpanding: Bool = false
    var products: [Product] {
        getProducts()
    }
    var groceryListId: String
    var typeOfSorting: SortingType {
        didSet {
            shouldSaveExpanding = false
            createDataSourceArray()
        }
    }

    init (products: [Product], typeOfSorting: SortingType,
          groceryListId: String) {
        self.typeOfSorting = typeOfSorting
        self.groceryListId = groceryListId
    }
    
    private func getProducts() -> [Product] {
        guard let domainList = CoreDataManager.shared.getList(list: groceryListId) else { return [] }
        let localList = DomainModelsToLocalTransformer().transformCoreDataModelToModel(domainList)
        return localList.products
    }
    
    var dataChangedCallBack: (() -> Void)?
    
    var dataSourceArray: [Category] = [] {
        didSet {
            dataChangedCallBack?()
        }
    }

    func createDataSourceArray() {
        if products.isEmpty { dataSourceArray = [] }
        guard !products.isEmpty else { return }
        if typeOfSorting == .category { createArrayWithSections() }
        if typeOfSorting == .alphabet { createArraySortedByAlphabet() }
        if typeOfSorting == .recipe { createArraySortedByTime() }
        if typeOfSorting == .time { createArraySortedByTime() }
        shouldSaveExpanding = true
    }
    
    func appendCopiedProducts(product: [Product]) {
        createDataSourceArray()
    }
    
    // MARK: - Сортировка по алфавиту
    private func createArraySortedByAlphabet() {
        var dict: [ String: [Product] ] = [:]
        
        var dictPurchased: [ String: [Product] ] = [:]
        dictPurchased["Purchased".localized] = []
        
        var dictFavorite: [ String: [Product] ] = [:]
        dictFavorite["Favorite"] = []
      
        // тип сортировки
        let products = products.sorted(by: { $0.name < $1.name })
        
        products.forEach({ product in
           
            guard !product.isPurchased else { dictPurchased["Purchased".localized]?.append(product); return }
            guard !product.isFavorite else { dictFavorite["Favorite"]?.append(product); return }

            if dict["sortedByCategory"] != nil {
                dict["sortedByCategory"]?.append(product)
            } else {
                dict["sortedByCategory"] = [product]
            }
        })
        
        var newArray: [Category] = []
        
        // Избранное
        if products.contains(where: { $0.isFavorite && !$0.isPurchased }) {
            newArray.append(contentsOf: dictFavorite.map({ Category(name: $0.key, products: $0.value, typeOFCell: .favorite) }))
        }
        
        // Все что не избрано и не куплено
        newArray.append(contentsOf: dict.map({ Category(name: $0.key, products: $0.value, typeOFCell: .sortedByAlphabet) }))
     
        // Все что куплено
        if products.contains(where: { $0.isPurchased }) {
            newArray.append(contentsOf: dictPurchased.map({ Category(name: $0.key, products: $0.value, typeOFCell: .purchased) }))
        }
        
        // Сохранение параметра свернутости развернутости списка
        guard shouldSaveExpanding else { return dataSourceArray = newArray }
        for (ind, newValue) in newArray.enumerated() {
            dataSourceArray.forEach({ oldValue in
                if newValue.name == oldValue.name {
                    newArray[ind].isExpanded = oldValue.isExpanded
                }
            })
        }
        dataSourceArray = newArray
    }
    
    // MARK: - Сортировка по Дате добавления
    // swiftlint:disable:next function_body_length
    private func createArraySortedByTime() {
        let idForDict = R.string.localizable.addedEarlier()
        var dict: [ String: [Product] ] = [:]
        
        var dictPurchased: [ String: [Product] ] = [:]
        dictPurchased["Purchased".localized] = []
        
        var dictFavorite: [ String: [Product] ] = [:]
        dictFavorite["Favorite"] = []
        
        var recipesDict: [String: [Product]] = [:]
        
        // тип сортировки
        let products = products.sorted(by: { $0.dateOfCreation < $1.dateOfCreation })
        products.forEach({ product in
            guard !product.isPurchased else {
                dictPurchased["Purchased".localized]?.append(product)
                return
            }
            
            guard !product.isFavorite  else {
                dictFavorite["Favorite"]?.append(product)
                return
            }
            
            guard product.fromRecipeTitle == nil else {
                guard let recipeTitle = product.fromRecipeTitle else {
                    return
                }
                if recipesDict[recipeTitle] != nil {
                    recipesDict[recipeTitle]?.append(product)
                } else {
                    recipesDict[recipeTitle] = [product]
                }
                return
            }
            
            if dict[idForDict] != nil {
                dict[idForDict]?.append(product)
            } else {
                dict[idForDict] = [product]
            }
        })
        
        var newArray: [Category] = []
        
        // Избранное
        if products.contains(where: { $0.isFavorite && !$0.isPurchased }) {
            newArray.append(contentsOf: dictFavorite.map({ Category(name: $0.key, products: $0.value, typeOFCell: .favorite) }))
        }
        
        newArray.append(contentsOf: dict.map({ Category(name: $0.key, products: $0.value, typeOFCell: .sortedByDate) }).sorted(by: { $0.name < $1.name }))
        
        if products.contains(where: { $0.fromRecipeTitle != nil }) {
            newArray.append(contentsOf: recipesDict.map({ Category(name: $0.key, products: $0.value, typeOFCell: .sortedByDate) }))
        }
        
        // Все что не избрано и не куплено
 
        // Все что куплено
        if products.contains(where: { $0.isPurchased }) {
            newArray.append(contentsOf: dictPurchased.map({ Category(name: $0.key, products: $0.value, typeOFCell: .purchased) }))
        }
        
        // Сохранение параметра свернутости развернутости списка
        guard shouldSaveExpanding else { return dataSourceArray = newArray }
        for (ind, newValue) in newArray.enumerated() {
            dataSourceArray.forEach({ oldValue in
                if newValue.name == oldValue.name {
                    newArray[ind].isExpanded = oldValue.isExpanded
                }
            })
        }
        dataSourceArray = newArray
    }
    
    // MARK: - Сортировка по секциям
    private func createArrayWithSections() {
        var dict: [ String: [Product] ] = [:]
        
        var dictPurchased: [ String: [Product] ] = [:]
        dictPurchased["Purchased".localized] = []
        
        var dictFavorite: [ String: [Product] ] = [:]
        dictFavorite["Favorite"] = []
        
        // тип сортировки
        let products = products.sorted(by: { $0.dateOfCreation < $1.dateOfCreation })
        products.forEach({ product in
           
            guard !product.isPurchased else { dictPurchased["Purchased".localized]?.append(product); return }
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
            newArray.append(contentsOf: dictFavorite.map({ Category(name: $0.key, products: $0.value, typeOFCell: .favorite) }))
        }
        
        // Все что не избрано и не куплено
        newArray.append(contentsOf: dict.map({ Category(name: $0.key, products: $0.value, typeOFCell: .normal) }).sorted(by: { $0.name < $1.name }))
        
        // Все что куплено
        if products.contains(where: { $0.isPurchased }) {
            newArray.append(contentsOf: dictPurchased.map({ Category(name: $0.key, products: $0.value, typeOFCell: .purchased) }))
        }
        
        // Сохранение параметра свернутости развернутости списка
        guard shouldSaveExpanding else { return dataSourceArray = newArray }
        for (ind, newValue) in newArray.enumerated() {
            dataSourceArray.forEach({ oldValue in
                if newValue.name == oldValue.name {
                    newArray[ind].isExpanded = oldValue.isExpanded
                }
            })
        }
        dataSourceArray = newArray
    }
    
    func updatePurchasedStatus(for product: Product) {
        var newProduct = product
        newProduct.isPurchased = !product.isPurchased
        CoreDataManager.shared.createProduct(product: newProduct)
        createDataSourceArray()
    }
    
    func updateFavoriteStatus(for product: Product) {
        var newProduct = product
        newProduct.isFavorite = !product.isFavorite
        CoreDataManager.shared.createProduct(product: newProduct)
        createDataSourceArray()
    }
    
    func updateImage(for product: Product) {
        CoreDataManager.shared.createProduct(product: product)
        createDataSourceArray()
    }
    
    func delete(product: Product) {
        CoreDataManager.shared.removeProduct(product: product)
        if products.isEmpty { dataSourceArray = [] }
        createDataSourceArray()
    }
        
}
