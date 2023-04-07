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
        case regular(size: CGFloat)
        case black(size: CGFloat)
        
        var font: UIFont! {
            switch self {
            case .heavy(let size):
                return R.font.sfProTextHeavy(size: size)
            case .medium(let size):
                return R.font.sfProTextMedium(size: size)
            case .semibold(let size):
                return R.font.sfProTextSemibold(size: size)
            case .bold(let size):
                return R.font.sfProTextBold(size: size)
            case .regular(let size):
                return R.font.sfProTextRegular(size: size)
            case .black(let size):
                return R.font.sfProTextBlack(size: size)
            }
        }
    }
    
    enum SFProDisplay {
        case heavy(size: CGFloat)
        case medium(size: CGFloat)
        case semibold(size: CGFloat)
        case bold(size: CGFloat)
        case regular(size: CGFloat)
        
        var font: UIFont! {
            switch self {
            case .heavy(let size):
                return R.font.sfProDisplayHeavy(size: size)
            case .medium(let size):
                return R.font.sfProDisplayMedium(size: size)
            case .semibold(let size):
                return R.font.sfProDisplaySemibold(size: size)
            case .bold(let size):
                return R.font.sfProDisplayBold(size: size)
            case .regular(let size):
                return R.font.sfProDisplayRegular(size: size)
            }
        }
    }
    
    enum SFProRounded {
        case heavy(size: CGFloat)
        case medium(size: CGFloat)
        case semibold(size: CGFloat)
        case bold(size: CGFloat)
        case regular(size: CGFloat)
        
        var font: UIFont! {
            switch self {
            case .heavy(let size):
                return R.font.sfProRoundedHeavy(size: size)
            case .medium(let size):
                return R.font.sfProRoundedMedium(size: size)
            case .semibold(let size):
                return R.font.sfProRoundedSemibold(size: size)
            case .bold(let size):
                return R.font.sfProRoundedBold(size: size)
            case .regular(let size):
                return R.font.sfProRoundedRegular(size: size)
            }
        }
    }
    
    enum SFCompactDisplay {
        case semibold(size: CGFloat)
        
        var font: UIFont! {
            switch self {
            case .semibold(let size):
                return R.font.sfCompactDisplaySemibold(size: size)
            }
        }
    }
}
