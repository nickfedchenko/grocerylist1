//
//  SignUpViewForTyping.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 09.02.2023.
//

import Foundation
import SnapKit
import UIKit

class SignUpViewForTyping: UIView {
    
    var textFieldReturnPressed: ((SignUpViewTextfieldType) -> Void)?
    var isFieldCorrect: ((Bool, String) -> Void)?
    
    private var type: SignUpViewTextfieldType = .password

    private lazy var textfield: PasswordTextField = {
        let textfield = PasswordTextField()
        textfield.font = UIFont.SFPro.medium(size: 16).font
        textfield.textColor = .black
        textfield.textAlignment = .left
        textfield.keyboardAppearance = .light
        textfield.delegate = self
        textfield.clearsOnBeginEditing = false
        return textfield
    }()
    
    private let pencilImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = R.image.whitePencil()?.withTintColor(UIColor(hex: "#19645A"))
        return imageView
    }()
    
    private let bottomLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#F4FFF5")
        return view
    }()
    
    var text: String? {
        textfield.text
    }
    
    // MARK: - LifeCycle
    init(type: SignUpViewTextfieldType) {
        super.init(frame: .zero)
        self.type = type
        setupView(type: type)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupTextForTextfield(text: String) {
        textfield.text = text
    }
    
    func makeTextfieldFirstResponder() {
        textfield.becomeFirstResponder()
    }
    
    func resignTextfieldFirstResponder() {
        textfield.resignFirstResponder()
    }
    
    func field(isCorrect: Bool) {
        bottomLineView.backgroundColor = isCorrect ? UIColor(hex: "#F4FFF5") : UIColor(hex: "#DF0404")
    }
    
    private func setupView(type: SignUpViewTextfieldType) {
        textfield.attributedPlaceholder = NSAttributedString(string: type.getPlaceholder(), attributes: [
            .font: UIFont.SFPro.medium(size: 16).font ?? UIFont(),
            .foregroundColor: UIColor(hex: "#19645A")
        ])
        
        textfield.isSecureTextEntry = type.isSecured()
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        addSubviews([bottomLineView, textfield, pencilImage])
        
        snp.makeConstraints { make in
            make.height.equalTo(54)
        }
        
        textfield.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.right.equalTo(pencilImage.snp.left).inset(-16)
            make.centerY.equalToSuperview()
        }

        pencilImage.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(3)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }
        
        bottomLineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(2)
        }
    }
}

extension SignUpViewForTyping: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textFieldReturnPressed?(type)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        var correctText = ""
        if string.isEmpty {
            correctText = String(text.dropLast())
        } else {
            correctText = text + string
        }
        checkPassword(lenght: newLength, text: correctText)
        checkScreenName(lenght: newLength, text: correctText)
        checkEmail(correctText)
        return true
    }
    
    private func checkEmail(_ email: String) {
        guard type == .email else { return }
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        field(isCorrect: emailPred.evaluate(with: email))
        isFieldCorrect?(emailPred.evaluate(with: email), email)
    }
    
    private func checkPassword(lenght: Int, text: String) {
        guard type == .password else { return }
        field(isCorrect: lenght > 4)
        isFieldCorrect?(lenght > 4, text)
    }
    
    private func checkScreenName(lenght: Int, text: String) {
        guard type == .screenName else { return }
        isFieldCorrect?(true, text)
    }
}

enum SignUpViewTextfieldType {
    case email
    case password
    case screenName
    
    func getPlaceholder() -> String {
        switch self {
        case .email:
            return R.string.localizable.email()
        case .password:
            return R.string.localizable.password()
        case .screenName:
            return R.string.localizable.settingsScreenName()
        }
    }
    
    func isSecured() -> Bool {
        switch self {
        case .email:
            return false
        case .password:
            return true
        case .screenName:
            return false
        }
    }
}

class PasswordTextField: UITextField {

    override var isSecureTextEntry: Bool {
        didSet {
            if isFirstResponder {
                _ = becomeFirstResponder()
            }
        }
    }

    override func becomeFirstResponder() -> Bool {

        let success = super.becomeFirstResponder()
        if isSecureTextEntry, let text = self.text {
            self.text?.removeAll()
            insertText(text)
        }
         return success
    }
}
