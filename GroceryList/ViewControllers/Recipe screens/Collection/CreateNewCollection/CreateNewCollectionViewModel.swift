//
//  CreateNewCollectionViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 07.03.2023.
//

import Foundation

final class CreateNewCollectionViewModel {
    
    var updateUICallBack: (([CollectionModel]) -> Void)?
    var updateColor: ((Theme) -> Void)?
    
    var editCollections: [CollectionModel] = []
    
    private let colorManager = ColorManager.shared
    private var selectedThemeIndex = 0
    
    
    func getNumberOfCells() -> Int {
        colorManager.gradientsCount
    }
    
    func getColor(by index: Int) -> Theme {
        colorManager.getGradient(index: index)
    }
    
    func setColor(at index: Int) {
        selectedThemeIndex = index
        updateColor?(colorManager.getGradient(index: index))
    }
    
    func save(_ title: String?) {
        guard let title else {
            return
        }
        
        let index = CoreDataManager.shared.getAllCollection()?.count ?? 0
        
        let newCollection = CollectionModel(id: UUID().integer, index: -index,
                                            title: title, color: selectedThemeIndex)
        
//        if editCollections.isEmpty {
//            let dbCollections = CoreDataManager.shared.getAllCollection() ?? []
//            editCollections = dbCollections.compactMap { CollectionModel(from: $0) }
//        }
//
//        var updateCollections: [CollectionModel] = []
//        editCollections.forEach { collection in
//            updateCollections.append(CollectionModel(id: collection.id,
//                                                     index: collection.index + 1,
//                                                     title: collection.title,
//                                                     color: collection.color,
//                                                     isDefault: collection.isDefault))
//        }
//        updateCollections.append(newCollection)
        CoreDataManager.shared.saveCollection(collections: [newCollection])
        updateUICallBack?([newCollection])
    }
}
