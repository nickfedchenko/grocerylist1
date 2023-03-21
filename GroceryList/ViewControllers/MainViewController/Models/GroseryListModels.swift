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
    var recipes: [Recipe]
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
    var typeOfSorting: Int
    var sharedId: String = ""
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
    }
    
    init(id: UUID = UUID(), dateOfCreation: Date,
         name: String? = nil, color: Int, isFavorite: Bool = false,
         products: [Product], typeOfSorting: Int, isShared: Bool = false,
         sharedId: String = "", isSharedListOwner: Bool = false) {
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
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Product, rhs: Product) -> Bool {
        return lhs.name == rhs.name &&
        lhs.dateOfCreation == rhs.dateOfCreation &&
        lhs.category == rhs.category && lhs.isPurchased == rhs.isPurchased &&
        lhs.id == rhs.id && lhs.isFavorite == rhs.isFavorite &&
        lhs.description == rhs.description && lhs.imageData == rhs.imageData
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
    }
    
    init(
        id: UUID = UUID(),
        listId: UUID = UUID(),
        name: String,
        isPurchased: Bool,
        dateOfCreation: Date,
        category: String,
        isFavorite: Bool,
        isSelected: Bool = false,
        imageData: Data? = nil,
        description: String,
        fromRecipeTitle: String? = nil
    ) {
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
    }
}

class Category: Hashable, Equatable {
    
    init(name: String, products: [Product], isExpanded: Bool = true, typeOFCell: TypeOfCell ) {
        self.name = name
        self.isExpanded = isExpanded
        self.products = products
        self.typeOFCell = typeOFCell
    }
    var name: String
    var isExpanded: Bool = true
    var products: [Product]
    var typeOFCell: TypeOfCell
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.name == rhs.name 
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
}

enum TypeOfCell {
    case favorite
    case purchased
    case sortedByAlphabet
    case sortedByDate
    case sortedByRecipe
    case normal
}
