//
//  ExtensionApphudProduct.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 14.07.2023.
//

import ApphudSDK
import Foundation
import StoreKit

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
    
    var priceStringX2: String {
        guard let skProduct = self.skProduct else {
            return loadingInfo
        }
        let price = skProduct.price.doubleValue * 2
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
    
    func getPricePerMinPeriod(allProducts: [ApphudProduct]) -> String {
        guard let skProduct = self.skProduct else {
            return loadingInfo
        }
        let price = skProduct.price.doubleValue
        let numberOfUnits = skProduct.subscriptionPeriod?.numberOfUnits
        let currencySymbol = "\(skProduct.priceLocale.currencySymbol ?? "$")"
        let minPeriod = getMinimumPeriod(allProducts: allProducts)
        let perMinPeriod = getPerMinPeriod(minPeriod: minPeriod)
        let perPeriod = getPeriodPerPeriod(unit: skProduct.subscriptionPeriod?.unit,
                                              minPeriod: minPeriod,
                                              numberOfUnits: numberOfUnits)
        
        switch skProduct.subscriptionPeriod?.unit {
        case .year:
            return currencySymbol + String(format: "%.2f", price / perPeriod) + perMinPeriod
        case .month:
            return currencySymbol + String(format: "%.2f", price / perPeriod) + perMinPeriod
        case .week:
            if skProduct.subscriptionPeriod?.numberOfUnits == 1 {
                return currencySymbol + String(format: "%.2f", price) + perMinPeriod
            }
        case .day:
            if skProduct.subscriptionPeriod?.numberOfUnits == 7 {
                return currencySymbol + String(format: "%.2f", price) + perMinPeriod
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
        let minPeriod = getMinimumPeriod(allProducts: allProducts)
        let perMinPeriod = getPeriodPerPeriod(unit: skProduct.subscriptionPeriod?.unit,
                                              minPeriod: minPeriod,
                                              numberOfUnits: numberOfUnits)
        return minPrice == 0 ? 0 : Int(100 - (price * 100) / (minPrice * perMinPeriod))
    }
    
    func findPriceOfMinimumPeriod(allProducts: [ApphudProduct]) -> Double {
        guard let minPrice = allProducts.min(by: {
            $0.skProduct?.price.doubleValue ?? 0 < $1.skProduct?.price.doubleValue ?? 0
        }) else {
            return 0
        }
        
        return minPrice.skProduct?.price.doubleValue ?? 0
    }
    
    func getMinimumPeriod(allProducts: [ApphudProduct]) -> SKProduct.PeriodUnit {
        guard let minPeriod = allProducts.min(by: {
            $0.skProduct?.subscriptionPeriod?.unit.rawValue ?? 0 < $1.skProduct?.subscriptionPeriod?.unit.rawValue ?? 0
        }) else {
            return .week
        }
        
        if minPeriod.skProduct?.subscriptionPeriod?.unit == .day &&
            minPeriod.skProduct?.subscriptionPeriod?.numberOfUnits == 7 {
            return .week
        }
        
        return minPeriod.skProduct?.subscriptionPeriod?.unit ?? .week
    }
    
    func getPeriodPerPeriod(unit: SKProduct.PeriodUnit?, minPeriod: SKProduct.PeriodUnit, numberOfUnits: Int?) -> Double {
        if minPeriod == .week {
            switch unit {
            case .month:
                return numberOfUnits == 6 ? 26.0715 : numberOfUnits == 1 ? 4.345 : 1
            case .year:
                return 52.1786
            default:
                return 1
            }
        } else if minPeriod == .month {
            switch unit {
            case .year:
                return 12
            default:
                return 1
            }
        }
        return 1
    }
    
    func getPerMinPeriod(minPeriod: SKProduct.PeriodUnit) -> String {
        switch minPeriod {
        case .day:      return " / " + R.string.localizable.perDay()
        case .week:     return " / " + R.string.localizable.perWeek()
        case .month:    return " / " + R.string.localizable.perMonth()
        case .year:     return " / " + R.string.localizable.perYear()
        @unknown default:
            return ""
        }
    }
    
    var forAnalitcs: String {
        guard let skProduct = self.skProduct else {
            return ""
        }
        let numberOfUnits = skProduct.subscriptionPeriod?.numberOfUnits
        
        switch skProduct.subscriptionPeriod?.unit {
        case .year:
            return isFamilyShareable ? .yearlyF : .yearly
        case .month:
            return isFamilyShareable ? .monthlyF : .monthly
        case .week:
            return isFamilyShareable ? .weeklyF : .weekly
        default: break
        }
        
        return ""
    }
}
