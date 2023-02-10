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
    func resingPasswordViewFirstResp()
    func resignEmailFirstResponder()
    func showEmailTaken()
    func hideEmailTaken()
    func underlineEmail(isValid: Bool)
    func underlinePassword(isValid: Bool)
    func registrationButton(isEnable: Bool)
    func showNoInternet()
    func hideNoInternet()
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
    
    private var emailParametrs = ValidationState(type: .email, text: "", isValidated: false)
    private var passwordParametrs = ValidationState(type: .password, text: "", isValidated: false)
    
    // MARK: - Init
    init() {
        state = .signUp
    }
    
    // MARK: - Func
    func setup(state: RegistrationState) {
        self.state = state
    }
    
    // MARK: - Navigation
    func backButtonPressed() {
        router?.pop()
    }
    
    func haveAccountPressed() {
        if state == .signUp {
            state = .signIn
            delegate?.hideEmailTaken()
            isEmailValidated = emailParametrs.isValidated
            delegate?.underlineEmail(isValid: isEmailValidated)
        } else {
            state = .signUp
            if emailParametrs.isValidated {
                checkMail(text: emailParametrs.text)
            }
        }
    }
    
    // MARK: - TextFieldActions
    func textfieldChangeCharcter(type: SignUpViewTextfieldType, isCorrect: Bool, text: String) {
        switch type {
        case .email:
            emailParametrs.text = text
            emailParametrs.isValidated = isCorrect
          
            isEmailValidated = isCorrect
            if isCorrect {
                checkMail(text: text)
            }
        case .password:
            passwordParametrs.text = text
            passwordParametrs.isValidated = isCorrect
           
            isPasswordValidated = isCorrect
        }
    }
    
    func textfieldReturnPressed(type: SignUpViewTextfieldType) {
        switch type {
        case .email:
            delegate?.setupPasswordViewFirstResponder()
        case .password:
            delegate?.resingPasswordViewFirstResp()
        }
    }
 
    // MARK: - AcceptTerms
    func terms(isTermsAccepted: Bool) {
        self.isTermsValidated = isTermsAccepted
        delegate?.resingPasswordViewFirstResp()
        delegate?.resignEmailFirstResponder()
    }
    
    // MARK: - AcceptTerms
    func sighUpPressed() {
        switch state {
        case .signUp:
            signUpUser()
        case .signIn:
            signInUser()
        }
    }
    
    func resetPasswordPressed() {
        print("resetPasswordPressed")
    }
    
    func signWithApplePressed() {
        print("signWithApplePressed")
    }
    
    // MARK: - Validation
    private func signUpUser() {
        network.createUser(email: emailParametrs.text,
                           password: passwordParametrs.text) { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
                self?.delegate?.showNoInternet()
            case .success(let response):
                self?.delegate?.hideNoInternet()
                self?.saveUserModel(userModel: response.user)
            }
        }
    }
   
    private func signInUser() {
        network.logIn(email: emailParametrs.text, password: passwordParametrs.text) { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
                self?.delegate?.showNoInternet()
            case .success(let response):
                self?.delegate?.hideNoInternet()
                if response.error {
                    self?.delegate?.underlinePassword(isValid: false)
                }
                guard let user = response.user else { return }
                self?.saveUserModel(userModel: user)
            }
        }
    }
    
    private func saveUserModel(userModel: User) {
        print(userModel)
        router?.pop()
    }
    
    // MARK: - Validation
    private func checkAllFieldsValidation() {
        switch state {
        case .signUp:
            if isEmailValidated, isPasswordValidated, isTermsValidated {
                delegate?.registrationButton(isEnable: true)
            } else {
                delegate?.registrationButton(isEnable: false)
            }
        case .signIn:
            if isEmailValidated, isPasswordValidated {
                delegate?.registrationButton(isEnable: true)
            } else {
                delegate?.registrationButton(isEnable: false)
            }
        }
    }
    
    private func checkMail(text: String) {
        guard state == .signUp else { return }
        network.checkEmail(email: text) { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
                self?.delegate?.showNoInternet()
            case .success(let model):
                self?.delegate?.hideNoInternet()
                if model.isExist {
                    self?.delegate?.showEmailTaken()
                    self?.isEmailValidated = false
                } else {
                    self?.delegate?.hideEmailTaken()
                    self?.isEmailValidated = true
                }
            }
        }
    }
}

struct ValidationState {
    var type: SignUpViewTextfieldType
    var text: String
    var isValidated: Bool
}
