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
    
    var selectedProductsCompl: (([Product]) -> Void)?
    weak var delegate: SelectListViewModelDelegate?
    var copiedProducts: [Product] = []
   
    func cellTapped(with model: GroceryListsModel, viewHeight: Double) {
        let viewController = router?.presentSelectProduct(height: viewHeight, model: model, compl: { [weak self] products in
            self?.copiedProducts.append(contentsOf: products)
        })
        
        guard let viewController else { return }
     
        viewController.modalPresentationStyle = .overCurrentContext
        delegate?.presentSelectedVC(controller: viewController)
    }
    
    func controllerDissmissed() {
        selectedProductsCompl?(copiedProducts)
    }
}
