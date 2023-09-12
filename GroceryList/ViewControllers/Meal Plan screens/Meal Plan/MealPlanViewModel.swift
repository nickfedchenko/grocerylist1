//
//  MealPlanViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 09.09.2023.
//

import Foundation

class MealPlanViewModel {
    
    weak var router: RootRouter?
    
    private let dataSource: MealPlanDataSource
    
    init(dataSource: MealPlanDataSource) {
        self.dataSource = dataSource
    }
}
