//
//  MealPlanViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 09.09.2023.
//

import UIKit

class MealPlanViewModel {
    
    weak var router: RootRouter?
    var reloadData: (() -> Void)?
    
    private let dataSource: MealPlanDataSource
    private let colorManager = ColorManager.shared
    
    var theme: Theme {
        colorManager.colorMealPlan
    }
    
    init(dataSource: MealPlanDataSource) {
        self.dataSource = dataSource
        
        dataSource.reloadData = { [weak self] in
            self?.reloadData?()
        }
    }
    
    func getMealPlanSections(by date: Date) -> [MealPlanSection] {
        return dataSource.getMealPlans(by: date)
    }

    func isEmptySection(by date: Date) -> Bool {
        var planEmpty = true
        var noteEmpty = true
        let section = dataSource.getMealPlans(by: date)
        
        section.forEach { section in
            section.mealPlans.forEach {
                if $0.type == .plan {
                    planEmpty = false
                }
                if $0.type == .note {
                    noteEmpty = false
                }
            }
        }
        
        return planEmpty && noteEmpty
    }
    
    func getRecipe(by date: Date, for index: IndexPath) -> ShortRecipeModel? {
        return dataSource.getRecipe(by: date, for: index)
    }
    
    func getLabel(by date: Date, for index: IndexPath, type: MealPlanCellType) -> (text: String, color: UIColor) {
        guard let label = dataSource.getLabel(by: date, for: index, type: type) else {
            return ("", .clear)
        }
        let color = colorManager.getLabelColor(index: label.color)
        return (label.title, color)
    }
    
    func getLabelColors(by date: Date) -> [UIColor] {
        let colorNumbers = dataSource.getLabelColors(by: date)
        return colorNumbers.map { colorManager.getLabelColor(index: $0) }
    }
    
    func getNote(by date: Date, for index: IndexPath) -> MealPlanNote? {
        return dataSource.getNote(by: date, for: index)
    }
    
    func updateIndexAfterMove(cellModels: [MealPlanCellModel]) {
        dataSource.updateIndexAfterMove(cellModels: cellModels)
        dataSource.getMealPlansFromStorage()
        reloadData?()
    }
    
    func showSelectRecipeToMealPlan(selectedDate: Date) {
        router?.goToSelectRecipeToMealPlan(date: selectedDate, updateUI: { [weak self] in
            self?.dataSource.getMealPlansFromStorage()
            self?.reloadData?()
        })
    }
    
    func showAddRecipeToMealPlan(by index: IndexPath) {
        guard let mealPlan = dataSource.getMealPlan(by: index),
              let dbRecipe = CoreDataManager.shared.getRecipe(by: mealPlan.recipeId),
              let recipe = Recipe(from: dbRecipe) else {
            return
        }
        
        router?.goToRecipeFromMealPlan(recipe: recipe, mealPlan: mealPlan, updateUI: { [weak self] in
            self?.dataSource.getMealPlansFromStorage()
            self?.reloadData?()
        })
    }
    
    func showAddNoteToMealPlan(by date: Date, for index: IndexPath? = nil) {
        var note: MealPlanNote?
        if let index {
            note = dataSource.getNote(by: index)
        }
        
        router?.goToAddNoteToMealPlan(note: note, date: note?.date ?? date,
                                      updateUI: { [weak self] in
            self?.dataSource.getMealPlansFromStorage()
            self?.reloadData?()
        })
    }
}
