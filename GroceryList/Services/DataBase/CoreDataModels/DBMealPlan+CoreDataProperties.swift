//
//  DBMealPlan+CoreDataProperties.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 19.09.2023.
//
//

import Foundation
import CoreData

extension DBMealPlan {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBMealPlan> {
        return NSFetchRequest<DBMealPlan>(entityName: "DBMealPlan")
    }

    @NSManaged public var id: UUID
    @NSManaged public var recipeId: Int64
    @NSManaged public var date: Date
    @NSManaged public var label: Data?
    @NSManaged public var destinationListId: UUID?

    static func prepare(fromPlainModel model: MealPlan, context: NSManagedObjectContext) -> DBMealPlan {
        let dbLabel = DBMealPlan(context: context)
        dbLabel.id = model.id
        dbLabel.recipeId = Int64(model.recipeId)
        dbLabel.date = model.date
        dbLabel.label = try? JSONEncoder().encode(model.label)
        dbLabel.destinationListId = model.destinationListId
        return dbLabel
    }
}

extension DBMealPlan : Identifiable {

}
