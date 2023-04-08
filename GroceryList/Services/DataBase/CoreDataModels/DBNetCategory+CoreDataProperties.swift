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
        let dbProduct = DBNetCategory(context: context)
        dbProduct.id = Int64(category.id)
        dbProduct.netId = category.netId
        dbProduct.name = category.title
        return dbProduct
    }
    
}

extension DBNetCategory : Identifiable {

}
