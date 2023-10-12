//
//  MealPlanLabelsViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 20.09.2023.
//

import UIKit

class MealPlanLabelsViewModel {
    
    weak var router: RootRouter?
    var updateUI: ((MealPlanLabel?) -> Void)?
    let isDisplayState: Bool
    
    var reloadData: (() -> Void)?
    var necessaryHeight: Double {
        labels.isEmpty ? 66 : Double(labels.count * 66 + 66)
    }
    
    var labelsIsEmpty: Bool {
        labels.isEmpty
    }
    
    private var labels: [MealPlanLabel] = []
    private var currentLabel: MealPlanLabel?
    private var hasBeenChangedLabel = false
    private let colorManager = ColorManager.shared
    
    init(label: MealPlanLabel?, isDisplayState: Bool) {
        currentLabel = label
        self.isDisplayState = isDisplayState
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
    
    func getLabelTitle(by index: Int) -> String? {
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
            labels[index].isSelected = label.id == currentLabel?.id
        }
        reloadData?()
        hasBeenChangedLabel = true
    }
    
    func deleteLabel(by index: Int) {
        guard let label = labels[safe: index] else {
            return
        }
        if label.id == currentLabel?.id {
            currentLabel = MealPlanLabel(defaultLabel: .none)
        }
        CoreDataManager.shared.deleteLabel(by: label.id)
        CloudManager.shared.delete(recordType: .mealPlanLabel, recordID: label.recordId)
        getLabelFromStorage()
        hasBeenChangedLabel = true
        reloadData?()
    }
    
    func canMove(by indexPath: IndexPath) -> Bool {
        return indexPath.row != 0
    }
    
    func canDeleteLabel(by index: Int) -> Bool {
        guard let label = labels[safe: index] else {
            return false
        }
        return label.id != DefaultLabel.none.id
    }
    
    func swapLabels(from firstIndex: Int, to secondIndex: Int) {
        let swapItem = labels.remove(at: firstIndex)
        labels.insert(swapItem, at: secondIndex)
        reloadData?()
    }
    
    func saveChanges() {
        var updateLabels: [MealPlanLabel] = []
        let editLabels = labels
        editLabels.enumerated().forEach { index, label in
            if label.index != index {
                updateLabels.append(MealPlanLabel(id: label.id,
                                                  title: label.title,
                                                  color: label.color,
                                                  index: index))
            }
        }
        if !updateLabels.isEmpty {
            hasBeenChangedLabel = true
            CoreDataManager.shared.saveLabel(updateLabels)
            updateLabels.forEach {
                CloudManager.shared.saveCloudData(mealPlanLabel: $0)
            }
        }
    }
    
    func dismissView() {
        guard hasBeenChangedLabel else {
            return
        }
        updateUI?(currentLabel)
    }
    
    @objc
    private func getLabelFromStorage() {
        labels = CoreDataManager.shared.getAllLabels()?.map({
            var label = MealPlanLabel(dbModel: $0)
            label.isSelected = label.id == currentLabel?.id
            return label
        }) ?? []
        
        self.reloadData?()
    }
}
