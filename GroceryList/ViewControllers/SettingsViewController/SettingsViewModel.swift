//
//  SettingsViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 01.12.2022.
//

import Foundation
import UIKit

protocol SettingsViewModelDelegate: AnyObject {
    func updateSelectionView()
}

class SettingsViewModel {
    
    weak var delegate: SettingsViewModelDelegate?
    weak var router: RootRouter?
    var isMetricSystem: Bool {
        UserDefaultsManager.isMetricSystem
    }
   
    func closeButtonTapped() {
        router?.popToRoot()
    }
    
    func registerButtonPressed() {
        router?.goToSignUpController()
    }
    
    func getTextForUnitSystemView() -> String {
        if isMetricSystem {
            return "Metric".localized
        } else {
            return "Imperial".localized
        }
    }
    
    func getBackgroundColorForMetric() -> UIColor {
        if isMetricSystem {
            return UIColor(hex: "#A1F0D6")
        } else {
            return .white
        }
    }
    
    func getBackgroundColorForImperial() -> UIColor {
        if isMetricSystem {
            return .white
        } else {
            return UIColor(hex: "#A1F0D6")
        }
    }
    
    func systemSelected(system: SelectedUnitSystem) {
        switch system {
        case .metric:
            UserDefaultsManager.isMetricSystem = true
        case .imperial:
            UserDefaultsManager.isMetricSystem = false
        }
        delegate?.updateSelectionView()
    }
}

enum SelectedUnitSystem {
    case imperial
    case metric
}
