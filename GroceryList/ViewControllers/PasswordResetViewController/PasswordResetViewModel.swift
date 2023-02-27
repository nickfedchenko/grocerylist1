//
//  PasswordResetViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 10.02.2023.
//

import Foundation

protocol PasswordResetViewModelDelegate: AnyObject {
    func setupTextfieldText(text: String)
    func applySecondState()
    func dismissController()
}

class PasswordResetViewModel {
    weak var delegate: PasswordResetViewModelDelegate?
    weak var router: RootRouter?

    var passwordResetedCompl: (() -> Void)?
   
    var email: String = "" {
        didSet {
            delegate?.setupTextfieldText(text: email)
        }
    }
    private var network: NetworkEngine
    private var isFirstState: Bool = true
    
    init(network: NetworkEngine) {
        self.network = network
    }
    
    func closeButtonPressed() {
        delegate?.dismissController()
    }
    
    func resetButtonPressed(text: String) {
        if isFirstState {
            resetPassword(text: text)
            isFirstState = false
        } else {
            passwordResetedCompl?()
            delegate?.dismissController()
        }
 
    }
    
    private func resetPassword(text: String) {
        email = text
        NetworkEngine().passwordReset(email: text) { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let response):
                self?.setupResetToken(model: response)
            }
        }
        applySecondState()
    }
    
    private func setupResetToken(model: PasswordResetResponse) {
        let resetPasswordModel = ResetPasswordModel(email: email,
                                                    resetToken: model.result.passwordResetToken,
                                                    dateOfExpiration: Date())
        ResetPasswordModelManager.shared.saveResetPasswordModel(model: resetPasswordModel)
    }
    
    private func applySecondState() {
        delegate?.applySecondState()
    }
}
