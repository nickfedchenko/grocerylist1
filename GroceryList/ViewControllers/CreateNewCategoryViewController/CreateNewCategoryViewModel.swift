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
    
    init(model: GroceryListsModel?, newModelInd: Int) {
        self.model = model
        self.newModelInd = newModelInd
    }
    
    var categoryCreatedCallBack: ((CategoryModel) -> Void)?
    weak var delegate: CreateNewCategoryViewModelDelegate?
    weak var router: RootRouter?
    let model: GroceryListsModel?
    let newModelInd: Int
    
    private var colorManager = ColorManager()
    
    func getBackgroundColor() -> UIColor {
        guard let colorInd = model?.color else { return UIColor.white}
        return colorManager.getGradient(index: colorInd).medium
    }
    
    func getForegroundColor() -> UIColor {
        guard let colorInd = model?.color else { return UIColor.white}
        return colorManager.getGradient(index: colorInd).light
    }
    
    func saveNewCategory(name: String) {
        let newCategory = CategoryModel(ind: newModelInd, name: name)
        CoreDataManager.shared.saveCategory(category: newCategory)
        categoryCreatedCallBack?(newCategory)
    }
}
