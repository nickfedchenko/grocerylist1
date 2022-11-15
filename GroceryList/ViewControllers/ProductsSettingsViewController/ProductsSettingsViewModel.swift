//
//  ProductsSettingsViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 10.11.2022.
//

import Foundation
import UIKit

class ProductsSettingsViewModel {
    
    var colors: (UIColor, UIColor)
    weak var router: RootRouter?
    var valueChangedCallback: (() -> Void)?
   
    init(colors: (UIColor, UIColor)) {
        self.colors = colors
    }
    
    func getNumberOfCells() -> Int {
        return TableViewContent.allCases.count
    }
    
    func getImage(at ind: Int) -> UIImage? {
        return TableViewContent.allCases[ind].image
    }
    
    func getText(at ind: Int) -> String? {
        return TableViewContent.allCases[ind].rawValue.localized
    }
    
    func getInset(at ind: Int) -> Bool {
        return TableViewContent.allCases[ind].isInset
    }
    
    func getTextColor() -> UIColor {
        return colors.0
    }
    
    func getSeparatirLineColor() -> UIColor {
        return colors.1
    }
    
    enum TableViewContent: String, CaseIterable {
        case rename
        case pinch
        case changeColor
        case sort
        case byCategory
        case byTime
        case byAlphabet
        case copy
        case print
        case send
        case delete
        
        var image: UIImage? {
            switch self {
            case .rename:
                return UIImage(named: "Rename")
            case .pinch:
                return UIImage(named: "Pin")
            case .changeColor:
                return UIImage(named: "Color")
            case .sort:
                return UIImage(named: "Sort")
            case .byCategory:
                return UIImage(named: "Category")
            case .byTime:
                return UIImage(named: "Time")
            case .byAlphabet:
                return UIImage(named: "ABC")
            case .copy:
                return UIImage(named: "Copy")
            case .print:
                return UIImage(named: "Print")
            case .send:
                return UIImage(named: "Send")
            case .delete:
                return UIImage(named: "Trash")
            }
        }
        
        var isInset: Bool {
            switch self {
            case .byTime, .byAlphabet, .byCategory:
                return true
            default:
                return false
            }
        }
    }

}
