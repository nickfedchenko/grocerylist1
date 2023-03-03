//
//  CreateNewRecipeViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 01.03.2023.
//

import UIKit

final class CreateNewRecipeStepOneViewModel {
    
    weak var router: RootRouter?
    private var recipe: CreateNewRecipeStepOne?
    
    func back() {
        router?.navigationPopViewController(animated: true)
    }
    
    func openCollection() {
        print("выбор категорий")
    }
    
    func next() {
        
    }
    
    func saveRecipe(title: String, servings: Int,
                    collection: String?, photo: UIImage?) {
        recipe = .init(title: title, totalServings: servings,
                       collection: collection, photo: photo)
    }
}
