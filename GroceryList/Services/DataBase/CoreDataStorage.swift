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
        taskContext.mergePolicy = NSMergePolicy(merge: .overwriteMergePolicyType)
        return taskContext
    }()
    
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: containerName)
        container.loadPersistentStores(completionHandler: { (_, error) in
            guard let error = error as NSError? else { return }
            container.viewContext.mergePolicy = NSMergePolicy(merge: .overwriteMergePolicyType)
            container.viewContext.automaticallyMergesChangesFromParent = true
            fatalError("Unresolved error \(error), \(error.userInfo)")
        })
        return container
    }()
    
}
