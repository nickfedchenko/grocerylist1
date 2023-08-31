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
            var newStock = Stock(copyStock: stock)
            newStock.pantryId = list.id
            CoreDataManager.shared.saveStock(stocks: [newStock], for: list.id.uuidString)
            CloudManager.shared.saveCloudData(stock: newStock)
        }
    }
    
    func createNewListWithEditModeTapped(controller: UIViewController) {
        router?.goToCreateNewPantry(presentedController: controller,
                                    currentPantry: nil,
                                    updateUI: { [weak self] _ in
            self?.dataSource.updatePantry()
        })
    }
}
