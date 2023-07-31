//
//  SharingPopUpViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 16.02.2023.
//

import UIKit

final class SharingPopUpViewController: UIViewController {
    
    weak var router: RootRouter?
    var registerComp: (() -> Void)?
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#F3FFFE")
        view.layer.cornerRadius = 14
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "RegistrationRequired".localized
        label.font = UIFont.SFPro.regular(size: 17).font
        label.textColor = UIColor(hex: "#023B46")
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("REGISTER".localized.capitalized, for: .normal)
        button.titleLabel?.font = UIFont.SFProRounded.semibold(size: 18).font
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = R.color.primaryDark()
        button.layer.cornerRadius = 8
        button.addDefaultShadowForPopUp()
        button.addTarget(self, action: #selector(registerButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel".localized, for: .normal)
        button.titleLabel?.font = UIFont.SFProRounded.semibold(size: 17).font
        button.setTitleColor(R.color.primaryDark(), for: .normal)
        button.addTarget(self, action: #selector(cancelButtonPressed), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        self.view.backgroundColor = .black.withAlphaComponent(0.2)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(cancelButtonPressed))
        self.view.addGestureRecognizer(tapRecognizer)
        
        makeConstraints()
    }
    
    @objc
    private func registerButtonPressed() {
        self.dismiss(animated: true) {
            self.registerComp?()
            self.router?.goToSettingsController(animated: false)
            self.router?.goToSignUpController()
        }
    }
    
    @objc
    private func cancelButtonPressed() {
        self.dismiss(animated: true)
    }
    
    private func makeConstraints() {
        self.view.addSubview(contentView)
        contentView.addSubviews([titleLabel, registerButton, cancelButton])
        
        contentView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(72)
            $0.center.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(24)
            $0.bottom.equalTo(registerButton.snp.top).offset(-24)
        }
        
        registerButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(48)
            $0.bottom.equalTo(cancelButton.snp.top).offset(-18)
        }
        
        cancelButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(40)
            $0.bottom.equalToSuperview().offset(-9)
        }
    }
}
