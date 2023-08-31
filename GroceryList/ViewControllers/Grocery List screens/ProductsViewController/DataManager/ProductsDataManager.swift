//
//  ProductsDataManager.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 11.11.2022.
//

import UIKit

class ProductsDataManager {
    
    var dataChangedCallBack: (() -> Void)?
    var products: [Product] {
        getProducts()
    }
    var groceryListId: UUID
    var typeOfSorting: SortingType {
        didSet {
            shouldSaveExpanding = false
            createDataSourceArray()
        }
    }
    var typeOfSortingPurchased: SortingType = .category {
        didSet {
            shouldSaveExpanding = false
            createDataSourceArray()
        }
    }
    var isAscendingOrder = true
    var isAscendingOrderPurchased = true
    var dataSourceArray: [Category] = [] {
        didSet {
            dataChangedCallBack?()
        }
    }
    var isEditState = false
    
    private(set) var editProducts: [Product] = []
    private var shouldSaveExpanding: Bool = false
    private var isVisibleCost: Bool = false
    private var users: [User] = []
    private var outOfStockProducts: [Product] {
        getOutOfStockProducts()
    }
    private var itemsInStock: [Stock] = []

    init (products: [Product], typeOfSorting: SortingType,
          groceryListId: UUID) {
        self.typeOfSorting = typeOfSorting
        self.groceryListId = groceryListId
        
        if let domainList = CoreDataManager.shared.getList(list: groceryListId.uuidString) {
            typeOfSortingPurchased = SortingType(rawValue: Int(domainList.typeOfSortingPurchased)) ?? .category
            isAscendingOrder = domainList.isAscendingOrder
            isAscendingOrderPurchased = getIsAscendingOrderPurchased(domainList.isAscendingOrderPurchased)
            if let sharedId = domainList.sharedListId {
                users = SharedListManager.shared.sharedListsUsers[sharedId] ?? []
            }
        }
        
        itemsInStock = getItemsInStock()
    }

    func createDataSourceArray() {
        let allProducts = products + outOfStockProducts
        if allProducts.isEmpty {
            dataSourceArray = []
            return
        }
        createSortedProducts(products: allProducts)
        shouldSaveExpanding = true
    }
    
    func appendCopiedProducts(product: [Product]) {
        createDataSourceArray()
    }
    
    func updatePurchasedStatus(for product: Product) {
        var newProduct = product
        newProduct.isPurchased = !product.isPurchased
        CoreDataManager.shared.createProduct(product: newProduct)
        CloudManager.shared.saveCloudData(product: newProduct)
        createDataSourceArray()
    }
    
    func updateFavoriteStatus(for product: Product) {
        var newProduct = product
        newProduct.isFavorite = !product.isFavorite
        CoreDataManager.shared.createProduct(product: newProduct)
        CloudManager.shared.saveCloudData(product: newProduct)
        createDataSourceArray()
    }
    
    func updateStockStatus(for product: Product) {
        let stockId = product.id
        guard let dbStock = CoreDataManager.shared.getStock(by: stockId) else {
            return
        }
        
        var stock = Stock(dbModel: dbStock)
        stock.isAvailability = true
        CoreDataManager.shared.saveStock(stocks: [stock], for: stock.pantryId.uuidString)
        CloudManager.shared.saveCloudData(stock: stock)
        createDataSourceArray()
    }
    
    func updateImage(for product: Product) {
        CoreDataManager.shared.createProduct(product: product)
        CloudManager.shared.saveCloudData(product: product)
        createDataSourceArray()
    }
    
    func delete(product: Product) {
        CoreDataManager.shared.removeProduct(product: product)
        CloudManager.shared.delete(recordType: .product, recordID: product.recordId)
        createDataSourceArray()
    }
    
    func updateEditProduct(_ product: Product) {
        if editProducts.contains(where: { $0.id == product.id }) {
            editProducts.removeAll { $0.id == product.id }
            return
        }
        editProducts.append(product)
    }
    
    func resetEditProduct() {
        editProducts.removeAll()
    }
    
    func addEditAllProducts() {
        editProducts.removeAll()
        editProducts = products
    }
    
    func getTotalCost() -> Double? {
        let products = dataSourceArray.flatMap { $0.products }
        let cost = products.compactMap { calculateCost(quantity: $0.quantity, cost: $0.cost) }
        guard !cost.isEmpty else {
            return nil
        }
        return cost.reduce(0, +)
    }
    
    func getPurchasedCost() -> Double? {
        let cost = products.filter({ $0.isPurchased })
                           .compactMap { calculateCost(quantity: $0.quantity, cost: $0.cost) }
        guard !cost.isEmpty else {
            return nil
        }
        return cost.reduce(0, +)
    }
    
    func removeInStockInfo(product: Product) {
        guard let itemInStockId = product.inStock else {
            return
        }
        itemsInStock.removeAll { $0.id == itemInStockId }
        createDataSourceArray()
    }
    
    private func getProducts() -> [Product] {
        guard let domainList = CoreDataManager.shared.getList(list: groceryListId.uuidString) else { return [] }
        let localList = DomainModelsToLocalTransformer().transformCoreDataModelToModel(domainList)
        isVisibleCost = localList.isVisibleCost
        
        var products = localList.products
        products.enumerated().forEach { (index, product) in
            itemsInStock.forEach { stock in
                if stock.name.lowercased() == product.name.lowercased() {
                    products[index].inStock = stock.id
                    AmplitudeManager.shared.logEvent(.pantryItemInStock)
                }
            }
        }
        
        return products
    }
    
    private func getOutOfStockProducts() -> [Product] {
        if isEditState {
            return []
        }
        var outOfStockProducts: [Product] = []
        let dbPantries = CoreDataManager.shared.getSynchronizedPantry(by: groceryListId)
        let pantries = dbPantries.map { PantryModel(dbModel: $0) }
        pantries.forEach { pantry in
            let outOfStock = pantry.stock.filter { !$0.isAvailability }
            outOfStockProducts.append(contentsOf: outOfStock.map({ Product(stock: $0, listId: groceryListId) }))
        }
        return outOfStockProducts
    }
    
    private func getItemsInStock() -> [Stock] {
        var inStock: [Stock] = []
        let dbStocks = CoreDataManager.shared.getAllStock()?.filter({ $0.isAvailability }) ?? []
        inStock = dbStocks.map({ Stock(dbModel: $0) })
        return inStock
    }
    
    func getIndexPath(for newProduct: Product) -> IndexPath {
        var index = 0
        for category in dataSourceArray {
            if category.isExpanded {
                for product in category.products {
                    if product.id == newProduct.id {
                        index += 1
                        return IndexPath(row: index, section: 0)
                    }
                    index += 1
                }
            }
            index += 1
        }
        return IndexPath(row: 0, section: 0)
    }
    
    func getSectionIndex() -> [Int] {
        var index = 0
        var sectionIndices: [Int] = []
        for category in dataSourceArray {
            sectionIndices.append(index)
            if category.isExpanded {
                for _ in category.products {
                    index += 1
                }
            }
            index += 1
        }
        // удаляем последний номер секции, так как отвечает за показ цены
        sectionIndices.removeLast()
        return sectionIndices
    }
    
    private func createSortedProducts(products: [Product]) {
        let products = getSortedProductsInOrder(products: products,
                                                isAscendingOrder: isAscendingOrder,
                                                typeOfSorting: typeOfSorting)
        var newArray: [Category] = []
        
        // Избранное
        let dictFavorite = getDictionaryFavorite(by: products)
        if products.contains(where: { $0.isFavorite && !$0.isPurchased }) {
            newArray.append(contentsOf: dictFavorite.map({ Category(name: $0.key, products: $0.value, typeOFCell: .favorite) }))
        }
        
        // Сортировка продуктов
        let dict = getDictionaryProducts(by: products, isPurchased: false)
        newArray.append(contentsOf: getSortCategory(dict: dict.base, isPurchased: false))
        newArray.append(contentsOf: getSortCategory(dict: dict.other, isPurchased: false))
        
        // Все что куплено
        let dictPurchased = getDictionaryProducts(by: products, isPurchased: true)
        if products.contains(where: { $0.isPurchased }) {
            newArray.append(Category(name: "Purchased".localized, products: [],
                                     cost: getPurchasedCost(),
                                     isVisibleCost: isVisibleCost, typeOFCell: .purchased))
            
            newArray.append(contentsOf: getSortCategory(dict: dictPurchased.base, isPurchased: true))
            newArray.append(contentsOf: getSortCategory(dict: dictPurchased.other, isPurchased: true))
        }
        
        newArray.append(Category(name: "", products: [], typeOFCell: .displayCostSwitch))
        saveExpanding(newArray: newArray)
    }
    
    private func getSortedProductsInOrder(products: [Product],
                                          isAscendingOrder: Bool, typeOfSorting: SortingType) -> [Product] {
        guard isAscendingOrder else {
            switch typeOfSorting {
            case .category, .time, .user:
                return products.sorted(by: { $0.dateOfCreation > $1.dateOfCreation })
            case .alphabet, .recipe, .store:
                return products.sorted(by: { $0.name > $1.name })
            }
        }
        switch typeOfSorting {
        case .category, .time, .user:
            return products.sorted(by: { $0.dateOfCreation < $1.dateOfCreation })
        case .alphabet, .recipe, .store:
            return products.sorted(by: { $0.name < $1.name })
        }
    }
    
    private func getDictionaryFavorite(by products: [Product]) -> [String: [Product]] {
        var dictFavorite: [String: [Product]] = [:]
        dictFavorite["DictionaryFavorite"] = []
        let favoriteProducts = products.filter { $0.isFavorite && !$0.isPurchased }
        favoriteProducts.forEach { dictFavorite["DictionaryFavorite"]?.append($0) }
        
        return dictFavorite
    }
    
    private func getDictionaryProducts(by products: [Product], isPurchased: Bool) ->
    (base: [String: [Product]], other: [String: [Product]]) {
        var baseDict: [String: [Product]] = [:]
        var otherDict: [String: [Product]] = [:]
        let typeOfSort = isPurchased ? typeOfSortingPurchased : typeOfSorting
        let sortProducts = getProducts(products: products, isPurchased: isPurchased)
        
        sortProducts.forEach({ product in
            switch typeOfSort {
            case .category:
                baseDict.add(product, toArrayOn: product.category)
            case .alphabet:
                baseDict.add(product, toArrayOn: "alphabeticalSorted")
            case .time:
                if let recipeTitle = product.fromRecipeTitle {
                    baseDict.add(product, toArrayOn: recipeTitle)
                } else {
                    otherDict.add(product, toArrayOn: R.string.localizable.addedEarlier())
                }
            case .recipe:
                if let recipeTitle = product.fromRecipeTitle {
                    let dicTitle = R.string.localizable.recipe().getTitleWithout(symbols: [" "]) + ": " + recipeTitle
                    baseDict.add(product, toArrayOn: dicTitle)
                } else {
                    otherDict.add(product, toArrayOn: R.string.localizable.other())
                }
            case .user:
                if !(product.userToken == "0"), let userToken = product.userToken,
                    let dicTitle = getUserName(by: userToken) {
                    baseDict.add(product, toArrayOn: dicTitle)
                } else {
                    otherDict.add(product, toArrayOn: R.string.localizable.addedEarlier())
                }
            case .store:
                if let storeTitle = product.store?.title {
                    baseDict.add(product, toArrayOn: storeTitle)
                } else {
                    otherDict.add(product, toArrayOn: R.string.localizable.other())
                }
            }
        })
        return (baseDict, otherDict)
    }
    
    private func getProducts(products: [Product], isPurchased: Bool) -> [Product] {
        guard isPurchased else {
            return filteredProducts(products: products)
        }
        let purchasedProducts = products.filter { $0.isPurchased || $0.category == "Purchased".localized }
        return getSortedProductsInOrder(products: purchasedProducts, isAscendingOrder: isAscendingOrderPurchased,
                                        typeOfSorting: typeOfSortingPurchased)
    }
    
    private func filteredProducts(products: [Product]) -> [Product] {
        var products = products.filter { !$0.isPurchased }
        products = products.filter { !$0.isFavorite }
        products = products.filter { $0.category != "Purchased".localized }
        return products
    }
    
    private func getSortCategory(dict: [String: [Product]], isPurchased: Bool) -> [Category] {
        let typeOfSort = isPurchased ? typeOfSortingPurchased : typeOfSorting
        var categories: [Category] = []
        var typeOFCell: TypeOfCell = .normal
        switch typeOfSort {
        case .category:     typeOFCell = .normal
        case .recipe:       typeOFCell = .sortedByRecipe
        case .time:         typeOFCell = .sortedByDate
        case .alphabet:     typeOFCell = .sortedByAlphabet
        case .user:         typeOFCell = .sortedByUser
        case .store:        typeOFCell = .normal
        }
        
        categories = dict.map({ Category(name: $0.key, products: $0.value,
                                         typeOFCell: $0.key == "" ? .withoutCategory : typeOFCell) })
        let isAscendingOrder = isPurchased ? isAscendingOrderPurchased : isAscendingOrder
        guard isAscendingOrder else {
            return categories.sorted(by: { $0.name > $1.name })
        }
        return categories.sorted(by: { $0.name < $1.name })
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
    
    private func getIsAscendingOrderPurchased(_ dbIsAscendingOrderPurchased: Int16) -> Bool {
        guard let isAscendingOrder = BoolWithNilForCD(rawValue: dbIsAscendingOrderPurchased) else {
            return isAscendingOrder
        }
        return isAscendingOrder.getBool(defaultValue: self.isAscendingOrder)
    }
    
    private func getUserName(by token: String) -> String? {
        guard let user = users.first(where: { $0.token == token }) else {
            return nil
        }
        return user.username ?? user.email
    }
    
    private func calculateCost(quantity: Double?, cost: Double?) -> Double? {
        guard quantity != 0 && cost != 0 else {
            return nil
        }
        
        guard let cost else {
            return nil
        }
        
        if let quantity {
            if quantity == 0 {
                return cost
            }
            return quantity * cost
        } else {
            return cost
        }
    }
}
