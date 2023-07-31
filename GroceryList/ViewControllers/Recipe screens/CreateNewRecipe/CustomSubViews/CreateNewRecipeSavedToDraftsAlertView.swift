//
//  CreateNewRecipeSavedToDraftsAlertView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 28.06.2023.
//

import UIKit

class CreateNewRecipeSavedToDraftsAlertView: UIView {

    var leaveCreatingRecipeTapped: (() -> Void)?
    var continueWorkTapped: (() -> Void)?

    private lazy var contentView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 14
        view.layer.cornerCurve = .continuous
        view.backgroundColor = .white
        view.addDefaultShadowForPopUp()
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = R.string.localizable.savedInDrafts()
        label.textAlignment = .center
        label.font = UIFont.SFProRounded.bold(size: 22).font
        label.textColor = R.color.primaryDark()
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = R.string.localizable.youCanFindYourDrafts()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.SFPro.semibold(size: 16).font
        label.textColor = .black
        return label
    }()
    
    private lazy var leaveCreatingRecipeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = R.color.primaryDark()
        button.addTarget(self, action: #selector(leaveCreatingRecipeButtonTapped), for: .touchUpInside)
        button.setTitle(R.string.localizable.leaveCreatingARecipe(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.SFProRounded.semibold(size: 18).font
        button.layer.cornerRadius = 8
        return button
    }()
    
    private lazy var continueWorkButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(continueWorkButtonTapped), for: .touchUpInside)
        button.setTitle(R.string.localizable.continueWork(), for: .normal)
        button.setTitleColor(R.color.primaryDark(), for: .normal)
        button.titleLabel?.font = UIFont.SFProRounded.semibold(size: 18).font
        button.layer.cornerRadius = 8
        button.layer.borderColor = R.color.primaryDark()?.cgColor
        button.layer.borderWidth = 2
        return button
    }()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setup() {
        self.backgroundColor = .black.withAlphaComponent(0.2)
        
        makeConstraints()
    }
    
    @objc
    private func leaveCreatingRecipeButtonTapped() {
        leaveCreatingRecipeTapped?()
    }
    
    @objc
    private func continueWorkButtonTapped() {
        continueWorkTapped?()
    }
    
    private func makeConstraints() {
        self.addSubview(contentView)
        contentView.addSubviews([titleLabel, descriptionLabel, leaveCreatingRecipeButton, continueWorkButton])
        
        contentView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(99)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(315)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
        }
        
        leaveCreatingRecipeButton.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(24)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        continueWorkButton.snp.makeConstraints {
            $0.top.equalTo(leaveCreatingRecipeButton.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(24)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview().offset(-38)
        }
    }
    
}
