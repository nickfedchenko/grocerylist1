//
//  SettingsViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 01.12.2022.
//

import Foundation
import Kingfisher
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
    private var userName: String?
    private var originalUserName: String?
    
    init(network: NetworkEngine) {
        self.network = network
    }
    
    func viewWillAppear() {
        checkUser()
    }
    
    func saveNewUserName(name: String) {
        guard var user = user else { return }
        
        user.username = name
        UserAccountManager.shared.saveUser(user: user)
        network.updateUserName(userToken: user.token, newName: name) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let response):
                print(response)
            }
        }
    }
    
    func getTextFromTextField(_ text: String?) {
        userName = text
    }
    
    func closeButtonTapped() {
        if let userName, originalUserName != userName {
            saveNewUserName(name: userName)
        }
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
        self.user?.avatarAsData = imageData
        UserAccountManager.shared.saveUser(user: user)
        network.uploadAvatar(userToken: user.token, imageData: imageData) { result in
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
    
    func downloadImage(user: User) {
        guard user.avatarAsData == nil, let userAvatarUrl = user.avatar else { return }
        ImageDownloader.default.downloadImage(with: URL(string: userAvatarUrl)!,
                                              options: [], progressBlock: nil) { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let image):
                let image = image.image
                self?.saveAvatarToUser(user: user, image: image)
            }
        }
    }
    
    func saveAvatarToUser(user: User, image: UIImage) {
        var newUser = user
        newUser.avatarAsData = image.jpegData(compressionQuality: 1)
        UserAccountManager.shared.saveUser(user: newUser)
        checkUser()
    }
    
    private func checkUser() {
        guard let user = UserAccountManager.shared.getUser() else {
            delegate?.setupNotRegisteredView()
            return
        }
       
        self.user = user
        originalUserName = user.username
        downloadImage(user: user)
        
        let avatarImage = UIImage(data: user.avatarAsData ?? Data())

        delegate?.setupRegisteredView(avatarImage: avatarImage, userName: user.username, email: user.email)
    }
}

enum SelectedUnitSystem {
    case imperial
    case metric
}