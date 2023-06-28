//
//  CreateNewCollectionViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 07.03.2023.
//

import Foundation

final class CreateNewCollectionViewModel {
    
    var updateUICallBack: ((CollectionModel) -> Void)?
    var updateColor: ((Theme) -> Void)?
    
    var editCollections: [CollectionModel] = []
    var currentCollection: CollectionModel?
    
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
        let newCollection: CollectionModel
        if var currentCollection {
            currentCollection.title = title
            currentCollection.color = selectedThemeIndex
            newCollection = currentCollection
        } else {
            let index = CoreDataManager.shared.getAllCollection()?.count ?? 0
            
            newCollection = CollectionModel(id: UUID().integer, index: -index,
                                            title: title, color: selectedThemeIndex)
        }
        
        CoreDataManager.shared.saveCollection(collections: [newCollection])
        updateUICallBack?(newCollection)
    }
}
