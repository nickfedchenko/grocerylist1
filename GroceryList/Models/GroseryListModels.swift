//
//  GroseryListModels.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 04.11.2022.
//

import UIKit

struct RecipeSectionsModel {
    enum RecipeCellType {
        case topMenuCell
        case recipePreview
    }
    
    enum RecipeSectionType: Equatable {
        case breakfast, lunch, dinner, snacks, none, favorites
        case custom(String)
        
        var title: String {
            switch self {
            case .breakfast:
                return R.string.localizable.breakfast()
            case .lunch:
                return R.string.localizable.lunch()
            case .dinner:
                return R.string.localizable.dinner()
            case .snacks:
                return R.string.localizable.snacks()
            case .none:
                return "NoneType"
            case .favorites:
                return R.string.localizable.favorites()
            case .custom(let title):
                return title
            }
        }
    }
    
    var cellType: RecipeCellType
    var sectionType: RecipeSectionType
    var recipes: [ShortRecipeModel]
}

struct ShortRecipeModel {
    let id: Int
    let title: String
    let photo: String
    var ingredients: [Ingredient]?
    var localCollection: [CollectionModel]?
    var localImage: Data?
    
    init?(withCollection dbModel: DBRecipe) {
        id = Int(dbModel.id)
        title = dbModel.title ?? ""
        photo = dbModel.photo ?? ""
        localCollection = (try? JSONDecoder().decode([CollectionModel].self, from: dbModel.localCollection ?? Data()))
        localImage = dbModel.localImage
    }
    
    init?(withIngredients dbModel: DBRecipe) {
        id = Int(dbModel.id)
        title = dbModel.title ?? ""
        photo = dbModel.photo ?? ""
        ingredients = (try? JSONDecoder().decode([Ingredient].self, from: dbModel.ingredients ?? Data()))
        localImage = dbModel.localImage
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
    var dateOfCreation: Date
    var name: String?
    var color: Int
    var isFavorite: Bool = false
    var products: [Product]
    var isAutomaticCategory: Bool = true
    var typeOfSorting: Int
    var typeOfSortingPurchased: Int
    var isAscendingOrder = true
    var isAscendingOrderPurchased: BoolWithNilForCD = .nothing
    var sharedId: String = ""
    var isShared: Bool = false
    var isSharedListOwner: Bool = false
    var isShowImage: BoolWithNilForCD = .nothing
    var isVisibleCost: Bool = false
    
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
    }
    
    init(id: UUID = UUID(), dateOfCreation: Date,
         name: String? = nil, color: Int, isFavorite: Bool = false,
         products: [Product], isAutomaticCategory: Bool = true,
         typeOfSorting: Int, isShared: Bool = false,
         sharedId: String = "", isSharedListOwner: Bool = false,
         isShowImage: BoolWithNilForCD = .nothing,
         typeOfSortingPurchased: Int = 1,
         isAscendingOrder: Bool = true, isAscendingOrderPurchased: BoolWithNilForCD = .nothing,
         isVisibleCost: Bool = false) {
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
    }
}

struct Product: Hashable, Equatable, Codable {
    var id = UUID()
    var listId: UUID
    var name: String
    var isPurchased: Bool
    var dateOfCreation: Date
    var category: String
    var isFavorite: Bool
    var isSelected = false
    var imageData: Data?
    var description: String
    var fromRecipeTitle: String?
    var unitId: UnitSystem?
    var isUserImage: Bool? = false
    var userToken: String?
    var store: Store?
    var cost: Double?
    var quantity: Double?
    var isVisibleСost: Bool = false // не нужно сохранять в базу, нужно чтобы показать цену
    var isOutOfStock: Bool = false // не нужно сохранять в базу, продукт из Кладовой
    var inStock: UUID? // не нужно сохранять в базу, продукт из Кладовой
    
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
        unitId = UnitSystem(rawValue: Int(dbProduct.unitId))
        isUserImage = dbProduct.isUserImage
        userToken = dbProduct.userToken
        let storeFromDB = (try? JSONDecoder().decode(Store.self, from: dbProduct.store ?? Data()))
        store = storeFromDB?.title == "" ? nil : storeFromDB
        cost = dbProduct.cost == -1 ? nil : dbProduct.cost
        quantity = dbProduct.quantity == -1 ? nil : dbProduct.quantity
    }
    
    init(id: UUID = UUID(), listId: UUID = UUID(),
         name: String, isPurchased: Bool,
         dateOfCreation: Date, category: String,
         isFavorite: Bool, isSelected: Bool = false,
         imageData: Data? = nil, description: String,
         fromRecipeTitle: String? = nil,
         unitId: UnitSystem? = nil, isUserImage: Bool? = false,
         userToken: String? = nil, store: Store? = nil, cost: Double? = nil,
         quantity: Double? = nil, isVisibleСost: Bool = false) {
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
        self.unitId = unitId
        self.isUserImage = isUserImage
        self.userToken = userToken
        self.store = store
        self.cost = cost
        self.quantity = quantity
        self.isVisibleСost = isVisibleСost
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

struct Store: Hashable, Equatable, Codable {
    var id: UUID
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
