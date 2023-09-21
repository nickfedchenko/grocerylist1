//
//  MealPlanModels.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 11.09.2023.
//

import Foundation

struct MealPlan: Hashable, Codable {
    let id: UUID
    let recipeId: Int
    var date: Date
    var label: MealPlanLabel?
    var destinationListId: UUID?
    
    init(id: UUID = UUID(), recipeId: Int, date: Date,
         label: MealPlanLabel, destinationListId: UUID? = nil) {
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
        self.label = (try? JSONDecoder().decode(MealPlanLabel.self, from: dbModel.label ?? Data()))
        self.destinationListId = dbModel.destinationListId
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
    
    init(title: String, color: Int, index: Int) {
        self.id = UUID()
        self.title = title
        self.color = color
        self.index = index
    }
}

struct MealPlanNote: Hashable, Codable {
    let id: UUID
    let title: String
    let details: String
    var date: Date
    var label: MealPlanLabel
}

struct MealPlanSection: Hashable {
    var sectionType: MealPlanSectionType
    var date: Date
    var mealPlans: [MealPlanCellModel]
}

struct MealPlanCellModel: Hashable {
    var type: MealPlanCellType
    var date: Date
    var mealPlan: MealPlan?
    var note: String?
    
    init(type: MealPlanCellType,
         date: Date,
         mealPlan: MealPlan? = nil,
         note: String? = nil) {
        self.type = type
        self.date = date
        self.mealPlan = mealPlan
        self.note = note
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
