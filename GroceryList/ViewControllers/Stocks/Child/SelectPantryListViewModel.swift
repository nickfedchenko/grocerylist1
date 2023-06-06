//
//  SelectPantryListViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 06.06.2023.
//

import UIKit

class SelectPantryListViewModel: PantryViewModel {

    let state: EditListState
    private let copiedStocks: [Stock]
    
    init(dataSource: PantryDataSource, copiedStocks: [Stock], state: EditListState) {
        self.copiedStocks = copiedStocks
        self.state = state
        super.init(dataSource: dataSource)
    }
    
    func saveCopiedStock(to list: PantryModel, controller: UIViewController) {
        copiedStocks.forEach { stock in
            let newStock = Stock(copyStock: stock)
//            CoreDataManager.shared.createProduct(product: newProduct)
        }
    }
    
    func createNewListWithEditModeTapped(controller: UIViewController) {
        router?.goToCreateNewPantry(presentedController: controller,
                                    currentPantry: nil,
                                    updateUI: { [weak self] newPantry in
            self?.dataSource.addPantry(newPantry)
        })
    }
}
