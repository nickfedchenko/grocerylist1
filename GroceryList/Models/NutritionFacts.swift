//
//  NutritionFacts.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 02.08.2023.
//

import UIKit

enum NutritionFacts: Int, CaseIterable {
    case carb
    case protein
    case fat
    case kcal

    var title: String {
        switch self {
        case .carb:     return R.string.localizable.carb()
        case .protein:  return R.string.localizable.protein()
        case .fat:      return R.string.localizable.fat()
        case .kcal:     return R.string.localizable.kcal()
        }
    }
    
    var recipeTitle: String {
        switch self {
        case .kcal:     return R.string.localizable.calories()
        default:        return title
        }
    }
    
    var activeColor: UIColor {
        switch self {
        case .carb:     return UIColor(hex: "CAAA00")
        case .protein:  return UIColor(hex: "1EB824")
        case .fat:      return UIColor(hex: "00B6CE")
        case .kcal:     return UIColor(hex: "EF6033")
        }
    }
    
    var placeholder: String {
        switch self {
        case .kcal:     return ""
        default:        return R.string.localizable.gram()
        }
    }
}
