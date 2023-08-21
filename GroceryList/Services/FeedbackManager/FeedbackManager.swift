//
//  FeedbackManager.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 17.05.2023.
//

import Foundation

final class FeedbackManager {
    
    static let shared = FeedbackManager()
    
    private var firstLaunchDate: Date? {
        UserDefaultsManager.shared.firstLaunchDate
    }

    private init() { }
    
    func setDoneFeedBack() {
        UserDefaultsManager.shared.isDoneFeedBack = true
    }
    
    func setLastShowDate() {
        UserDefaultsManager.shared.lastShowFeedBackDate = Date()
    }
    
    func isShowFeedbackScreen() -> Bool {
        guard !UserDefaultsManager.shared.isDoneFeedBack else {
            return false
        }
        
        guard UserDefaultsManager.shared.lastShowFeedBackDate?.onlyDate != Date().onlyDate else {
            return false
        }
        
        guard let firstLaunchDate else {
            return false
        }
        
        let daysNumber = Date().days(sinceDate: firstLaunchDate)
        guard daysNumber != 0 else {
            return false
        }
        
        return daysNumber == 3 || daysNumber % 7 == 0
    }
}
