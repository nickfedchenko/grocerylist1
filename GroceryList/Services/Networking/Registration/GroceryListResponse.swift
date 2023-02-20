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
    var groceryList: GroceryList
    
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
