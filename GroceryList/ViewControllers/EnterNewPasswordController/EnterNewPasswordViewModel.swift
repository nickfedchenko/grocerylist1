//
//  EnterNewPasswordViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 14.02.2023.
//

import Foundation

protocol EnterNewPasswordViewModelDelegate: AnyObject {
    func resingPasswordViewFirstResp()
    func setChangePasswordInactive()
    func setChangePasswordActive()
    func showNoInternet()
}

class EnterNewPasswordViewModel {
    weak var delegate: EnterNewPasswordViewModelDelegate?
    weak var router: RootRouter?
    
    private let network: NetworkEngine
    private var newPassword: String = ""
    
    init(network: NetworkEngine) {
        self.network = network
    }
    
    // MARK: - Functions
    func backButtonPressed() {
        router?.pop()
    }
    
    func changePasswordButtonPressed() {
        guard let resetModel = ResetPasswordModelManager.shared.getResetPasswordModel() else { return }
        let resetToken = resetModel.resetToken
        network.updatePassword(newPassword: newPassword,
                                       resetToken: resetToken) { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
                self?.delegate?.showNoInternet()
            case .success(let response):
                print(response)
            }
        }
    }
    
    func textfieldReturnPressed() {
        delegate?.resingPasswordViewFirstResp()
    }
    
    // MARK: - TextFieldActions
    func textfieldChangeCharacter(isCorrect: Bool, text: String) {
        newPassword = text
        
        if isCorrect {
            delegate?.setChangePasswordActive()
        } else {
            delegate?.setChangePasswordInactive()
        }
    }
}
