//
//  DBCollection+CoreDataProperties.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 07.03.2023.
//
//

import Foundation
import CoreData


extension DBCollection {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBCollection> {
        return NSFetchRequest<DBCollection>(entityName: "DBCollection")
    }

    @NSManaged public var id: Int64
    @NSManaged public var title: String?
    @NSManaged public var index: Int16
    @NSManaged public var isDefault: Bool

    static func prepare(fromPlainModel model: CollectionModel, context: NSManagedObjectContext) -> DBCollection {
        let dbCollection = DBCollection(context: context)
        dbCollection.id = Int64(model.id)
        dbCollection.title = model.title
        dbCollection.index = Int16(model.index)
        dbCollection.isDefault = model.isDefault
        return dbCollection
    }
}

extension DBCollection : Identifiable {

}
