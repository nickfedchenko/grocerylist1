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
    
    private static func setValue<T>(value: T, for key: UDKeys) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }
    
    private static func getValue<T>(for key: UDKeys) -> T? {
        UserDefaults.standard.object(forKey: key.rawValue) as? T
    }
}
