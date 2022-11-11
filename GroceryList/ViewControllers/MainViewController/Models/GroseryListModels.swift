//
//  GroseryListModels.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 04.11.2022.
//

import UIKit

struct SectionModel: Hashable {
    var id: Int
    var cellType: CellType
    var sectionType: SectionType
    var lists: [GroseryListsModel]
    
    static func == (lhs: SectionModel, rhs: SectionModel) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct GroseryListsModel: Hashable {
    var id = UUID()
    var dateOfCreation: Date
    var name: String?
    var color: Int
    var isFavorite: Bool = false
    var supplays: [Supplay?]
    
    static func == (lhs: GroseryListsModel, rhs: GroseryListsModel) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Supplay: Hashable {
    var id = UUID()
    var name: String
    var isPurchased: Bool
    var dateOfCreation: Date
    var category: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Category: Hashable {
    var id = UUID()
    var name: String
    var supplays: [Supplay?]
   
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
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
