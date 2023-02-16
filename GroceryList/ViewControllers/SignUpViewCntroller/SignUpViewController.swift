//
//  SignUpViewController.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 08.02.2023.
//

import AuthenticationServices
import UIKit

class SignUpViewController: UIViewController {
    
    var viewModel: SignUpViewModel?
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        let attrTitle = NSAttributedString(
            string: R.string.localizable.preferencies(),
            attributes: [
                .font: UIFont.SFProRounded.semibold(size: 17).font ?? .systemFont(ofSize: 15),
                .foregroundColor: UIColor(hex: "1A645A")
            ]
        )
        button.imageEdgeInsets.left = -17
        button.setImage(R.image.greenArrowBack(), for: .normal)
        button.tintColor = UIColor(hex: "1A645A")
        button.setAttributedTitle(attrTitle, for: .normal)
        button.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private let bigTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProRounded.bold(size: 22).font
        label.textColor = UIColor(hex: "#1A645A")
        return label
    }()
    
    private lazy var emailTextFieldView: SignUpViewForTyping = {
        let view = SignUpViewForTyping(type: .email)

        view.textFieldReturnPressed = { [weak self] type in
            self?.viewModel?.textfieldReturnPressed(type: type)
        }
        
        view.isFieldCorrect = { [weak self] isCorrect, text in
            self?.viewModel?.textfieldChangeCharacter(type: .email, isCorrect: isCorrect, text: text)
        }
        return view
    }()
    
    private lazy var passwordTextFieldView: SignUpViewForTyping = {
        let view = SignUpViewForTyping(type: .password)
       
        view.textFieldReturnPressed = { [weak self] type in
            self?.viewModel?.textfieldReturnPressed(type: type)
        }
       
        view.isFieldCorrect = { [weak self] isCorrect, text in
            self?.viewModel?.textfieldChangeCharacter(type: .password, isCorrect: isCorrect, text: text)
        }
        return view
    }()
    
    private lazy var termsView: TermsView = {
        let view = TermsView()
        view.isActiveCompl = { [weak self] isAccepted in
            self?.viewModel?.terms(isTermsAccepted: isAccepted)
        }
        return view
    }()
    
    private lazy var signUpButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.SFProDisplay.semibold(size: 20).font
        button.titleLabel?.textColor = UIColor(hex: "#FFFFFF")
        button.addTarget(self, action: #selector(signUpPressed), for: .touchUpInside)
        button.backgroundColor = UIColor(hex: "#31635A")
        button.layer.cornerRadius = 16
        button.layer.cornerCurve = .continuous
        button.layer.masksToBounds = true
        button.addShadowForView(radius: 5)
        return button
    }()
    
    private lazy var haveAccountButton: UIButton = {
        let button = UIButton()
        button.setTitle(R.string.localizable.registeR(), for: .normal)
        button.titleLabel?.font = UIFont.SFProDisplay.semibold(size: 20).font
        button.setTitleColor(UIColor(hex: "#19645A"), for: .normal)
        button.addTarget(self, action: #selector(haveAccountPressed), for: .touchUpInside)
        button.layer.cornerRadius = 16
        button.layer.cornerCurve = .continuous
        button.layer.borderColor = UIColor(hex: "#31635A").cgColor
        button.layer.borderWidth = 2
        button.layer.masksToBounds = true
        return button
    }()
    
    private lazy var resetPasswordButton: UIButton = {
        let button = UIButton()
        
        let attributedTitle = NSAttributedString(string: R.string.localizable.resetPassword(), attributes: [
            .font: UIFont.SFProDisplay.regular(size: 20).font ?? UIFont(),
            .foregroundColor: UIColor(hex: "#617774"),
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ])
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(resetPasswordPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var signInWithAppleButton: SignInWithAppleButton = {
        let button = SignInWithAppleButton()
        button.addTarget(self, action: #selector(signInWithApplePressed), for: .touchUpInside)
        return button
    }()
    
    private let emailTakenView = RedAlertView()
    private let noInternetView = RedAlertView(state: .internet)
    
    private let orLogIn: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProDisplay.regular(size: 20).font
        label.textColor = .black
        label.text = R.string.localizable.orLog()
        return label
    }()

    // MARK: - Lifecycle
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
    }

    deinit {
        print("SignUpViewController deinited")
    }
    
    // MARK: - Constraints
    // swiftlint:disable:next function_body_length
    private func setupConstraints() {
        view.backgroundColor = .backgroundColor
        view.addSubviews([backButton , bigTitle, emailTextFieldView,
                          passwordTextFieldView, termsView, signUpButton,
                          haveAccountButton, resetPasswordButton, signInWithAppleButton,
                          emailTakenView, orLogIn, noInternetView
                         ])
        
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.left.equalToSuperview().inset(35)
        }
        
        bigTitle.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(20)
            make.top.equalTo(backButton.snp.bottom).inset(-24)
        }
        
        emailTextFieldView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(bigTitle.snp.bottom).inset(-16)
        }
        
        passwordTextFieldView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(emailTextFieldView.snp.bottom)
        }
        
        termsView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(passwordTextFieldView.snp.bottom).inset(-16)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(passwordTextFieldView.snp.bottom).inset(-123)
            make.height.equalTo(64)
        }
        
        haveAccountButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(signUpButton.snp.bottom).inset(-20)
            make.height.equalTo(64)
        }
        
        resetPasswordButton.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.top.equalTo(passwordTextFieldView.snp.bottom).inset(-35)
            make.centerX.equalToSuperview()
        }
        
        signInWithAppleButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(60)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(64)
        }
        
        emailTakenView.snp.makeConstraints { make in
            make.centerY.equalTo(bigTitle)
            make.right.equalToSuperview().inset(23)
        }
        
        noInternetView.snp.makeConstraints { make in
            make.centerY.equalTo(bigTitle)
            make.right.equalToSuperview().inset(23)
        }
        
        orLogIn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(signInWithAppleButton.snp.top).inset(-20)
        }
        
    }
    
    // MARK: - Button pressed
    
    @objc
    private func backButtonPressed() {
        viewModel?.backButtonPressed()
    }
    
    @objc
    private func signUpPressed() {
        viewModel?.sighUpPressed()
    }
    
    @objc
    private func haveAccountPressed() {
        viewModel?.haveAccountPressed()
    }
    
    @objc
    private func resetPasswordPressed() {
        viewModel?.resetPasswordPressed()
    }
    
    @objc
    private func signInWithApplePressed() {
        viewModel?.signWithApplePressed()
    }
}

extension SignUpViewController: SignUpViewModelDelegate {
    func signWithAppleTapped() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func setupEmailFirstResponder() {
        emailTextFieldView.makeTextfieldFirstResponder()

    }
    
    func setupResetPasswordState(email: String) {
        setupView(state: .signIn)
        haveAccountButton.isHidden = true
        signInWithAppleButton.isHidden = true
        orLogIn.isHidden = true
        emailTextFieldView.setupTextForTextfield(text: email)
    }
    
    func showNoInternet() {
        noInternetView.showView()
    }
    
    func hideNoInternet() {
        noInternetView.hideView()
    }
    
    func resignEmailFirstResponder() {
        emailTextFieldView.resignTextfieldFirstResponder()
    }
    
    func registrationButton(isEnable: Bool) {
        signUpButton.isUserInteractionEnabled = isEnable
        switch isEnable {
        case true:
            signUpButton.backgroundColor = UIColor(hex: "#3E625A")
        case false:
            signUpButton.backgroundColor = UIColor(hex: "#617774")
        }
    }
    
    func resingPasswordViewFirstResp() {
        passwordTextFieldView.resignTextfieldFirstResponder()
    }
    
    func underlinePassword(isValid: Bool) {
        passwordTextFieldView.field(isCorrect: isValid)
    }
    
    func underlineEmail(isValid: Bool) {
        emailTextFieldView.field(isCorrect: isValid)
    }
    
    func hideEmailTaken() {
        emailTakenView.hideView()
        emailTextFieldView.field(isCorrect: true)
    }
    
    func showEmailTaken() {
        emailTakenView.showView()
        emailTextFieldView.field(isCorrect: false)
    }
    
    func setupPasswordViewFirstResponder() {
        passwordTextFieldView.makeTextfieldFirstResponder()
    }
    
    func setupView(state: RegistrationState) {
        bigTitle.text = state.getTitle()
        signUpButton.setTitle(state.getTitle(), for: .normal)
        haveAccountButton.setTitle(state.getHaveAccountTitle(), for: .normal)
        termsView.isHidden = state.isTermsHidden()
        resetPasswordButton.isHidden = !state.isTermsHidden()
        registrationButton(isEnable: false)
    }
}

extension SignUpViewController: ASAuthorizationControllerDelegate {

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error.localizedDescription)
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let appleId = appleIDCredential.user
            let appleUserEmail = appleIDCredential.email
            viewModel?.signWithAppleSucceed(email: appleUserEmail, appleId: appleId)
        }
    }
}

extension SignUpViewController: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
