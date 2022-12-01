//
//  DBNetworkProduct+CoreDataProperties.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 01.12.2022.
//
//

import Foundation
import CoreData


extension DBNetworkProduct {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBNetworkProduct> {
        return NSFetchRequest<DBNetworkProduct>(entityName: "DBNetworkProduct")
    }

    @NSManaged public var title: String?
    @NSManaged public var photo: Data?
    @NSManaged public var marketCategory: String?
    @NSManaged public var id: Int64

}

extension DBNetworkProduct : Identifiable {

}
