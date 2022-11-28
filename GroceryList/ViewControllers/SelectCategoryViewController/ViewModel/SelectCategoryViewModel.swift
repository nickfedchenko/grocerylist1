//
//  SelectCategoryViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 28.11.2022.
//

import Foundation
import UIKit

protocol SelectCategoryViewModelDelegate: AnyObject {
    func reloadData()
}

class SelectCategoryViewModel {
    
    init (model: GroceryListsModel) {
        self.model = model
        self.colorManager = ColorManager()
        self.dataSource = SelectCategoryDataSource()
    }
    
    var categorySelectedCallback: ((String) -> Void)?
    weak var delegate: SelectCategoryViewModelDelegate?
    private var colorManager: ColorManager
    private var dataSource: SelectCategoryDataSource
    weak var router: RootRouter?
    var model: GroceryListsModel
    
    func getNumberOfCells() -> Int {
        dataSource.getNumberOfCategories()
    }
   
    func getBackgroundColor() -> UIColor {
        return colorManager.getGradient(index: model.color).1
    }
    
    func getForegroundColor() -> UIColor {
        return colorManager.getGradient(index: model.color).0
    }
    
    func getTitleText(at ind: Int) -> String? {
        dataSource.getCategory(at: ind).name
    }
    
    func isCellSelected(at ind: Int) -> Bool {
        dataSource.isSelected(at: ind)
    }

    func selectCell(at ind: Int) {
        dataSource.selectCell(at: ind)
        delegate?.reloadData()
    }
}
