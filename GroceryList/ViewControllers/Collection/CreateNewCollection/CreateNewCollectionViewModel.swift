//
//  CreateNewCollectionViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 07.03.2023.
//

import Foundation

final class CreateNewCollectionViewModel {
    
    var updateUICallBack: (() -> Void)?
    
    func save(_ title: String?) {
        guard let title else {
            return
        }
        
        let newCollection = CollectionModel(id: UUID().integer, index: 0, title: title)
        
        var updateCollections: [CollectionModel] = []
        let dbCollections = CoreDataManager.shared.getAllCollection() ?? []
        var editCollections = dbCollections.compactMap { CollectionModel(from: $0) }
        editCollections.forEach { collection in
            updateCollections.append(CollectionModel(id: collection.id,
                                                     index: collection.index + 1,
                                                     title: collection.title,
                                                     isDefault: collection.isDefault))
        }
        updateCollections.append(newCollection)
        CoreDataManager.shared.saveCollection(collections: updateCollections)
//        updateUICallBack?()
    }
}
