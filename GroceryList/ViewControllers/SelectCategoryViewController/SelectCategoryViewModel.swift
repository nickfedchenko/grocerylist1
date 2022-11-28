//
//  SelectCategoryViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 28.11.2022.
//

import Foundation
import UIKit

protocol SelectCategoryViewModelDelegate: AnyObject {
    
}

class SelectCategoryViewModel {
    
    var categorySelectedCallback: ((String) -> Void)?
    weak var delegate: SelectCategoryViewModelDelegate?
    weak var router: RootRouter?
    var model: GroceryListsModel?
    private var colorManager = ColorManager()

    func getBackgroundColor() -> UIColor {
        guard let model else { return .white }
        return colorManager.getGradient(index: model.color).1
    }
    
    func getForegroundColor() -> UIColor {
        guard let model else { return .white }
        return colorManager.getGradient(index: model.color).0
    }
}

