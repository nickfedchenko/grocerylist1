//
//  GroseryListModels.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 04.11.2022.
//

import CloudKit
import UIKit

struct RecipeSectionsModel {
    enum RecipeCellType {
        case topMenuCell
        case recipePreview
    }
    
    enum RecipeSectionType: Equatable {
        case breakfast, lunch, dinner, snacks, none
        case willCook, drafts, favorites, inbox
        case custom(String)
        
        var title: String {
            switch self {
            case .breakfast:            return "Breakfast"
            case .lunch:                return "Lunch"
            case .dinner:               return "Dinner"
            case .snacks:               return "Snacks"
            case .none:                 return "NoneType"
            case .custom(let title):    return title
                
            case .willCook:             return "willCook"
            case .drafts:               return "drafts"
            case .favorites:            return "Favorites"
            case .inbox:                return "inbox"
            }
        }
        
        static func getCorrectTitle(id: Int) -> String {
            let collection = EatingTime(rawValue: id)
            switch collection {
            case .breakfast:            return "Breakfast"
            case .lunch:                return "Lunch"
            case .dinner:               return "Dinner"
            case .snack:                return "Snacks"

            case .willCook:             return "willCook"
            case .drafts:               return "drafts"
            case .favorites:            return "Favorites"
            case .inbox:                return "inbox"
            case .none:                 return "NoneType"
            }
        }
    }
    
    var collectionId: Int
    var cellType: RecipeCellType
    var sectionType: RecipeSectionType
    var recipes: [ShortRecipeModel]
    var color: Int
    var imageUrl: String?
    var localImage: Data?
}

struct RecipeForSearchModel {
    let id: Int
    let createdAt: Date
    let title: String
    let photo: String
    var localImage: Data?
    let time: Int32
    var ingredients: [Ingredient]?
    var values: Values?
    var eatingTags, dishTypeTags, processingTypeTags, dietTags, exceptionTags: [AdditionalTag]
    var isFavorite = false
    var isDefaultRecipe = false
    
    init(dbModel: DBRecipe, isFavorite: Bool) {
        id = Int(dbModel.id)
        createdAt = dbModel.createdAt ?? Date()
        title = dbModel.title ?? ""
        photo = dbModel.photo ?? ""
        localImage = dbModel.localImage
        time = dbModel.cookingTime
        ingredients = (try? JSONDecoder().decode([Ingredient].self, from: dbModel.ingredients ?? Data()))
        values = (try? JSONDecoder().decode(Values.self, from: dbModel.values ?? Data()))
        eatingTags = (try? JSONDecoder().decode([AdditionalTag].self, from: dbModel.eatingTags ?? Data())) ?? []
        dishTypeTags = (try? JSONDecoder().decode([AdditionalTag].self, from: dbModel.dishTypeTags ?? Data())) ?? []
        processingTypeTags = (try? JSONDecoder().decode([AdditionalTag].self, from: dbModel.processingTypeTags ?? Data())) ?? []
        dietTags = (try? JSONDecoder().decode([AdditionalTag].self, from: dbModel.dietTags ?? Data())) ?? []
        exceptionTags = (try? JSONDecoder().decode([AdditionalTag].self, from: dbModel.exceptionTags ?? Data())) ?? []
        self.isFavorite = isFavorite
        self.isDefaultRecipe = dbModel.isDefaultRecipe
    }
    
    init(shortRecipeModel: ShortRecipeModel) {
        id = shortRecipeModel.id
        createdAt = shortRecipeModel.createdAt
        title = shortRecipeModel.title
        photo = shortRecipeModel.photo
        localImage = shortRecipeModel.localImage
        time = shortRecipeModel.time
        isFavorite = shortRecipeModel.isFavorite
        isDefaultRecipe = shortRecipeModel.isDefaultRecipe
        
        let dbModel = CoreDataManager.shared.getRecipe(by: shortRecipeModel.id)
        ingredients = (try? JSONDecoder().decode([Ingredient].self, from: dbModel?.ingredients ?? Data()))
        values = (try? JSONDecoder().decode(Values.self, from: dbModel?.values ?? Data()))
        eatingTags = (try? JSONDecoder().decode([AdditionalTag].self, from: dbModel?.eatingTags ?? Data())) ?? []
        dishTypeTags = (try? JSONDecoder().decode([AdditionalTag].self, from: dbModel?.dishTypeTags ?? Data())) ?? []
        processingTypeTags = (try? JSONDecoder().decode([AdditionalTag].self, from: dbModel?.processingTypeTags ?? Data())) ?? []
        dietTags = (try? JSONDecoder().decode([AdditionalTag].self, from: dbModel?.dietTags ?? Data())) ?? []
        exceptionTags = (try? JSONDecoder().decode([AdditionalTag].self, from: dbModel?.exceptionTags ?? Data())) ?? []
        
    }
}

struct ShortRecipeModel {
    let id: Int
    let time: Int32
    let title: String
    let photo: String
    let createdAt: Date
    var ingredients: [Ingredient]?
    var localCollection: [CollectionModel]?
    var localImage: Data?
    var values: Values?
    var isFavorite = false
    var isDefaultRecipe = false
    
    init(withCollection dbModel: DBRecipe, isFavorite: Bool) {
        id = Int(dbModel.id)
        title = dbModel.title ?? ""
        photo = dbModel.photo ?? ""
        createdAt = dbModel.createdAt ?? Date()
        localCollection = (try? JSONDecoder().decode([CollectionModel].self, from: dbModel.localCollection ?? Data()))
        localImage = dbModel.localImage
        values = (try? JSONDecoder().decode(Values.self, from: dbModel.values ?? Data()))
        time = dbModel.cookingTime
        self.isFavorite = isFavorite
        self.isDefaultRecipe = dbModel.isDefaultRecipe
    }
    
    init(withIngredients dbModel: DBRecipe) {
        id = Int(dbModel.id)
        title = dbModel.title ?? ""
        photo = dbModel.photo ?? ""
        createdAt = dbModel.createdAt ?? Date()
        ingredients = (try? JSONDecoder().decode([Ingredient].self, from: dbModel.ingredients ?? Data()))
        localImage = dbModel.localImage
        values = (try? JSONDecoder().decode(Values.self, from: dbModel.values ?? Data()))
        time = dbModel.cookingTime
    }
    
    init(withCollection model: Recipe) {
        id = model.id
        title = model.title
        photo = model.photo
        createdAt = model.createdAt
        localCollection = model.localCollection
        localImage = model.localImage
        values = model.values
        time = Int32(model.cookingTime ?? -1)
        isFavorite = UserDefaultsManager.shared.favoritesRecipeIds.contains(model.id)
        isDefaultRecipe = model.isDefaultRecipe
    }
    
    init(modelForSearch: RecipeForSearchModel) {
        id = modelForSearch.id
        title = modelForSearch.title
        photo = modelForSearch.photo
        createdAt = modelForSearch.createdAt
        localImage = modelForSearch.localImage
        values = modelForSearch.values
        time = Int32(modelForSearch.time)
        isFavorite = UserDefaultsManager.shared.favoritesRecipeIds.contains(modelForSearch.id)
        isDefaultRecipe = modelForSearch.isDefaultRecipe
    }
}

struct SectionModel: Hashable {
    var id: Int
    var cellType: CellType
    var sectionType: SectionType
    var lists: [GroceryListsModel]
    
    static func == (lhs: SectionModel, rhs: SectionModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct GroceryListsModel: Hashable, Codable {
    var id = UUID()
    var sharedId: String = ""
    var recordId = ""
    
    var dateOfCreation: Date
    var name: String?
    var color: Int
    var products: [Product]
    var typeOfSorting: Int
    var typeOfSortingPurchased: Int
    
    var isFavorite: Bool = false
    var isAutomaticCategory: Bool = true
    var isAscendingOrder = true
    var isAscendingOrderPurchased: BoolWithNilForCD = .nothing
    var isShowImage: BoolWithNilForCD = .nothing
    var isVisibleCost: Bool = false
    var isShared: Bool = false
    var isSharedListOwner: Bool = false
    
    static func == (lhs: GroceryListsModel, rhs: GroceryListsModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    init?(from dbModel: DBGroceryListModel) {
        id = dbModel.id ?? UUID()
        name = dbModel.name
        dateOfCreation = dbModel.dateOfCreation ?? Date()
        color = Int(dbModel.color)
        typeOfSorting = Int(dbModel.typeOfSorting)
        guard let prods = dbModel.products?.allObjects as? [DBProduct] else { return nil }
        products = prods.compactMap({ Product(from: $0) })
        isFavorite = dbModel.isFavorite
        sharedId = dbModel.sharedListId ?? ""
        isShared = dbModel.isShared
        isSharedListOwner = dbModel.isSharedListOwner
        isShowImage = BoolWithNilForCD(rawValue: dbModel.isShowImage) ?? .nothing
        typeOfSortingPurchased = Int(dbModel.typeOfSortingPurchased)
        isAscendingOrder = dbModel.isAscendingOrder
        isAscendingOrderPurchased = BoolWithNilForCD(rawValue: dbModel.isAscendingOrderPurchased) ?? .nothing
        isAutomaticCategory = dbModel.isAutomaticCategory
        recordId = dbModel.recordId ?? ""
    }
    
    init(id: UUID = UUID(), dateOfCreation: Date,
         name: String? = nil, color: Int, isFavorite: Bool = false,
         products: [Product], isAutomaticCategory: Bool = true,
         typeOfSorting: Int, isShared: Bool = false,
         sharedId: String = "", isSharedListOwner: Bool = false,
         isShowImage: BoolWithNilForCD = .nothing,
         typeOfSortingPurchased: Int = 1,
         isAscendingOrder: Bool = true, isAscendingOrderPurchased: BoolWithNilForCD = .nothing,
         isVisibleCost: Bool = false, recordId: String? = nil) {
        self.dateOfCreation = dateOfCreation
        self.color = color
        self.products = products
        self.typeOfSorting = typeOfSorting
        self.id = id
        self.name = name
        self.isFavorite = isFavorite
        self.isShared = isShared
        self.sharedId = sharedId
        self.isSharedListOwner = isSharedListOwner
        self.isShowImage = isShowImage
        self.isVisibleCost = isVisibleCost
        self.typeOfSortingPurchased = typeOfSortingPurchased
        self.isAscendingOrder = isAscendingOrder
        self.isAscendingOrderPurchased = isAscendingOrderPurchased
        self.isAutomaticCategory = isAutomaticCategory
        self.recordId = recordId ?? ""
    }
    
    init?(record: CKRecord) {
        guard let idAsString = record.value(forKey: "id") as? String,
              let id = UUID(uuidString: idAsString) else {
            return nil
        }
        self.id = id
        sharedId = record.value(forKey: "sharedId") as? String ?? ""
        recordId = record.recordID.recordName
        
        dateOfCreation = record.value(forKey: "dateOfCreation") as? Date ?? Date()
        name = record.value(forKey: "name") as? String
        color = record.value(forKey: "color") as? Int ?? 0
        typeOfSorting = record.value(forKey: "typeOfSorting") as? Int ?? 0
        typeOfSortingPurchased = record.value(forKey: "typeOfSortingPurchased") as? Int ?? 0
        
        let productDatas = record.value(forKey: "products") as? [Data] ?? []
        products = productDatas.compactMap({ (try? JSONDecoder().decode(Product.self, from: $0)) })
        
        isFavorite = (record.value(forKey: "isFavorite") as? Int64 ?? 0).boolValue
        isAutomaticCategory = (record.value(forKey: "isAutomaticCategory") as? Int64 ?? 0).boolValue
        isAscendingOrder = (record.value(forKey: "isAscendingOrder") as? Int64 ?? 0).boolValue
        isVisibleCost = (record.value(forKey: "isVisibleCost") as? Int64 ?? 0).boolValue
        isShared = (record.value(forKey: "isShared") as? Int64 ?? 0).boolValue
        isSharedListOwner = (record.value(forKey: "isSharedListOwner") as? Int64 ?? 0).boolValue
        let isAscendingOrderPurchasedRawValue = record.value(forKey: "isAscendingOrderPurchased") as? Int64 ?? 0
        let isShowImageRawValue = record.value(forKey: "isShowImage") as? Int64 ?? 0
        isAscendingOrderPurchased = BoolWithNilForCD(rawValue: Int16(isAscendingOrderPurchasedRawValue)) ?? .nothing
        isShowImage = BoolWithNilForCD(rawValue: Int16(isShowImageRawValue)) ?? .nothing
    }
}

struct Product: Hashable, Equatable, Codable {
    var id = UUID()
    var listId: UUID
    var recordId = ""
    
    var dateOfCreation: Date
    var name: String
    var description: String
    var category: String
    var imageData: Data?
    var fromRecipeTitle: String?
    var fromMealPlan: UUID?
    var unitId: UnitSystem?
    var store: Store?
    var cost: Double?
    var quantity: Double?
    var userToken: String?
    
    var isPurchased: Bool
    var isFavorite: Bool
    var isUserImage: Bool? = false
    
    var isSelected = false
    var isVisibleСost: Bool = false
    var isOutOfStock: Bool = false
    var inStock: UUID?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Product, rhs: Product) -> Bool {
        return lhs.name == rhs.name &&
        lhs.dateOfCreation == rhs.dateOfCreation &&
        lhs.category == rhs.category && lhs.isPurchased == rhs.isPurchased &&
        lhs.id == rhs.id && lhs.isFavorite == rhs.isFavorite &&
        lhs.description == rhs.description && lhs.imageData == rhs.imageData &&
        lhs.unitId == rhs.unitId && lhs.isUserImage == rhs.isUserImage &&
        lhs.userToken == rhs.userToken && lhs.store == rhs.store &&
        lhs.cost == rhs.cost && lhs.quantity == rhs.quantity &&
        lhs.isVisibleСost == rhs.isVisibleСost && lhs.inStock == rhs.inStock
    }
    
    init?(from dbProduct: DBProduct) {
        id = dbProduct.id ?? UUID()
        listId = dbProduct.listId ?? UUID()
        name = dbProduct.name ?? ""
        isPurchased = dbProduct.isPurchased
        dateOfCreation = dbProduct.dateOfCreation ?? Date()
        category = dbProduct.category ?? ""
        isFavorite = dbProduct.isFavorite
        imageData = dbProduct.image
        description = dbProduct.userDescription ?? ""
        fromRecipeTitle = dbProduct.fromRecipeTitle
        fromMealPlan = dbProduct.fromMealPlan
        unitId = UnitSystem(rawValue: Int(dbProduct.unitId))
        isUserImage = dbProduct.isUserImage
        userToken = dbProduct.userToken
        let storeFromDB = (try? JSONDecoder().decode(Store.self, from: dbProduct.store ?? Data()))
        store = storeFromDB?.title == "" ? nil : storeFromDB
        cost = dbProduct.cost == -1 ? nil : dbProduct.cost
        quantity = dbProduct.quantity == -1 ? nil : dbProduct.quantity
        recordId = dbProduct.recordId ?? ""
    }
    
    init(id: UUID = UUID(), listId: UUID = UUID(),
         name: String, isPurchased: Bool,
         dateOfCreation: Date, category: String,
         isFavorite: Bool, isSelected: Bool = false,
         imageData: Data? = nil, description: String,
         fromRecipeTitle: String? = nil,
         fromMealPlan: UUID? = nil,
         unitId: UnitSystem? = nil, isUserImage: Bool? = false,
         userToken: String? = nil, store: Store? = nil, cost: Double? = nil,
         quantity: Double? = nil, isVisibleСost: Bool = false,
         recordId: String? = nil) {
        self.id = id
        self.listId = listId
        self.name = name
        self.isPurchased = isPurchased
        self.dateOfCreation = dateOfCreation
        self.category = category
        self.isFavorite = isFavorite
        self.imageData = imageData
        self.description = description
        self.isSelected = isSelected
        self.fromRecipeTitle = fromRecipeTitle
        self.fromMealPlan = fromMealPlan
        self.unitId = unitId
        self.isUserImage = isUserImage
        self.userToken = userToken
        self.store = store
        self.cost = cost
        self.quantity = quantity
        self.isVisibleСost = isVisibleСost
        self.recordId = recordId ?? ""
    }
    
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
        case unitId
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
        dateOfCreation = try container.decode(Date.self, forKey: .dateOfCreation)
        category = try container.decode(String.self, forKey: .category)
        isFavorite = try container.decode(Bool.self, forKey: .isFavorite)
        isSelected = try container.decode(Bool.self, forKey: .isSelected)
        imageData = try? container.decode(Data.self, forKey: .imageData)
        description = try container.decode(String.self, forKey: .description)
        fromRecipeTitle = try? container.decode(String.self, forKey: .fromRecipeTitle)
        unitId = try? container.decode(UnitSystem.self, forKey: .unitId)
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
    
    init(stock: Stock, listId: UUID) {
        id = stock.id
        self.listId = listId
        name = stock.name
        isPurchased = false
        dateOfCreation = stock.dateOfCreation
        category = stock.category ?? ""
        isFavorite = false
        imageData = stock.imageData
        description = stock.description ?? ""
        fromRecipeTitle = nil
        unitId = stock.unitId
        isUserImage = stock.isUserImage
        userToken = stock.userToken
        store = stock.store
        cost = stock.cost
        quantity = stock.quantity
        isOutOfStock = true
    }
    
    init?(record: CKRecord, imageData: Data?) {
        guard let idAsString = record.value(forKey: "id") as? String,
              let id = UUID(uuidString: idAsString),
              let listIdAsString = record.value(forKey: "listId") as? String,
              let listId = UUID(uuidString: listIdAsString) else {
            return nil
        }
        self.id = id
        self.listId = listId
        recordId = record.recordID.recordName
        
        dateOfCreation = record.value(forKey: "dateOfCreation") as? Date ?? Date()
        name = record.value(forKey: "name") as? String ?? ""
        description = record.value(forKey: "description") as? String ?? ""
        category = record.value(forKey: "category") as? String ?? ""
        self.imageData = imageData
        fromRecipeTitle = record.value(forKey: "fromRecipeTitle") as? String
        unitId = UnitSystem(rawValue: Int(record.value(forKey: "unitId") as? Int ?? -1))
        cost = record.value(forKey: "cost") as? Double
        quantity = record.value(forKey: "quantity") as? Double
        userToken = record.value(forKey: "userToken") as? String
        
        let storeData = record.value(forKey: "store") as? Data ?? Data()
        let storeFromCloud = (try? JSONDecoder().decode(Store.self, from: storeData))
        store = storeFromCloud?.title == "" ? nil : storeFromCloud
        
        isFavorite = (record.value(forKey: "isFavorite") as? Int64 ?? 0).boolValue
        isPurchased = (record.value(forKey: "isPurchased") as? Int64 ?? 0).boolValue
        isUserImage = (record.value(forKey: "isUserImage") as? Int64 ?? 0).boolValue
    }
}

class Category: Hashable, Equatable {
    
    init(name: String, products: [Product], cost: Double? = nil, isVisibleCost: Bool = false, isExpanded: Bool = true, typeOFCell: TypeOfCell) {
        self.name = name
        self.isExpanded = isExpanded
        self.products = products
        self.typeOFCell = typeOFCell
        self.cost = cost
        self.isVisibleCost = isVisibleCost
    }
    var name: String
    var isExpanded: Bool = true
    var products: [Product]
    var typeOFCell: TypeOfCell
    var cost: Double?
    var isVisibleCost: Bool = false
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.name == rhs.name && lhs.products == rhs.products &&
        lhs.isExpanded == rhs.isExpanded && lhs.typeOFCell == rhs.typeOFCell &&
        lhs.cost == rhs.cost && lhs.isVisibleCost == rhs.isVisibleCost
    }
}

enum CellType {
    case topMenu
    case usual
    case instruction
    case empty
}

enum SectionType: String {
    case favorite
    case today
    case week
    case month
    case empty
}

enum SortingType: Int {
    case category
    case recipe
    case time
    case alphabet
    case user
    case store
}

enum TypeOfCell {
    case favorite
    case purchased
    case sortedByAlphabet
    case sortedByDate
    case sortedByRecipe
    case sortedByUser
    case normal
    case displayCostSwitch
    case withoutCategory
}

enum BoolWithNilForCD: Int16, Codable {
    case nothing
    case itsTrue
    case itsFalse
    
    func getBool(defaultValue: Bool) -> Bool {
        switch self {
        case .nothing:  return defaultValue
        case .itsTrue:  return true
        case .itsFalse: return false
        }
    }
}

enum ColdStartState: Int {
    case initial
    case firstItemAdded
    case coldStartFinished
}

enum ImageHeight {
    case empty
    case min
    case middle
}
