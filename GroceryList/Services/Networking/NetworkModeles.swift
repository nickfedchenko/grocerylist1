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

struct NetworkProductModel: Codable {
    let id: Int
    let title: String
    let marketCategory: MarketCategory?
    let units: [Unit]
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
struct Recipe: Codable {
    let id: Int
    let title, description: String
    let cookingTime: Int?
    let totalServings: Int
    let dishWeight: Double?
    let dishWeightType: Int?
    let countries: [String]
    let instructions: [String]?
    let ingredients: [Ingredient]
    let eatingTags, dishTypeTags, processingTypeTags, additionalTags: [AdditionalTag]
    let dietTags, exceptionTags: [AdditionalTag]
    let photo: String
    let isDraft: Bool
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, title
        case description
        case cookingTime, totalServings, dishWeight, dishWeightType
        case countries, instructions, ingredients, eatingTags, dishTypeTags, processingTypeTags, additionalTags, dietTags, exceptionTags, photo, isDraft, createdAt
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
    }
}

// MARK: - AdditionalTag
struct AdditionalTag: Codable {
    enum EatingTime: Int {
        case breakfast = 8
        case dinner = 10
        case lunch = 9
        case snack = 11
    }
    
    let id: Int
    let title: String

    var eatingType: EatingTime? {
        EatingTime(rawValue: id)
    }
    
}

// MARK: - Ingredient
struct Ingredient: Codable {
    let id: Int
    let product: NetworkProductModel
    let quantity: Double
    let isNamed: Bool
    let unit: MarketUnitClass?
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
    let isOnlyForMarket: Bool
    var step: MarketUnitPrepared? {
        print("Id for step instance  =  \(id)")
        return MarketUnitPrepared(rawValue: id)
        
    }
    
}
