//
//  DBNetCategory+CoreDataProperties.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 30.03.2023.
//
//

import Foundation
import CoreData


extension DBNetCategory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBNetCategory> {
        return NSFetchRequest<DBNetCategory>(entityName: "DBNetCategory")
    }

    @NSManaged public var id: Int64
    @NSManaged public var netId: String?
    @NSManaged public var name: String?

    static func prepare(from category: NetworkCategory,
                        using context: NSManagedObjectContext) -> DBNetCategory {
        let dbNetCategory = DBNetCategory(context: context)
        dbNetCategory.id = Int64(category.id)
        dbNetCategory.netId = category.netId
        dbNetCategory.name = category.title
        return dbNetCategory
    }
    
}

extension DBNetCategory : Identifiable {

}
