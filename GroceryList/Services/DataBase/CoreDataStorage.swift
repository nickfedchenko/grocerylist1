//
//  CoreDataStorage.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 08.11.2022.
//

import Foundation
import CoreData

class CoreDataStorage {
    
    let containerName = "DataBase"
    
    lazy var context: NSManagedObjectContext = container.viewContext
    lazy var taskContext: NSManagedObjectContext = {
        let taskContext = container.newBackgroundContext()
        taskContext.mergePolicy = SafeMergePolicy()
        return taskContext
    }()
    
    lazy var viewContext: NSManagedObjectContext = {
        let context = context
        context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        context.automaticallyMergesChangesFromParent = true
        return context
    }()
    
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: containerName)
        let storeURL = URL.storeURL(for: "group.com.ksens.shopp", databaseName: containerName)
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        container.persistentStoreDescriptions = [storeDescription]
        
        container.loadPersistentStores(completionHandler: { (_, error) in
            guard let error = error as NSError? else { return }
            container.viewContext.mergePolicy = NSMergePolicy(merge: .overwriteMergePolicyType)
            container.viewContext.automaticallyMergesChangesFromParent = true
            fatalError("Unresolved error \(error), \(error.userInfo)")
        })
        return container
    }()
}

class SafeMergePolicy: NSMergePolicy {
    
    init() {
        super.init(merge: .mergeByPropertyObjectTrumpMergePolicyType)
    }
    
    override func resolve(constraintConflicts list: [NSConstraintConflict]) throws {
        for conflict in list {
            guard let databaseObject = conflict.databaseObject else {
                try super.resolve(constraintConflicts: list)
                return
            }
            let allKeys = databaseObject.entity.propertiesByName.keys
            for conflictObject in conflict.conflictingObjects {
                let changedKeys = conflictObject.changedValues().keys
                let keys = allKeys.filter { !changedKeys.contains($0) }
                for key in keys where key == "localCollection" {
                    let value = databaseObject.value(forKey: key)
                    conflictObject.setValue(value, forKey: key)
                    databaseObject.setValue(nil, forKey: key)
                }
            }
        }
        try super.resolve(constraintConflicts: list)
    }
}

extension URL {
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Shared file container could not be created.")
        }

        return fileContainer.appendingPathComponent("\(databaseName).sqlite")
    }
}
