//
//  MealPlanLabelsViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 20.09.2023.
//

import UIKit

class MealPlanLabelsViewModel {
    
    weak var router: RootRouter?
    var updateUI: ((MealPlanLabel) -> Void)?
    
    var reloadData: (() -> Void)?
    var necessaryHeight: Double {
        labels.isEmpty ? 66 : Double(labels.count * 66 + 66)
    }
    
    var labelsIsEmpty: Bool {
        labels.isEmpty
    }
    
    private var labels: [MealPlanLabel] = []
    private var currentLabel: MealPlanLabel
    private var hasBeenChangedLabel = false
    private let colorManager = ColorManager.shared
    
    init(label: MealPlanLabel) {
        currentLabel = label
        getLabelFromStorage()
    }
    
    func createNewLabel() {
        router?.goToCreateMealPlanLabel(label: nil, updateUI: { [weak self] in
            self?.getLabelFromStorage()
            self?.hasBeenChangedLabel = true
            self?.reloadData?()
        })
    }
    
    func editLabel(by index: Int) {
        guard let label = labels[safe: index] else {
            return
        }
        router?.goToCreateMealPlanLabel(label: label, updateUI: { [weak self] in
            self?.getLabelFromStorage()
            self?.hasBeenChangedLabel = true
            self?.reloadData?()
        })
    }
    
    func getNumberOfRows() -> Int {
        return labels.count + 1
    }
    
    func getCollectionTitle(by index: Int) -> String? {
        return labels[safe: index]?.title.localized
    }
    
    func isSelect(by index: Int) -> Bool {
        guard let label = labels[safe: index] else {
            return false
        }
        return label.isSelected
    }
    
    func getColor(by index: Int) -> UIColor {
        let label = labels[index]
        return colorManager.getLabelColor(index: label.color)
    }
    
    func updateSelect(by index: Int) {
        currentLabel = labels[index]
        for (index, label) in labels.enumerated() {
            labels[index].isSelected = label.id == currentLabel.id
        }
        reloadData?()
        hasBeenChangedLabel = true
    }
    
    func deleteLabel(by index: Int) {
        guard let label = labels[safe: index] else {
            return
        }

        CoreDataManager.shared.deleteLabel(by: label.id)
        getLabelFromStorage()
        hasBeenChangedLabel = true
        reloadData?()
    }
    
    func canMove(by indexPath: IndexPath) -> Bool {
        return indexPath.row != 0
    }
    
    func swapCategories(from firstIndex: Int, to secondIndex: Int) {
        let swapItem = labels.remove(at: firstIndex)
        labels.insert(swapItem, at: secondIndex)
    }
    
    func saveChanges() {
//        guard viewState == .select else {
//            saveEditCollections()
//            return
//        }
//        saveSelectCollections()
    }
    
    func dismissView() {
        guard hasBeenChangedLabel else {
            return
        }
        updateUI?(currentLabel)
    }
    
    private func saveSelectCollections() {
//        var selectCollections = collections.filter({ $0.select }).map({ $0.collection })
//        guard let recipe else {
//            selectedCollection?(selectCollections)
//            return
//        }
//        selectCollections.enumerated().forEach { index, collection in
//            var dishes = Set(collection.dishes ?? [])
//            dishes.insert(recipe.id)
//            selectCollections[index].dishes = Array(dishes)
//        }
//        CoreDataManager.shared.saveCollection(collections: selectCollections)
//        selectCollections.forEach { collectionModel in
//            CloudManager.shared.saveCloudData(collectionModel: collectionModel)
//        }
//        selectedCollection?(selectCollections)
//        hasBeenChangedLabel = true
    }
    
    private func saveEditCollections() {
//        var updateCollections: [CollectionModel] = []
//        let editCollections = collections.map { $0.collection }
//        editCollections.enumerated().forEach { index, collection in
//            if collection.index != index {
//                updateCollections.append(CollectionModel(id: collection.id,
//                                                         index: index,
//                                                         title: collection.title,
//                                                         color: collection.color ?? 0,
//                                                         dishes: collection.dishes))
//            }
//        }
//        if !updateCollections.isEmpty {
//            hasBeenChangedLabel = true
//            DispatchQueue.main.async {
//                CoreDataManager.shared.saveCollection(collections: updateCollections)
//                updateCollections.forEach { collectionModel in
//                    CloudManager.shared.saveCloudData(collectionModel: collectionModel)
//                }
//            }
//        }
    }
    
    @objc
    private func getLabelFromStorage() {
        if currentLabel == nil {
            
        }
        labels = CoreDataManager.shared.getAllLabels()?.map({
            var label = MealPlanLabel(dbModel: $0)
            label.isSelected = label.id == currentLabel.id
            return label
        }) ?? []
        
        self.reloadData?()
    }
}
