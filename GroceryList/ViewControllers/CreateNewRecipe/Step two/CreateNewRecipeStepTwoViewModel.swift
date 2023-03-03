//
//  CreateNewRecipeStepTwoViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 03.03.2023.
//

import Foundation

final class CreateNewRecipeStepTwoViewModel {
    
    weak var router: RootRouter?
    
    func back() {
        router?.navigationPopViewController(animated: true)
    }

    func next() {
        
    }
}
