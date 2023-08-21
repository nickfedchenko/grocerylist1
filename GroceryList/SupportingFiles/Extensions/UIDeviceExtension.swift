//
//  UIDeviceExtension.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 16.05.2023.
//

import UIKit

extension UIDevice {
    class var isSEorXor12mini: Bool {
        screenType == .iPhones678SE2 ||
        screenType == .iPhonesXXS11Pro ||
        screenType == .iPhone1213mini
    }
    
    class var isSE2: Bool {
        return UIScreen.main.nativeBounds.height == 1334
    }
    
    class var isDefaultPhone: Bool {
        return screenType == .iPhone121314
    }
    
    class var isLessPhoneSE: Bool {
        return UIScreen.main.nativeBounds.height <= 1334
    }
    
    class var isLessPhoneMini: Bool {
        return UIScreen.main.nativeBounds.height < 2340
    }
    
    class var isMoreDefaultPhone: Bool {
        return UIScreen.main.nativeBounds.height > 2556
    }
    
    enum ScreenType {
        case iPhones5andSE              // 320x568
        case iPhones678SE2              // 375x667
        case iPhones678Plus             // 414x736
        case iPhonesXXS11Pro            // 375x812
        case iPhoneXR11                 // 414x896
        case iPhoneXSMax11ProMax        // 375x812, 414x896

        case iPhone121314               // 390x844
        case iPhone14ProMax14Plus       // 430x932, 428x926
        case iPhone1213mini             // 360x780
        
        case unknown
    }
    
    class var screenType: ScreenType {
        switch UIScreen.main.nativeBounds.height {
        case 1136:
            return .iPhones5andSE
        case 1334:
            return .iPhones678SE2
        case 1792:
            return .iPhoneXR11
        case 1920, 2208:
            return .iPhones678Plus
        case 2340:
            return .iPhone1213mini
        case 2436:
            return .iPhonesXXS11Pro
        case 2532, 2556:
            return .iPhone121314
        case 2688:
            return .iPhoneXSMax11ProMax
        case 2778, 2796:
            return .iPhone14ProMax14Plus
        default:
            return .unknown
        }
    }
}
