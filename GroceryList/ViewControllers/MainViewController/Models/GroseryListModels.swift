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
    
    enum RecipeSectionType: String {
        case breakfast, lunch, dinner, snacks, none
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

struct GroceryListsModel: Hashable {
    var id = UUID()
    var dateOfCreation: Date
    var name: String?
    var color: Int
    var isFavorite: Bool = false
    var products: [Product]
    var typeOfSorting: Int
    
    static func == (lhs: GroceryListsModel, rhs: GroceryListsModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
//    init?(from dbModel: DBGroceryListModel) {
//        id = dbModel.id ?? UUID()
//        dateOfCreation = dbModel.dateOfCreation ?? Date()
//        color = Int(dbModel.color)
//        typeOfSorting = Int(dbModel.typeOfSorting)
//        guard let prods = dbModel.products?.allObjects as? [DBProduct] else { return nil }
//        products = prods.compactMap({ Product(from: $0)})
//    }
//
//    init(id: UUID = UUID(), dateOfCreation: Date, name: String? = nil, color: Int, isFavorite: Bool = false, products: [Product], typeOfSorting: Int) {
//        self.dateOfCreation = dateOfCreation
//        self.color = color
//        self.products = products
//        self.typeOfSorting = typeOfSorting
//        self.id = id
//        self.name = name
//        self.isFavorite = isFavorite
//    }
}

struct Product: Hashable, Equatable {
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
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Product, rhs: Product) -> Bool {
        return lhs.name == rhs.name &&
        lhs.dateOfCreation == rhs.dateOfCreation &&
        lhs.category == rhs.category && lhs.isPurchased == rhs.isPurchased
        && lhs.id == rhs.id && lhs.isFavorite == rhs.isFavorite
    }
    
//    init?(from dbProduct: DBProduct) {
//         id = dbProduct.id ?? UUID()
//         listId = dbProduct.listId ?? UUID()
//         name = dbProduct.name ?? ""
//         isPurchased = dbProduct.isPurchased
//         dateOfCreation = dbProduct.dateOfCreation ?? Date()
//         category = dbProduct.category ?? ""
//         isFavorite = dbProduct.isFavorite
//         imageData = dbProduct.image
//         description = dbProduct.userDescription ?? ""
//    }
//
//    init(
//        id: UUID = UUID(),
//        listId: UUID = UUID(),
//        name: String,
//        isPurchased: Bool,
//        dateOfCreation: Date,
//        category: String,
//        isFavorite: Bool,
//        isSelected: Bool = false,
//        imageData: Data? = nil,
//        description: String
//    ) {
//        self.id = id
//        self.listId = listId
//        self.name = name
//        self.isPurchased = isPurchased
//        self.dateOfCreation = dateOfCreation
//        self.category = category
//        self.isFavorite = isFavorite
//        self.imageData = imageData
//        self.description = description
//        self.isSelected = isSelected
//
//    }
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
    case time
    case alphabet
}

enum TypeOfCell {
    case favorite
    case purchased
    case sortedByAlphabet
    case sortedByDate
    case normal
}
