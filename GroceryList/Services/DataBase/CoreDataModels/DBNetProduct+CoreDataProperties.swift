//
//  DBNetProduct+CoreDataProperties.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 16.03.2023.
//
//

import Foundation
import CoreData


extension DBNetProduct {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBNetProduct> {
        return NSFetchRequest<DBNetProduct>(entityName: "DBNetProduct")
    }

    @NSManaged public var defaultMarketUnitID: Int16
    @NSManaged public var id: Int64
    @NSManaged public var marketCategory: String?
    @NSManaged public var photo: String?
    @NSManaged public var title: String?

    static func prepare(fromProduct product: NetworkProductModel,
                        using context: NSManagedObjectContext) -> DBNetProduct {
        let dbProduct = DBNetProduct(context: context)
        dbProduct.title = product.title
        dbProduct.id = Int64(product.id)
        dbProduct.marketCategory = product.marketCategory?.title
        dbProduct.photo = product.photo
        dbProduct.defaultMarketUnitID = Int16(product.marketUnit?.id ?? -1)
        return dbProduct
    }
}

extension DBNetProduct : Identifiable {

}
