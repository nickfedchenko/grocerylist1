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
    @NSManaged public var label: UUID?
    @NSManaged public var destinationListId: UUID?
    @NSManaged public var index: Int16
    @NSManaged public var recordId: String?
    @NSManaged public var isOwner: Bool
    @NSManaged public var sharedId: String?

    static func prepare(fromPlainModel model: MealPlan, context: NSManagedObjectContext) -> DBMealPlan {
        let dbPlan = DBMealPlan(context: context)
        dbPlan.id = model.id
        dbPlan.recipeId = Int64(model.recipeId)
        dbPlan.date = model.date
        dbPlan.label = model.label
        dbPlan.destinationListId = model.destinationListId
        dbPlan.index = Int16(model.index)
        dbPlan.recordId = model.recordId
        dbPlan.isOwner = model.isOwner
        dbPlan.sharedId = model.sharedId
        return dbPlan
    }
}

extension DBMealPlan : Identifiable {

}
