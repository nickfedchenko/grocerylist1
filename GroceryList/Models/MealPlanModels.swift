//
//  MealPlanModels.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 11.09.2023.
//

import Foundation

protocol ItemWithLabelProtocol {
    var label: UUID? { get set }
    var date: Date { get set }
    var index: Int { get set }
}

struct MealPlan: Hashable, Codable, ItemWithLabelProtocol {
    let id: UUID
    let recipeId: Int
    var date: Date
    var label: UUID?
    var destinationListId: UUID?
    var index: Int = 0
    
    init(id: UUID = UUID(), recipeId: Int, date: Date,
         label: UUID?, destinationListId: UUID? = nil) {
        self.id = id
        self.recipeId = recipeId
        self.date = date
        self.label = label
        self.destinationListId = destinationListId
    }
    
    // для пустых дат
    init(date: Date) {
        id = 0.asUUID
        recipeId = -1
        self.date = date
        label = nil
        destinationListId = nil
    }
    
    init(dbModel: DBMealPlan) {
        self.id = dbModel.id
        self.recipeId = dbModel.recipeId.asInt
        self.date = dbModel.date
        self.label = dbModel.label
        self.destinationListId = dbModel.destinationListId
        self.index = Int(dbModel.index)
    }
    
    init(copy: MealPlan, date: Date) {
        self.id = UUID()
        self.recipeId = copy.recipeId
        self.date = date
        self.label = copy.label
        self.destinationListId = copy.destinationListId
        self.index = copy.index
    }
}

struct MealPlanLabel: Hashable, Codable {
    let id: UUID
    var title: String
    var color: Int
    var index: Int
    
    var isSelected = false
    
    init(defaultLabel: DefaultLabel) {
        self.id = defaultLabel.id
        self.title = defaultLabel.title
        self.color = defaultLabel.color
        self.index = defaultLabel.rawValue
    }
    
    init(dbModel: DBLabel) {
        self.id = dbModel.id
        self.title = (dbModel.title ?? "").localized
        self.color = Int(dbModel.color)
        self.index = Int(dbModel.index)
    }
    
    init(id: UUID = UUID(), title: String, color: Int, index: Int) {
        self.id = id
        self.title = title
        self.color = color
        self.index = index
    }
}

struct MealPlanNote: Hashable, Codable, ItemWithLabelProtocol {
    let id: UUID
    var title: String
    var details: String?
    var date: Date
    var label: UUID?
    var index: Int = 0
    
    init(id: UUID = UUID(), title: String, details: String?, date: Date, label: UUID?) {
        self.id = id
        self.title = title
        self.details = details
        self.date = date
        self.label = label
    }
    
    init(dbModel: DBMealPlanNote) {
        self.id = dbModel.id
        self.title = dbModel.title
        self.details = dbModel.details
        self.date = dbModel.date
        self.label = dbModel.label
        self.index = Int(dbModel.index)
    }
}

struct MealPlanSection: Hashable {
    var sectionType: MealPlanSectionType
    var date: Date
    var mealPlans: [MealPlanCellModel]
}

struct MealPlanCellModel: Hashable {
    var type: MealPlanCellType
    var date: Date
    var index: Int
    var mealPlan: MealPlan?
    var note: MealPlanNote?
    var isEdit: Bool = false
    var isSelectedEditMode: Bool = false
    
    init(type: MealPlanCellType, date: Date, index: Int,
         mealPlan: MealPlan? = nil,  note: MealPlanNote? = nil,
         isEdit: Bool = false, isSelectedEditMode: Bool = false) {
        self.type = type
        self.date = date
        self.index = index
        self.mealPlan = mealPlan
        self.note = note
        self.isEdit = isEdit
        self.isSelectedEditMode = isSelectedEditMode
    }
}

enum MealPlanSectionType {
    case month
    case weekStart
    case week
}

enum MealPlanCellType {
    case plan
    case planEmpty
    case note
    case noteEmpty
    case noteFilled
}
