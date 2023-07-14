//
//  ExtensionApphudProduct.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 14.07.2023.
//

import ApphudSDK
import Foundation

extension ApphudProduct {

    var loadingInfo: String {
        "Loading info".localized
    }
    
    var period: String {
        guard let skProduct = self.skProduct else {
            return loadingInfo
        }
        let numberOfUnits = skProduct.subscriptionPeriod?.numberOfUnits
 
        switch skProduct.subscriptionPeriod?.unit {
        case .year:
            return "yearly".localized
        case .month:
            if numberOfUnits == 6 {
                return "6 Month".localized
            } else if numberOfUnits == 1 {
                return "Monthly".localized
            }
        case .week:
            return "Week".localized
        case .day:
            if numberOfUnits == 7 {
                return "Week".localized
            }
        default: break
        }
        
        return loadingInfo
    }
    
    var priceString: String {
        guard let skProduct = self.skProduct else {
            return loadingInfo
        }
        let price = skProduct.price.doubleValue
        let numberOfUnits = skProduct.subscriptionPeriod?.numberOfUnits
        let currencySymbol = "\(skProduct.priceLocale.currencySymbol ?? "$")"
        
        switch skProduct.subscriptionPeriod?.unit {
        case .year:
            return currencySymbol + String(format: "%.2f", price)
        case .month:
            if numberOfUnits == 6 || numberOfUnits == 1 {
                return currencySymbol + String(format: "%.2f", price)
            }
        case .week:
            return currencySymbol + String(format: "%.2f", price)
        case .day:
            if numberOfUnits == 7 {
                return currencySymbol + String(format: "%.2f", price)
            }
        default: break
        }
        
        return loadingInfo
    }
    
    var pricePerWeek: String {
        guard let skProduct = self.skProduct else {
            return loadingInfo
        }
        let price = skProduct.price.doubleValue
        let numberOfUnits = skProduct.subscriptionPeriod?.numberOfUnits
        let currencySymbol = "\(skProduct.priceLocale.currencySymbol ?? "$")"
        let perWeek = " / " + "weekly".localized
        
        switch skProduct.subscriptionPeriod?.unit {
        case .year:
            return currencySymbol + String(format: "%.2f", price / 52.1786) + perWeek
        case .month:
            if numberOfUnits == 6 {
                return currencySymbol + String(format: "%.2f", price / 26.0715) + perWeek
            } else if numberOfUnits == 1 {
                return currencySymbol + String(format: "%.2f", price / 4.345) + perWeek
            }
        case .week:
            if skProduct.subscriptionPeriod?.numberOfUnits == 1 {
                return currencySymbol + String(format: "%.2f", price) + perWeek
            }
        case .day:
            if skProduct.subscriptionPeriod?.numberOfUnits == 7 {
                return currencySymbol + String(format: "%.2f", price) + perWeek
            }
        default: break
        }
        return loadingInfo
    }
    
}
