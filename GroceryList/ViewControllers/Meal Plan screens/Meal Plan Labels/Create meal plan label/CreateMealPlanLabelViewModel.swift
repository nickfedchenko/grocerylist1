//
//  CreateMealPlanLabelViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 20.09.2023.
//

import UIKit

class CreateMealPlanLabelViewModel {
    
    var updateLabels: (() -> Void)?
    
    var updateColor: ((UIColor) -> Void)?
    private(set) var currentLabel: MealPlanLabel?
    private let colorManager = ColorManager.shared
    private var labelColors: [UIColor]
    private var selectedColorIndex = 0
    private var currentColorIndex = -1
    private var labels: [MealPlanLabel] = []
    
    init(currentLabel: MealPlanLabel?) {
        self.currentLabel = currentLabel
        labelColors = colorManager.labelColor
        
        if let currentLabel {
            currentColorIndex = currentLabel.color
            if currentLabel.id != DefaultLabel.none.id {
                labelColors.removeFirst()
            }
        } else {
            labelColors.removeFirst()
        }
        
        labels = CoreDataManager.shared.getAllLabels()?.map({ MealPlanLabel(dbModel: $0) }) ?? []
        arrangeColors()
    }
    
    func getNumberOfCells() -> Int {
        labelColors.count
    }
    
    func getColor(by index: Int) -> UIColor {
        labelColors[index]
    }
    
    func setColor(at index: Int) {
        selectedColorIndex = index
        updateColor?(getColor(by: index))
    }
    
    func save(_ title: String?) {
        guard let title else {
            return
        }
        let newLabel: MealPlanLabel
        let color = getColorNumber()
        if var currentLabel {
            currentLabel.title = title
            currentLabel.color = color
            newLabel = currentLabel
        } else {
            let index = CoreDataManager.shared.getAllLabels()?.count ?? 0
            newLabel = MealPlanLabel(title: title, color: color, index: -index - 10)
        }
        
        CoreDataManager.shared.saveLabel([newLabel])
        updateLabels?()
    }
    
    private func arrangeColors() {
        let usedColors = labels.map { colorManager.getLabelColor(index: $0.color) }
        labelColors.sort { _, color in
            usedColors.contains(color)
        }
        if currentColorIndex >= 0 {
            let currentColor = colorManager.getLabelColor(index: currentColorIndex)
            labelColors.removeAll { $0 == currentColor }
            labelColors.insert(currentColor, at: 0)
        }
    }
    
    private func getColorNumber() -> Int {
        let selectedColor = getColor(by: selectedColorIndex)
        let defaultColors = colorManager.labelColor
        
        for (index, color) in defaultColors.enumerated() where color == selectedColor {
            return index
        }
        
        return 0
    }
}
