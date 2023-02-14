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
    func setupRegisteredView(avatarImage: UIImage?, userName: String?, email: String)
    func pickImage()
}

class SettingsViewModel {
    
    weak var delegate: SettingsViewModelDelegate?
    weak var router: RootRouter?
    
    var network: NetworkEngine
   
    var isMetricSystem: Bool {
        UserDefaultsManager.isMetricSystem
    }
    
    private var user: User?
    
    init(network: NetworkEngine) {
        self.network = network
    }
    
    func viewWillAppear() {
        checkUser()
    }
    
    func saveNewUserName(name: String) {
        guard var user = user else { return }
        
        user.userName = name
        UserAccountManager.shared.saveUser(user: user)
        NetworkEngine().updateUserName(userToken: user.token, newName: name) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let response):
                print(response)
            }
        }
    }
    
    func closeButtonTapped() {
        router?.popToRoot()
    }
    
    func accountButtonTapped() {
        router?.goToAccountController()
    }
    
    func avatarButtonTapped() {
        delegate?.pickImage()
    }
    
    func saveAvatar(image: UIImage?) {
        guard let imageData = image?.jpegData(compressionQuality: 1), var user = user else { return }
     
        user.avatarAsData = imageData
        UserAccountManager.shared.saveUser(user: user)
        NetworkEngine().uploadAvatar(userToken: user.token, imageData: imageData) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let response):
                print(response)
            }
        }
        
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
        guard let user = UserAccountManager.shared.getUser() else {
            delegate?.setupNotRegisteredView()
            return
        }
       
        self.user = user
        
        var image: UIImage?
        if let avatarData = user.avatarAsData, let domainImage = UIImage(data: avatarData) {
            image = domainImage
        }
        
        delegate?.setupRegisteredView(avatarImage: image, userName: user.userName, email: user.email)
    }
}

enum SelectedUnitSystem {
    case imperial
    case metric
}
