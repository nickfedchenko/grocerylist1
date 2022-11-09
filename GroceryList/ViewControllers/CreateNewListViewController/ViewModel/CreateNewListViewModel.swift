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
    
    func getNumberOfCells() -> Int {
        colorManager.gradientsCount
    }
    
    func getColorForCell(at ind: Int) -> (UIColor, UIColor) {
        colorManager.getGradient(index: ind)
    }
}
