//
//  UIDeviceExtension.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 16.05.2023.
//

import UIKit

extension UIDevice {
    class var isSE: Bool {
        if UIDevice.current.userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136, 1334, 2436: // SE, 12mini, X
                return true
            default:
                return false
            }
        }
        return false
    }
}
