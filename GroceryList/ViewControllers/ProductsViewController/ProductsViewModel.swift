//
//  ProductsViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 10.11.2022.
//

import Foundation
import UIKit

protocol ProductsViewModelDelegate: AnyObject {
    func updateController()
}

class ProductsViewModel {
    
    weak var router: RootRouter?
    private var colorManager = ColorManager()
    var valueChangedCallback: (() -> Void)?
    var model: GroceryListsModel
    var dataSource: ProductsDataManager
    weak var delegate: ProductsViewModelDelegate?
   
    init(model: GroceryListsModel, dataSource: ProductsDataManager) {
        self.dataSource = dataSource
        self.model = model
        
        self.dataSource.dataChangedCallBack = { [weak self] in
            self?.valueChangedCallback?()
        }
        
        self.dataSource.createArrayWithSections()
    }
    
    var arrayWithSections: [Category] {
        return dataSource.arrayWithSections
    }
    
    func getColorForBackground() -> UIColor {
        colorManager.getGradient(index: model.color).1
    }
    
    func getColorForForeground() -> UIColor {
        colorManager.getGradient(index: model.color).0
    }
    
    func getNameOfList() -> String {
        model.name ?? "..."
    }
    
    func goBackButtonPressed() {
        router?.pop()
    }
    
    func getCellIndex(with category: Category) -> Int {
        guard let index = arrayWithSections.firstIndex(of: category ) else { return 0 }
        return index
    }
    
    func settingsTapped(with snapshot: UIImage?) {
        router?.goProductsSettingsVC(snapshot: snapshot, model: model, compl: { [weak self] updatedModel in
            self?.model = updatedModel
            self?.delegate?.updateController()
        })
    }
    
    func cellTapped(product: Product) {
        dataSource.updateFavoriteStatus(for: product)
    }
    
    func delete(product: Product) {
        dataSource.delete(product: product)
    }

}
