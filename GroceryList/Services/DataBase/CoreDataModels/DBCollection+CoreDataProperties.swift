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
    @NSManaged public var color: Int16
    @NSManaged public var isDefault: Bool
    @NSManaged public var localImage: Data?
    @NSManaged public var dishes: Data?

    static func prepare(fromPlainModel model: CollectionModel, context: NSManagedObjectContext) -> DBCollection {
        let dbCollection = DBCollection(context: context)
        dbCollection.id = Int64(model.id)
        dbCollection.title = model.title
        dbCollection.index = Int16(model.index)
        dbCollection.color = Int16(model.color ?? 0)
        dbCollection.isDefault = model.isDefault
        dbCollection.localImage = model.localImage
        dbCollection.dishes = try? JSONEncoder().encode(model.dishes)
        return dbCollection
    }
}

extension DBCollection : Identifiable {

}
