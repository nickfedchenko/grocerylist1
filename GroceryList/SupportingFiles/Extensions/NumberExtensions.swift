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
