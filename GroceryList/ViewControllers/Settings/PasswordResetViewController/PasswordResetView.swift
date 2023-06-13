//
//  PasswordResetView.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 10.02.2023.
//

import Foundation
import UIKit

final class PasswordResetView: UIView {
    
    var resetButtonPressed: ((String) -> Void)?
    var closeButtonPressed: (() -> Void)?
 
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProRounded.bold(size: 22).font
        label.textColor = UIColor(hex: "#19645A")
        label.text = R.string.localizable.passwordReset()
        label.textAlignment = .center
        return label
    }()
    
    private var emailTextfieldView = YourEmailView()
    
    private lazy var resetButton: UIButton = {
        let button = UIButton()
        button.setTitle(R.string.localizable.resetPassword(), for: .normal)
        button.titleLabel?.font = UIFont.SFPro.semibold(size: 20).font
        button.setTitleColor(UIColor(hex: "#FFFFFF"), for: .normal)
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        button.backgroundColor = UIColor(hex: "#31635A")
        button.layer.cornerRadius = 8
        button.layer.cornerCurve = .continuous
        button.layer.masksToBounds = true
        button.addShadowForView(radius: 7)
        return button
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setTitle(R.string.localizable.close(), for: .normal)
        button.titleLabel?.font = UIFont.SFPro.semibold(size: 20).font
        button.setTitleColor(R.color.darkGray(), for: .normal)
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        button.backgroundColor = .clear
        return button
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 16).font
        label.textColor = .black
        label.text = R.string.localizable.recievePasswordShortly()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    // MARK: - LifeCycle
    
    init() {
        super.init(frame: .zero)
        setupView()
        setupConstraint()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func resignTextFieldFiresResponder() {
        emailTextfieldView.resignTextFieldFirstResponder()
    }
    
    func setupTextfieldText(text: String) {
        emailTextfieldView.setupEmailTextField(text: text)
    }
    
    func applySecondState() {
        emailTextfieldView.isHidden = true
        closeButton.isHidden = true
        descriptionLabel.isHidden = false
        resetButton.setTitle(R.string.localizable.ok(), for: .normal)
    }
    
    // MARK: - setupView and constraints
    
    private func setupView() {
        self.backgroundColor = .backgroundColor
        self.layer.cornerRadius = 14
        self.layer.cornerCurve = .continuous
        self.layer.masksToBounds = true
        self.addShadowForView(radius: 7)
    }
    
    private func setupConstraint() {
        self.addSubviews([titleLabel, emailTextfieldView, resetButton, closeButton, descriptionLabel])
        
        snp.makeConstraints { make in
            make.height.equalTo(275)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.centerX.equalToSuperview()
        }
        
        emailTextfieldView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).inset(-9)
        }
        
        resetButton.snp.makeConstraints { make in
            make.top.equalTo(emailTextfieldView.snp.bottom).inset(-16)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(48)
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(resetButton.snp.bottom).inset(-5)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(48)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(emailTextfieldView)
            make.left.right.equalToSuperview().inset(20)
        }
        
    }
    
    @objc
    private func nextButtonTapped() {
        resetButtonPressed?(emailTextfieldView.getTextfieldText())
    }
    
    @objc
    private func closeButtonTapped() {
        closeButtonPressed?()
    }

}
