//
//  HapticManager.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 01.12.2022.
//

import Foundation
import UIKit

class HapticManager {
    
    var isHapticOn: Bool {
        UserDefaultsManager.shared.isHapticOn
    }
    
    func setupHaptic(isOn: Bool) {
        UserDefaultsManager.shared.isHapticOn = isOn
    }
}

enum Vibration {
    case error
    case success
    case warning
    case light
    case medium
    case heavy
    case soft
    case rigid
    case selection
    
    func vibrate() {
        if UserDefaultsManager.shared.isHapticOn {
            switch self {
            case .error:
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            case .success:
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            case .warning:
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
            case .light:
                UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 1.0)
            case .medium:
                UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: 1.0)
            case .heavy:
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred(intensity: 1.0)
            case .soft:
                UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 1.0)
            case .rigid:
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 1.0)
            case .selection:
                UISelectionFeedbackGenerator().selectionChanged()
            }
        } else {
            return
        }
    }
}
