//
//  PantryViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 22.05.2023.
//

import Foundation

final class PantryViewModel {
    
    weak var router: RootRouter?
    var dataSource: PantryDataSource

    init(dataSource: PantryDataSource) {
        self.dataSource = dataSource
    }
}
