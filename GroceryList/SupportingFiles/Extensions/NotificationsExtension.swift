//
//  NotificationsExtension.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 01.02.2023.
//

import Foundation

extension Notification.Name {
    static let productsDownloadedAndSaved = Notification.Name("productsDownloadedAndSaved")
    static let recipesDownloadedAndSaved = Notification.Name("recipesDownloadedAndSaved")
    static let sharedListDownloadedAndSaved = Notification.Name("sharedListDownloadedAndSaved")
    static let sharedListLoading = Notification.Name("sharedListLoading")
    
    static let sharedPantryDownloadedAndSaved = Notification.Name("sharedPantryDownloadedAndSaved")
    static let sharedPantryListLoading = Notification.Name("sharedPantryListLoading")
    
    static let sharedMealPlanDownloadedAndSaved = Notification.Name("sharedMealPlanDownloadedAndSaved")
    
    static let cloudList = Notification.Name("cloudList")
    static let cloudProducts = Notification.Name("cloudProducts")
    static let cloudCollection = Notification.Name("cloudCollection")
    static let cloudRecipe = Notification.Name("cloudRecipe")
    static let cloudPantry = Notification.Name("cloudPantry")
    static let cloudStock = Notification.Name("cloudStock")
    static let cloudMealPlans = Notification.Name("cloudMealPlans")
}
