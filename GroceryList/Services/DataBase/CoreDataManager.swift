//
//  CoreDataManager.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 08.11.2022.
//

import CoreData
import Foundation
import UIKit

class CoreDataManager {
    let coreData: CoreDataStorage
    static let shared = CoreDataManager()
    
    private init() {
        coreData = CoreDataStorage()
    }
    
    func saveList(list: GroceryListsModel) {
        guard getList(list: list.id.uuidString) == nil else {
            updateList(list)
            return
        }
        let context = coreData.container.viewContext
        let object = DBGroceryListModel(context: context)
        object.id = list.id
        object.isFavorite = list.isFavorite
        object.color = Int64(list.color)
        object.name = list.name
        object.dateOfCreation = list.dateOfCreation
        object.typeOfSorting = Int64(list.typeOfSorting)
        object.supplays = nil
        try? context.save()

    }
    
    func createSupplay(supplay: Supplay) {
        guard getSupplay(id: supplay.id) == nil else {
            updateSupplay(supplay: supplay)
            return
        }
        
        let context = coreData.container.viewContext
        let fetchRequest: NSFetchRequest<DBGroceryListModel> = DBGroceryListModel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "\(#keyPath(DBGroceryListModel.id)) = '\(supplay.listId)'")
        guard let list = try? context.fetch(fetchRequest).first else { return }
        
        let object = DBSupplay(context: context)
        object.list = list
        object.isPurchased = supplay.isPurchased
        object.name = supplay.name
        object.dateOfCreation = supplay.dateOfCreation
        object.id = supplay.id
        object.listId = supplay.listId
        object.category = supplay.category
        try? context.save()
    }
    
    func getSupplay(id: UUID) -> DBSupplay? {
        let fetchRequest: NSFetchRequest<DBSupplay> = DBSupplay.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = '\(id)'")
        guard let object = try? coreData.container.viewContext.fetch(fetchRequest).first else {
            return nil
        }
        return object
    }
    
    func updateSupplay(supplay: Supplay) {
        let context = coreData.container.viewContext
        let fetchRequest: NSFetchRequest<DBSupplay> = DBSupplay.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = '\(supplay.id)'")
        if let object = try? context.fetch(fetchRequest).first {
            object.isPurchased = supplay.isPurchased
            object.name = supplay.name
            object.dateOfCreation = supplay.dateOfCreation
            object.category = supplay.category
        }
        try? context.save()
    }
    
    func getSupplays(for list: GroceryListsModel) -> [DBSupplay] {
        let fetchRequest: NSFetchRequest<DBSupplay> = DBSupplay.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "listId = '\(list.id)'")
        return (try? coreData.container.viewContext.fetch(fetchRequest).compactMap { $0 }) ?? []
    }
    
    func getList(list: String) -> DBGroceryListModel? {
        let fetchRequest: NSFetchRequest<DBGroceryListModel> = DBGroceryListModel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = '\(list)'")
        guard let object = try? coreData.container.viewContext.fetch(fetchRequest).first else {
            return nil
        }
        return object
    }
    
    private func updateList(_ list: GroceryListsModel) {
        let context = coreData.container.viewContext
        let fetchRequest: NSFetchRequest<DBGroceryListModel> = DBGroceryListModel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = '\(list.id)'")
        if let object = try? context.fetch(fetchRequest).first {
            object.id = list.id
            object.isFavorite = list.isFavorite
            object.color = Int64(list.color)
            object.name = list.name
            object.dateOfCreation = list.dateOfCreation
            object.typeOfSorting = Int64(list.typeOfSorting)
        }
        try? context.save()
    }
    
    func getAllLists() -> [DBGroceryListModel]? {
        let fetchRequest: NSFetchRequest<DBGroceryListModel> = DBGroceryListModel.fetchRequest()
        guard let object = try? coreData.container.viewContext.fetch(fetchRequest) else {
            return nil
        }
        return object
    }
    
    func removeList(_ id: UUID) {
        let context = coreData.container.viewContext
        let fetchRequest: NSFetchRequest<DBGroceryListModel> = DBGroceryListModel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = '\(id)'")
        if let object = try? context.fetch(fetchRequest).first {
            context.delete(object)
        }
        try? context.save()
    }
    
    func deleteAllEntities() {
        let entities = coreData.container.managedObjectModel.entities
        entities.forEach {
            delete(entityName: $0.name)
        }
    }
    
    private func delete(entityName: String?) {
        guard let entityName = entityName else {
            return
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try coreData.container.viewContext.execute(deleteRequest)
        } catch let error as NSError {
            debugPrint(error)
        }
    }
}
