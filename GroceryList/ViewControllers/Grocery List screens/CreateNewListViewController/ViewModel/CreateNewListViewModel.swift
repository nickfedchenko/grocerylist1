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
    private var colorManager = ColorManager.shared
    var valueChangedCallback: ((GroceryListsModel, [Product]) -> Void)?
    var model: GroceryListsModel?
    var copiedProducts: Set<Product> = []
    var newSavedProducts: [Product] = []
   
    func savePressed(nameOfList: String?, numberOfColor: Int, isAutomaticCategory: Bool) {
        if var model = model {
            model.name = nameOfList
            model.color = numberOfColor
            copiedProducts.forEach({ saveCopiedProduct(product: $0, listId: model.id) })
            model.products = newSavedProducts
            model.isAutomaticCategory = isAutomaticCategory
            CoreDataManager.shared.saveList(list: model)
            valueChangedCallback?(model, newSavedProducts)
            return
        }
        let isAutomaticCategory = isAutomaticCategory
        var list = GroceryListsModel(id: UUID(), dateOfCreation: Date(),
                                     name: nameOfList, color: numberOfColor, isFavorite: false, products: [],
                                     isAutomaticCategory: isAutomaticCategory, typeOfSorting: 0)
        CoreDataManager.shared.saveList(list: list)
        UserDefaultsManager.coldStartState = 2
        
        copiedProducts.forEach({ saveCopiedProduct(product: $0, listId: list.id) })
        list.products = newSavedProducts
        valueChangedCallback?(list, newSavedProducts)
        UserDefaultsManager.isFirstListCreated = true
    }
    
    func saveCopiedProduct(product: Product, listId: UUID) {
        let newProduct = Product(listId: listId, name: product.name, isPurchased: false,
                                 dateOfCreation: Date(), category: product.category, isFavorite: false, isSelected: false, description: product.description)
        newSavedProducts.append(newProduct)
        CoreDataManager.shared.createProduct(product: newProduct)
    }
    
    func getNumberOfCells() -> Int {
        colorManager.gradientsCount
    }
    
    func getTextFieldColor(at ind: Int) -> UIColor {
        colorManager.getGradient(index: ind).medium
    }
    
    func getBackgroundColor(at ind: Int) -> UIColor {
        colorManager.getGradient(index: ind).light
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
