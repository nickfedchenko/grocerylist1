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
    func saveCategories(categories: [NetworkCategory])
}

class CoreDataManager {
    let coreData: CoreDataStorage
    static let shared = CoreDataManager()
    
    private init() {
        coreData = CoreDataStorage()
        
        // удаление старой базы продуктов с сервера
        deleteOldEntities()
    }
    
    // MARK: - Products
    func createProduct(product: Product) {
        guard getProduct(id: product.id) == nil else {
            updateProduct(product: product)
            return
        }
        
        let context = coreData.container.viewContext
        let fetchRequest: NSFetchRequest<DBGroceryListModel> = DBGroceryListModel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "\(#keyPath(DBGroceryListModel.id)) = '\(product.listId)'")
        guard let list = try? context.fetch(fetchRequest).first else { return }
        
        let object = DBProduct.prepare(fromPlainModel: product, context: context)
        object.list = list
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
            object.listId = product.listId
            object.isPurchased = product.isPurchased
            object.name = product.name
            object.userDescription = product.description
            object.image = product.imageData
            object.dateOfCreation = product.dateOfCreation
            object.category = product.category
            object.isFavorite = product.isFavorite
            object.fromRecipeTitle = product.fromRecipeTitle
            object.userDescription = product.description
            object.unitId = Int16(product.unitId?.rawValue ?? 0)
            object.isUserImage = product.isUserImage ?? false
            object.userToken = product.userToken
            object.store = try? JSONEncoder().encode(product.store)
            object.cost = product.cost ?? -1
            object.quantity = product.quantity ?? -1
        }
        
        try? context.save()
    }
    
    func getProducts(for listId: String) -> [DBProduct] {
        let fetchRequest: NSFetchRequest<DBProduct> = DBProduct.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "listId = '\(listId)'")
        return (try? coreData.container.viewContext.fetch(fetchRequest).compactMap { $0 }) ?? []
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
    
    func removeProduct(id: String) {
        let context = coreData.container.viewContext
        let fetchRequest: NSFetchRequest<DBProduct> = DBProduct.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = '\(id)'")
        if let object = try? context.fetch(fetchRequest).first {
            context.delete(object)
        }
        try? context.save()
    }
    
    func getAllProducts() -> [DBProduct]? {
        let fetchRequest: NSFetchRequest<DBProduct> = DBProduct.fetchRequest()
        guard let object = try? coreData.container.viewContext.fetch(fetchRequest) else {
            return nil
        }
        return object
    }
    
    // MARK: - NetworkProducts
    
    func getAllNetworkProducts() -> [DBNewNetProduct]? {
        let fetchRequest: NSFetchRequest<DBNewNetProduct> = DBNewNetProduct.fetchRequest()
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
    
    
    // MARK: - GroceryList
    func saveList(list: GroceryListsModel) {
        idsOfChangedLists.insert(list.id)
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
        object.isShared = list.isShared
        object.sharedListId = list.sharedId
        object.isSharedListOwner = list.isSharedListOwner
        object.isShowImage = list.isShowImage.rawValue
        object.isVisibleCost = list.isVisibleCost
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
            object.isShared = list.isShared
            object.sharedListId = list.sharedId
            object.isShowImage = list.isShowImage.rawValue
            object.isVisibleCost = list.isVisibleCost
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
        idsOfChangedLists.insert(id)
    }
    
    func removeSharedList(by sharedListId: String) {
        let context = coreData.container.viewContext
        let fetchRequest: NSFetchRequest<DBGroceryListModel> = DBGroceryListModel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "sharedListId = '\(sharedListId)'")
        if let object = try? context.fetch(fetchRequest).first {
            context.delete(object)
        }
        try? context.save()
    }
    
    func removeSharedLists() {
        let context = coreData.container.viewContext
        let fetchRequest: NSFetchRequest<DBGroceryListModel> = DBGroceryListModel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isShared = %d", true)
      
        if let objects = try? context.fetch(fetchRequest){
            objects.forEach {
                context.delete($0)
            }
        }
        try? context.save()
    }
    
    
    // MARK: - Categories
    func saveCategory(category: CategoryModel) {
        let context = coreData.container.viewContext
        let object = DBCategories(context: context)
        object.id = Int64(category.ind)
        object.name = category.name
        try? context.save()
    }
    
    func getUserCategories() -> [DBCategories]? {
        let fetchRequest: NSFetchRequest<DBCategories> = DBCategories.fetchRequest()
        guard let object = try? coreData.container.viewContext.fetch(fetchRequest) else {
            return nil
        }
        return object
    }
    
    func getDefaultCategories() -> [DBNetCategory]? {
        let fetchRequest: NSFetchRequest<DBNetCategory> = DBNetCategory.fetchRequest()
        guard let object = try? coreData.container.viewContext.fetch(fetchRequest) else {
            return nil
        }
        return object
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
    
    // MARK: - USER
    lazy var userRequest: NSFetchRequest = {
        return NSFetchRequest<NSFetchRequestResult>(entityName: "DomainUser")
    }()
    
    private func deleteEntitiesOfType(request: NSFetchRequest<NSFetchRequestResult> ) {
        do {
            let data = try coreData.container.viewContext.fetch(request)
            for item in data {
                guard let item = item as? NSManagedObject else { return }
                coreData.container.viewContext.delete(item)
            }
            try? coreData.container.viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteUser() {
        deleteEntitiesOfType(request: userRequest)
    }
    
    func saveUser(user: User) {
        let context = coreData.container.viewContext
        let object = DomainUser(context: context)
        object.id = 0
        object.name = user.username
        object.mail = user.email
        object.password = user.password
        object.token = user.token
        object.avatarUrl = user.avatar
        object.avatarAsData = user.avatarAsData
        try? context.save()
    }
    
    func getUser() -> DomainUser? {
        do {
            let data = try coreData.container.viewContext.fetch(userRequest)
            for item in data {
                if let item = item as? DomainUser {
                    if item == data.last as? DomainUser {
                        return item
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    
    // MARK: - ResetPasswordModel
    lazy var resetPasswordModelRequest: NSFetchRequest = {
        return NSFetchRequest<NSFetchRequestResult>(entityName: "DomainResetPasswordModel")
    }()
    
    
    func deleteResetPasswordModel() {
        deleteEntitiesOfType(request: resetPasswordModelRequest)
    }
    
    func saveResetPasswordModel(resetPasswordModel: ResetPasswordModel) {
        let context = coreData.container.viewContext
        let object = DomainResetPasswordModel(context: context)
        object.id = 0
        object.email = resetPasswordModel.email
        object.resetToken = resetPasswordModel.resetToken
        object.dateOfExpiration = resetPasswordModel.dateOfExpiration
        
        try? context.save()
    }
    
    func getResetPasswordModel() -> DomainResetPasswordModel? {
        do {
            let data = try coreData.container.viewContext.fetch(resetPasswordModelRequest)
            for item in data {
                if let item = item as? DomainResetPasswordModel {
                    if item == data.last as? DomainResetPasswordModel {
                        return item
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    // MARK: - Collection
    func saveCollection(collections: [CollectionModel]) {
        let asyncContext = coreData.viewContext
        let _ = collections.map { DBCollection.prepare(fromPlainModel: $0, context: asyncContext)}
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
    
    func getAllCollection() -> [DBCollection]? {
        let fetchRequest: NSFetchRequest<DBCollection> = DBCollection.fetchRequest()
        let sort = NSSortDescriptor(key: "index", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        guard let object = try? coreData.container.viewContext.fetch(fetchRequest) else {
            return nil
        }
        return object
    }
    
    func deleteCollection(by id: Int) {
        let context = coreData.container.viewContext
        let fetchRequest: NSFetchRequest<DBCollection> = DBCollection.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = '\(id)'")
        if let object = try? context.fetch(fetchRequest).first {
            context.delete(object)
        }
        try? context.save()
    }
    
    // MARK: - Recipe
    func getRecipe(by id: Int) -> DBRecipe? {
        let fetchRequest: NSFetchRequest<DBRecipe> = DBRecipe.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = '\(id)'")
        guard let object = try? coreData.container.viewContext.fetch(fetchRequest).first else {
            return nil
        }
        return object
    }
    
    private func deleteOldEntities() {
        let oldEntityNames = ["DBNetworkProduct", "DBNetProduct"]
        oldEntityNames.forEach { oldEntityName in
            if coreData.container.managedObjectModel.entities.contains(where: { $0.name == oldEntityName }) {
                delete(entityName: oldEntityName)
            }
        }
    }
    
    // MARK: - Store {
    func saveStore(_ store: Store) {
        let context = coreData.container.viewContext
        let object = DBStore(context: context)
        object.id = store.id
        object.title = store.title
        try? context.save()
    }
    
    func getAllStores() -> [DBStore]? {
        let fetchRequest: NSFetchRequest<DBStore> = DBStore.fetchRequest()
        guard let object = try? coreData.container.viewContext.fetch(fetchRequest) else {
            return nil
        }
        return object
    }
    
}

extension CoreDataManager: CoredataSyncProtocol {
    func saveRecipes(recipes: [Recipe]) {
        let asyncContext = coreData.taskContext
        asyncContext.perform {
            do {
                let _ = recipes.map { DBRecipe.prepare(fromPlainModel: $0, context: asyncContext)}
                try asyncContext.save()
                NotificationCenter.default.post(name: .recieptsDownladedAnsSaved, object: nil)
            } catch let error {
                print(error)
                asyncContext.rollback()
            }
        }
    }
    
    func saveProducts(products: [NetworkProductModel]) {
        let asyncContext = coreData.taskContext
        asyncContext.perform {
            do {
                let _ = products.map { DBNewNetProduct.prepare(fromProduct: $0, using: asyncContext) }
                try asyncContext.save()
                NotificationCenter.default.post(name: .productsDownladedAnsSaved, object: nil)
            } catch {
                asyncContext.rollback()
            }
        }
    }
    
    func saveCategories(categories: [NetworkCategory]) {
        let asyncContext = coreData.taskContext
        asyncContext.perform {
            do {
                let _ = categories.map { DBNetCategory.prepare(from: $0, using: asyncContext) }
                try asyncContext.save()
            } catch {
                asyncContext.rollback()
            }
        }
    }
}
