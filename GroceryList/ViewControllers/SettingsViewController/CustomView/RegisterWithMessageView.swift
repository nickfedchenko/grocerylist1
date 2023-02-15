//
//  RegisterWithMessageView.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 08.02.2023.
//

import Foundation
import UIKit

final class RegisterWithMessageView: UIView {
    
    var registerButtonPressed: (() -> Void)?
    
    private lazy var nextButton: UIButton = {
        let button = UIButton()
        let attributedTitle = NSAttributedString(string: R.string.localizable.registeR(), attributes: [
            .font: UIFont.SFPro.semibold(size: 20).font ?? UIFont(),
            .foregroundColor: UIColor(hex: "#FFFFFF")
        ])
        button.addTarget(self, action: #selector(nextButtonPressed), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.backgroundColor = UIColor(hex: "#31635A")
        button.layer.cornerRadius = 16
        button.layer.cornerCurve = .continuous
        button.layer.masksToBounds = true
        button.addShadowForView(radius: 5)
        return button
    }()
    
    private let viewUnderRegistrationButton: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = R.image.viewUnderRegisterButton()
        imageView.addShadowForView(radius: 5)
        return imageView
    }()
    
    private let orangeCircle: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = R.image.orangeCircle()
        return imageView
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 15).font
        label.textColor = .black
        label.text = R.string.localizable.registrationRequired()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - LifeCycle
    
    init() {
        super.init(frame: .zero)
        setupConstraint()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Constraints
    private func setupConstraint() {
        self.addSubviews([nextButton, viewUnderRegistrationButton, orangeCircle])
        viewUnderRegistrationButton.addSubview(textLabel)
        
        nextButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(64)
        }
        
        viewUnderRegistrationButton.snp.makeConstraints { make in
            make.bottom.equalTo(nextButton.snp.top).inset(-8)
            make.centerX.equalToSuperview()
            make.width.equalTo(240)
            make.height.equalTo(91)
            make.top.equalToSuperview()
        }
        
        orangeCircle.snp.makeConstraints { make in
            make.centerY.equalTo(viewUnderRegistrationButton.snp.top)
            make.centerX.equalTo(viewUnderRegistrationButton.snp.right)
            make.width.height.equalTo(16)
        }
        
        textLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-10)
            make.left.right.equalToSuperview().inset(17)
        }
    }
    
    @objc
    private func nextButtonPressed() {
        registerButtonPressed?()
    }
    
}
