//
//  DBPantry+CoreDataProperties.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 08.06.2023.
//
//

import Foundation
import CoreData


extension DBPantry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBPantry> {
        return NSFetchRequest<DBPantry>(entityName: "DBPantry")
    }

    @NSManaged public var color: Int16
    @NSManaged public var dateOfCreation: Date
    @NSManaged public var icon: Data?
    @NSManaged public var id: UUID
    @NSManaged public var index: Int16
    @NSManaged public var isShared: Bool
    @NSManaged public var isSharedListOwner: Bool
    @NSManaged public var isShowImage: Int16
    @NSManaged public var isVisibleCost: Bool
    @NSManaged public var name: String
    @NSManaged public var sharedId: String?
    @NSManaged public var synchronizedLists: Data?
    @NSManaged public var stocks: NSSet?

    static func prepare(fromPlainModel model: PantryModel, context: NSManagedObjectContext) -> DBPantry {
        let dbPantry = DBPantry(context: context)
        dbPantry.id = model.id
        dbPantry.name = model.name
        dbPantry.index = Int16(model.index)
        dbPantry.color = Int16(model.color)
        dbPantry.icon = model.icon
        dbPantry.synchronizedLists = try? JSONEncoder().encode(model.synchronizedLists)
        dbPantry.dateOfCreation = model.dateOfCreation
        dbPantry.sharedId = model.sharedId
        dbPantry.isShared = model.isShared
        dbPantry.isSharedListOwner = model.isSharedListOwner
        dbPantry.isShowImage = model.isShowImage.rawValue
        dbPantry.isVisibleCost = model.isVisibleCost
        return dbPantry
    }
}

// MARK: Generated accessors for stocks
extension DBPantry {

    @objc(addStocksObject:)
    @NSManaged public func addToStocks(_ value: DBStock)

    @objc(removeStocksObject:)
    @NSManaged public func removeFromStocks(_ value: DBStock)

    @objc(addStocks:)
    @NSManaged public func addToStocks(_ values: NSSet)

    @objc(removeStocks:)
    @NSManaged public func removeFromStocks(_ values: NSSet)

}

extension DBPantry : Identifiable {

}
