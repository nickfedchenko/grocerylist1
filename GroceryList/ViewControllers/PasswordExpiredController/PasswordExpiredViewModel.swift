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
        guard let user = UserAccountManager.shared.getUser() else { return }
        let email = user.email
        router?.goToPaswordResetController(email: email,
                                           passwordResetedCompl: { [weak self] in
            self?.router?.pop()
        })
    }
}
