//
//  AmplitudeManager.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 01.02.2023.
//

import Amplitude
import ApphudSDK
import Foundation

class AmplitudeManager {
    
    private init() {
        Amplitude.instance().initializeApiKey("", userId: Apphud.userID())
    }
    
    static let shared = AmplitudeManager()

    private func logEvent(_ eventName: String, properties: [String: Any]? = nil) {
        if let properties = properties {
            Amplitude.instance().logEvent(eventName, withEventProperties: properties)
        } else {
            Amplitude.instance().logEvent(eventName)
        }
    }

    func logEvent(_ event: EventName, properties: [String: String]? = nil) {
        logEvent(event.rawValue, properties: properties)
    }

}

enum EventName: String {
    case feedbackScreenOpen = "FeedbackScreenOpen"
}

typealias PropertyKey = String
extension PropertyKey {
    static let value = "value"
}

typealias PropertyValue = String
extension PropertyValue {
    static let like = "like"
    static let dislike = "dislike"
}
