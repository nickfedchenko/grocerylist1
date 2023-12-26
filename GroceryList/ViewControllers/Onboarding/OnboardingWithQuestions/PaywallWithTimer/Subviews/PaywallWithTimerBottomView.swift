//
//  PaywallWithTimerBottomView.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 26.12.2023.
//

import Foundation
import UIKit

final class PaywallWithTimerBottomView: UIView {
    
    var continueButtonCallback: (() -> Void)?
    var privacyButtonCallback: (() -> Void)?
    var termsButtonCallback: (() -> Void)?
    
    private var cancelLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "#FFFFFF").withAlphaComponent(0.4)
        label.font = UIFont.SFPro.regular(size: 15).font
        label.text = R.string.localizable.onboardingWithQuestionsCancelAnyTime()
        label.textAlignment = .center
        return label
    }()
    
    private lazy var continueButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSAttributedString(string: R.string.localizable.continue().uppercased(), attributes: [
            .font: UIFont.SFPro.semibold(size: 20).font ?? UIFont(),
            .foregroundColor: UIColor(hex: "#0C5151")
        ])
        button.addTarget(self, action: #selector(continueButtonPressed), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.backgroundColor = UIColor(hex: "#6FF4E1")
        button.layer.cornerRadius = 16
        button.layer.cornerCurve = .continuous
        button.addShadowForView()
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        button.setImage(UIImage(named: "nextArrow"), for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        button.tintColor = UIColor(hex: "#0C5151")
        button.imageEdgeInsets.left = 8
        return button
    }()
    
    private lazy var privacyButton: UIButton = {
        let button = UIButton()
        button.setTitle(R.string.localizable.privacyPolicy(), for: .normal)
        button.setTitleColor(UIColor(hex: "#FFFFFF").withAlphaComponent(0.4), for: .normal)
        button.titleLabel?.font = UIFont.SFPro.semibold(size: 13).font
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.3
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.textAlignment = .left
        button.addTarget(self, action: #selector(privacyDidTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var termsButton: UIButton = {
        let button = UIButton()
        button.setTitle(R.string.localizable.termOfUse(), for: .normal)
        button.setTitleColor(UIColor(hex: "#FFFFFF").withAlphaComponent(0.4), for: .normal)
        button.titleLabel?.font = UIFont.SFPro.semibold(size: 13).font
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.3
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.textAlignment = .right
        button.addTarget(self, action: #selector(termsDidTap), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Init
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    @objc
    private func continueButtonPressed() {
        continueButtonCallback?()
    }

    @objc
    private func privacyDidTap() {
        privacyButtonCallback?()
    }
    
    @objc
    private func termsDidTap() {
        termsButtonCallback?()
    }
}

extension PaywallWithTimerBottomView {
    // MARK: - SetupView
    private func setupView() {
        addSubview()
        setupConstraint()
    }
    
    private func addSubview() {
        addSubviews([
            cancelLabel,
            continueButton,
            privacyButton,
            termsButton
        ])
    }
    
    private func setupConstraint() {
        cancelLabel.snp.makeConstraints { make in
            make.bottom.equalTo(continueButton.snp.top).inset(-12)
            make.centerX.equalToSuperview()
        }
        
        continueButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(64)
            make.bottom.equalTo(privacyButton.snp.top).inset(-16)
            make.top.equalToSuperview()
        }
        
        privacyButton.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(20)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(14)
        }
        
        termsButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(20)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(14)
        }
    }
}
