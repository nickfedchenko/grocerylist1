//
//  FeatureManager.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 21.03.2023.
//

import FirebaseRemoteConfig
import Foundation

enum Feature: String, CaseIterable {
    case autoCategory
    
    var onlyFirstLaunch: Bool {
        switch self {
        case .autoCategory: return true
        }
    }
}

final class FeatureManager {
    
    static var shared = FeatureManager()
    var isActiveAutoCategory: Bool? {
        get { return UserDefaultsManager.isActiveAutoCategory }
        set { UserDefaultsManager.isActiveAutoCategory = newValue }
    }
    
    private var remoteConfig = RemoteConfig.remoteConfig()
    
    private init() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 15 * 60
        remoteConfig.configSettings = settings
    }
    
    func activeFeatures() {
        Feature.allCases.forEach { feature in
            if !feature.onlyFirstLaunch {
                isActive(feature)
            }
        }
    }
    
    func activeFeaturesOnFirstLaunch() {
        Feature.allCases.forEach { feature in
            if feature.onlyFirstLaunch {
                isActive(feature)
            }
        }
    }
    
    private func isActive(_ feature: Feature) {
        remoteConfig.fetchAndActivate { [weak self] status, error in
            if let error {
                print(error.localizedDescription)
            }
            if status != .error,
               let value = self?.remoteConfig[feature.rawValue].stringValue {
                switch feature {
                case .autoCategory: self?.autoCategoryFeature(value)
                }
            }
        }
    }
    
    private func autoCategoryFeature(_ value: String) {
        isActiveAutoCategory = value == "on"
        if let isActiveAutoCategory {
            UserDefaultsManager.isActiveAutoCategory = isActiveAutoCategory
            let type = isActiveAutoCategory ? "autocategory_on" : "autocategory_off"
            AmplitudeManager.shared.setUserProperty(properties: ["user_type": type])
        }
    }
}
