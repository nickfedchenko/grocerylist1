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
    
    enum CodingKeys: String, CodingKey {
        case groceryListId = "grocery_list_id", isOwner = "is_owner", createdAt = "created_at", groceryList = "grocery_list"
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
    
    enum CodingKeys: String, CodingKey {
        case error, messages, sharingToken = "sharing_token", groceryListId = "grocery_list_id"
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
}

struct SharedProduct: Codable {
    var id: UUID
    var listId: UUID
    var name: String
    var isPurchased: Bool
    var dateOfCreation: Double
    var category: String
    var isFavorite: Bool
    var isSelected = false
    var imageData: Data?
    var description: String
    var fromRecipeTitle: String?
}
