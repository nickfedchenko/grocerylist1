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
    
    var reloadData: (() -> Void)?
    
    private var mealPlan: [MealPlan] = []
    private var weekSection: [MealPlanSection] = []
    
    private var sortType: SortType {
        UserDefaultsManager.shared.selectedMonthOrWeek == 0 ? .month : .week
    }
    
    private(set) var section: [MealPlanSection] = []
    
    init() {
        getMealPlansFromStorage()
        setDefaultLabels()
    }
    
    func getMealPlans(by date: Date) -> [MealPlanSection] {
        guard sortType == .month else {
            section = getMealPlanForWeekState(date: date)
            return section
        }
        
        let mealPlansByDate = mealPlan.filter { $0.date.onlyDate == date.onlyDate }
        let cellModel = mapMealPlanToCellModel(date: date, mealPlan: mealPlansByDate, sortType: .month)
        section = [MealPlanSection(sectionType: .month, date: date, mealPlans: cellModel)]
        return section
    }
    
    func getMealPlan(by indexPath: IndexPath) -> MealPlan? {
        guard let plan = section[safe: indexPath.section]?.mealPlans[safe: indexPath.row]?.mealPlan else {
            return nil
        }
        return plan
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
        guard let labelId = getMealPlan(by: date, for: index)?.label,
              let dbLabel = CoreDataManager.shared.getLabel(id: labelId.uuidString) else {
            return nil
        }
        return MealPlanLabel(dbModel: dbLabel)
    }
    
    func getLabelColors(by date: Date) -> [Int] {
        let mealPlansByDate = mealPlan.filter { $0.date.onlyDate == date.onlyDate }
        let labels = mealPlansByDate.compactMap {
            if let labelId = $0.label,
               let dbLabel = CoreDataManager.shared.getLabel(id: labelId.uuidString) {
                return MealPlanLabel(dbModel: dbLabel)
            } else {
                return MealPlanLabel(defaultLabel: .none)
            }
        }
        
        return labels.compactMap { $0.color }
    }
    
    func getMealPlansFromStorage() {
        mealPlan = CoreDataManager.shared.getAllMealPlans()?.map({ MealPlan(dbModel: $0) }) ?? []
        
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
                let cellModel = self.mapMealPlanToCellModel(date: date, mealPlan: mealPlansByDate, sortType: .week)
                section.append(MealPlanSection(sectionType: type, date: date, mealPlans: cellModel))
            }
            self.weekSection = section
            if self.sortType == .week {
                self.reloadData?()
            }
        }
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
            let cellModel = mapMealPlanToCellModel(date: date, mealPlan: mealPlansByDate, sortType: .week)
            section.append(MealPlanSection(sectionType: type, date: date, mealPlans: cellModel))
        }
        return section
    }
    
    private func mapMealPlanToCellModel(date: Date, mealPlan: [MealPlan], sortType: SortType) -> [MealPlanCellModel] {
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
        guard !UserDefaultsManager.shared.isFillingDefaultLabels else {
            return
        }
        var labels: [MealPlanLabel] = []
        DefaultLabel.allCases.forEach {
            labels.append(MealPlanLabel(defaultLabel: $0))
        }
        CoreDataManager.shared.saveLabel(labels)
        UserDefaultsManager.shared.isFillingDefaultLabels = true
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
        case .none:         return "DefaultLabel_none"
        case .breakfast:    return "DefaultLabel_breakfast"
        case .lunch:        return "DefaultLabel_lunch"
        case .dinner:       return "DefaultLabel_dinner"
        case .snack:        return "DefaultLabel_snack"
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
