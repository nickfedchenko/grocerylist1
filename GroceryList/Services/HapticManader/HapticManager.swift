//
//  HapticManager.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 01.12.2022.
//

import Foundation

class HapticManager {
    
    var isHapticOn: Bool {
        UserDefaultsManager.isHapticOn
    }
    
    func setupHaptic(isOn: Bool) {
        UserDefaultsManager.isHapticOn = isOn
    }
}
