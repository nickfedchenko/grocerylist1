//
//  SignUpViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 08.02.2023.
//

import Foundation

protocol SignUpViewModelDelegate: AnyObject {

}

class SignUpViewModel {
    weak var delegate: SignUpViewModelDelegate?
    weak var router: RootRouter?
    
    private var state: RegistrationState = .signUp
    
    func backButtonPressed() {
        router?.pop()
    }
    
    func returnPressed(type: SignUpViewTextfieldType) {
        print(type.getPlaceholder())
    }
    
    func emailTextFieldEndEditing() {
        print("emailTextFieldEndEditing")
    }
    
    func terms(isActive: Bool) {
        print(isActive)
    }
    
    func sighUpPressed() {
        print("sighUpPressed")
    }
}

enum RegistrationState {
    case signUp
    case signIn
}
