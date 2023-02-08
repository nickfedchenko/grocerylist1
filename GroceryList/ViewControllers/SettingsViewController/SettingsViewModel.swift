//
//  SettingsViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 01.12.2022.
//

import Foundation
import UIKit

protocol SettingsViewModelDelegate: AnyObject {

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
    
    func imperialSystemSelected() {
        UserDefaultsManager.isMetricSystem = false
    }
    
    func metricSystemSelected() {
        UserDefaultsManager.isMetricSystem = true
    }
}
