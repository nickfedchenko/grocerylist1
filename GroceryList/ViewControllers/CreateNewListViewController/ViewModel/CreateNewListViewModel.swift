//
//  CreateNewListViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 09.11.2022.
//

import Foundation
import UIKit

protocol CreateNewLiseViewModelDelegate: AnyObject {
    func updateLabelText(text: String)
    func presentController(controller: UIViewController?)
}

class CreateNewListViewModel {
    
    weak var delegate: CreateNewLiseViewModelDelegate?
    weak var router: RootRouter?
    private var colorManager = ColorManager()
    var valueChangedCallback: ((GroceryListsModel, [Product]) -> Void)?
    var model: GroceryListsModel?
    var copiedProducts: Set<Product> = []
    var newSavedProducts: [Product] = []
   
    func savePressed(nameOfList: String?, numberOfColor: Int, isSortByCategory: Bool) {
        if var model = model {
            model.name = nameOfList
            model.color = numberOfColor
            model.typeOfSorting = isSortByCategory ? 0 : 2
            CoreDataManager.shared.saveList(list: model)
            copiedProducts.forEach({ saveCopiedProduct(product: $0, listId: model.id) })
            valueChangedCallback?(model, newSavedProducts)
            return
        }
        let typeOfSorting = isSortByCategory ? 0 : 2
        let list = GroceryListsModel(id: UUID(), dateOfCreation: Date(),
                                     name: nameOfList, color: numberOfColor, isFavorite: false, products: [], typeOfSorting: typeOfSorting)
        CoreDataManager.shared.saveList(list: list)
        UserDefaultsManager.coldStartState = 2
        
        copiedProducts.forEach({ saveCopiedProduct(product: $0, listId: list.id) })
        valueChangedCallback?(list, newSavedProducts)
    }
    
    func saveCopiedProduct(product: Product, listId: UUID) {
        let newProduct = Product(id: UUID(), listId: listId, name: product.name, isPurchased: false,
                                 dateOfCreation: Date(), category: product.category, isFavorite: false, isSelected: false)
        newSavedProducts.append(newProduct)
        CoreDataManager.shared.createProduct(product: newProduct)
    }
    
    func getNumberOfCells() -> Int {
        colorManager.gradientsCount
    }
    
    func getTextFieldColor(at ind: Int) -> UIColor {
        colorManager.getGradient(index: ind).0
    }
    
    func getBackgroundColor(at ind: Int) -> UIColor {
        colorManager.getGradient(index: ind).1
    }
    
    func pickItemTapped(height: Double) {
        let controller = router?.prepareSelectListController(height: height, setOfSelectedProd: copiedProducts, compl: { [weak self] products in
            self?.copiedProducts = products
            self?.updateText()
        })
        delegate?.presentController(controller: controller)
    }
    
    func updateText() {
        let text = "PickFromAnotherList".localized + " " + "(\(copiedProducts.count))"
        delegate?.updateLabelText(text: text)
    }
}
