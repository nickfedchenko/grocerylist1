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
}

class EnterNewPasswordViewModel {
    weak var delegate: EnterNewPasswordViewModelDelegate?
    weak var router: RootRouter?
    
    private var newPassword: String = ""
    // MARK: - Navigation
    func backButtonPressed() {
        router?.pop()
    }
    
    func changePasswordButtonPressed() {
        print("change password prwessed")
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
