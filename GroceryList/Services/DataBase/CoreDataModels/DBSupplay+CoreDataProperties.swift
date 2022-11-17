//
//  DBSupplay+CoreDataProperties.swift
//  
//
//  Created by Шамиль Моллачиев on 17.11.2022.
//
//

import Foundation
import CoreData


extension DBSupplay {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBSupplay> {
        return NSFetchRequest<DBSupplay>(entityName: "DBSupplay")
    }

    @NSManaged public var dateOfCreation: Date?
    @NSManaged public var isPurchased: Bool
    @NSManaged public var name: String?
    @NSManaged public var id: UUID?
    @NSManaged public var listId: UUID?
    @NSManaged public var list: DBGroceryListModel?

}
