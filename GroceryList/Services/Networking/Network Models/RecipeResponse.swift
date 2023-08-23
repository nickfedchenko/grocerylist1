//
//  RecipeResponse.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 21.07.2023.
//

import CloudKit
import Foundation

struct AllRecipesResponse: Codable {
    let error: Bool
    let data: [Recipe]
}

struct Recipe: Codable, Hashable, Equatable {
    let id: Int
    var recordId = ""
    var title, description: String
    var cookingTime: Int?
    var totalServings: Int
    var dishWeight: Double?
    var dishWeightType: Int?
    var values: Values?
    let countries: [String]
    var instructions: [String]?
    var ingredients: [Ingredient]
    let eatingTags, dishTypeTags, processingTypeTags, additionalTags: [AdditionalTag]
    let dietTags, exceptionTags: [AdditionalTag]
    var photo: String
    let isDraft: Bool
    let createdAt: Date
    var localCollection: [CollectionModel]?
    var localImage: Data?
    var isDefaultRecipe: Bool = true
    var isShowCost: Bool = false
    var sourceUrl: String?

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
        sourceUrl = dbModel.sourceUrl
        recordId = dbModel.recordId ?? ""
    }
    
    init?(title: String, totalServings: Int = -1,
          localCollection: [CollectionModel]? = nil, localImage: Data? = nil,
          cookingTime: Int? = nil, description: String? = nil, kcal: Value? = nil,
          ingredients: [Ingredient] = [], instructions: [String]? = nil, isShowCost: Bool = false) {
        self.id = UUID().integer
        self.title = title
        self.totalServings = totalServings
        self.localCollection = localCollection
        self.localImage = localImage
        
        self.cookingTime = cookingTime
        self.description = description ?? ""
        self.values = Values(serving: kcal)
        self.ingredients = ingredients
        self.instructions = instructions
        self.isShowCost = isShowCost
        
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
    
    init?(record: CKRecord, imageData: Data?) {
        guard let recipeId = record.value(forKey: "id") as? Int else {
            return nil
        }
        
        id = recipeId
        recordId = record.recordID.recordName
        
        title = record.value(forKey: "title") as? String ?? ""
        description = record.value(forKey: "description") as? String ?? ""
        cookingTime = record.value(forKey: "cookingTime") as? Int
        totalServings = record.value(forKey: "totalServings") as? Int ?? -1
        dishWeight = record.value(forKey: "dishWeight") as? Double
        dishWeightType = record.value(forKey: "dishWeightType") as? Int
        countries = record.value(forKey: "countries") as? [String] ?? []
        instructions = record.value(forKey: "instructions") as? [String] ?? []
        photo = record.value(forKey: "photo") as? String ?? ""
        isDraft = (record.value(forKey: "isDraft") as? Int64 ?? 0).boolValue
        createdAt = record.value(forKey: "createdAt") as? Date ?? Date()
        localImage = imageData
        isDefaultRecipe = (record.value(forKey: "isDefaultRecipe") as? Int64 ?? 0).boolValue
        sourceUrl = record.value(forKey: "sourceUrl") as? String
        
        let valuesData = record.value(forKey: "values") as? Data
        values = (try? JSONDecoder().decode(Values.self, from: valuesData ?? Data()))
        let ingredientsData = record.value(forKey: "ingredients") as? Data
        ingredients = (try? JSONDecoder().decode([Ingredient].self, from: ingredientsData ?? Data())) ?? []
        let eatingTagsData = record.value(forKey: "eatingTags") as? Data
        eatingTags = (try? JSONDecoder().decode([AdditionalTag].self, from: eatingTagsData ?? Data())) ?? []
        let dishTypeTagsData = record.value(forKey: "dishTypeTags") as? Data
        dishTypeTags = (try? JSONDecoder().decode([AdditionalTag].self, from: dishTypeTagsData ?? Data())) ?? []
        let processingTypeTagsData = record.value(forKey: "processingTypeTags") as? Data
        processingTypeTags = (try? JSONDecoder().decode([AdditionalTag].self, from: processingTypeTagsData ?? Data())) ?? []
        let additionalTagsData = record.value(forKey: "additionalTags") as? Data
        additionalTags = (try? JSONDecoder().decode([AdditionalTag].self, from: additionalTagsData ?? Data())) ?? []
        let dietTagsData = record.value(forKey: "dietTags") as? Data
        dietTags = (try? JSONDecoder().decode([AdditionalTag].self, from: dietTagsData ?? Data())) ?? []
        let exceptionTagsData = record.value(forKey: "exceptionTags") as? Data
        exceptionTags = (try? JSONDecoder().decode([AdditionalTag].self, from: exceptionTagsData ?? Data())) ?? []
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

struct Values: Codable {
    var dish: Value?
    var serving: Value?
    var hundred: Value?
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

struct NetworkProductModel: Codable {
    let id: Int
    let title: String
    let productTypeId: Int?
    let marketCategory: MarketCategory?
    let units: [Unit]?
    let photo: String
    let marketUnit: MarketUnitClass?
    let localImage: Data?
    var store: Store?
    var cost: Double?
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

struct Store: Hashable, Equatable, Codable {
    var id: UUID
    var recordId = ""
    var title: String
    var createdAt: Date
    
    init(title: String) {
        self.id = UUID()
        self.createdAt = Date()
        self.title = title
    }
    
    init?(from dbStore: DBStore) {
        id = dbStore.id ?? UUID()
        title = dbStore.title ?? ""
        createdAt = dbStore.createdAt ?? Date()
        recordId = dbStore.recordId ?? ""
    }
    
    init?(record: CKRecord) {
        guard let idAsString = record.value(forKey: "id") as? String,
        let id = UUID(uuidString: idAsString) else {
            return nil
        }
        self.id = id
        recordId = record.recordID.recordName
        title = record.value(forKey: "title") as? String ?? ""
        createdAt = record.value(forKey: "createdAt") as? Date ?? Date()
    }
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

// MARK: - Collection
struct NetworkCollectionResponse: Codable {
    let error: Bool
    let messages: [String]
    let data: [NetworkCollection]
}
