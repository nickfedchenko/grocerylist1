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
        Amplitude.instance().initializeApiKey("b199f09c9cddea79687c52f8a0c77e6b", userId: Apphud.userID())
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
    case core = "Core"
    case createItem = "CreateItem"
    case sharing = "Sharing"
    case recipes = "Recipes"
}

typealias PropertyKey = String
extension PropertyKey {
    static let value = "value"
}

typealias PropertyValue = String
extension PropertyValue {
    static let like = "like"
    static let dislike = "dislike"
    static let itemAdd = "item_add"
    static let itemChecked = "item_checked"
    static let itemDelete = "item_delete"
    static let listCreate = "list_create"
    static let listDelete = "list_delete"
    static let categoryChange = "category_change"
    static let categoryNew = "category_new"
    static let photoDelete = "photo_delete"
    static let itemQuantityButtons = "item_quantity_buttons"
    static let itemUnitsButton = "item_units_button"
    static let signInEmail = "sign_in_email"
    static let sendInvite = "send_invite"
    static let recipeSection = "recipe_section"
}
