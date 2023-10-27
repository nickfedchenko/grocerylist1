//
//  MealPlanResponse.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 09.10.2023.
//

import Foundation

struct ShareMealPlanResponse: Codable {
    var error: Bool
    var messages: [String]
    var sharingToken: String
    var mealListId: String
    var url: String
    
    enum CodingKeys: String, CodingKey {
        case error, messages, sharingToken = "sharing_token", mealListId = "meal_list_id", url
    }
}

struct FetchMyMealPlansResponse: Codable {
    var error: Bool
    var messages: [String]
    var items: [MealPlanItem]
}

struct MealPlanItem: Codable {
    var mealListId: String
    var isOwner: Bool
    var createdAt: String
    var mealLists: [MealList]
    var users: [User]

    enum CodingKeys: String, CodingKey {
        case mealListId = "meal_list_id"
        case isOwner = "is_owner"
        case createdAt = "created_at"
        case mealLists = "meal_list"
        case users = "users"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let listId = try container.decode(String.self, forKey: .mealListId)
        mealListId = listId == "" ? "-1" : listId
        isOwner = try container.decode(Bool.self, forKey: .isOwner)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        users = try container.decode([User].self, forKey: .users)

        if let mealList = try? container.decode(MealList.self, forKey: .mealLists) {
            self.mealLists = [mealList]
        } else {
            mealLists = []
        }
    }
}
