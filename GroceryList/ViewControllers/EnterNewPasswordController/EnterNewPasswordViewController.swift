//
//  EnterNewPasswordViewController.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 14.02.2023.
//

import UIKit

class EnterNewPasswordViewController: UIViewController {
    
    var viewModel: EnterNewPasswordViewModel?
    
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
    
    private let enterNewPasswordLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProRounded.bold(size: 22).font
        label.textColor = UIColor(hex: "#19645A")
        label.text = R.string.localizable.resetPasswordEnterNewPassw()
        return label
    }()
    
    private lazy var passwordTextFieldView: SignUpViewForTyping = {
        let view = SignUpViewForTyping(type: .password)
       
        view.textFieldReturnPressed = { [weak self] _ in
            self?.viewModel?.textfieldReturnPressed()
        }
       
        view.isFieldCorrect = { [weak self] isCorrect, text in
            self?.viewModel?.textfieldChangeCharacter(isCorrect: isCorrect, text: text)
        }
        return view
    }()
    
    private lazy var changePasswordButton: UIButton = {
        let button = UIButton()
        let attributedTitle = NSAttributedString(string: R.string.localizable.resetPasswordChangePassword(),
                                                 attributes: [
                                                    .font: UIFont.SFProRounded.semibold(size: 18).font ?? UIFont(),
                                                    .foregroundColor: UIColor(hex: "#FFFFFF")
                                                 ])
        button.addTarget(self, action: #selector(changePasswordButtonPressed), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.backgroundColor = UIColor(hex: "#617774")
        button.layer.cornerRadius = 16
        button.layer.cornerCurve = .continuous
        button.layer.masksToBounds = true
        button.isUserInteractionEnabled = false
        button.addShadowForView(radius: 5)
        return button
    }()
    
    private let noInternetView = RedAlertView(state: .internet)
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
    }
    
    deinit {
        print("PasswordExpiredViewController deinitd")
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        view.backgroundColor = .backgroundColor
        view.addSubviews([backButton, enterNewPasswordLabel,
                          passwordTextFieldView, changePasswordButton, noInternetView])
        
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.left.equalToSuperview().inset(35)
        }
        
        enterNewPasswordLabel.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).inset(-24)
            make.left.equalToSuperview().inset(20)
        }
        
        passwordTextFieldView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(enterNewPasswordLabel.snp.bottom).inset(-40)
        }

        changePasswordButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextFieldView.snp.bottom).inset(-48)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(63)
        }
        
        noInternetView.snp.makeConstraints { make in
            make.bottom.equalTo(enterNewPasswordLabel.snp.top).inset(-10)
            make.right.equalToSuperview().inset(23)
        }
    }
    
    // MARK: - Actions
    @objc
    private func backButtonPressed() {
        viewModel?.backButtonPressed()
    }
    
    @objc
    private func changePasswordButtonPressed() {
        viewModel?.changePasswordButtonPressed()
    }
}

extension EnterNewPasswordViewController: EnterNewPasswordViewModelDelegate {
    func showNoInternet() {
        noInternetView.showView()
    }
    
    func setChangePasswordInactive() {
        changePasswordButton.isUserInteractionEnabled = false
        changePasswordButton.backgroundColor = UIColor(hex: "#617774")
    }
    
    func setChangePasswordActive() {
        changePasswordButton.isUserInteractionEnabled = true
        changePasswordButton.backgroundColor = UIColor(hex: "#19645A")
    }
    
    func resingPasswordViewFirstResp() {
        passwordTextFieldView.resignTextfieldFirstResponder()
    }
}
