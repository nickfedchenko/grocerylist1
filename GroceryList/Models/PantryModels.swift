//
//  PantryModels.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 24.05.2023.
//

import Foundation

struct PantryModel: Hashable, Codable {
    var id = UUID()
    var name: String
    var index: Int = 0
    var color: Int
    var icon: Data?
    var stock: [Stock]
    var synchronizedLists: [UUID]
    
    var dateOfCreation: Date
    var sharedId: String = ""
    var isShared: Bool = false
    var isSharedListOwner: Bool = false
    
    var isShowImage: BoolWithNilForCD = .nothing
    var isVisibleCost: Bool = false
    
    init(id: UUID = UUID(), name: String, index: Int, color: Int, icon: Data? = nil,
         stock: [Stock] = [], synchronizedLists: [UUID] = [],
         dateOfCreation: Date = Date(), sharedId: String = "", isShared: Bool = false,
         isSharedListOwner: Bool = false, isShowImage: BoolWithNilForCD = .nothing,
         isVisibleCost: Bool = false) {
        self.id = id
        self.name = name
        self.index = index
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
    
    init(dbModel: DBPantry) {
        id = dbModel.id
        name = dbModel.name
        index = Int(dbModel.index)
        color = Int(dbModel.color)
        icon = dbModel.icon
        let dbStocks = dbModel.stocks?.allObjects as? [DBStock]
        stock = dbStocks?.map({ Stock(dbModel: $0,
                                      isVisibleСost: dbModel.isVisibleCost) }) ?? []
        synchronizedLists = (try? JSONDecoder().decode([UUID].self, from: dbModel.synchronizedLists ?? Data())) ?? []
        dateOfCreation = dbModel.dateOfCreation
        sharedId = dbModel.sharedId ?? ""
        isShared = dbModel.isShared
        isSharedListOwner = dbModel.isSharedListOwner
        isShowImage = BoolWithNilForCD(rawValue: dbModel.isShowImage) ?? .nothing
        isVisibleCost = dbModel.isVisibleCost
    }
    
    init(sharedList: SharedPantryModel, stock: [Stock]) {
        id = sharedList.id
        name = sharedList.name
        index = -100
        color = sharedList.color
        icon = sharedList.icon
        self.stock = stock
        isShared = true
        isSharedListOwner = sharedList.isSharedListOwner
        dateOfCreation = Date()
        synchronizedLists = []
    }
}

struct Stock: Hashable, Codable {
    var id = UUID()
    var index: Int = 0
    var pantryId: UUID
    var name: String
    var imageData: Data?
    var description: String?
    var category: String?
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
        self.id = UUID()
        self.index = copyStock.index
        self.pantryId = copyStock.pantryId
        self.name = copyStock.name
        self.category = copyStock.category
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
    
    init(index: Int, pantryId: UUID, name: String, imageData: Data?,
         description: String? = nil, category: String? = nil,
         store: Store? = nil, cost: Double? = nil, quantity: Double? = nil,
         unitId: UnitSystem? = nil, isAvailability: Bool = true,
         isAutoRepeat: Bool = false, autoRepeat: AutoRepeatModel? = nil,
         isReminder: Bool = false) {
        self.index = index
        self.pantryId = pantryId
        self.name = name
        self.imageData = imageData
        self.description = description
        self.category = category
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
    
    init(dbModel: DBStock, isVisibleСost: Bool = false) {
        id = dbModel.id
        index = Int(dbModel.index)
        pantryId = dbModel.pantryId
        name = dbModel.name
        imageData = dbModel.imageData
        description = dbModel.stockDescription
        category = dbModel.category
        let storeFromDB = (try? JSONDecoder().decode(Store.self, from: dbModel.store ?? Data()))
        store = storeFromDB?.title == "" ? nil : storeFromDB
        cost = dbModel.cost
        quantity = dbModel.quantity
        unitId = UnitSystem(rawValue: Int(dbModel.unitId))
        isAvailability = dbModel.isAvailability
        isAutoRepeat = dbModel.isAutoRepeat
        autoRepeat = (try? JSONDecoder().decode(AutoRepeatModel.self, from: dbModel.autoRepeat ?? Data()))
        isReminder = dbModel.isReminder
        dateOfCreation = dbModel.dateOfCreation
        isUserImage = dbModel.isUserImage
        userToken = dbModel.userToken
        self.isVisibleСost = isVisibleСost
    }
    
    init(sharedStock: SharedStock) {
        id = sharedStock.id
        index = sharedStock.index
        pantryId = sharedStock.pantryId
        name = sharedStock.name
        imageData = sharedStock.imageData
        description = sharedStock.description
        category = sharedStock.category
        store = sharedStock.store
        cost = sharedStock.cost
        quantity = sharedStock.quantity
        unitId = sharedStock.unitId
        isAvailability = sharedStock.isAvailability
        isAutoRepeat = sharedStock.isAutoRepeat
        autoRepeat = sharedStock.autoRepeat
        isReminder = false
        isUserImage = sharedStock.isUserImage
        userToken = sharedStock.userToken ?? "0"
        dateOfCreation = Date()
    }
}

struct AutoRepeatModel: Hashable, Codable {
    let state: StockAutoRepeat
    let times: Int?
    let weekday: Int?
    let period: RepeatPeriods?
}

enum StockAutoRepeat: Int, Codable, CaseIterable {
    case daily
    case weekly
    case monthly
    case yearly
    case custom
}

enum RepeatPeriods: Int, Codable, CaseIterable {
    case days
    case weeks
    case months
    case years
}

struct PantryStocks: Hashable {
    var name: String
    var stock: [Stock]
    var typeOFCell: TypeOfCellPantryStocks
    
    init(name: String, stock: [Stock], typeOFCell: TypeOfCellPantryStocks) {
        self.name = name
        self.stock = stock
        self.typeOFCell = typeOFCell
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

enum TypeOfCellPantryStocks {
    case outOfStock
    case inStock
    case normal
}
