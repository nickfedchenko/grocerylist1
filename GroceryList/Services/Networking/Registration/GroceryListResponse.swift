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

struct FetchMyGroceryLists: Codable {
    var error: Bool
    var messages: [String]
    var items: Bool?
}

