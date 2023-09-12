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
    var label: MealPlanLabel
    var destinationListId: UUID?
    
    init(id: UUID = UUID(), recipeId: Int, date: Date,
         label: MealPlanLabel, destinationListId: UUID? = nil) {
        self.id = id
        self.recipeId = recipeId
        self.date = date
        self.label = label
        self.destinationListId = destinationListId
    }
    
}

struct MealPlanLabel: Hashable, Codable {
    let id: UUID
    let title: String
    let color: Int
    
    init(defaultLabel: DefaultLabel) {
        self.id = defaultLabel.id
        self.title = defaultLabel.title
        self.color = defaultLabel.color
    }
}

struct MealPlanNote: Hashable, Codable {
    let id: UUID
    let title: String
    let details: String
    var date: Date
    var label: MealPlanLabel
}
