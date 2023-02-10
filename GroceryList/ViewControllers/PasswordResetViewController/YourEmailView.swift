//
//  YourEmailView.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 10.02.2023.
//

import Foundation
import UIKit

final class YourEmailView: UIView {
    
    var registerButtonPressed: (() -> Void)?
    
    private let emailTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 16).font
        label.textColor = UIColor(hex: "#617774")
        label.text = R.string.localizable.yourEmail()
        return label
    }()
    
    private var textFieldContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.cornerCurve = .continuous
        view.layer.borderColor = UIColor(hex: "#19645A").cgColor
        view.layer.borderWidth = 1
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var textfield: UITextField = {
        let textfield = UITextField()
        textfield.font = UIFont.SFPro.medium(size: 16).font
        textfield.textColor = .black
        textfield.textAlignment = .left
        textfield.keyboardAppearance = .light
        textfield.autocorrectionType = .no
        textfield.spellCheckingType = .no
        textfield.paddingLeft(inset: 10)
        textfield.becomeFirstResponder()
        return textfield
    }()
    
    // MARK: - LifeCycle
    
    init() {
        super.init(frame: .zero)
        setupConstraint()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func resignTextFieldFirstResponder() {
        textfield.resignFirstResponder()
    }
    
    func setupEmailTextField(text: String) {
        textfield.text = text
    }
    
    func getTextfieldText() -> String {
        textfield.text ?? ""
    }
    
    // MARK: - setupView and constraints

    private func setupConstraint() {
        self.addSubviews([emailTitleLabel, textFieldContainer])
       textFieldContainer.addSubview(textfield)
       
        snp.makeConstraints { make in
            make.height.equalTo(96)
        }
        
        textfield.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        textFieldContainer.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(12)
            make.height.equalTo(49)
            make.left.right.equalToSuperview().inset(20)
        }
      
        emailTitleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(20)
            make.bottom.equalTo(textFieldContainer.snp.top).inset(-6)
        }
    }
    
    @objc
    private func nextButtonPressed() {
        registerButtonPressed?()
    }
    
}
