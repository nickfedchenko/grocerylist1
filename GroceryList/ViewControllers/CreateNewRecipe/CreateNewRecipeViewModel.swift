//
//  CreateNewRecipeViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 01.03.2023.
//

import UIKit

final class CreateNewRecipeViewModel {
    
    weak var router: RootRouter?
    
    func back() {
        router?.navigationPopViewController(animated: true)
    }
    
}
