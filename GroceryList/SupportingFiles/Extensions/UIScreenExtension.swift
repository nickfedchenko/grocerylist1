//
//  UIScreenExtension.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 02.11.2022.
//

import UIKit

extension UIScreen {
    
    var isSizeAsIPhoneSE: Bool {
        return bounds.width == 320
    }
    
    var isSizeAsIPhone8: Bool {
        return bounds.width == 375
    }
    
    var isSizeAsIPhone8OrLarger: Bool {
        return bounds.width >= 375
    }
    
    var isSizeAsIPhone8Plus: Bool {
        return bounds.width == 414
    }
    
    var isSizeAsIPhone8PlusOrBigger: Bool {
        return bounds.width >= 414
    }
    
    var isMoreIphonePlus: Bool {
        if UIDevice.current.userInterfaceIdiom == .phone {
            switch UIScreen.main.bounds.height {
            case 700...1000:
                return true
            default:
                return false
            }
        }
        return false
    }
    
}
