//
//  RateUsReachability.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 28.12.2023.
//

import ApphudSDK
import Foundation

class RateUsReachability {
    
    static var shared = RateUsReachability()
    
    private init() {}
    
    func newProductCreated(router: RootRouter?) {
        UserDefaultsManager.shared.newProductCreatedCount += 1
        guard UserDefaultsManager.shared.newProductCreatedCount == 4 else {
            return
        }
        router?.openRateUs()
    }
    
    func pantyOpened(router: RootRouter?) {
        UserDefaultsManager.shared.pantryOpenedCount += 1
        guard UserDefaultsManager.shared.pantryOpenedCount == 3 else {
            return
        }
        router?.openRateUs()
    }
    
    func listShared(router: RootRouter?) {
        guard !UserDefaultsManager.shared.listHasBeenShared else {
            return
        }
        UserDefaultsManager.shared.listHasBeenShared = true
        router?.openRateUs()
    }
}
