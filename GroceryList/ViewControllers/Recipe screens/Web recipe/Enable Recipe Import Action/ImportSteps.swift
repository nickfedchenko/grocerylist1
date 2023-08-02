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
        case .first:
            return R.image.manual_0()
        case .second:
            return R.image.manual_1()
        case .third:
            return R.image.manual_2()
        case .fourth:
            return R.image.manual_3()
        case .fifth:
            return R.image.manual_4()
        }
    }
    
    var title: String {
        switch self {
        case .first:
            return "First, tap the Share button in the Safari toolbar"
        case .second:
            return "Scroll to the bottom of the share sheet, then select Edit Actions..."
        case .third:
            return "Find the Grocery List Recipe Import action, and turn on the switch next to it. Optionaly, tap the green plus icon to left of the action name to make it one of your favorite actions. Then tap Done."
        case .fourth:
            return "Now the Grocery List Recipe Import action will be available. Tap on it while viewing a web page that constains a recipe."
        case .fifth:
            return "Review the imported recipe, than tap the Save button to save it to your collection of recipes in Grocery List App. You can edit it later, inside the application"
        }
    }
    
    var highlightedInBold: String {
        switch self {
        case .first:
            return "Share"
        case .second:
            return "Edit Actions..."
        case .third:
            return "Grocery List Recipe Import"
        case .fourth:
            return "Grocery List Recipe Import"
        case .fifth:
            return "Save"
        }
    }
}
