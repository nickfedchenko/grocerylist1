//
//  DBGroceryListModel+CoreDataProperties.swift
//  
//
//  Created by Шамиль Моллачиев on 08.11.2022.
//
//

import Foundation
import CoreData


extension DBGroceryListModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBGroceryListModel> {
        return NSFetchRequest<DBGroceryListModel>(entityName: "DBGroceryListModel")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var dateOfCreation: Date?
    @NSManaged public var name: String?
    @NSManaged public var color: String?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var supplays: NSSet?

}

// MARK: Generated accessors for supplays
extension DBGroceryListModel {

    @objc(addSupplaysObject:)
    @NSManaged public func addToSupplays(_ value: DBSupplay)

    @objc(removeSupplaysObject:)
    @NSManaged public func removeFromSupplays(_ value: DBSupplay)

    @objc(addSupplays:)
    @NSManaged public func addToSupplays(_ values: NSSet)

    @objc(removeSupplays:)
    @NSManaged public func removeFromSupplays(_ values: NSSet)

}
