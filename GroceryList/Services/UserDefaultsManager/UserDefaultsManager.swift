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
            return UserDefaults.standard.integer(forKey: "3")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "3")
        }
    }
}
