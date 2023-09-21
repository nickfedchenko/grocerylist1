//
//  DBLabel+CoreDataProperties.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 19.09.2023.
//
//

import Foundation
import CoreData

extension DBLabel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBLabel> {
        return NSFetchRequest<DBLabel>(entityName: "DBLabel")
    }

    @NSManaged public var id: UUID
    @NSManaged public var title: String?
    @NSManaged public var color: Int16
    @NSManaged public var index: Int16

    static func prepare(fromPlainModel model: MealPlanLabel, context: NSManagedObjectContext) -> DBLabel {
        let dbLabel = DBLabel(context: context)
        dbLabel.id = model.id
        dbLabel.title = model.title
        dbLabel.color = Int16(model.color)
        dbLabel.index = Int16(model.index)
        return dbLabel
    }
}

extension DBLabel : Identifiable {

}
