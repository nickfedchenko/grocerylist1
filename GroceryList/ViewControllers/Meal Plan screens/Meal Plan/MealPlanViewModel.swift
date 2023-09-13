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
        Theme(dark: UIColor(hex: "045C5C"),
              medium: UIColor(hex: "045C5C"),
              light: UIColor(hex: "EBFEFE"))
    }
    
    init(dataSource: MealPlanDataSource) {
        self.dataSource = dataSource
    }
    
    func getMealPlanSections(by date: Date) -> [MealPlanSection] {
        return dataSource.getMealPlans(by: date)
    }

    func getRecipe(by date: Date, for index: IndexPath) -> ShortRecipeModel? {
        return dataSource.getRecipe(by: date, for: index)
    }
    
    func getLabel(by date: Date, for index: IndexPath) -> (text: String, color: UIColor) {
        guard let label = dataSource.getLabel(by: date, for: index) else {
            return ("", .clear)
        }
        let color = colorManager.getLabelColor(index: label.color)
        return (label.title, color)
    }
    
    func getLabelColors(by date: Date) -> [UIColor] {
        let colorNumbers = dataSource.getLabelColors(by: date)
        return colorNumbers.map { colorManager.getLabelColor(index: $0) }
    }
    
}
