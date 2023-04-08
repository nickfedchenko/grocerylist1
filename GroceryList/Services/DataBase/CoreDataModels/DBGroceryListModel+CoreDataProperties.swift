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

    static func prepare(fromPlainModel model: GroceryListsModel, context: NSManagedObjectContext) -> DBGroceryListModel {
        let object = DBGroceryListModel(context: context)
        object.id = model.id
        object.isFavorite = model.isFavorite
        object.color = Int64(model.color)
        object.name = model.name
        object.dateOfCreation = model.dateOfCreation
        object.typeOfSorting = Int64(model.typeOfSorting)
        object.isShared = model.isShared
        object.sharedListId = model.sharedId
        object.isSharedListOwner = model.isSharedListOwner
        object.isShowImage = model.isShowImage.rawValue
        return object
    }
}
