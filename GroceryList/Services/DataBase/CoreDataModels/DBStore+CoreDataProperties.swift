//
//  DBStore+CoreDataProperties.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 19.04.2023.
//
//

import Foundation
import CoreData


extension DBStore {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBStore> {
        return NSFetchRequest<DBStore>(entityName: "DBStore")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var createdAt: Date?

}

extension DBStore : Identifiable {

}
