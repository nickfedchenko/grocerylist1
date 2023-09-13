//
//  MealPlanDataSource.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 09.09.2023.
//

import Foundation

class MealPlanDataSource {
    
    enum SortType {
        case month
        case week
    }
    
    private var mealPlan: [MealPlan] = []
    private var labels: [MealPlanLabel] = []
    private var dates: [Date] = []
    private var weekSection: [MealPlanSection] = []
    
    private var sortType: SortType {
        UserDefaultsManager.shared.selectedMonthOrWeek == 0 ? .month : .week
    }
    
    private(set) var section: [MealPlanSection] = []
    
    init() {
        // mock
        let allDBRecipes = CoreDataManager.shared.getAllRecipes() ?? []
        let recipes = allDBRecipes.compactMap { Recipe(from: $0) }
        
        dates = [Date().after(dayCount: -2), Date().after(dayCount: -2),
                 Date().after(dayCount: -2), Date().after(dayCount: -2), 
                 Date().after(dayCount: -2), Date().after(dayCount: -2), Date(),
                 Date().after(dayCount: 3), Date().after(dayCount: 3), Date().after(dayCount: 3)]
        setDefaultLabels()
        
        dates.forEach {
            if let recipe = recipes.randomElement(),
               let label = labels.randomElement() {
                mealPlan.append(MealPlan(recipeId: recipe.id, date: $0, label: label))
            }
        }
        
        DispatchQueue.main.async {
            var section: [MealPlanSection] = []
            let dates = Date().after(dayCount: -365).getDates(by: Date().after(dayCount: 365))
            dates.forEach { date in
                let type: MealPlanSectionType
                type = date.onlyDate == date.startOfWeek.onlyDate ? .weekStart : .week
                var mealPlansByDate = self.mealPlan.filter { $0.date.onlyDate == date.onlyDate }
                if mealPlansByDate.isEmpty {
                    mealPlansByDate.append(MealPlan(date: date))
                }
                let cellModel = self.mapMealPlanToCellModel(date: date, mealPlan: mealPlansByDate)
                section.append(MealPlanSection(sectionType: type, date: date, mealPlans: cellModel))
            }
            self.weekSection = section
        }
        
    }
    
    func getMealPlans(by date: Date) -> [MealPlanSection] {
        guard sortType == .month else {
            return getMealPlanForWeekState(date: date)
        }
        
        let mealPlansByDate = mealPlan.filter { $0.date.onlyDate == date.onlyDate }
        let cellModel = mapMealPlanToCellModel(date: date, mealPlan: mealPlansByDate)
        return [MealPlanSection(sectionType: .month, date: date, mealPlans: cellModel)]
    }
    
    func getRecipe(by date: Date, for index: IndexPath) -> ShortRecipeModel? {
        guard let recipeId = getMealPlan(by: date, for: index)?.recipeId,
              let dbRecipe = CoreDataManager.shared.getRecipe(by: recipeId) else {
            return nil
        }
        let isFavorite = UserDefaultsManager.shared.favoritesRecipeIds.contains(recipeId)
        return ShortRecipeModel(withCollection: dbRecipe, isFavorite: isFavorite)
    }
    
    func getLabel(by date: Date, for index: IndexPath) -> MealPlanLabel? {
        return getMealPlan(by: date, for: index)?.label
    }
    
    func getLabelColors(by date: Date) -> [Int] {
        let mealPlansByDate = mealPlan.filter { $0.date.onlyDate == date.onlyDate }
        return mealPlansByDate.compactMap { $0.label?.color }
    }
    
    private func getMealPlan(by date: Date, for index: IndexPath) -> MealPlan? {
        let section = getMealPlans(by: date)
        return section[safe: index.section]?.mealPlans[safe: index.row]?.mealPlan
    }
    
    private func getMealPlanForWeekState(date: Date) -> [MealPlanSection] {
        guard weekSection.isEmpty else {
            return weekSection.filter { $0.date >= date }
        }
        
        var section: [MealPlanSection] = []
        
        let dates = date.getDates(by: date.after(dayCount: 50))
        dates.forEach { date in
            let type: MealPlanSectionType
            type = date.onlyDate == date.startOfWeek.onlyDate ? .weekStart : .week
            var mealPlansByDate = mealPlan.filter { $0.date.onlyDate == date.onlyDate }
            if mealPlansByDate.isEmpty {
                mealPlansByDate.append(MealPlan(date: date))
            }
            let cellModel = mapMealPlanToCellModel(date: date, mealPlan: mealPlansByDate)
            section.append(MealPlanSection(sectionType: type, date: date, mealPlans: cellModel))
        }
        return section
    }
    
    private func mapMealPlanToCellModel(date: Date, mealPlan: [MealPlan]) -> [MealPlanCellModel] {
        var cellModel: [MealPlanCellModel] = []
        guard sortType == .month else {
            cellModel = mealPlan.map {
                MealPlanCellModel(type: .plan, date: date, mealPlan: $0)
            }
            return cellModel
        }
        
        if mealPlan.isEmpty {
            cellModel = [MealPlanCellModel(type: .planEmpty, date: date)]
        } else {
            cellModel = mealPlan.map {
                MealPlanCellModel(type: .plan, date: date, mealPlan: $0)
            }
        }
        
        cellModel.append(MealPlanCellModel(type: .noteEmpty, date: date))
        return cellModel
    }
    
    private func setDefaultLabels() {
        DefaultLabel.allCases.forEach {
            labels.append(MealPlanLabel(defaultLabel: $0))
        }
    }
}

enum DefaultLabel: Int, CaseIterable {
    case none
    case breakfast
    case lunch
    case dinner
    case snack
    
    var id: UUID {
        self.rawValue.asUUID
    }
    
    var title: String {
        switch self {
        case .none:         return "none"
        case .breakfast:    return "breakfast"
        case .lunch:        return "lunch"
        case .dinner:       return "dinner"
        case .snack:        return "snack"
        }
    }
    
    var color: Int {
        switch self {
        case .none:         return 0
        case .breakfast:    return 7
        case .lunch:        return 4
        case .dinner:       return 9
        case .snack:        return 1
        }
    }
}
