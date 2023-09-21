//
//  MainTabBarControllerDelegates.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 09.06.2023.
//

import Foundation

protocol MainTabBarControllerRecipeDelegate: AnyObject {
    func updateRecipeUI(_ recipe: Recipe?)
}

protocol MainTabBarControllerPantryDelegate: AnyObject {
    func updatePantryUI(_ pantry: PantryModel)
    func tappedAddItem()
}

protocol MainTabBarControllerListDelegate: AnyObject {
    func updatedUI()
    func tappedAddItem()
}

protocol MainTabBarControllerStocksDelegate: AnyObject {
    func tappedAddItem()
}

protocol MainTabBarControllerProductsDelegate: AnyObject {
    func tappedAddItem()
}

protocol MainTabBarControllerMealPlanDelegate: AnyObject {
    func tappedAddRecipeToMealPlan()
}
