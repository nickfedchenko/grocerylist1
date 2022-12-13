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
    @NSManaged public var photo: String?
    @NSManaged public var marketCategory: String?
    @NSManaged public var id: Int64
    @NSManaged public var defaultMarketUnitID: Int16

    static func prepare(
        fromProduct product: NetworkProductModel,
        using context: NSManagedObjectContext
    ) -> DBNetworkProduct {
        let dbProduct = DBNetworkProduct(context: context)
        dbProduct.title = product.title
        dbProduct.id = Int64(product.id)
        dbProduct.marketCategory = product.marketCategory?.title
        dbProduct.photo = product.photo
        dbProduct.defaultMarketUnitID = Int16(product.marketUnit?.id ?? -1)
        return dbProduct
    }
}

extension DBNetworkProduct : Identifiable {

}
