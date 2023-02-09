//
//  SignUpViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 08.02.2023.
//

import Foundation

protocol SignUpViewModelDelegate: AnyObject {
    func setupView(state: RegistrationState)
}

class SignUpViewModel {
    weak var delegate: SignUpViewModelDelegate?
    weak var router: RootRouter?
    
    private var isTermsAccepted: Bool = false
    private var state: RegistrationState {
        didSet {
            delegate?.setupView(state: state)
        }
    }
    
    init() {
        state = .signUp
    }
    
    func setup(state: RegistrationState) {
        self.state = state
    }
    
    func backButtonPressed() {
        router?.pop()
    }
    
    func returnPressed(type: SignUpViewTextfieldType) {
        print(type.getPlaceholder())
    }
    
    func emailTextFieldEndEditing() {
        print("emailTextFieldEndEditing")
    }
    
    func terms(isTermsAccepted: Bool) {
        self.isTermsAccepted = isTermsAccepted
        print(isTermsAccepted)
    }
    
    func sighUpPressed() {
        print("sighUpPressed")
    }
    
    func haveAccountPressed() {
        print("haveAccountPressed")
    }
    
    func resetPasswordPressed() {
        print("resetPasswordPressed")
    }
    
    func signWithApplePressed() {
        print("signWithApplePressed")
    }
}

enum RegistrationState {
    case signUp
    case signIn
    
    func getTitle() -> String {
        switch self {
        case .signUp:
            return R.string.localizable.singUp()
        case .signIn:
            return R.string.localizable.singIn()
        }
    }
    
    func getHaveAccountTitle() -> String {
        switch self {
        case .signUp:
            return R.string.localizable.iHaveAccount()
        case .signIn:
            return R.string.localizable.iDontHaveAccount()
        }
    }
    
    func isTermsHidden() -> Bool {
        switch self {
        case .signUp:
            return false
        case .signIn:
            return true
        }
    }
}
