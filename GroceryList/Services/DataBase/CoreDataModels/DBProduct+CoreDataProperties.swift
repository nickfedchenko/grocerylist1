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
    
    static func prepare(fromPlainModel model: Product, context: NSManagedObjectContext) -> DBProduct {
        let dbProduct = DBProduct(context: context)
        dbProduct.isPurchased = model.isPurchased
        dbProduct.name = model.name
        dbProduct.dateOfCreation = model.dateOfCreation
        dbProduct.id = model.id
        dbProduct.listId = model.listId
        dbProduct.category = model.category
        dbProduct.isFavorite = model.isFavorite
        dbProduct.image = model.imageData
        dbProduct.userDescription = model.description
        dbProduct.fromRecipeTitle = model.fromRecipeTitle
        dbProduct.unitId = Int16(model.unitId?.rawValue ?? 0)
        return dbProduct
    }
}
