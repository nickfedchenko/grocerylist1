//
//  DictionaryExtension.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 12.05.2023.
//

import Foundation

extension Dictionary {
    mutating func add<T>(_ element: T, toArrayOn key: Key) where Value == [T] {
        self[key] == nil ? self[key] = [element] : self[key]?.append(element)
    }
}
