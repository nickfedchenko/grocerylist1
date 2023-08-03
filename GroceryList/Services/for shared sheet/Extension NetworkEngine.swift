//
//  ManagerExtensionForSharedSheet.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 02.08.2023.
//

import Alamofire
import Foundation

extension NetworkEngine {
    ///  получить распарсенный веб рецепт
    func parseWebRecipe(recipeUrl: String, completion: @escaping WebRecipeResult) {
        performDecodableRequest(request: .parseWebLink(url: recipeUrl), completion: completion)
    }
}

typealias WebRecipeResult = (Result<WebRecipeResponse, AFError>) -> Void

// MARK: - WebRecipe
struct WebRecipeResponse: Codable {
    let error: Bool
    let messages: [String]
    let recipe: WebRecipe?
}

struct WebRecipe: Codable {
    let title: String
    let image: String?
    let info: String?
    let servings, cookTime: Int?
    let methods: [String]?
    let ingredients: [WebIngredient]
    let kcal: Int?
    let protein: Int?
    let fat: Int?
    let carbohydrates: Int?
    
    private enum CodingKeys: String, CodingKey {
        case title
        case image
        case info
        case servings
        case cookTime = "cook_time"
        case methods
        case ingredients
        case kcal
        case protein
        case fat
        case carbohydrates

    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        title = try container.decode(String.self, forKey: .title)
        image = try? container.decode(String.self, forKey: .image)
        info = try? container.decode(String.self, forKey: .info)
        methods = try? container.decode([String].self, forKey: .methods)
        ingredients = try container.decode([WebIngredient].self, forKey: .ingredients)
        kcal = try? container.decode(Int.self, forKey: .kcal)
        protein = try? container.decode(Int.self, forKey: .protein)
        fat = try? container.decode(Int.self, forKey: .fat)
        carbohydrates = try? container.decode(Int.self, forKey: .carbohydrates)
        
        if let servingsString = try? container.decode(String.self, forKey: .servings) {
            servings = servingsString.asInt
        } else if let servingsInt = try? container.decode(Int.self, forKey: .servings) {
            servings = servingsInt
        } else {
            servings = nil
        }
        
        if let cookTimeString = try? container.decode(String.self, forKey: .cookTime) {
            cookTime = cookTimeString.asInt
        } else if let cookTimeInt = try? container.decode(Int.self, forKey: .cookTime) {
            cookTime = cookTimeInt
        } else {
            cookTime = nil
        }
    }
}

struct WebIngredient: Codable {
    let title, name, amount, unit: String
}

struct Value: Codable {
    var weight: Double?
    var kcal: Double?
    var netCarbs: Double?
    var proteins: Double?
    var fats: Double?
    var carbohydrates: Double?
}

struct NetworkCollection: Codable {
    let id: Int
    let pos: Int
    let title: String
    let dishes: [Int]
}

enum EatingTime: Int, CaseIterable {
    case breakfast = 8
    case dinner = 10
    case lunch = 9
    case snack = 11
    
    case willCook = -103
    case drafts = -102
    case favorites = -101
    case inbox = -100
    
    var color: Int {
        switch self {
        case .breakfast:    return 4
        case .dinner:       return 6
        case .lunch:        return 12
        case .snack:        return 8
            
        case .willCook:     return 0
        case .drafts:       return 16
        case .favorites:    return 7
        case .inbox:        return 13
        }
    }
    
    var isTechnicalCollection: Bool {
        self == .willCook || self == .drafts || self == .favorites || self == .inbox
    }
    
    static var getTechnicalCollection: [EatingTime] {
        [.willCook, .drafts, .favorites, .inbox]
    }
    
    static var defaults: [EatingTime] {
        [.breakfast, .dinner, .lunch, .snack]
    }
}
