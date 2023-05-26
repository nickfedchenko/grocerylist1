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
    
    var dateOfCreation: Date
    var isUserImage: Bool? = false
    var userToken: String?
    var isVisibleСost: Bool = false
}
