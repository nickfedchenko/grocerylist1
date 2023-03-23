//
//  DBGroceryListModel+CoreDataProperties.swift
//  
//
//  Created by Шамиль Моллачиев on 18.11.2022.
//
//

import Foundation
import CoreData


extension DBGroceryListModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBGroceryListModel> {
        return NSFetchRequest<DBGroceryListModel>(entityName: "DBGroceryListModel")
    }

    @NSManaged public var color: Int64
    @NSManaged public var dateOfCreation: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var name: String?
    @NSManaged public var typeOfSorting: Int64
    @NSManaged public var products: NSSet?
    @NSManaged public var sharedListId: String?
    @NSManaged public var isShared: Bool
    @NSManaged public var isSharedListOwner: Bool
    @NSManaged public var isShowImage: Int16

}

// MARK: Generated accessors for products
extension DBGroceryListModel {

    @objc(addProductsObject:)
    @NSManaged public func addToProducts(_ value: DBProduct)

    @objc(removeProductsObject:)
    @NSManaged public func removeFromProducts(_ value: DBProduct)

    @objc(addProducts:)
    @NSManaged public func addToProducts(_ values: NSSet)

    @objc(removeProducts:)
    @NSManaged public func removeFromProducts(_ values: NSSet)

}
