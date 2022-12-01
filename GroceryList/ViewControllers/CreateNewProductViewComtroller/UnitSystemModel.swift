//
//  UnitSystemModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 30.11.2022.
//

import Foundation

enum UnitSystem: String, CaseIterable {
    case ozz
    case lbс
    case pt
    case fluidOz
    
    case gram
    case kilogram
    case liter
    case mililiter
   
    case can
    case piece
    case pack
    case bottle
    
    var stepValue: Int {
        switch self {
        case .ozz:
            return 5
        case .fluidOz:
            return 5
        case .pack:
            return 1
        case .piece:
            return 1
        case .lbс:
            return 1
        case .pt:
            return 1
        case .gram:
            return 100
        case .kilogram:
            return 1
        case .liter:
            return 1
        case .mililiter:
            return 100
        case .bottle:
            return 1
        case .can:
            return 1
        }
    }
}
