//
//  DBProduct+CoreDataProperties.swift
//  
//
//  Created by Шамиль Моллачиев on 18.11.2022.
//
//

import Foundation
import CoreData


extension DBProduct {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBProduct> {
        return NSFetchRequest<DBProduct>(entityName: "DBProduct")
    }

    @NSManaged public var category: String?
    @NSManaged public var dateOfCreation: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var isPurchased: Bool
    @NSManaged public var listId: UUID?
    @NSManaged public var name: String?
    @NSManaged public var list: DBGroceryListModel?

}
