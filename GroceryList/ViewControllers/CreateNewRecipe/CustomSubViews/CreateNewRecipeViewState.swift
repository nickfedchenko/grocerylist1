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
    case used
    case filled
    
    var borderWidth: CGFloat {
        switch self {
        case .required: return 2
        case .optional: return 1
        case .used:     return 2
        case .filled:   return 1
        }
    }
    
    var borderColor: UIColor {
        switch self {
        case .required: return UIColor(hex: "#62D3B4")
        case .optional: return UIColor(hex: "#B3EFDE")
        case .used:     return UIColor(hex: "#1A645A")
        case .filled:   return UIColor(hex: "#B3EFDE")
        }
    }
    
    var shadowColors: [UIColor] {
        switch self {
        case .required: return [UIColor(hex: "#484848"), UIColor(hex: "#858585")]
        case .optional: return [UIColor(hex: "#123E5E"), UIColor(hex: "#06BBBB")]
        case .used:     return [.clear, .clear]
        case .filled:   return [UIColor(hex: "#484848"), UIColor(hex: "#858585")]
        }
    }
    
    var shadowOpacity: [Float] {
        switch self {
        case .required: return [0.15, 0.1]
        case .optional: return [0.25, 0.2]
        case .used:     return [0, 0]
        case .filled:   return [0.15, 0.1]
        }
    }
    
    var shadowRadius: [CGFloat] {
        switch self {
        case .required: return [1, 6]
        case .optional: return [1, 5]
        case .used:     return [0, 0]
        case .filled:   return [1, 6]
        }
    }
    
    var shadowOffset: [CGSize] {
        switch self {
        case .required: return [.init(width: 0, height: 0.5), .init(width: 0, height: 4)]
        case .optional: return [.init(width: 0, height: 0.5), .init(width: 0, height: 4)]
        case .used:     return [.zero, .zero]
        case .filled: return [.init(width: 0, height: 0.5), .init(width: 0, height: 4)]
        }
    }
    
    var placeholder: String {
        switch self {
        case .required: return R.string.localizable.required()
        case .optional: return R.string.localizable.optional()
        case .used:     return ""
        case .filled:   return ""
        }
    }
}
