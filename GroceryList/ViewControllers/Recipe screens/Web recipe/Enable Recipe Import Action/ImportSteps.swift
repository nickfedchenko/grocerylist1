//
//  ImportManual.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 01.08.2023.
//

import UIKit

enum ImportStep: CaseIterable {
    case first
    case second
    case third
    case fourth
    case fifth
    
    var image: UIImage? {
        switch self {
        case .first:    return R.image.manual_0()
        case .second:   return R.image.manual_1()
        case .third:    return R.image.manual_2()
        case .fourth:   return R.image.manual_3()
        case .fifth:    return R.image.manual_4()
        }
    }
    
    var title: String {
        switch self {
        case .first:    return R.string.localizable.importManual1()
        case .second:   return R.string.localizable.importManual2()
        case .third:    return R.string.localizable.importManual3()
        case .fourth:   return R.string.localizable.importManual4()
        case .fifth:    return R.string.localizable.importManual5()
        }
    }
    
    var highlightedInBold: String {
        switch self {
        case .first:    return R.string.localizable.importManual1Bold()
        case .second:   return R.string.localizable.importManual2Bold()
        case .third:    return R.string.localizable.importManual34Bold()
        case .fourth:   return R.string.localizable.importManual34Bold()
        case .fifth:    return R.string.localizable.importManual5Bold()
        }
    }
}
