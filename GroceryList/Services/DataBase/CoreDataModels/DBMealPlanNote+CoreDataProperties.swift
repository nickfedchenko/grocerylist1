//
//  DBMealPlanNote+CoreDataProperties.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 25.09.2023.
//
//

import Foundation
import CoreData


extension DBMealPlanNote {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBMealPlanNote> {
        return NSFetchRequest<DBMealPlanNote>(entityName: "DBMealPlanNote")
    }

    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var details: String?
    @NSManaged public var date: Date
    @NSManaged public var label: UUID?

    static func prepare(fromPlainModel model: MealPlanNote, context: NSManagedObjectContext) -> DBMealPlanNote {
        let dbLabel = DBMealPlanNote(context: context)
        dbLabel.id = model.id
        dbLabel.title = model.title
        dbLabel.details = model.details
        dbLabel.date = model.date
        dbLabel.label = model.label
        return dbLabel
    }
}

extension DBMealPlanNote : Identifiable {

}
