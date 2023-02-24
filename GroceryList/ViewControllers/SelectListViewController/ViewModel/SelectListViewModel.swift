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
        let viewController = router?.prepareSelectProductController(height: viewHeight, model: model, setOfSelectedProd: copiedProducts, compl: { [weak self] products in
            self?.copiedProducts = products
        })
        
        guard let viewController else { return }
     
        viewController.modalPresentationStyle = .overCurrentContext
        delegate?.presentSelectedVC(controller: viewController)
    }
    
    // MARK: - Recipes part
    func shouldAdd(to list: GroceryListsModel, products: [Product]) {
        products.forEach { product in
            var newProduct = product
            newProduct.listId = list.id
            CoreDataManager.shared.createProduct(product: newProduct)
        }
        SharedListManager.shared.updateGroceryList(listId: list.id.uuidString)
    }
    
    func controllerDissmissed() {
        selectedProductsCompl?(copiedProducts)
    }
}
