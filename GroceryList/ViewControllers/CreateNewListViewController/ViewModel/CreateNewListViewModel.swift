//
//  CreateNewListViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 09.11.2022.
//

import Foundation
import UIKit

class CreateNewListViewModel {
    
    private var colorManager = ColorManager()
    var valueChangedCallback: (() -> Void)?
   
    init() {
    
    }
    
    func savePressed(nameOfList: String?, numberOfColor: Int) {
        let list = GroseryListsModel(id: UUID(), dateOfCreation: Date(),
                                     name: nameOfList, color: "f", isFavorite: false, supplays: [])
        CoreDataManager.shared.saveList(list: list)
    }
    
    func getNumberOfCells() -> Int {
        colorManager.gradientsCount
    }
    
    func getColorForCell(at ind: Int) -> (UIColor, UIColor) {
        colorManager.getGradient(index: ind)
    }
}
