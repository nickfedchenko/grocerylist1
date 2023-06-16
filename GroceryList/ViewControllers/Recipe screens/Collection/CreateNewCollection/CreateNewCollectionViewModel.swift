//
//  CreateNewCollectionViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 07.03.2023.
//

import Foundation

final class CreateNewCollectionViewModel {
    
    var updateUICallBack: (([CollectionModel]) -> Void)?
    
    var editCollections: [CollectionModel] = []
    
    func save(_ title: String?) {
        guard let title else {
            return
        }
        
        let newCollection = CollectionModel(id: UUID().integer, index: 0, title: title)
        
        if editCollections.isEmpty {
            let dbCollections = CoreDataManager.shared.getAllCollection() ?? []
            editCollections = dbCollections.compactMap { CollectionModel(from: $0) }
        }
        
        var updateCollections: [CollectionModel] = []
        editCollections.forEach { collection in
            updateCollections.append(CollectionModel(id: collection.id,
                                                     index: collection.index + 1,
                                                     title: collection.title,
                                                     isDefault: collection.isDefault))
        }
        updateCollections.append(newCollection)
        CoreDataManager.shared.saveCollection(collections: updateCollections)
        updateUICallBack?(updateCollections)
    }
}
