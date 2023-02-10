//
//  SignUpViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 08.02.2023.
//

import Foundation

protocol SignUpViewModelDelegate: AnyObject {
    func setupView(state: RegistrationState)
    func setupPasswordViewFirstResponder()
    func showEmailTaken()
    func hideEmailTaken()
    func underlineEmail(isValid: Bool)
    func underlinePassword(isValid: Bool)
    func resingPasswordViewFirstResp()
    func registrationButton(isEnable: Bool)
}

class SignUpViewModel {
    // MARK: - Property
    let network = NetworkEngine()
    weak var delegate: SignUpViewModelDelegate?
    weak var router: RootRouter?
    
    private var state: RegistrationState {
        didSet {
            delegate?.setupView(state: state)
        }
    }
    private var isEmailValidated: Bool = false {
        didSet {
            checkAllFieldsValidation()
        }
    }
    private var isPasswordValidated: Bool = false {
        didSet {
            checkAllFieldsValidation()
        }
    }
    private var isTermsValidated: Bool = false {
        didSet {
            checkAllFieldsValidation()
        }
    }
    
    // MARK: - Init
    init() {
        state = .signUp
    }
    
    // MARK: - Func
    func setup(state: RegistrationState) {
        self.state = state
    }
    
    func backButtonPressed() {
        router?.pop()
    }
    
    func textfieldEndEditing(type: SignUpViewTextfieldType, text: String) {
        switch type {
        case .email:
            checkEmailValidation(text: text)
        case .password:
            checkPasswordValidation(text: text)
        }
    }
    
    func terms(isTermsAccepted: Bool) {
        self.isTermsValidated = isTermsAccepted
        delegate?.resingPasswordViewFirstResp()
    }
    
    func sighUpPressed() {
        print("sighUpPressed")
    }
    
    func haveAccountPressed() {
        if state == .signUp {
            state = .signIn
        } else {
            state = .signUp
        }
    }
    
    func resetPasswordPressed() {
        print("resetPasswordPressed")
    }
    
    func signWithApplePressed() {
        print("signWithApplePressed")
    }
    
    // MARK: - Validation
    private func checkAllFieldsValidation() {
        if isEmailValidated, isPasswordValidated, isTermsValidated {
            delegate?.registrationButton(isEnable: true)
        } else {
            delegate?.registrationButton(isEnable: false)
        }
    }
    
    private func checkPasswordValidation(text: String) {
        if text.count > 4 {
            isPasswordValidated = true
            delegate?.underlinePassword(isValid: true)
            delegate?.resingPasswordViewFirstResp()
        } else {
            isPasswordValidated = false
            delegate?.underlinePassword(isValid: false)
        }
    }
    
    private func checkEmailValidation(text: String) {
        if isValidEmail(text) {
            delegate?.underlineEmail(isValid: true)
            checkMail(text: text)
        } else {
            delegate?.hideEmailTaken()
            delegate?.underlineEmail(isValid: false)
            isEmailValidated = false
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func checkMail(text: String) {
        guard state == .signUp else { return }
        network.checkEmail(email: text) { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let model):
                if model.isExist {
                    self?.delegate?.showEmailTaken()
                    self?.isEmailValidated = false
                } else {
                    self?.delegate?.hideEmailTaken()
                    self?.delegate?.setupPasswordViewFirstResponder()
                    self?.isEmailValidated = true
                }
            }
        }
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
