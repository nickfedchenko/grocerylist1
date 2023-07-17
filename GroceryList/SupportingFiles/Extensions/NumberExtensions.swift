//
//  NumberExtensions.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 20.02.2023.
//

import Foundation

extension Array {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension Int {
    var asString: String {
        return "\(self)"
    }
}

extension Double {
    var asString: String {
        return String(format: "%.\(self.truncatingRemainder(dividingBy: 1) == 0.0 ? 0 : 1)f", self)
    }
}
