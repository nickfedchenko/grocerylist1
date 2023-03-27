//
//  FeatureManager.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 21.03.2023.
//

import FirebaseRemoteConfig
import Foundation

enum Feature: String, CaseIterable {
    case predictiveText = "predictive_text"
}

final class FeatureManager {
    
    static var shared = FeatureManager()
    var isActivePredictiveText = false
    
    private var remoteConfig = RemoteConfig.remoteConfig()
    
    private init() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 15 * 60
        remoteConfig.configSettings = settings
    }
    
    func activeFeatures() {
        Feature.allCases.forEach { feature in
            isActive(feature)
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
                case .predictiveText: self?.predictiveTextFeature(value)
                }
            }
        }
    }
    
    private func predictiveTextFeature(_ value: String) {
        isActivePredictiveText = value == "exp1_1"
        AmplitudeManager.shared.setUserProperty(properties: ["user_type": isActivePredictiveText ? "1" : "2"])
    }
}
