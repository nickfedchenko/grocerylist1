//
//  AddIngredientsToListViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 29.09.2023.
//

import Foundation

class AddIngredientsToListViewModel {
    
    weak var router: RootRouter?
    
    private let startDate: Date
    
    init(date: Date) {
        startDate = date
    }
}
