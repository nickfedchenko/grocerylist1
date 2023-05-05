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
    func setupResetPasswordState(email: String)
    func setupEmailFirstResponder()
    func signWithAppleTapped()
}

class SignUpViewModel {
    // MARK: - Property
    let network: NetworkEngine
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
    
    private var emailParameters = ValidationState(type: .email, text: "", isValidated: false)
    private var passwordParameters = ValidationState(type: .password, text: "", isValidated: false)
    
    // MARK: - Init
    init(network: NetworkEngine) {
        self.network = network
        state = .signUp
    }
    
    /// используем в случае если переходим с экрана сброса пароля
    func setupResetPasswordState() {
        let resetEmail = ResetPasswordModelManager.shared.getResetPasswordModel()?.email ?? ""
        emailParameters.text = resetEmail
        emailParameters.isValidated = true
        isEmailValidated = true
        state = .signIn
        isTermsValidated = true
        delegate?.setupResetPasswordState(email: resetEmail)
        delegate?.setupEmailFirstResponder()
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
            isEmailValidated = emailParameters.isValidated
            delegate?.underlineEmail(isValid: isEmailValidated)
        } else {
            state = .signUp
            if emailParameters.isValidated {
                checkMail(text: emailParameters.text, compl: nil)
            }
        }
    }
    
    // MARK: - TextFieldActions
    func textfieldChangeCharacter(type: SignUpViewTextfieldType, isCorrect: Bool, text: String) {
        switch type {
        case .email:
            emailParameters.text = text
            emailParameters.isValidated = isCorrect
          
            isEmailValidated = isCorrect
            if isCorrect {
                checkMail(text: text, compl: nil)
            }
        default:
            passwordParameters.text = text
            passwordParameters.isValidated = isCorrect
           
            isPasswordValidated = isCorrect
        }
    }
    
    func textfieldReturnPressed(type: SignUpViewTextfieldType) {
        switch type {
        case .email:
            delegate?.setupPasswordViewFirstResponder()
        default:
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
            AmplitudeManager.shared.logEvent(.signInEmail, properties: [.accountType: .email])
            signUpUser()
        case .signIn:
            signInUser()
        }
    }
    
    func resetPasswordPressed() {
        router?.goToPaswordResetController(email: emailParameters.text,
                                           passwordResetedCompl: { [weak self] in
            self?.router?.pop()
        })
    }
    
    // MARK: - signWithApple
    func signWithApplePressed() {
        delegate?.signWithAppleTapped()
    }
    
    /// юзер прошел сайн виз эпл, пора его регать или входить в акк
    func signWithAppleSucceed(email: String?, appleId: String) {
        
        // проверяем есть ли в кейчейне данные, если нет то это первый вход и переходим регаться
        guard let emailData = KeyChainManager.load(key: .email),
              let passwordData = KeyChainManager.load(key: .password) else {
            createAccountAndLogIn(email: email)
            return
        }
        
        // если данные есть
        let email = String(decoding: emailData, as: UTF8.self)
        let password = String(decoding: passwordData, as: UTF8.self)
        
        // тут чекаем что почта занята - на случай если юзер удалил акк
        // если занята то переходим в функцию регистрации
        checkMail(text: email) { [weak self] isMailExist in
            guard isMailExist else {
                self?.createAccountAndLogIn(email: email)
                return
            }
            // если почта занята то проверка прошла и входим
            self?.emailParameters.text = email
            self?.passwordParameters.text = password
            self?.signInUser()
        }
    }
    
    /// сохраняем почту и логин в кейчейн и регистрируемся
    func createAccountAndLogIn(email: String?) {
        guard let email = email else {
            return
        }
        let password = UUID().uuidString
        
        KeyChainManager.save(key: .email, data: email.data(using: .utf8) ?? Data())
        KeyChainManager.save(key: .password, data: password.data(using: .utf8) ?? Data())
    
        emailParameters.text = email
        passwordParameters.text = password
        
        signUpUser()
    }
    
    // MARK: - Validation
    private func signUpUser() {
        network.createUser(email: emailParameters.text,
                           password: passwordParameters.text) { [weak self] result in
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
        network.logIn(email: emailParameters.text, password: passwordParameters.text) { [weak self] result in
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
        UserAccountManager.shared.saveUser(user: userModel)
        SharedListManager.shared.connectToListAfterRegistration()
        SocketManager.shared.connect()
        AmplitudeManager.shared.logEvent(.registerFromLink)
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
    
    private func checkMail(text: String, compl: ((Bool) -> Void)?) {
//        guard state == .signUp else { return }
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
                    DispatchQueue.main.async {
                        compl?(true)
                    }
                } else {
                    self?.delegate?.hideEmailTaken()
                    self?.isEmailValidated = true
                    DispatchQueue.main.async {
                        compl?(false)
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
}
