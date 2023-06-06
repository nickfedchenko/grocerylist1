//
//  PantryModels.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 24.05.2023.
//

import Foundation

struct PantryModel: Hashable {
    var id = UUID()
    var name: String
    var color: Int
    var icon: Data?
    var stock: [Stock]
    var synchronizedLists: [UUID]
    var isSort: Bool = false
    
    var dateOfCreation: Date
    var sharedId: String = ""
    var isShared: Bool = false
    var isSharedListOwner: Bool = false
    
    var isShowImage: BoolWithNilForCD = .nothing
    var isVisibleCost: Bool = false
    
    init(id: UUID = UUID(), name: String, color: Int, icon: Data? = nil,
         stock: [Stock] = [], synchronizedLists: [UUID] = [],
         dateOfCreation: Date = Date(), sharedId: String = "", isShared: Bool = false,
         isSharedListOwner: Bool = false, isShowImage: BoolWithNilForCD = .nothing,
         isVisibleCost: Bool = false) {
        self.id = id
        self.name = name
        self.color = color
        self.icon = icon
        self.stock = stock
        self.synchronizedLists = synchronizedLists
        self.dateOfCreation = dateOfCreation
        self.sharedId = sharedId
        self.isShared = isShared
        self.isSharedListOwner = isSharedListOwner
        self.isShowImage = isShowImage
        self.isVisibleCost = isVisibleCost
    }
}

struct Stock: Hashable {
    var id = UUID()
    var index: Int = 0
    var pantryId: UUID
    var name: String
    var imageData: Data?
    var description: String?
    var store: Store?
    var cost: Double?
    var quantity: Double?
    var unitId: UnitSystem?
    var isAvailability: Bool
    var isAutoRepeat: Bool
    var autoRepeat: AutoRepeatModel?
    var isReminder: Bool
    
    var dateOfCreation: Date
    var isUserImage: Bool? = false
    var userToken: String?
    var isVisibleСost: Bool = false
    
    init(copyStock: Stock) {
        self.pantryId = copyStock.pantryId
        self.name = copyStock.name
        self.imageData = copyStock.imageData
        self.description = copyStock.description
        self.store = copyStock.store
        self.cost = copyStock.cost
        self.quantity = copyStock.quantity
        self.unitId = copyStock.unitId
        self.isAvailability = copyStock.isAvailability
        self.isAutoRepeat = copyStock.isAutoRepeat
        self.autoRepeat = copyStock.autoRepeat
        self.isReminder = false
        self.dateOfCreation = Date()
        self.isUserImage = copyStock.isUserImage
    }
    
    init(pantryId: UUID, name: String, imageData: Data?, description: String?,
         store: Store?, cost: Double?, quantity: Double?,
         unitId: UnitSystem?, isAvailability: Bool,
         isAutoRepeat: Bool, autoRepeat: AutoRepeatModel?,
         isReminder: Bool) {
        self.pantryId = pantryId
        self.name = name
        self.imageData = imageData
        self.description = description
        self.store = store
        self.cost = cost
        self.quantity = quantity
        self.unitId = unitId
        self.isAvailability = isAvailability
        self.isAutoRepeat = isAutoRepeat
        self.autoRepeat = autoRepeat
        self.isReminder = isReminder
        self.dateOfCreation = Date()
    }
}

struct AutoRepeatModel: Hashable {
    let state: StockAutoRepeat
    let times: Int?
    let weekday: Int?
    let period: RepeatPeriods?
}

enum StockAutoRepeat: Int, CaseIterable {
    case daily
    case weekly
    case monthly
    case yearly
    case custom
}

enum RepeatPeriods: Int, CaseIterable {
    case days
    case weeks
    case months
    case years
}
