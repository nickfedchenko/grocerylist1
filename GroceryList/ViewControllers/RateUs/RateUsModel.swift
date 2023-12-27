//
//  RateUsModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 26.12.2023.
//

import UIKit

enum RateUsModel: Hashable {
    case topCell(model: RateUsTopCellModel)
    case bottomCell(model: RateUsBottomCellModel)
}

enum RateUsSection: Hashable {
    case main
    case positive
}

enum RateUsTopCellModel: Hashable {
    case first
    case second
    
    var backgroundImage: UIImage? {
        switch self {
        case .first:
            return R.image.rateUsTopCellFirstImage()
        case .second:
            return R.image.rateUsTopCellSecondImage()
        }
    }
    
    var labelInContainerText: String {
        switch self {
        case .first:
            return R.string.localizable.rateUsTellUsMore()
        case .second:
            return R.string.localizable.rateUsGreat()
        }
    }
    
    var titleLabelText: String {
        switch self {
        case .first:
            return R.string.localizable.rateUsHowDoYouLikeAppTitle()
        case .second:
            return R.string.localizable.rateUsThanksForFeedbackTitle()
        }
    }
    
    var subtitleLabelText: String {
        switch self {
        case .first:
            return R.string.localizable.rateUsHowDoYouLikeAppSubtitle()
        case .second:
            return R.string.localizable.rateUsThanksForFeedbackSubtitle()
        }
    }
}

enum RateUsBottomCellModel: Hashable, CaseIterable {
    case veryGood
    case good
    case neutral
    case bad
    case veryBad
    
    var image: UIImage? {
        switch self {
        case .veryGood:
            return R.image.rateUsVeryGood()
        case .good:
            return R.image.rateUsGood()
        case .neutral:
            return R.image.rateUsNeutral()
        case .bad:
            return R.image.rateUsBad()
        case .veryBad:
            return R.image.rateUsVeryBad()
        }
    }
    
    var title: String {
        switch self {
        case .veryGood:
            return R.string.localizable.rateUsVeryGood()
        case .good:
            return R.string.localizable.rateUsGood()
        case .neutral:
            return R.string.localizable.rateUsNeutral()
        case .bad:
            return R.string.localizable.rateUsBad()
        case .veryBad:
            return R.string.localizable.rateUsVeryBad()
        }
    }
}
