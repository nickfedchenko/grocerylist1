//
//  DBMealListSharedInfo+CoreDataProperties.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 13.10.2023.
//
//

import Foundation
import CoreData


extension DBMealListSharedInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBMealListSharedInfo> {
        return NSFetchRequest<DBMealListSharedInfo>(entityName: "DBMealListSharedInfo")
    }

    @NSManaged public var mealListId: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var isOwner: Bool

}

extension DBMealListSharedInfo : Identifiable {

}
