//
//  PasswordExpiredViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 14.02.2023.
//

import Foundation

protocol PasswordExpiredViewModelDelegate: AnyObject {

}

class PasswordExpiredViewModel {
    weak var delegate: PasswordExpiredViewModelDelegate?
    weak var router: RootRouter?
    
    // MARK: - Navigation
    func backButtonPressed() {
        router?.pop()
    }
    
    func resetButtonPressed() {
        guard let passwordResetModel = ResetPasswordModelManager.shared.getResetPasswordModel() else { return }
        let email = passwordResetModel.email
        router?.goToPaswordResetController(email: email,
                                           passwordResetedCompl: { [weak self] in
            self?.router?.pop()
        })
    }
}
