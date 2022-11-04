//
//  GroseryListModels.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 04.11.2022.
//

import UIKit

struct SectionModel: Hashable {
    var id = UUID()
    var cellType: CellType
    var sectionType: SectionType
    var lists: [GroseryListsModel]
    
    static func == (lhs: SectionModel, rhs: SectionModel) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(cellType)
    }
}

struct GroseryListsModel: Hashable {
    var id = UUID()
    var dateOfCreation: Date?
    var name: String?
    var color: UIColor
    var isFavorite: Bool = false
    var isEmpty: Bool = false
    var isTestCell: Bool = false
    var supplays: [Supplay?]
    
    static func == (lhs: GroseryListsModel, rhs: GroseryListsModel) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(dateOfCreation)
    }
}

struct Supplay {
    var name: String
    var isPurchased: Bool
    var dateOfCreation: Date
    var category: Category
}

enum Category {
    case head
}

enum CellType {
    case usual
    case instruction
    case empty
}

enum SectionType: String {
    case favorite
    case today
    case week
    case month
}
