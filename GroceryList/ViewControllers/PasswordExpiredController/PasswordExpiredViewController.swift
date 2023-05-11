//
//  PasswordExpiredViewController.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 14.02.2023.
//

import UIKit

class PasswordExpiredViewController: UIViewController {
    
    var viewModel: PasswordExpiredViewModel?
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        let attrTitle = NSAttributedString(
            string: R.string.localizable.preferencies(),
            attributes: [
                .font: UIFont.SFProRounded.semibold(size: 17).font ?? .systemFont(ofSize: 15),
                .foregroundColor: R.color.primaryDark() ?? UIColor(hex: "#045C5C")
            ]
        )
        button.imageEdgeInsets.left = -17
        button.setImage(R.image.greenArrowBack(), for: .normal)
        button.tintColor = R.color.primaryDark()
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
    
    private let textContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    private let linkInactiveLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProDisplay.medium(size: 20).font
        label.textColor = R.color.darkGray()
        label.text = R.string.localizable.resetPasswordLinkInactive()
        label.numberOfLines = 8
        return label
    }()
    
    private lazy var resetButton: UIButton = {
        let button = UIButton()
        let attributedTitle = NSAttributedString(string: R.string.localizable.resetPassword(),
                                                 attributes: [
                                                    .font: UIFont.SFProRounded.semibold(size: 18).font ?? UIFont(),
                                                    .foregroundColor: UIColor(hex: "#FFFFFF")
                                                 ])
        button.addTarget(self, action: #selector(resetButtonPressed), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.backgroundColor = UIColor(hex: "#19645A")
        button.layer.cornerRadius = 16
        button.layer.cornerCurve = .continuous
        button.layer.masksToBounds = true
        button.addShadowForView(radius: 5)
        return button
    }()
    
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
        view.addSubviews([backButton, enterNewPasswordLabel, textContainerView, resetButton])
        textContainerView.addSubview(linkInactiveLabel)
        
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.left.equalToSuperview().inset(35)
        }
        
        enterNewPasswordLabel.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).inset(-24)
            make.left.equalToSuperview().inset(20)
        }
        
        textContainerView.snp.makeConstraints { make in
            make.top.equalTo(enterNewPasswordLabel.snp.bottom).inset(-40)
            make.left.right.equalToSuperview().inset(20)
        }
        
        linkInactiveLabel.snp.makeConstraints { make in
            make.left.top.right.bottom.equalToSuperview().inset(8)
        }
        
        resetButton.snp.makeConstraints { make in
            make.top.equalTo(textContainerView.snp.bottom).inset(-24)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(63)
        }
    }
    
    // MARK: - Actions
    @objc
    private func backButtonPressed() {
        viewModel?.backButtonPressed()
    }
    
    @objc
    private func resetButtonPressed() {
        viewModel?.resetButtonPressed()
    }
}

extension PasswordExpiredViewController: PasswordExpiredViewModelDelegate {

}
