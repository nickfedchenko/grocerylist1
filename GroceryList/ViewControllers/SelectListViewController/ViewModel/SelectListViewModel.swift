//
//  SelectListViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 23.11.2022.
//

import Foundation
import UIKit

protocol SelectListViewModelDelegate: AnyObject {
    func dismissController()
}

class SelectListViewModel: MainScreenViewModel {
    
    var selectedProductsCompl: ((Set<Product>) -> Void)?
    weak var delegate: SelectListViewModelDelegate?
    var copiedProducts: Set<Product> = []
   
    func cellTapped(with model: GroceryListsModel, viewHeight: Double) {
        router?.goToSelectProductController(height: viewHeight, model: model, setOfSelectedProd: copiedProducts, compl: { [weak self] products in
            self?.copiedProducts = products
        })
    }
    
    func controllerDissmissed() {
        selectedProductsCompl?(copiedProducts)
    }
}
