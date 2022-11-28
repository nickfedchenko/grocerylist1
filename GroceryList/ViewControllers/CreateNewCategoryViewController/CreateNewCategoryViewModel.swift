//
//  CreateNewCategoryViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 28.11.2022.
//

import Foundation
import UIKit

protocol CreateNewCategoryViewModelDelegate: AnyObject {
   
}

class CreateNewCategoryViewModel {
    
    var categoryCreatedCallBack: ((CategoryModel) -> Void)?
    weak var delegate: CreateNewCategoryViewModelDelegate?
    weak var router: RootRouter?
    var model: GroceryListsModel?
    private var colorManager = ColorManager()
    
    func getBackgroundColor() -> UIColor {
        guard let colorInd = model?.color else { return UIColor.white}
        return colorManager.getGradient(index: colorInd).1
    }
}
