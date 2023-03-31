//
//  DBProduct+CoreDataProperties.swift
//  
//
//  Created by Шамиль Моллачиев on 01.12.2022.
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
    @NSManaged public var isFavorite: Bool
    @NSManaged public var isPurchased: Bool
    @NSManaged public var listId: UUID?
    @NSManaged public var name: String?
    @NSManaged public var image: Data?
    @NSManaged public var userDescription: String?
    @NSManaged public var list: DBGroceryListModel?
    @NSManaged public var fromRecipeTitle: String?
    @NSManaged public var unitId: Int16
}
