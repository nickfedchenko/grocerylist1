//
//  FeedbackManager.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 17.05.2023.
//

import Foundation

final class FeedbackManager {
    
    static let shared = FeedbackManager()
    
    private var isDoneFeedBack: Bool {
        get {
            guard let shouldShow = UserDefaults.standard.value(forKey: "isDoneFeedBack") as? Bool else {
                return false
            }
            return shouldShow
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isDoneFeedBack")
        }
    }
    
    private var firstLaunchDate: Date? {
        UserDefaultsManager.firstLaunchDate
    }

    private init() { }
    
    func setDoneFeedBack() {
        isDoneFeedBack = true
    }
    
    func isShowFeedbackScreen() -> Bool {
        guard !isDoneFeedBack else {
            return false
        }
        
        guard let firstLaunchDate,
              let daysNumber = Date().days(sinceDate: firstLaunchDate),
              daysNumber != 0 else {
            return false
        }
        
        return daysNumber == 3 || daysNumber % 7 == 0
    }
}
