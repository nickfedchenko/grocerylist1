//
//  CreateNewStoreViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 18.04.2023.
//

import Foundation

class CreateNewStoreViewModel: CreateNewCategoryViewModel {
    
    var storeCreatedCallBack: ((Store?) -> Void)?
    
    func saveNewStore(name: String) {
        AmplitudeManager.shared.logEvent(.shopSaveNewShop)
        let newStore = Store(title: name)
        CoreDataManager.shared.saveStore(newStore)
        storeCreatedCallBack?(newStore)
    }
    
    func dissmisStore() {
        storeCreatedCallBack?(nil)
    }
}
