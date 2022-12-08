//
//  AddProductsSelectionListViewModel.swift
//  GroceryList
//
//  Created by Vladimir Banushkin on 07.12.2022.
//

import Foundation

final class AddProductsListViewModel {
    private var dbLists = CoreDataManager.shared.getAllLists()
    private var plainLists: [GroceryListsModel] = [] {
        didSet {
            reloadCallback?()
        }
    }
    var reloadCallback:(() -> Void)?
    
    
    func requestData() {
//        plainLists =
    }
    
}
