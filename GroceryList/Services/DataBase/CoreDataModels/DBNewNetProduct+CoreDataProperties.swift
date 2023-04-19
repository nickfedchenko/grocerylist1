//
//  DBNewNetProduct+CoreDataProperties.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 13.04.2023.
//
//

import Foundation
import CoreData


extension DBNewNetProduct {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBNewNetProduct> {
        return NSFetchRequest<DBNewNetProduct>(entityName: "DBNewNetProduct")
    }

    @NSManaged public var defaultMarketUnitID: Int16
    @NSManaged public var id: Int64
    @NSManaged public var marketCategory: String?
    @NSManaged public var photo: String?
    @NSManaged public var title: String?
    @NSManaged public var productTypeId: Int16

    static func prepare(fromProduct product: NetworkProductModel,
                        using context: NSManagedObjectContext) -> DBNewNetProduct {
        let dbProduct = DBNewNetProduct(context: context)
        dbProduct.title = product.title
        dbProduct.id = Int64(product.id)
        dbProduct.marketCategory = product.marketCategory?.title
        dbProduct.photo = product.photo
        dbProduct.defaultMarketUnitID = Int16(product.marketUnit?.id ?? -1)
        dbProduct.productTypeId = Int16(product.productTypeId ?? -1)
        return dbProduct
    }
}

extension DBNewNetProduct : Identifiable {

}
