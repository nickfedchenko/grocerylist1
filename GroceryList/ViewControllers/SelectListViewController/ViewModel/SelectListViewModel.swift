//
//  SelectListViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 23.11.2022.
//

import Foundation
import UIKit

protocol SelectListViewModelDelegate: AnyObject {
    func presentSelectedVC(controller: UIViewController)
    func dismissController()
}

class SelectListViewModel: MainScreenViewModel {
    
    var selectedProductsCompl: ((Set<Product>) -> Void)?
    weak var delegate: SelectListViewModelDelegate?
    var copiedProducts: Set<Product> = []
   
    func cellTapped(with model: GroceryListsModel, viewHeight: Double) {
        let viewController = router?.presentSelectProduct(height: viewHeight, model: model, setOfSelectedProd: copiedProducts, compl: { [weak self] products in
            self?.copiedProducts = products
        })
        
        guard let viewController else { return }
     
        viewController.modalPresentationStyle = .overCurrentContext
        delegate?.presentSelectedVC(controller: viewController)
    }
    
    func controllerDissmissed() {
        selectedProductsCompl?(copiedProducts)
    }
}
