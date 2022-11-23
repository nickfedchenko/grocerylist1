//
//  SelectProductViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 23.11.2022.
//

import Foundation

class SelectProductViewModel {
    
    init(model: GroceryListsModel) {
        self.model = model
    }
   
    weak var router: RootRouter?
    var model: GroceryListsModel
}
