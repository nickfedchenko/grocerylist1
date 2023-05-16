//
//  UnitSystemModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 30.11.2022.
//

import Foundation

enum UnitSystem: Int, Codable, CaseIterable {
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
    
    case gallon
    case quart
    
    var stepValue: Int {
        switch self {
        case .ozz:          return 5
        case .fluidOz:      return 5
        case .pack:         return 1
        case .piece:        return 1
        case .lbс:          return 1
        case .pt:           return 1
        case .gram:         return 100
        case .kilogram:     return 1
        case .liter:        return 1
        case .mililiter:    return 100
        case .bottle:       return 1
        case .can:          return 1
        case .gallon:       return 1
        case .quart:        return 1
        }
    }
    
    var title: String {
        switch self {
        case .ozz:          return R.string.localizable.ozz()
        case .fluidOz:      return R.string.localizable.fluidOz()
        case .pack:         return R.string.localizable.pack()
        case .piece:        return R.string.localizable.piece()
        case .lbс:          return R.string.localizable.lbс()
        case .pt:           return R.string.localizable.pt()
        case .gram:         return R.string.localizable.gram()
        case .kilogram:     return R.string.localizable.kilogram()
        case .liter:        return R.string.localizable.liter()
        case .mililiter:    return R.string.localizable.mililiter()
        case .bottle:       return R.string.localizable.bottle()
        case .can:          return R.string.localizable.can()
        case .gallon:       return R.string.localizable.gallon()
        case .quart:        return R.string.localizable.quart()
        }
    }
}
