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

extension CoreDataManager {
    
    // MARK: - Products
    func createProduct(product: Product, successSave: (() -> Void)? = nil) {
        let asyncContext = coreData.context
        let fetchRequest: NSFetchRequest<DBGroceryListModel> = DBGroceryListModel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "\(#keyPath(DBGroceryListModel.id)) = '\(product.listId)'")
        guard let list = try? asyncContext.fetch(fetchRequest).first else {
            return
        }
        
        guard Thread.isMainThread else {
            asyncContext.perform { save() }
            return
        }
        asyncContext.performAndWait { save() }
        
        func save() {
            do {
                let _ = DBProduct.prepare(fromPlainModel: product, list: list, context: asyncContext)
                try asyncContext.save()
                successSave?()
            } catch let error {
                print(error)
                asyncContext.rollback()
            }
        }
    }
    
    func getProduct(id: UUID) -> DBProduct? {
        let fetchRequest: NSFetchRequest<DBProduct> = DBProduct.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = '\(id)'")
        guard let object = try? coreData.container.viewContext.fetch(fetchRequest).first else {
            return nil
        }
        return object
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
    
    func removeProduct(recordId: String) {
        let context = coreData.container.viewContext
        let fetchRequest: NSFetchRequest<DBProduct> = DBProduct.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "recordId = '\(recordId)'")
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
    
    // MARK: - GroceryList
    func saveList(list: GroceryListsModel) {
        idsOfChangedLists.insert(list.id)
        guard getList(list: list.id.uuidString) == nil else {
            updateList(list)
            return
        }
        let context = coreData.container.viewContext
        context.performAndWait {
            do {
                let _ = DBGroceryListModel.prepare(fromPlainModel: list, context: context)
                try context.save()
            } catch let error {
                print(error)
                context.rollback()
            }
        }
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
            object.typeOfSortingPurchased = Int64(list.typeOfSortingPurchased)
            object.isAscendingOrder = list.isAscendingOrder
            object.isAscendingOrderPurchased = list.isAscendingOrderPurchased.rawValue
            object.isAutomaticCategory = list.isAutomaticCategory
            object.recordId = list.recordId
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
    
    func removeList(recordId: String) {
        let context = coreData.container.viewContext
        let fetchRequest: NSFetchRequest<DBGroceryListModel> = DBGroceryListModel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "recordId = '\(recordId)'")
        if let object = try? context.fetch(fetchRequest).first {
            context.delete(object)
        }
        try? context.save()
    }
    
    // MARK: - Categories
    func saveCategory(category: CategoryModel) {
        let context = coreData.container.viewContext
        if let dbCategories = getCategory(id: Int64(category.ind)) {
            dbCategories.id = Int64(category.ind)
            dbCategories.name = category.name
            dbCategories.recordId = category.recordId
            try? context.save()
            return
        }
       
        let object = DBCategories(context: context)
        object.id = Int64(category.ind)
        object.name = category.name
        object.recordId = category.recordId
        try? context.save()
    }
    
    func getCategory(id: Int64) -> DBCategories? {
        let fetchRequest: NSFetchRequest<DBCategories> = DBCategories.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = '\(id)'")
        guard let object = try? coreData.container.viewContext.fetch(fetchRequest).first else {
            return nil
        }
        return object
    }
    
    func removeCategory(recordId: String) {
        let context = coreData.container.viewContext
        let fetchRequest: NSFetchRequest<DBCategories> = DBCategories.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "recordId = '\(recordId)'")
        if let object = try? context.fetch(fetchRequest).first {
            context.delete(object)
        }
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
    func deleteCollection(by id: Int) {
        let context = coreData.container.viewContext
        let fetchRequest: NSFetchRequest<DBCollection> = DBCollection.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = '\(id)'")
        if let object = try? context.fetch(fetchRequest).first {
            context.delete(object)
        }
        try? context.save()
    }
    
    func removeCollection(recordId: String) {
        let context = coreData.container.viewContext
        let fetchRequest: NSFetchRequest<DBCollection> = DBCollection.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "recordId = '\(recordId)'")
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
    
    func deleteRecipe(by id: Int) {
        let context = coreData.container.viewContext
        let fetchRequest: NSFetchRequest<DBRecipe> = DBRecipe.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = '\(id)'")
        if let object = try? context.fetch(fetchRequest).first {
            context.delete(object)
        }
        try? context.save()
    }
    
    func removeRecipe(recordId: String) {
        let context = coreData.container.viewContext
        let fetchRequest: NSFetchRequest<DBRecipe> = DBRecipe.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "recordId = '\(recordId)'")
        if let object = try? context.fetch(fetchRequest).first {
            context.delete(object)
        }
        try? context.save()
    }
    
    // MARK: - Store
    func saveStore(_ store: Store) {
        let context = coreData.container.viewContext
        let object = DBStore(context: context)
        object.id = store.id
        object.title = store.title
        object.recordId = store.recordId
        try? context.save()
    }
    
    func getAllStores() -> [DBStore]? {
        let fetchRequest: NSFetchRequest<DBStore> = DBStore.fetchRequest()
        guard let object = try? coreData.container.viewContext.fetch(fetchRequest) else {
            return nil
        }
        return object
    }
    
    func removeStore(recordId: String) {
        let context = coreData.container.viewContext
        let fetchRequest: NSFetchRequest<DBStore> = DBStore.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "recordId = '\(recordId)'")
        if let object = try? context.fetch(fetchRequest).first {
            context.delete(object)
        }
        try? context.save()
    }
    
    // MARK: - Pantry
    func savePantry(pantry: [PantryModel]) {
        let asyncContext = coreData.viewContext
        asyncContext.performAndWait {
            do {
                let _ = pantry.map { DBPantry.prepare(fromPlainModel: $0, context: asyncContext)}
                try asyncContext.save()
            } catch let error {
                print(error)
                asyncContext.rollback()
            }
        }
    }
    
    func getAllPantries() -> [DBPantry]? {
        let fetchRequest: NSFetchRequest<DBPantry> = DBPantry.fetchRequest()
        let sort = NSSortDescriptor(key: "index", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        guard let object = try? coreData.container.viewContext.fetch(fetchRequest) else {
            return nil
        }
        return object
    }
    
    func getPantry(id: String) -> DBPantry? {
        let fetchRequest: NSFetchRequest<DBPantry> = DBPantry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = '\(id)'")
        guard let object = try? coreData.container.viewContext.fetch(fetchRequest).first else {
            return nil
        }
        return object
    }
    
    func getSynchronizedPantry(by synchronizedIdGroceryList: UUID) -> [DBPantry] {
        var pantries: [DBPantry] = []
        guard let dbPantries = getAllPantries() else {
            return pantries
        }
        dbPantries.forEach { dbModel in
            let synchronizedLists = (try? JSONDecoder().decode([UUID].self, from: dbModel.synchronizedLists ?? Data())) ?? []
            if synchronizedLists.contains(where: { $0 == synchronizedIdGroceryList }) {
                pantries.append(dbModel)
            }
        }

        return pantries
    }
    
    func deletePantry(by id: UUID) {
        let context = coreData.container.viewContext
        let fetchRequest: NSFetchRequest<DBPantry> = DBPantry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = '\(id)'")
        if let object = try? context.fetch(fetchRequest).first {
            
            context.delete(object)
        }
        try? context.save()
    }

    func removeSharedPantryList(by sharedListId: String) {
        let context = coreData.container.viewContext
        let fetchRequest: NSFetchRequest<DBPantry> = DBPantry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "sharedId = '\(sharedListId)'")
        if let object = try? context.fetch(fetchRequest).first {
            context.delete(object)
        }
        try? context.save()
    }
    
    func removeSharedPantryLists() {
        let context = coreData.container.viewContext
        let fetchRequest: NSFetchRequest<DBPantry> = DBPantry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isShared = %d", true)
        if let objects = try? context.fetch(fetchRequest) {
            objects.forEach {
                context.delete($0)
            }
        }
        try? context.save()
    }
    
    func removePantryList(recordId: String) {
        let context = coreData.container.viewContext
        let fetchRequest: NSFetchRequest<DBPantry> = DBPantry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "recordId = '\(recordId)'")
        if let object = try? context.fetch(fetchRequest).first {
            context.delete(object)
        }
        try? context.save()
    }
    
    // MARK: - Stocks
    func saveStock(stocks: [Stock], for pantryId: String) {
        let asyncContext = coreData.newBackgroundContext
        let fetchRequest: NSFetchRequest<DBPantry> = DBPantry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = '\(pantryId)'")
        guard let pantry = try? asyncContext.fetch(fetchRequest).first else {
            return
        }
        
        guard Thread.isMainThread else {
            asyncContext.perform { save() }
            return
        }
        asyncContext.performAndWait { save() }
        
        func save() {
            do {
                let _ = stocks.map {
                    let object = DBStock.prepare(fromPlainModel: $0, context: asyncContext)
                    object.pantry = pantry
                }
                try asyncContext.save()
            } catch let error {
                print(error)
                asyncContext.rollback()
            }
        }
    }
    
    func getAllStock() -> [DBStock]? {
        let fetchRequest: NSFetchRequest<DBStock> = DBStock.fetchRequest()
        guard let object = try? coreData.container.viewContext.fetch(fetchRequest) else {
            return nil
        }
        return object
    }
    
    func getAllStocks(for pantryId: String) -> [DBStock]? {
        let fetchRequest: NSFetchRequest<DBStock> = DBStock.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "pantryId = '\(pantryId)'")
        return (try? coreData.viewContext.fetch(fetchRequest).compactMap { $0 })
    }
    
    func getStock(by id: UUID) -> DBStock? {
        let fetchRequest: NSFetchRequest<DBStock> = DBStock.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = '\(id)'")
        guard let object = try? coreData.container.viewContext.fetch(fetchRequest).first else {
            return nil
        }
        return object
    }
    
    func deleteStock(by id: UUID) {
        let context = coreData.container.viewContext
        let fetchRequest: NSFetchRequest<DBStock> = DBStock.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = '\(id)'")
        if let object = try? context.fetch(fetchRequest).first {
            context.delete(object)
        }
        try? context.save()
    }
    
    func removeStock(recordId: String) {
        let context = coreData.container.viewContext
        let fetchRequest: NSFetchRequest<DBStock> = DBStock.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "recordId = '\(recordId)'")
        if let object = try? context.fetch(fetchRequest).first {
            context.delete(object)
        }
        try? context.save()
    }
    
    // MARK: - iCloud
    func resetRecordIdForAllData() {
        resetRecordId(request: DBGroceryListModel.fetchRequest()) { $0.recordId = "" }
        resetRecordId(request: DBProduct.fetchRequest()) { $0.recordId = "" }
        resetRecordId(request: DBCategories.fetchRequest()) { $0.recordId = "" }
        resetRecordId(request: DBStore.fetchRequest()) { $0.recordId = "" }
        resetRecordId(request: DBPantry.fetchRequest()) { $0.recordId = "" }
        resetRecordId(request: DBStock.fetchRequest()) { $0.recordId = "" }
        resetRecordId(request: DBCollection.fetchRequest()) { $0.recordId = "" }
        resetRecordId(request: DBRecipe.fetchRequest()) { $0.recordId = "" }
        resetRecordId(request: DBMealPlan.fetchRequest()) { $0.recordId = "" }
        resetRecordId(request: DBMealPlanNote.fetchRequest()) { $0.recordId = "" }
        resetRecordId(request: DBLabel.fetchRequest()) { $0.recordId = "" }
    }
    
    // MARK: - Meal Plan
    func saveLabel(_ label: [MealPlanLabel]) {
        let asyncContext = coreData.taskContext
        asyncContext.performAndWait {
            do {
                _ = label.map({ DBLabel.prepare(fromPlainModel: $0, context: asyncContext) }) 
                try asyncContext.save()
            } catch let error {
                print(error)
                asyncContext.rollback()
            }
        }
    }
    
    func getAllLabels() -> [DBLabel]? {
        let fetchRequest = DBLabel.fetchRequest()
        let sort = NSSortDescriptor(key: "index", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        return fetch(request: fetchRequest, context: coreData.context)
    }
    
    func getLabel(id: String) -> DBLabel? {
        let fetchRequest = DBLabel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = '\(id)'")
        guard let object = fetch(request: fetchRequest, context: coreData.context).first else {
            return nil
        }
        return object
    }
    
    func deleteLabel(by id: UUID) {
        let context = coreData.context
        let fetchRequest = DBLabel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = '\(id)'")
        if let object = fetch(request: fetchRequest, context: context).first {
            context.delete(object)
        }
        try? context.save()
    }
    
    func removeLabel(recordId: String) {
        let context = coreData.container.viewContext
        let fetchRequest = DBLabel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "recordId = '\(recordId)'")
        if let object = try? context.fetch(fetchRequest).first {
            context.delete(object)
        }
        try? context.save()
    }
    
    func saveMealPlan(_ mealPlan: MealPlan) {
        let asyncContext = coreData.taskContext
        asyncContext.performAndWait {
            do {
                _ = DBMealPlan.prepare(fromPlainModel: mealPlan, context: asyncContext)
                try asyncContext.save()
            } catch let error {
                print(error)
                asyncContext.rollback()
            }
        }
    }
    
    func getAllMealPlans() -> [DBMealPlan]? {
//        let fetchRequest = DBLabel.fetchRequest()
//        let sort = NSSortDescriptor(key: "index", ascending: true)
//        fetchRequest.sortDescriptors = [sort]
        fetch(request: DBMealPlan.fetchRequest(), context: coreData.context)
    }
    
    func getMealPlan(date: Date) -> DBMealPlan? {
        let fetchRequest = DBMealPlan.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date = '\(date)'")
        guard let object = fetch(request: fetchRequest, context: coreData.context).first else {
            return nil
        }
        return object
    }
    
    func getMealPlan(id: String) -> DBMealPlan? {
        let fetchRequest = DBMealPlan.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = '\(id)'")
        guard let object = fetch(request: fetchRequest, context: coreData.context).first else {
            return nil
        }
        return object
    }
    
    func deleteMealPlan(by id: UUID) {
        let context = coreData.context
        let fetchRequest = DBMealPlan.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = '\(id)'")
        if let object = fetch(request: fetchRequest, context: context).first {
            context.delete(object)
        }
        try? context.save()
    }
    
    func removeMealPlan(recordId: String) {
        let context = coreData.container.viewContext
        let fetchRequest = DBMealPlan.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "recordId = '\(recordId)'")
        if let object = try? context.fetch(fetchRequest).first {
            context.delete(object)
        }
        try? context.save()
    }
    
    func saveMealPlanNote(_ note: MealPlanNote) {
        let asyncContext = coreData.taskContext
        asyncContext.performAndWait {
            do {
                _ = DBMealPlanNote.prepare(fromPlainModel: note, context: asyncContext)
                try asyncContext.save()
            } catch let error {
                print(error)
                asyncContext.rollback()
            }
        }
    }
    
    func getMealPlanNotes() -> [DBMealPlanNote]? {
        fetch(request: DBMealPlanNote.fetchRequest(), context: coreData.context)
    }

    func getMealPlanNote(id: String) -> DBMealPlanNote? {
        let fetchRequest = DBMealPlanNote.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = '\(id)'")
        guard let object = fetch(request: fetchRequest, context: coreData.context).first else {
            return nil
        }
        return object
    }
    
    func deleteMealPlanNote(by id: UUID) {
        let context = coreData.context
        let fetchRequest = DBMealPlanNote.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = '\(id)'")
        if let object = fetch(request: fetchRequest, context: context).first {
            context.delete(object)
        }
        try? context.save()
    }
    
    func removeMealPlanNote(recordId: String) {
        let context = coreData.container.viewContext
        let fetchRequest = DBMealPlanNote.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "recordId = '\(recordId)'")
        if let object = try? context.fetch(fetchRequest).first {
            context.delete(object)
        }
        try? context.save()
    }

    private func resetRecordId<T: NSManagedObject>(request: NSFetchRequest<T>,
                                                   configurationBlock: @escaping ((T) -> Void)) {
        let asyncContext = coreData.taskContext
        request.predicate = NSPredicate(format: "recordId != '\("")'")
        let objects = fetch(request: request, context: asyncContext)
        guard !objects.isEmpty else {
            return
        }
        asyncContext.performAndWait {
            for object in objects {
                let updateObject = object
                configurationBlock(updateObject)
            }
            try? asyncContext.save()
        }
    }
    
    private func fetch<T: NSManagedObject>(request: NSFetchRequest<T>,
                                           context: NSManagedObjectContext) -> [T] {
        return (try? context.fetch(request)) ?? []
    }
}

extension CoreDataManager: CoredataSyncProtocol {
    
    func saveProducts(products: [NetworkProductModel]) {
        let asyncContext = coreData.taskContext
        asyncContext.perform {
            do {
                let _ = products.map { DBNewNetProduct.prepare(fromProduct: $0, using: asyncContext) }
                try asyncContext.save()
                NotificationCenter.default.post(name: .productsDownloadedAndSaved, object: nil)
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
    
    func saveNetworkCollection(collections: [CollectionModel]) {
        saveCollection(collections: collections)
    }
}
