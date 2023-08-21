//
//  NewFeatureViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 21.08.2023.
//

import Foundation

final class NewFeatureViewModel {
    
    weak var router: RootRouter?
    
    func tappedGreatEnable() {
        
    }
    
    func tappedMaybeLater() {
        router?.navigationDismiss()
    }
}
