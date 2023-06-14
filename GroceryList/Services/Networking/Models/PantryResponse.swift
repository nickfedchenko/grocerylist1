//
//  PantryResponse.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 08.06.2023.
//

import Foundation

struct SharePantryResponse: Codable {
    var error: Bool
    var messages: [String]
    var sharingToken: String
    var pantryListId: String
    var url: String
    
    enum CodingKeys: String, CodingKey {
        case error, messages, sharingToken = "sharing_token", pantryListId = "pantry_list_id", url
    }
}

struct PantryListReleaseResponse: Codable {
    var error: Bool
    var messages: [String]
    var success: Bool?
    var id: String?
}

struct PantryListDeleteResponse: Codable {
    var error: Bool
    var messages: [String]
    var success: Bool?
}

struct UpdatePantryResponse: Codable {
    var error: Bool
    var messages: [String]
    var success: Bool?
}

struct PantryListUserDeleteResponse: Codable {
    var error: Bool
    var messages: [String]
    var success: Bool?
}

struct FetchMyPantryListsResponse: Codable {
    var error: Bool
    var messages: [String]
    var items: [FetchMyPantryListsItems]
}

struct FetchMyPantryListsItems: Codable {
    var pantryListId: String
    var isOwner: Bool
    var createdAt: String
    var pantryList: SharedPantryModel
    var users: [User]
    
    enum CodingKeys: String, CodingKey {
        case pantryListId = "pantry_list_id"
        case isOwner = "is_owner"
        case createdAt = "created_at"
        case pantryList = "pantry_list"
        case users = "users"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let listId = try container.decode(String.self, forKey: .pantryListId)
        pantryListId = listId == "" ? "-1" : listId
        isOwner = try container.decode(Bool.self, forKey: .isOwner)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        users = try container.decode([User].self, forKey: .users)

        if let pantryList = try? container.decode(SharedPantryModel.self, forKey: .pantryList) {
            self.pantryList = pantryList
        } else {
            pantryList = SharedPantryModel()
        }
    }
}

struct FetchPantryListUsersResponse: Codable {
    var error: Bool
    var messages: [String]
    var users: [User]
}

struct SharedPantryModel: Codable {
    var id: UUID
    var dateOfCreation: Double
    var name: String
    var icon: Data?
    var color: Int
    var stock: [SharedStock]
    var sharedId: String?
    var isShared: Bool? = false
    var isSharedListOwner: Bool
    var isShowImage: BoolWithNilForCD? = .nothing
    
    init() {
        id = UUID()
        dateOfCreation = 0
        name = "No name"
        color = 1
        stock = []
        sharedId = nil
        isShared = false
        isSharedListOwner = false
        isShowImage = nil
    }
}

struct SharedStock: Codable {
    var id: UUID
    var index: Int
    var pantryId: UUID
    var name: String
    var dateOfCreation: Double
    var category: String?
    var imageData: Data?
    var description: String?
    var store: Store?
    var cost: Double?
    var quantity: Double?
    var unitId: UnitSystem?
    var isAvailability: Bool
    var isAutoRepeat: Bool
    var autoRepeat: AutoRepeatModel?
    var isUserImage: Bool? = false
    var userToken: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case index
        case pantryId
        case name
        case dateOfCreation
        case category
        case imageData
        case description
        case store
        case cost
        case quantity
        case unitId
        case isAvailability
        case isAutoRepeat
        case autoRepeat
        case isUserImage
        case userToken
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        index = try container.decode(Int.self, forKey: .index)
        pantryId = try container.decode(UUID.self, forKey: .pantryId)
        name = try container.decode(String.self, forKey: .name)
        dateOfCreation = try container.decode(Double.self, forKey: .dateOfCreation)
        category = try? container.decode(String.self, forKey: .category)
        imageData = try? container.decode(Data.self, forKey: .imageData)
        description = try? container.decode(String.self, forKey: .description)
        store = try? container.decode(Store.self, forKey: .store)
        unitId = try? container.decode(UnitSystem.self, forKey: .unitId)
        isAvailability = try container.decode(Bool.self, forKey: .isAvailability)
        isAutoRepeat = try container.decode(Bool.self, forKey: .isAutoRepeat)
        autoRepeat = try? container.decode(AutoRepeatModel.self, forKey: .autoRepeat)
        isUserImage = try? container.decode(Bool.self, forKey: .isUserImage)
        userToken = try? container.decode(String.self, forKey: .userToken)
        
        if let costInt = try? container.decode(Int.self, forKey: .cost) {
            cost = Double(costInt)
        } else if let costDouble = try? container.decode(Double.self, forKey: .cost) {
            cost = costDouble
        }
        
        if let quantityInt = try? container.decode(Int.self, forKey: .quantity) {
            quantity = Double(quantityInt)
        } else if let quantityDouble = try? container.decode(Double.self, forKey: .quantity) {
            quantity = quantityDouble
        }
    }
}
