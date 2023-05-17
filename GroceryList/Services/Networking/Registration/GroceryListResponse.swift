//
//  GroceryListResponse.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 17.02.2023.
//

import Foundation

struct GroceryListReleaseResponse: Codable {
    var error: Bool
    var messages: [String]
    var success: Bool?
    var id: String?
}

struct GroceryListDeleteResponse: Codable {
    var error: Bool
    var messages: [String]
    var success: Bool?
}

struct FetchMyGroceryListsResponse: Codable {
    var error: Bool
    var messages: [String]
    var items: [FetchMyGroceryListsItems]
}

struct FetchMyGroceryListsItems: Codable {
    var groceryListId: String
    var isOwner: Bool
    var createdAt: String
    var groceryList: SharedGroceryList
    var users: [User]
    
    enum CodingKeys: String, CodingKey {
        case groceryListId = "grocery_list_id", isOwner = "is_owner", createdAt = "created_at", groceryList = "grocery_list", users = "users"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let listId = try container.decode(String.self, forKey: .groceryListId)
        groceryListId = listId == "" ? "-1" : listId
        isOwner = try container.decode(Bool.self, forKey: .isOwner)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        users = try container.decode([User].self, forKey: .users)

        if let groceryList = try? container.decode(SharedGroceryList.self, forKey: .groceryList) {
            self.groceryList = groceryList
        } else {
            groceryList = SharedGroceryList()
        }
    }
}

struct GroceryList: Codable {
    var hello: String
    var param: String
}

struct FetchGroceryListUsersResponse: Codable {
    var error: Bool
    var messages: [String]
    var users: [User]
}

struct GroceryListUserDeleteResponse: Codable {
    var error: Bool
    var messages: [String]
    var success: Bool?
}

struct ShareGroceryListResponse: Codable {
    var error: Bool
    var messages: [String]
    var sharingToken: String
    var groceryListId: String
    var url: String
    
    enum CodingKeys: String, CodingKey {
        case error, messages, sharingToken = "sharing_token", groceryListId = "grocery_list_id", url
    }
}

struct UpdateGroceryListResponse: Codable {
    var error: Bool
    var messages: [String]
    var success: Bool?
}

struct SharedGroceryList: Codable {
    var id: UUID
    var dateOfCreation: Double
    var name: String?
    var color: Int
    var isFavorite: Bool = false
    var products: [SharedProduct]
    var typeOfSorting: Int
    var sharedId: String?
    var isShared: Bool? = false
    var isSharedListOwner: Bool
    var isShowImage: BoolWithNilForCD? = .nothing
    
    init() {
        id = UUID()
        dateOfCreation = 0
        name = ""
        color = 1
        isFavorite = false
        products = []
        typeOfSorting = 0
        sharedId = nil
        isShared = false
        isSharedListOwner = false
        isShowImage = nil
    }
}

struct SharedProduct: Codable {
    var id: UUID
    var listId: UUID
    var name: String
    var isPurchased: Bool
    var dateOfCreation: Double
    var category: String?
    var isFavorite: Bool
    var isSelected = false
    var imageData: Data?
    var description: String?
    var fromRecipeTitle: String?
    var isUserImage: Bool? = false
    var userToken: String?
    var store: Store?
    var cost: Double?
    var quantity: Double?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case listId
        case name
        case isPurchased
        case dateOfCreation
        case category
        case isFavorite
        case isSelected
        case imageData
        case description
        case fromRecipeTitle
        case isUserImage
        case userToken
        case store
        case cost
        case quantity
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        listId = try container.decode(UUID.self, forKey: .listId)
        name = try container.decode(String.self, forKey: .name)
        isPurchased = try container.decode(Bool.self, forKey: .isPurchased)
        dateOfCreation = try container.decode(Double.self, forKey: .dateOfCreation)
        category = try? container.decode(String.self, forKey: .category)
        isFavorite = try container.decode(Bool.self, forKey: .isFavorite)
        isSelected = try container.decode(Bool.self, forKey: .isSelected)
        imageData = try? container.decode(Data.self, forKey: .imageData)
        description = try? container.decode(String.self, forKey: .description)
        fromRecipeTitle = try? container.decode(String.self, forKey: .fromRecipeTitle)
        isUserImage = try? container.decode(Bool.self, forKey: .isUserImage)
        userToken = try? container.decode(String.self, forKey: .userToken)
        store = try? container.decode(Store.self, forKey: .store)
        
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
