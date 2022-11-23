//
//  SelectProductViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 23.11.2022.
//

import UIKit

class SelectProductViewModel {
    
    init(model: GroceryListsModel) {
        self.model = model
    }
   
    private var colorManager = ColorManager()
    weak var router: RootRouter?
    var model: GroceryListsModel
    
    func getNameOfList() -> String {
        return model.name ?? ""
    }
    
    func getColorForBackground() -> UIColor {
        colorManager.getGradient(index: model.color).1
    }
    
    func getColorForText() -> UIColor {
        colorManager.getGradient(index: model.color).0
    }
    
    func closeTapped(height: Double) {
   
    }
}
