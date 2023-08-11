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

    var duration: String? {
        guard let skProduct = self.skProduct else {
            return nil
        }
        let numberOfUnits = skProduct.subscriptionPeriod?.numberOfUnits
 
        switch skProduct.subscriptionPeriod?.unit {
        case .year:
            return .yearly
        case .month:
            if numberOfUnits == 6 {
                return "6 Month"
            } else if numberOfUnits == 1 {
                return .monthly
            }
        case .week:
            return .weekly
        case .day:
            if numberOfUnits == 7 {
                return .weekly
            }
        default: break
        }
        
        return nil
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
    
    var isFamilyShareable: Bool {
        guard let skProduct = self.skProduct else {
            return false
        }
        return skProduct.isFamilyShareable
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

    func savePercent(allProducts: [ApphudProduct]) -> Int {
        guard let skProduct = self.skProduct else {
            return 0
        }
        let price = skProduct.price.doubleValue
        let numberOfUnits = skProduct.subscriptionPeriod?.numberOfUnits
        let minPrice = findPriceOfMinimumPeriod(allProducts: allProducts)
        switch skProduct.subscriptionPeriod?.unit {
        case .year:
            return minPrice == 0 ? 0 : Int(100 - (price * 100) / (minPrice * 52.1786))
        case .month:
            if numberOfUnits == 6 {
                return minPrice == 0 ? 0 : Int(100 - (price * 100) / (minPrice * 26.0715))
            } else if numberOfUnits == 1 {
                return minPrice == 0 ? 0 : Int(100 - (price * 100) / (minPrice * 4.345))
            }
        default: return 0
        }
        
        return 0
    }
    
    func findPriceOfMinimumPeriod(allProducts: [ApphudProduct]) -> Double {
        guard let minPrice = allProducts.min(by: {
            $0.skProduct?.price.doubleValue ?? 0 < $1.skProduct?.price.doubleValue ?? 0
        }) else {
            return 0
        }
        
        return minPrice.skProduct?.price.doubleValue ?? 0
    }
}
