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
    @NSManaged public var index: Int16
    @NSManaged public var recordId: String?
    @NSManaged public var isOwner: Bool
    @NSManaged public var sharedId: String?

    static func prepare(fromPlainModel model: MealPlanNote, context: NSManagedObjectContext) -> DBMealPlanNote {
        let dbNote = DBMealPlanNote(context: context)
        dbNote.id = model.id
        dbNote.title = model.title
        dbNote.details = model.details
        dbNote.date = model.date
        dbNote.label = model.label
        dbNote.index = Int16(model.index)
        dbNote.recordId = model.recordId
        dbNote.isOwner = model.isOwner
        dbNote.sharedId = model.sharedId
        return dbNote
    }
}

extension DBMealPlanNote : Identifiable {

}
