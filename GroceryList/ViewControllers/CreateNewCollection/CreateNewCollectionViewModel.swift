//
//  CreateNewCollectionViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 07.03.2023.
//

import Foundation

final class CreateNewCollectionViewModel {
    
    var updateUICallBack: (() -> Void)?
    
    func save(_ title: String?) {
        guard let title else {
            return
        }
        
        updateUICallBack?()
    }
    
}
