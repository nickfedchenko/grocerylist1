//
//  ProductsViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 10.11.2022.
//

import Foundation
import UIKit

class ProductsViewModel {
    
    weak var router: RootRouter?
    private var colorManager = ColorManager()
    var valueChangedCallback: (() -> Void)?
    var model: GroseryListsModel
    var dataSource: ProductsDataManager?
   
    init(model: GroseryListsModel) {
        self.model = model
        print(model)
    }
    
    func getColorForBackground() -> UIColor {
        colorManager.getGradient(index: model.color).1
    }
    
    func getAddItemViewColor() -> UIColor {
        colorManager.getGradient(index: model.color).0
    }
    
    func getNameOfList() -> String {
        model.name ?? "..."
    }
    
    func goBackButtonPressed() {
        router?.pop()
    }
    
    func settingsTapped() {
        router?.goProductsSettingsVC(compl: {
            
        })
    }

}
