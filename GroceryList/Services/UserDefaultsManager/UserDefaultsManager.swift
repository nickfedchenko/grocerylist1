//
//  UserDefaultsManager.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 21.11.2022.
//

import Foundation

class UserDefaultsManager {
    enum UDKeys: String {
        case favoriteRecipes
    }
    
    static var shouldShowOnboarding: Bool {
        get {
            guard let shouldShow = UserDefaults.standard.value(forKey: "shouldShowOnboarding") as? Bool else {
                return true
            }
            return shouldShow
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "shouldShowOnboarding")
        }
    }
    
    static var firstLaunchDate: Date? {
        get {
            return UserDefaults.standard.object(forKey: "firstLaunchDate") as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "firstLaunchDate")
        }
    }
    
    static var coldStartState: Int {
        get {
            return UserDefaults.standard.integer(forKey: "coldStartState")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "coldStartState")
        }
    }
    
    static var isMetricSystem: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isMetricSystem")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isMetricSystem")
        }
    }
    
    static var isHapticOn: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isHapticOn")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isHapticOn")
        }
    }
    
    static var isReviewShowed: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "shouldOpenWriteReview")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "shouldOpenWriteReview")
        }
    }
    
    static var isReviewShowedAfterSharing: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isReviewShowedAfterSharing")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isReviewShowedAfterSharing")
        }
    }
    
    static var isNativeRateUsShowed: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isNativeRateUsShowed")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isNativeRateUsShowed")
        }
    }
    
    static var isFirstListCreated: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isFirstListCreated")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isFirstListCreated")
        }
    }
    
    static var countInfoMessage: Int {
        get {
            return UserDefaults.standard.integer(forKey: "countInfoMessage")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "countInfoMessage")
        }
    }
    
    static var userTokens: [String]? {
        get {
            return UserDefaults.standard.array(forKey: "userTokens") as? [String]
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "userTokens")
        }
    }
    
    static var favoritesRecipeIds: [Int] {
        get {
            guard
                let data: Data = getValue(for: .favoriteRecipes),
                let ids = try? JSONDecoder().decode([Int].self, from: data)
            else { return [] }
            return ids
        }
        
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                setValue(value: data, for: .favoriteRecipes)
            }
        }
    }
    
    static var isCollectionFilling: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isCollectionFilling")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isCollectionFilling")
        }
    }
    
    static var isFillingDefaultCollection: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isFillingDefaultCollection")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isFillingDefaultCollection")
        }
    }
    
    static var miscellaneousCollectionId: Int {
        get {
            return UserDefaults.standard.integer(forKey: "miscellaneousCollectionId")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "miscellaneousCollectionId")
        }
    }
    
    static var isShowRecipePrompting: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isShowRecipePrompting")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isShowRecipePrompting")
        }
    }
    
    static var isShowImage: Bool {
        get {
            return !UserDefaults.standard.bool(forKey: "isShowImage")
        }
        set {
            UserDefaults.standard.set(!newValue, forKey: "isShowImage")
        }
    }
    
    static var countAutoCategoryInfo: Int {
        get {
            return UserDefaults.standard.integer(forKey: "countAutoCategoryInfo")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "countAutoCategoryInfo")
        }
    }
    
    static var isActiveAutoCategory: Bool? {
        get {
            guard let shouldShow = UserDefaults.standard.value(forKey: "isActiveAutoCategory") as? Bool else {
                return nil
            }
            return shouldShow
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isActiveAutoCategory")
        }
    }
    
    static var isFillingDefaultPantry: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isFillingDefaultPantry")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isFillingDefaultPantry")
        }
    }
    
    static var pantryUserTokens: [String]? {
        get {
            return UserDefaults.standard.array(forKey: "pantryUserTokens") as? [String]
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "pantryUserTokens")
        }
    }
    
    static var lastUpdateStockDate: Date? {
        get {
            return UserDefaults.standard.object(forKey: "lastUpdateStockDate") as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "lastUpdateStockDate")
        }
    }
    
    static var lastShowStockReminderDate: Date? {
        get {
            return UserDefaults.standard.object(forKey: "lastShowStockReminderDate") as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "lastShowStockReminderDate")
        }
    }
    
    private static func setValue<T>(value: T, for key: UDKeys) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }
    
    private static func getValue<T>(for key: UDKeys) -> T? {
        UserDefaults.standard.object(forKey: key.rawValue) as? T
    }
}
