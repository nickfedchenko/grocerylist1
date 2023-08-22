//
//  CloudModels.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 22.08.2023.
//

import UIKit

struct CKProduct {
    var id: Int64
    var listId: Int64
    var recordId: String
    
    var dateOfCreation: Date
    var name: String
    var description: String
    var category: String
    var imageData: Data?
    var fromRecipeTitle: String?
    var unitId: UnitSystem?
    var store: CKStore?
    var cost: Double?
    var quantity: Double?
    var userToken: String?
    
    var isPurchased: Int64
    var isFavorite: Int64
    var isUserImage: Int64
    
    init(product: Product) {
        id = product.id.int64
        listId = product.listId.int64
        recordId = product.recordId
        dateOfCreation = product.dateOfCreation
        name = product.name
        description = product.description
        category = product.category
        imageData = product.imageData
        fromRecipeTitle = product.fromRecipeTitle
        unitId = product.unitId
        store = CKStore(store: product.store)
        cost = product.cost
        quantity = product.quantity
        userToken = product.userToken
        isPurchased = product.isPurchased.asInt64
        isFavorite = product.isFavorite.asInt64
        isUserImage = product.isUserImage?.asInt64 ?? 0
    }
}

struct CKStore {
    var id: Int64
    var recordId: String
    var title: String
    var createdAt: Date
    
    init?(store: Store?) {
        guard let store else {
            return nil
        }
        id = store.id.int64
        recordId = store.recordId
        title = store.title
        createdAt = store.createdAt
    }
}

struct CKStock {
    var id: Int64
    var recordId: String
    var pantryId: Int64
    var index: Int64 = 0
    var name: String
    var imageData: Data?
    var description: String?
    var category: String?
    var store: CKStore?
    var cost: Double?
    var quantity: Double?
    var unitId: UnitSystem?
    var isAvailability: Bool
    var isAutoRepeat: Bool
    var autoRepeat: AutoRepeatModel?
    var isReminder: Int64
    var dateOfCreation: Date
    var isUserImage: Int64
    var userToken: String?
    
    init(stock: Stock) {
        id = stock.id.int64
        recordId = stock.recordId
        pantryId = stock.pantryId.int64
        index = stock.index.asInt64
        name = stock.name
        imageData = stock.imageData
        description = stock.description
        category = stock.category
        store = CKStore(store: stock.store)
        cost = stock.cost
        quantity = stock.quantity
        unitId = stock.unitId
        isAvailability = stock.isAvailability
        isAutoRepeat = stock.isAutoRepeat
        autoRepeat = stock.autoRepeat
        isReminder = stock.isReminder.asInt64
        dateOfCreation = stock.dateOfCreation
        isUserImage = stock.isUserImage.asInt64
        userToken = stock.userToken
    }
    
}
