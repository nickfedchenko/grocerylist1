//
//  MeashureManager.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 30.11.2022.
//

import Foundation

class MeasureManager {
    
    static var shared = MeasureManager()
    
    var isCurrentSustemMetric = true
    
    func getGramOrOz(value: Int) -> Int {
        switch isCurrentSustemMetric {
        case true:
            return value
        case false:
            return Int(Double(value) / 28.34952)
        }
    }
}
