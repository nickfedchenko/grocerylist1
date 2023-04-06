//
//  ProductsDataManager.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 11.11.2022.
//

import UIKit

class ProductsDataManager {
    
    private var shouldSaveExpanding: Bool = false
    private var users: [User] = []
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
        if let domainList = CoreDataManager.shared.getList(list: groceryListId),
            let sharedId = domainList.sharedListId {
            users = SharedListManager.shared.sharedListsUsers[sharedId] ?? []
        }
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
        if typeOfSorting == .user { createArraySortedByUsers() }
        if typeOfSorting == .category { createArrayWithSections() }
        if typeOfSorting == .alphabet { createArraySortedByAlphabet() }
        if typeOfSorting == .recipe { createArraySortedByRecipe() }
        if typeOfSorting == .time { createArraySortedByTime() }
        shouldSaveExpanding = true
    }
    
    func appendCopiedProducts(product: [Product]) {
        createDataSourceArray()
    }
    
    // MARK: - Сортировка по алфавиту
    private func createArraySortedByAlphabet() {
        let products = products.sorted(by: { $0.name < $1.name })
        var dict: [ String: [Product] ] = [:]
        
        // сортировкa
        products.forEach({ product in
            guard !product.isPurchased || product.isFavorite else { return }

            if dict["alphabeticalSorted"] != nil {
                dict["alphabeticalSorted"]?.append(product)
            } else {
                dict["alphabeticalSorted"] = [product]
            }
        })
        
        var newArray: [Category] = []
        let dictPurchased = getDictionaryPurchased(by: products)
        let dictFavorite = getDictionaryFavorite(by: products)
        
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
        
        saveExpanding(newArray: newArray)
    }
    
    // MARK: - Сортировка по Дате добавления
    private func createArraySortedByTime() {
        let products = products.sorted(by: { $0.dateOfCreation < $1.dateOfCreation })
        let idForDict = R.string.localizable.addedEarlier()
        var dict: [ String: [Product] ] = [:]
        var recipesDict: [String: [Product]] = [:]
        
        // сортировкa
        products.forEach({ product in
            guard !product.isPurchased || product.isFavorite else { return }
            
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
        let dictPurchased = getDictionaryPurchased(by: products)
        let dictFavorite = getDictionaryFavorite(by: products)
        
        // Избранное
        if products.contains(where: { $0.isFavorite && !$0.isPurchased }) {
            newArray.append(contentsOf: dictFavorite.map({ Category(name: $0.key, products: $0.value, typeOFCell: .favorite) }))
        }
        
        newArray.append(contentsOf: dict.map({ Category(name: $0.key, products: $0.value, typeOFCell: .sortedByDate) })
                                        .sorted(by: { $0.name < $1.name }))
        
        if products.contains(where: { $0.fromRecipeTitle != nil }) {
            newArray.append(contentsOf: recipesDict.map({ Category(name: $0.key, products: $0.value, typeOFCell: .sortedByDate) }))
        }
 
        // Все что куплено
        if products.contains(where: { $0.isPurchased }) {
            newArray.append(contentsOf: dictPurchased.map({ Category(name: $0.key, products: $0.value, typeOFCell: .purchased) }))
        }
        
        saveExpanding(newArray: newArray)
    }
    
    // MARK: - Сортировка по рецепту
    private func createArraySortedByRecipe() {
        let products = products.sorted(by: { $0.dateOfCreation < $1.dateOfCreation })
        var recipesDict: [String: [Product]] = [:]
        var dict: [ String: [Product] ] = [:]
        dict[R.string.localizable.other()] = []

        // сортировкa
        products.forEach({ product in
            guard !product.isPurchased || product.isFavorite else { return }
            
            guard product.fromRecipeTitle != nil else {
                dict[R.string.localizable.other()]?.append(product)
                return
            }
            
            guard let recipeTitle = product.fromRecipeTitle else {
                return
            }
            let dicTitle = R.string.localizable.recipe().getTitleWithout(symbols: [" "]) + ": " + recipeTitle
            if recipesDict[dicTitle] != nil {
                recipesDict[dicTitle]?.append(product)
            } else {
                recipesDict[dicTitle] = [product]
            }
        })
        
        var newArray: [Category] = []
        let dictPurchased = getDictionaryPurchased(by: products)
        let dictFavorite = getDictionaryFavorite(by: products)
        
        // Избранное
        if products.contains(where: { $0.isFavorite && !$0.isPurchased }) {
            newArray.append(contentsOf: dictFavorite.map({ Category(name: $0.key, products: $0.value, typeOFCell: .favorite) }))
        }
        
        if products.contains(where: { $0.fromRecipeTitle != nil }) {
            newArray.append(contentsOf: recipesDict.map({ Category(name: $0.key, products: $0.value, typeOFCell: .sortedByRecipe) }))
        }
        
        if !(dict[R.string.localizable.other()]?.isEmpty ?? true) {
            newArray.append(contentsOf: dict.map({ Category(name: $0.key, products: $0.value, typeOFCell: .sortedByRecipe) }))
        }
 
        // Все что куплено
        if products.contains(where: { $0.isPurchased }) {
            newArray.append(contentsOf: dictPurchased.map({ Category(name: $0.key, products: $0.value, typeOFCell: .purchased) }))
        }
        
        saveExpanding(newArray: newArray)
    }
    
    // MARK: - Сортировка по секциям
    private func createArrayWithSections() {
        let products = products.sorted(by: { $0.dateOfCreation < $1.dateOfCreation })
        var dict: [ String: [Product] ] = [:]
        
        // сортировкa
        products.forEach({ product in
            guard !product.isPurchased || product.isFavorite else { return }

            if dict[product.category] != nil {
                dict[product.category]?.append(product)
            } else {
                dict[product.category] = [product]
            }
        })
        
        var newArray: [Category] = []
        let dictPurchased = getDictionaryPurchased(by: products)
        let dictFavorite = getDictionaryFavorite(by: products)
        
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
        
        saveExpanding(newArray: newArray)
    }
    
    // MARK: - Сортировка по пользователям
    private func createArraySortedByUsers() {
        let products = products.sorted(by: { $0.dateOfCreation < $1.dateOfCreation })
        let keyDictWithoutUser = R.string.localizable.addedEarlier()
        var dictWithoutUser: [String: [Product]] = [:]
        var usersDict: [String: [Product]] = [:]
        dictWithoutUser[keyDictWithoutUser] = []
        
        products.forEach({ product in
            guard !product.isPurchased || product.isFavorite else { return }
            
            guard !(product.userToken == "0") else {
                dictWithoutUser[keyDictWithoutUser]?.append(product)
                return
            }
            
            guard let userToken = product.userToken,
                  let dicTitle = getUserName(by: userToken) else {
                return
            }
            
            if usersDict[dicTitle] != nil {
                usersDict[dicTitle]?.append(product)
            } else {
                usersDict[dicTitle] = [product]
            }
        })
        
        var newArray: [Category] = []
        let dictPurchased = getDictionaryPurchased(by: products)
        let dictFavorite = getDictionaryFavorite(by: products)
        
        // Избранное
        if products.contains(where: { $0.isFavorite && !$0.isPurchased }) {
            newArray.append(contentsOf: dictFavorite.map({ Category(name: $0.key, products: $0.value, typeOFCell: .favorite) }))
        }
        // Пользователи
        if products.contains(where: { $0.userToken != nil }) {
            newArray.append(contentsOf: usersDict.map({ Category(name: $0.key, products: $0.value, typeOFCell: .sortedByUser) })
                                                 .sorted(by: { $0.name < $1.name }))
        }
        // Ранее добавленные пользователи, когда не было данной фичи
        if !(dictWithoutUser[keyDictWithoutUser]?.isEmpty ?? true) {
            newArray.append(contentsOf: dictWithoutUser.map({ Category(name: $0.key, products: $0.value, typeOFCell: .sortedByUser) }))
        }
        // Все что куплено
        if products.contains(where: { $0.isPurchased }) {
            newArray.append(contentsOf: dictPurchased.map({ Category(name: $0.key, products: $0.value, typeOFCell: .purchased) }))
        }
        
        saveExpanding(newArray: newArray)
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
    
    private func getDictionaryPurchased(by products: [Product]) -> [String: [Product]] {
        var dictPurchased: [String: [Product]] = [:]
        dictPurchased["Purchased".localized] = []
        let purchasedProducts = products.filter { $0.isPurchased }
        purchasedProducts.forEach { dictPurchased["Purchased".localized]?.append($0) }

        return dictPurchased
    }
    
    private func getDictionaryFavorite(by products: [Product]) -> [String: [Product]] {
        var dictFavorite: [String: [Product]] = [:]
        dictFavorite["Favorite"] = []
        let favoriteProducts = products.filter { $0.isFavorite }
        favoriteProducts.forEach { dictFavorite["Favorite"]?.append($0) }
        
        return dictFavorite
    }
    
    /// Сохранение параметра свернутости развернутости списка
    private func saveExpanding(newArray: [Category]) {
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
    
    private func getUserName(by token: String) -> String? {
        guard let user = users.first(where: { $0.token == token }) else {
            return nil
        }
        return user.username ?? user.email
    }
}
