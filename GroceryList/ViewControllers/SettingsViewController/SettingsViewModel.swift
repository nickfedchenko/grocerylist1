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
    func setupNotRegisteredView()
    func setupRegisteredView()
    func pickImage()
}

class SettingsViewModel {
    
    weak var delegate: SettingsViewModelDelegate?
    weak var router: RootRouter?
    var isMetricSystem: Bool {
        UserDefaultsManager.isMetricSystem
    }
    
    func viewWillAppear() {
        checkUser()
    }
    
    func saveNewUserName(name: String) {
        print(name)
    }
    
    func closeButtonTapped() {
        router?.popToRoot()
    }
    
    func accountButtonTapped() {
        print("accountButtonTapped")
    }
    
    func avatarButtonTapped() {
        delegate?.pickImage()
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
    
    private func checkUser() {
//        guard let user = CoreDataManager.shared.getUser() else {
//            delegate?.setupNotRegisteredView()
//            return
//        }
        delegate?.setupRegisteredView()
    }
}

enum SelectedUnitSystem {
    case imperial
    case metric
}
