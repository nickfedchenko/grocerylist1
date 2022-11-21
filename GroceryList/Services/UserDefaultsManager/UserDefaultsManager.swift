//
//  UserDefaultsManager.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 21.11.2022.
//

import Foundation

class UserDefaultsManager {
    
    static var isColdStartModelAdded: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isColdStartModelAdded")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isColdStartModelAdded")
        }
    }
}
