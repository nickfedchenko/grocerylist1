//
//  CreateNewRecipeViewState.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 03.03.2023.
//

import UIKit

enum CreateNewRecipeViewState {
    case required
    case optional
    case recommended
    case used
    case filled
    
    var borderWidth: CGFloat {
        switch self {
        case .required:     return 2
        case .optional:     return 1
        case .recommended:  return 1
        case .used:         return 1
        case .filled:       return 1
        }
    }
    
    var borderColor: UIColor {
        switch self {
        case .required:     return R.color.action() ?? UIColor(hex: "#78F6E6")
        case .optional:     return R.color.mediumGray() ?? UIColor(hex: "#ACB4B4")
        case .recommended:  return R.color.mediumGray() ?? UIColor(hex: "#ACB4B4")
        case .used:         return R.color.primaryDark() ?? UIColor(hex: "#045C5C")
        case .filled:       return R.color.primaryLight() ?? UIColor(hex: "#DBF6F6")
        }
    }
    
    var shadowColors: [UIColor] {
        switch self {
        case .required, .optional, .recommended, .filled:
            return [UIColor(hex: "#484848"), UIColor(hex: "#858585")]
        case .used:
            return [.clear, .clear]
        }
    }
    
    var shadowOpacity: [Float] {
        switch self {
        case .required, .optional, .recommended, .filled:
            return [0.15, 0.1]
        case .used:
            return [0, 0]
        }
    }
    
    var shadowRadius: [CGFloat] {
        switch self {
        case .required:     return [1, 6]
        case .optional:     return [1, 5]
        case .recommended:  return [1, 5]
        case .used:         return [0, 0]
        case .filled:       return [1, 6]
        }
    }
    
    var shadowOffset: [CGSize] {
        switch self {
        case .required, .optional, .recommended, .filled:
            return [.init(width: 0, height: 0.5), .init(width: 0, height: 4)]
        case .used:
            return [.zero, .zero]
        }
    }
    
    var placeholder: String {
        switch self {
        case .required:     return R.string.localizable.required()
        case .optional:     return R.string.localizable.optional()
        case .recommended:  return R.string.localizable.recommended().firstCharacterUpperCase()
        case .used:         return ""
        case .filled:       return ""
        }
    }
    
    var placeholderColor: UIColor? {
        switch self {
        case .required:     return R.color.darkGray()
        case .optional:     return R.color.mediumGray()
        case .recommended:  return R.color.mediumGray()
        case .used:         return nil
        case .filled:       return R.color.darkGray()
        }
    }
}
