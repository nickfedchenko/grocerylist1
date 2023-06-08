//
//  DBStock+CoreDataProperties.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 08.06.2023.
//
//

import Foundation
import CoreData


extension DBStock {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBStock> {
        return NSFetchRequest<DBStock>(entityName: "DBStock")
    }

    @NSManaged public var autoRepeat: Data?
    @NSManaged public var cost: Double
    @NSManaged public var dateOfCreation: Date
    @NSManaged public var id: UUID
    @NSManaged public var imageData: Data?
    @NSManaged public var index: Int16
    @NSManaged public var isAutoRepeat: Bool
    @NSManaged public var isAvailability: Bool
    @NSManaged public var isReminder: Bool
    @NSManaged public var isUserImage: Bool
    @NSManaged public var name: String
    @NSManaged public var pantryId: UUID
    @NSManaged public var quantity: Double
    @NSManaged public var stockDescription: String?
    @NSManaged public var store: Data?
    @NSManaged public var unitId: Int16
    @NSManaged public var userToken: String?
    @NSManaged public var pantry: DBPantry?

    static func prepare(fromPlainModel model: Stock, context: NSManagedObjectContext) -> DBStock {
        let dbStock = DBStock(context: context)
        dbStock.id = model.id
        dbStock.index = Int16(model.index)
        dbStock.pantryId = model.pantryId
        dbStock.name = model.name
        dbStock.imageData = model.imageData
        dbStock.stockDescription = model.description
        dbStock.store = try? JSONEncoder().encode(model.store)
        dbStock.cost = model.cost ?? -1
        dbStock.quantity = model.quantity ?? -1
        dbStock.unitId = Int16(model.unitId?.rawValue ?? 0)
        dbStock.isAvailability = model.isAvailability
        dbStock.isAutoRepeat = model.isAutoRepeat
        dbStock.autoRepeat = try? JSONEncoder().encode(model.autoRepeat)
        dbStock.isReminder = model.isReminder
        dbStock.dateOfCreation = model.dateOfCreation
        dbStock.isUserImage = model.isUserImage ?? false
        dbStock.userToken = model.userToken
        return dbStock
    }
}

extension DBStock : Identifiable {

}
