//
//  NetworkModeles.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 29.11.2022.
//

import Foundation

struct GetAllProductsResponse: Codable {
    let error: Bool
    let messages: [String]
    let data: [NetworkProductModel]
}

struct GetAllItemsResponse: Codable {
    let error: Bool
    let messages: [String]
    let data: [NetworkProductModel]
}

struct GetCategoriesResponse: Codable {
    let error: Bool
    let messages: [String]
    let data: [NetworkCategory]
}

struct NetworkProductModel: Codable {
    let id: Int
    let title: String
    let productTypeId: Int?
    let marketCategory: MarketCategory?
    let units: [Unit]?
    let photo: String
    let marketUnit: MarketUnitClass?
}

struct Unit: Codable {
    let title: String?
    let value: Double
    let isDefault: Bool?
}

struct MarketCategory: Codable {
    let id: Int
    let title: String
}

struct AllRecipesResponse: Codable {
    let error: Bool
    let data: [Recipe]
}

// MARK: - Recipe
struct Recipe: Codable, Hashable, Equatable {
    let id: Int
    let title, description: String
    let cookingTime: Int?
    let totalServings: Int
    let dishWeight: Double?
    let dishWeightType: Int?
    var values: Values?
    let countries: [String]
    let instructions: [String]?
    let ingredients: [Ingredient]
    let eatingTags, dishTypeTags, processingTypeTags, additionalTags: [AdditionalTag]
    let dietTags, exceptionTags: [AdditionalTag]
    let photo: String
    let isDraft: Bool
    let createdAt: Date
    var localCollection: [CollectionModel]?
    var localImage: Data?
    var isDefaultRecipe: Bool = true

    enum CodingKeys: String, CodingKey {
        case id, title
        case description
        case cookingTime, totalServings, dishWeight, dishWeightType
        case values
        case countries, instructions, ingredients, eatingTags, dishTypeTags, processingTypeTags, additionalTags, dietTags, exceptionTags, photo, isDraft, createdAt
        case localCollection, localImage
    }
    
    init?(from dbModel: DBRecipe) {
        id = Int(dbModel.id)
        title = dbModel.title ?? ""
        description = dbModel.recipeDescription ?? ""
        cookingTime = Int(dbModel.cookingTime)
        totalServings = Int(dbModel.totalServings)
        dishWeight = dbModel.dishWeight < 0 ? nil : dbModel.dishWeight
        dishWeightType = dbModel.dishWeightType < 0 ? nil : Int(dbModel.dishWeightType)
        countries = (try? JSONDecoder().decode([String].self, from: dbModel.countries ?? Data())) ?? []
        if let decodedInstructions = (try? JSONDecoder().decode([String].self, from: dbModel.instructions ?? Data())) {
       
        } else {
          
        }
        instructions = (try? JSONDecoder().decode([String].self, from: dbModel.instructions ?? Data())) ?? []
        ingredients = (try? JSONDecoder().decode([Ingredient].self, from: dbModel.ingredients ?? Data())) ?? []
        eatingTags = (try? JSONDecoder().decode([AdditionalTag].self, from: dbModel.eatingTags ?? Data())) ?? []
        dishTypeTags = (try? JSONDecoder().decode([AdditionalTag].self, from: dbModel.dishTypeTags ?? Data())) ?? []
        processingTypeTags = (try? JSONDecoder().decode([AdditionalTag].self, from: dbModel.processingTypeTags ?? Data())) ?? []
        additionalTags = (try? JSONDecoder().decode([AdditionalTag].self, from: dbModel.additionalTags ?? Data())) ?? []
        dietTags = (try? JSONDecoder().decode([AdditionalTag].self, from: dbModel.dietTags ?? Data())) ?? []
        exceptionTags = (try? JSONDecoder().decode([AdditionalTag].self, from: dbModel.exceptionTags ?? Data())) ?? []
        photo = dbModel.photo ?? ""
        isDraft = dbModel.isDraft
        createdAt = dbModel.createdAt ?? Date()
        localCollection = (try? JSONDecoder().decode([CollectionModel].self, from: dbModel.localCollection ?? Data())) ?? []
        localImage = dbModel.localImage
        values = (try? JSONDecoder().decode(Values.self, from: dbModel.values ?? Data()))
        isDefaultRecipe = dbModel.isDefaultRecipe
    }
    
    init?(title: String, totalServings: Int,
          localCollection: [CollectionModel]?, localImage: Data?,
          cookingTime: Int?, description: String?,
          ingredients: [Ingredient], instructions: [String]?) {
        self.id = UUID().integer
        self.title = title
        self.totalServings = totalServings
        self.localCollection = localCollection
        self.localImage = localImage
        
        self.cookingTime = cookingTime
        self.description = description ?? ""
        self.ingredients = ingredients
        self.instructions = instructions
        
        photo = ""
        createdAt = Date()
        dishWeight = nil
        dishWeightType = nil
        countries = []
        eatingTags = []
        dishTypeTags = []
        processingTypeTags = []
        additionalTags = []
        dietTags = []
        exceptionTags = []
        isDraft = false
        isDefaultRecipe = false
    }
    
    func hasDefaultCollection() -> Bool {
        var hasDefaultCollection = false
        localCollection?.forEach({
            if $0.isDefault { hasDefaultCollection = true }
        })
        return hasDefaultCollection
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (left: Recipe, right: Recipe) -> Bool {
        return left.id == right.id
    }
}

// MARK: - AdditionalTag
struct AdditionalTag: Codable {
    let id: Int
    let title: String

    var eatingType: EatingTime? {
        EatingTime(rawValue: id)
    }
    
    var color: Int {
        eatingType?.color ?? 0
    }
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
}

// MARK: - Ingredient
struct Ingredient: Codable {
    let id: Int
    let product: NetworkProductModel
    let quantity: Double
    let isNamed: Bool
    let unit: MarketUnitClass?
    var description: String?
    var quantityStr: String?
}

// MARK: - MarketUnitClass
struct MarketUnitClass: Codable {
    enum MarketUnitPrepared: Int {
        case kilogram = 17
        case gram = 18
        case litter = 19
        case millilitre = 20
        case piece = 21
        case pack = 22
        case bottle = 23
        case tin = 27
        var defaultQuantityStep: Double {
            switch self {
            case .kilogram:
                return 1
            case .gram:
                return 100
            case .litter:
                return 1
            case .millilitre:
                return 100
            case .piece:
                return 1
            case .pack:
                return 1
            case .bottle:
                return 1
            case .tin:
                return 1
            }
        }
    }

    let id: Int
    let title, shortTitle: String
    let isOnlyForMarket: Bool?
    var step: MarketUnitPrepared? {
        print("Id for step instance  =  \(id)")
        return MarketUnitPrepared(rawValue: id)
        
    }
    
}

struct Values: Codable {
    var dish: Value?
    var serving: Value?
    var hundred: Value?
}

struct Value: Codable {
    var weight: Double?
    var kcal: Double?
    var netCarbs: Double?
    var proteins: Double?
    var fats: Double?
    var carbohydrates: Double?
}

// MARK: - Category
struct NetworkCategory: Codable {
    let id: Int
    let title: String
    var netId: String?
}

// MARK: - Продукты пользователя
struct UserProduct: Codable {
    let userToken: String
    let country: String?
    let lang: String?
    let modelType: String?
    let modelId: String?
    let modelTitle: String
    let categoryId: String?
    let categoryTitle: String
    let new: Bool
    let version: String
}

struct UserProductResponse: Codable {
    var error: Bool
    var messages: [String]
    var success: Bool?
}

// MARK: - Feedback
struct Feedback: Codable {
    let userToken: String
    let stars: Int
    let totalLists: Int
    let isAutoCategory: Bool
    let text: String?
}

struct FeedbackResponse: Codable {
    var error: Bool
    var messages: [String]
    var data: [String]
}
