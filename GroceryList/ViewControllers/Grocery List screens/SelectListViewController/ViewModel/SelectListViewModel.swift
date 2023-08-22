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

class SelectListViewModel: ListViewModel {
    
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
            newProduct.id = UUID()
            newProduct.listId = list.id
            CoreDataManager.shared.createProduct(product: newProduct)
            CloudManager.saveCloudData(product: newProduct)
        }
        SharedListManager.shared.updateGroceryList(listId: list.id.uuidString)
    }
    
    // MARK: - Edit product cell
    func saveCopiedProduct(to list: GroceryListsModel, products: [Product]) {
        products.forEach { product in
            let newProduct = Product(listId: list.id, name: product.name,
                                     isPurchased: false,
                                     dateOfCreation: Date(),
                                     category: product.category,
                                     isFavorite: false, isSelected: false,
                                     description: product.description)
            CoreDataManager.shared.createProduct(product: newProduct)
            CloudManager.saveCloudData(product: newProduct)
        }
        
        router?.popList()
        router?.goProductsVC(model: list, compl: { })
    }
    
    func createNewListWithEditModeTapped() {
        router?.goCreateNewList(compl: { [weak self] _, _ in
            guard let list = self?.dataSource.updateListOfModels() else { return }
            self?.updateCells?(list)
            self?.dataSource.setOfModelsToUpdate = []
        })
    }
    
    func controllerDissmissed() {
        selectedProductsCompl?(copiedProducts)
    }
}
