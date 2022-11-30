//
//  UserDefaultsManager.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 21.11.2022.
//

import Foundation

class UserDefaultsManager {
    
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
}
