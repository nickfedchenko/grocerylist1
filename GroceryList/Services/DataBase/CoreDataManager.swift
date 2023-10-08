//
//  CoreDataManager.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 03.08.2023.
//

import CoreData
import Foundation

class CoreDataManager {
    let coreData: CoreDataStorage
    static let shared = CoreDataManager()
    
    // MARK: - USER
    lazy var userRequest: NSFetchRequest = {
        return NSFetchRequest<NSFetchRequestResult>(entityName: "DomainUser")
    }()
    
    // MARK: - ResetPasswordModel
    lazy var resetPasswordModelRequest: NSFetchRequest = {
        return NSFetchRequest<NSFetchRequestResult>(entityName: "DomainResetPasswordModel")
    }()
    
    private init() {
        coreData = CoreDataStorage()
    }
    
    func saveRecipes(recipes: [Recipe]) {
        let asyncContext = coreData.taskContext
        asyncContext.perform {
            do {
                let _ = recipes.map { DBRecipe.prepare(fromPlainModel: $0, context: asyncContext)}
                try asyncContext.save()
                
                if !UserDefaultsManager.shared.isUpdateRecipeWithCollection {
                    self.updateRecipeWithCollection()
                } else {
                    NotificationCenter.default.post(name: .recipesDownloadedAndSaved, object: nil)
                }
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
    
    func saveCollection(collections: [CollectionModel]) {
        let asyncContext = coreData.taskContext
        asyncContext.perform {
            do {
                let _ = collections.map { DBCollection.prepare(fromPlainModel: $0, context: asyncContext)}
                try asyncContext.save()
            } catch let error {
                print(error)
                asyncContext.rollback()
            }
        }
    }
    
    func getAllRecipes() -> [DBRecipe]? {
        let fetchRequest: NSFetchRequest<DBRecipe> = DBRecipe.fetchRequest()
        guard let object = try? coreData.context.fetch(fetchRequest) else {
            return nil
        }
        return object
    }
    
    func getCollection(by id: Int) -> DBCollection? {
        let context = coreData.container.viewContext
        let fetchRequest: NSFetchRequest<DBCollection> = DBCollection.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = '\(id)'")
        guard let object = try? context.fetch(fetchRequest).first else {
            return nil
        }
        return object
    }
    
    func delete(entityName: String?) {
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
    
    private func updateRecipeWithCollection() {
        guard !UserDefaultsManager.shared.isUpdateRecipeWithCollection else {
            return
        }
        let allRecipe = getAllRecipes()
        var recipes = allRecipe?.compactMap({ Recipe(from: $0) }) ?? []
        recipes.sort { $0.id < $1.id }
        
        let recipeWithCollection = recipes.filter({ !($0.localCollection?.isEmpty ?? true) })
        recipeWithCollection.forEach({ recipe in
            if let collections = recipe.localCollection,
                !collections.isEmpty {
                collections.forEach { collection in
                    if let dbCollection = getCollection(by: collection.id) {
                        var collection = CollectionModel(from: dbCollection)
                        var dishes = Set(collection.dishes ?? [])
                        dishes.insert(recipe.id)
                        collection.dishes = Array(dishes)
                        saveCollection(collections: [collection])
                    }
                }
            }
        })
        
        UserDefaultsManager.shared.isUpdateRecipeWithCollection = true
        NotificationCenter.default.post(name: .recipesDownloadedAndSaved, object: nil)
    }
}
