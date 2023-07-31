//
//  DBCategories+CoreDataProperties.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 30.11.2022.
//
//

import Foundation
import CoreData


extension DBCategories {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBCategories> {
        return NSFetchRequest<DBCategories>(entityName: "DBCategory")
    }

    @NSManaged public var id: Int64
    @NSManaged public var name: String?

}
