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
    
    var sharedStoreURL: URL? {
        let id = "group.com.ksens.shopp"
        let groupContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: id)
        return groupContainer?.appendingPathComponent("DataBase.sqlite")
    }
    
    var oldStoreURL: URL? {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        return appSupport?.appendingPathComponent("DataBase.sqlite")
    }
    
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
    
    var container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: containerName)
        if let oldStoreURL,
            !FileManager.default.fileExists(atPath: oldStoreURL.path) {
            container.persistentStoreDescriptions.first?.url = sharedStoreURL
        }

        container.loadPersistentStores { _, error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        migrateStore(for: container)
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    
    func migrateStore(for container: NSPersistentContainer) {
        guard let sharedStoreURL,
              let oldStoreURL else {
            return
        }
        guard !FileManager.default.fileExists(atPath: sharedStoreURL.path),
              !UserDefaultsManager.shared.isFixCoreDataMigration else {
            return
        }
        let coordinator = container.persistentStoreCoordinator
        guard let oldStore = coordinator.persistentStore(for: oldStoreURL) else {
            return
        }
        do {
            try coordinator.migratePersistentStore(oldStore,
                                                   to: sharedStoreURL,
                                                   options: nil,
                                                   withType: NSSQLiteStoreType)
            UserDefaultsManager.shared.isFixCoreDataMigration = true
        } catch {
            print("Something went wrong migrating the store: \(error)")
        }
        do {
            try FileManager.default.removeItem(at: oldStoreURL)
        } catch {
            print("Something went wrong migrating the store: \(error)")
        }
    }
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
