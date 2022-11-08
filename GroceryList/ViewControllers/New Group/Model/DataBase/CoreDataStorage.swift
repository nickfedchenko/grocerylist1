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

    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: containerName)
        container.loadPersistentStores(completionHandler: { (_, error) in
            guard let error = error as NSError? else { return }
            fatalError("Unresolved error \(error), \(error.userInfo)")
        })
        return container
    }()
    
}
