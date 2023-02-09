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
    
    var returnPressed: (() -> Void)?
    var textFieldEndEditing: (() -> Void)?

    private lazy var textfield: UITextField = {
        let textfield = UITextField()
        textfield.font = UIFont.SFPro.medium(size: 16).font
        textfield.textColor = .black
        textfield.textAlignment = .left
        textfield.keyboardAppearance = .light
        textfield.delegate = self
        return textfield
    }()
    
    private let pencilImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = R.image.whitePencil()?.withTintColor(UIColor(hex: "#4C877F"))
        return imageView
    }()
    
    private let bottomLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#F4FFF5")
        return view
    }()
    
    // MARK: - LifeCycle
    init(type: SignUpViewTextfieldType) {
        super.init(frame: .zero)
        setupView(type: type)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func email(isRight: Bool) {
        bottomLineView.backgroundColor = isRight ? UIColor(hex: "#F4FFF5") : UIColor(hex: "#DF0404")
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
            make.trailing.equalToSuperview().inset(8)
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
        returnPressed?()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        textFieldEndEditing?()
    }
}

enum SignUpViewTextfieldType {
    case email
    case password
    
    func getPlaceholder() -> String {
        switch self {
        case .email:
            return R.string.localizable.email()
        case .password:
            return R.string.localizable.password()
        }
    }
    
    func isSecured() -> Bool {
        switch self {
        case .email:
            return false
        case .password:
            return true
        }
    }
}
