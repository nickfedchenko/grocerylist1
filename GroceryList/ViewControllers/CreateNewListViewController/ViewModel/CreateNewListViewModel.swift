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
    var valueChangedCallback: (() -> Void)?
   
    init() {
    
    }
    
    func savePressed(nameOfList: String?, numberOfColor: Int, isSortByCategory: Bool) {
        let typeOfSorting = isSortByCategory ? 0 : 1
        
        let list = GroseryListsModel(id: UUID(), dateOfCreation: Date(),
                                     name: nameOfList, color: numberOfColor, isFavorite: false, supplays: [], typeOfSorting: typeOfSorting)
        CoreDataManager.shared.saveList(list: list)
        valueChangedCallback?()
    }
    
    func getNumberOfCells() -> Int {
        colorManager.gradientsCount
    }
    
    func getColorForCell(at ind: Int) -> (UIColor, UIColor) {
        colorManager.getGradient(index: ind)
    }
    
}
