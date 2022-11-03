//
//  UIFontExtension.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 01.11.2022.
//

import UIKit

extension UIFont {
    enum SFPro {
        case heavy(size: CGFloat)
        case medium(size: CGFloat)
        case semibold(size: CGFloat)
        case bold(size: CGFloat)
        
        var font: UIFont! {
            switch self {
            case .heavy(let size):
                return UIFont(name: "SF Pro Display Heavy", size: size)
            case .medium(let size):
                return UIFont(name: "SF Pro Display Medium", size: size)
            case .semibold(let size):
                return UIFont(name: "SF Pro Display Semibold", size: size)
            case .bold(let size):
                return UIFont(name: "SF Pro Display Bold", size: size)
            }
        }
    }
}
