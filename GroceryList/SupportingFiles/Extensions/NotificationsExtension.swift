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
    
    static let cloudListDownloadedAndSaved = Notification.Name("cloudListDownloadedAndSaved")
    static let cloudProductsDownloadedAndSaved = Notification.Name("cloudProductsDownloadedAndSaved")
}
