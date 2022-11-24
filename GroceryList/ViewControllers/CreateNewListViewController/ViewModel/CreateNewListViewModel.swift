//
//  CreateNewListViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 09.11.2022.
//

import Foundation
import UIKit

class CreateNewListViewModel {
    
    weak var router: RootRouter?
    private var colorManager = ColorManager()
    var valueChangedCallback: ((GroceryListsModel) -> Void)?
    var model: GroceryListsModel?
   
    init() {
    
    }
    
    func savePressed(nameOfList: String?, numberOfColor: Int, isSortByCategory: Bool) {
        
        if var model = model {
            model.name = nameOfList
            model.color = numberOfColor
            model.typeOfSorting = isSortByCategory ? SortingType.category.rawValue : model.typeOfSorting
            CoreDataManager.shared.saveList(list: model)
            valueChangedCallback?(model)
            return
        }
        let typeOfSorting = isSortByCategory ? 0 : 1
        let list = GroceryListsModel(id: UUID(), dateOfCreation: Date(),
                                     name: nameOfList, color: numberOfColor, isFavorite: false, products: [], typeOfSorting: typeOfSorting)
        CoreDataManager.shared.saveList(list: list)
        UserDefaultsManager.coldStartState = 2
        valueChangedCallback?(list)
    }
    
    func getNumberOfCells() -> Int {
        colorManager.gradientsCount
    }
    
    func getTextFieldColor(at ind: Int) -> UIColor {
        colorManager.getGradient(index: ind).0
    }
    
    func getBackgroundColor(at ind: Int) -> UIColor {
        colorManager.getGradient(index: ind).1
    }
    
    func pickItemTapped(height: Double) {
        router?.presentSelectList(height: height, compl: { products in
            print(products)
        })
    }
}
