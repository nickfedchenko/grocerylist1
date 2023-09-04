//
//  StopSharingViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 04.09.2023.
//

import Foundation

class StopSharingViewModel {
    
    var updateUI: ((Bool) -> Void)?
    var listToShareModel: GroceryListsModel?
    var pantryToShareModel: PantryModel?
    let user: User
    
    init(user: User) {
        self.user = user
    }
    
    func stopSharing() {
        updateUI?(true)
    }
    
    func cancel() {
        updateUI?(false)
    }
}
