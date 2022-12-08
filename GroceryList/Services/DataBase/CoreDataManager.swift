//
//  CoreDataManager.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 08.11.2022.
//

import CoreData
import Foundation
import UIKit

protocol CoredataSyncProtocol {
    func saveRecipes(recipes: [Recipe])
    func saveProducts(products: [NetworkProductModel])
}

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
        try? context.save()
    }
    
    func createProduct(product: Product) {
        guard getProduct(id: product.id) == nil else {
            updateProduct(product: product)
            return
        }
        
        let context = coreData.container.viewContext
        let fetchRequest: NSFetchRequest<DBGroceryListModel> = DBGroceryListModel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "\(#keyPath(DBGroceryListModel.id)) = '\(product.listId)'")
        guard let list = try? context.fetch(fetchRequest).first else { return }
        
        let object = DBProduct(context: context)
        object.list = list
        object.isPurchased = product.isPurchased
        object.name = product.name
        object.dateOfCreation = product.dateOfCreation
        object.id = product.id
        object.listId = product.listId
        object.category = product.category
        object.isFavorite = product.isFavorite
        object.image = product.imageData
        object.userDescription = product.description
        try? context.save()
    }
    
    func getProduct(id: UUID) -> DBProduct? {
        let fetchRequest: NSFetchRequest<DBProduct> = DBProduct.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = '\(id)'")
        guard let object = try? coreData.container.viewContext.fetch(fetchRequest).first else {
            return nil
        }
        return object
    }
    
    func updateProduct(product: Product) {
        let context = coreData.container.viewContext
        let fetchRequest: NSFetchRequest<DBProduct> = DBProduct.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = '\(product.id)'")
        if let object = try? context.fetch(fetchRequest).first {
            object.isPurchased = product.isPurchased
            object.name = product.name
            object.dateOfCreation = product.dateOfCreation
            object.category = product.category
            object.isFavorite = product.isFavorite
        }
        try? context.save()
    }
    
    func getProducts(for list: GroceryListsModel) -> [DBProduct] {
        let fetchRequest: NSFetchRequest<DBProduct> = DBProduct.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "listId = '\(list.id)'")
        return (try? coreData.container.viewContext.fetch(fetchRequest).compactMap { $0 }) ?? []
    }
    
    func createNetworkProduct(product: NetworkProductModel) {
        guard getNetworkProduct(id: product.id) == nil else {
            updateNetworkProduct(product: product)
            return
        }
        
        let context = coreData.container.viewContext
        let fetchRequest: NSFetchRequest<DBNetworkProduct> = DBNetworkProduct.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = '\(product.id)'")
        
        let object = DBNetworkProduct(context: context)
        object.title = product.title
        object.id = Int64(product.id)
        object.marketCategory = product.marketCategory?.title
        object.photo = product.photo
        try? context.save()
    }
    
    func getNetworkProduct(id: Int) -> DBNetworkProduct? {
        let fetchRequest: NSFetchRequest<DBNetworkProduct> = DBNetworkProduct.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = '\(id)'")
        guard let object = try? coreData.container.viewContext.fetch(fetchRequest).first else {
            return nil
        }
        return object
    }
    
    func updateNetworkProduct(product: NetworkProductModel) {
        let context = coreData.container.viewContext
        let fetchRequest: NSFetchRequest<DBNetworkProduct> = DBNetworkProduct.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = '\(product.id)'")
        if let object = try? context.fetch(fetchRequest).first {
            object.title = product.title
            object.id = Int64(product.id)
            object.marketCategory = product.marketCategory?.title
            object.photo = product.photo
        }
        try? context.save()
    }
    
    func getAllNetworkProducts() -> [DBNetworkProduct]? {
        let fetchRequest: NSFetchRequest<DBNetworkProduct> = DBNetworkProduct.fetchRequest()
        guard let object = try? coreData.container.viewContext.fetch(fetchRequest) else {
            return nil
        }
        return object
    }
    
    func getAllRecipes() -> [DBRecipe]? {
        let fetchRequest: NSFetchRequest<DBRecipe> = DBRecipe.fetchRequest()
        guard let object = try? coreData.context.fetch(fetchRequest) else {
            return nil
        }
        return object
    }
    
    func removeProduct(product: Product) {
        let context = coreData.container.viewContext
        let fetchRequest: NSFetchRequest<DBProduct> = DBProduct.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = '\(product.id)'")
        if let object = try? context.fetch(fetchRequest).first {
            context.delete(object)
        }
        try? context.save()
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
    
    func saveCategory(category: CategoryModel) {
        let context = coreData.container.viewContext
        let object = DBCategories(context: context)
        object.id = Int64(category.ind)
        object.name = category.name
        try? context.save()
    }
    
    func getAllCategories() -> [DBCategories]? {
        let fetchRequest: NSFetchRequest<DBCategories> = DBCategories.fetchRequest()
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

extension CoreDataManager: CoredataSyncProtocol {
    func saveRecipes(recipes: [Recipe]) {
        let asyncContext = coreData.taskContext
        let _ = recipes.map { DBRecipe.prepare(fromPlainModel: $0, context: asyncContext)}
        guard asyncContext.hasChanges else { return }
        asyncContext.perform {
            do {
                try asyncContext.save()
            } catch let error {
                print(error)
                asyncContext.rollback()
            }
        }
    }
    
    func saveProducts(products: [NetworkProductModel]) {
        let asyncContext = coreData.taskContext
        let _ = products.map { DBNetworkProduct.prepare(fromProduct: $0, using: asyncContext) }
        guard asyncContext.hasChanges else { return }
        asyncContext.perform {
            do {
                try asyncContext.save()
            } catch {
                asyncContext.rollback()
            }
        }
    }
    
    
}

