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
    var index: Int = 0
    var color: Int
    var icon: Data?
    var stock: [StockShortModel]
    var synchronizedLists: [UUID]
    
    var dateOfCreation: Date
    var sharedId: String = ""
    var isShared: Bool = false
    var isSharedListOwner: Bool = false
    
    var isShowImage: BoolWithNilForCD = .nothing
    var isVisibleCost: Bool = false
    
    init(id: UUID = UUID(), name: String, index: Int, color: Int, icon: Data? = nil,
         stock: [StockShortModel] = [], synchronizedLists: [UUID] = [],
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
        stock = dbStocks?.map({ StockShortModel(dbModel: $0) }) ?? []
        synchronizedLists = (try? JSONDecoder().decode([UUID].self, from: dbModel.synchronizedLists ?? Data())) ?? []
        dateOfCreation = dbModel.dateOfCreation
        sharedId = dbModel.sharedId ?? ""
        isShared = dbModel.isShared
        isSharedListOwner = dbModel.isSharedListOwner
        isShowImage = BoolWithNilForCD(rawValue: dbModel.isShowImage) ?? .nothing
        isVisibleCost = dbModel.isVisibleCost
    }
}

struct Stock: Hashable, Codable {
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
        self.id = UUID()
        self.index = copyStock.index
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
    
    init(index: Int, pantryId: UUID, name: String, imageData: Data?, description: String? = nil,
         store: Store? = nil, cost: Double? = nil, quantity: Double? = nil,
         unitId: UnitSystem? = nil, isAvailability: Bool = true,
         isAutoRepeat: Bool = false, autoRepeat: AutoRepeatModel? = nil,
         isReminder: Bool = false) {
        self.index = index
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
    
    init(dbModel: DBStock) {
        id = dbModel.id
        index = Int(dbModel.index)
        pantryId = dbModel.pantryId
        name = dbModel.name
        imageData = dbModel.imageData
        description = dbModel.stockDescription
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
    }
}

struct StockShortModel: Hashable, Equatable, Codable {
    var id: UUID
    var pantryId: UUID
    var name: String
    var isAvailability: Bool
    var store: Store?
    
    init(dbModel: DBStock) {
        self.id = dbModel.id
        self.pantryId = dbModel.pantryId
        self.name = dbModel.name
        self.isAvailability = dbModel.isAvailability
        let storeFromDB = (try? JSONDecoder().decode(Store.self, from: dbModel.store ?? Data()))
        self.store = storeFromDB?.title == "" ? nil : storeFromDB
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
    case normal
}
