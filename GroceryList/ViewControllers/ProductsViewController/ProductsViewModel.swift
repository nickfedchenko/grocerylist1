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
    var model: GroseryListsModel
    var dataSource: ProductsDataManager
    weak var delegate: ProductsViewModelDelegate?
   
    init(model: GroseryListsModel, dataSource: ProductsDataManager) {
        self.dataSource = dataSource
        self.model = model
        
        self.dataSource.dataChangedCallBack = {
            self.valueChangedCallback?()
        }
        
        self.dataSource.createArrayWithSections()
    }
    
    var arrayWithSections: [Category] {
        return dataSource.arrayWithSections
    }
    
    func getColorForBackground() -> UIColor {
        colorManager.getGradient(index: model.color).1
    }
    
    func getAddItemViewColor() -> UIColor {
        colorManager.getGradient(index: model.color).0
    }
    
    func getNameOfList() -> String {
        model.name ?? "..."
    }
    
    func goBackButtonPressed() {
        router?.pop()
    }
    
    func settingsTapped(with snapshot: UIImage?) {
        router?.goProductsSettingsVC(snapshot: snapshot, model: model, compl: { [weak self] updatedModel in
            self?.model = updatedModel
        })
    }
    
    func cellTapped(product: Supplay) {
        dataSource.updateFavoriteStatus(for: product)
    }

}
