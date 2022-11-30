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
    func presentController(controller: UIViewController?)
}

class SelectCategoryViewModel {
    
    init (model: GroceryListsModel) {
        self.model = model
        self.colorManager = ColorManager()
        self.dataSource = SelectCategoryDataSource()
        dataSource.arrayUpdatedCallback = { [weak self] in
            self?.delegate?.reloadData()
        }
    }
    
    var categorySelectedCallback: ((String) -> Void)?
    weak var delegate: SelectCategoryViewModelDelegate?
    private var colorManager: ColorManager
    private var dataSource: SelectCategoryDataSource
    weak var router: RootRouter?
    var model: GroceryListsModel
    
    func categorySelected(at ind: Int) {
        let nameOfCategory = getTitleText(at: ind) ?? ""
        categorySelectedCallback?(nameOfCategory)
    }
    
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
    
    func addNewCategoryTapped() {
        let newCategoryInd = dataSource.getNewCategoryInd()
        let createNewCatCV = router?.prepareCreateNewCategoryController(model: model, newCategoryInd: newCategoryInd, compl: { [weak self] newCategory in
            self?.dataSource.addNewCategory(category: newCategory)
        })
        
        delegate?.presentController(controller: createNewCatCV)
    }
    
    func searchByWord(word: String) {
        dataSource.filterArray(word: word)
    }
}
