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

}

extension DBCollection : Identifiable {

}
