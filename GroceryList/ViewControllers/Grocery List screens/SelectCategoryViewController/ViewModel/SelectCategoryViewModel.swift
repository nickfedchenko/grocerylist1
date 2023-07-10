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
    func dismissController()
}

class SelectCategoryViewModel {
    
    init (model: GroceryListsModel?) {
        self.model = model
        self.colorManager = ColorManager.shared
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
    var model: GroceryListsModel?
    
    func categorySelected(with name: String?) {
        let selectedName = name ?? ""
        categorySelectedCallback?(selectedName)
        delegate?.dismissController()
    }
    
    func goBackButtonPressed() {
        delegate?.dismissController()
    }
    
    func getNumberOfCells() -> Int {
        dataSource.getNumberOfCategories()
    }
   
    func getBackgroundColor() -> UIColor {
        guard let model else {
            return colorManager.getGradient(index: 2).light
        }
        return colorManager.getGradient(index: model.color).light
    }
    
    func getForegroundColor() -> UIColor {
        guard let model else {
            return colorManager.getGradient(index: 2).medium
        }
        return colorManager.getGradient(index: model.color).medium
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
        let createNewCatCV = router?.prepareCreateNewCategoryController(
            model: model,
            newCategoryInd: newCategoryInd,
            compl: { [weak self] newCategory in
                self?.dataSource.addNewCategory(category: newCategory)
                self?.categorySelectedCallback?(newCategory.name)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    self?.delegate?.dismissController()
                }
            })
        
        delegate?.presentController(controller: createNewCatCV)
    }
    
    func searchByWord(word: String) {
        dataSource.filterArray(word: word)
    }
}
