//
//  AccountViewController.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 14.02.2023.
//

import UIKit

class AccountViewController: UIViewController {
    
    var viewModel: AccountViewModel?
    
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
    
    private let logOutViewButton: SettingsParametrView = {
        let view = SettingsParametrView()
        view.setupView(text: R.string.localizable.settingsAccountLogOut(),
                       isAttrHidden: true,
                       titleColor: UIColor(hex: "#19645A"))
        return view
    }()
    
    private let deleteAccountViewButton: SettingsParametrView = {
        let view = SettingsParametrView()
        view.setupView(text: R.string.localizable.settingsAccountDeleteAccount(),
                       isAttrHidden: true,
                       titleColor: UIColor(hex: "#DF0404"))
        return view
    }()
    
    private lazy var logOutView: LogOutView = {
        let view = LogOutView()
        view.logOutPressed = { [weak self] in
            self?.viewModel?.logOutInPopupPressed()
        }
        
        view.cancelPressed = { [weak self] in
            self?.logOutView.hideView()
        }
        
        return view
    }()
    
    private lazy var deleteAccountView: DeleteAccountView = {
        let view = DeleteAccountView()
        view.deletePressed = { [weak self] in
            self?.viewModel?.deleteInPopupPressed()
        }
        
        view.cancelPressed = { [weak self] in
            self?.deleteAccountView.hideView()
        }
        
        return view
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        addRecognizers()
    }
    
    deinit {
        print("AccountViewController deinied")
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        view.backgroundColor = .backgroundColor
        view.addSubviews([backButton, logOutViewButton, deleteAccountViewButton, logOutView, deleteAccountView])
        
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.left.equalToSuperview().inset(35)
        }
        
        logOutViewButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(backButton.snp.bottom).inset(-30)
            make.height.equalTo(54)
        }
        
        deleteAccountViewButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(logOutViewButton.snp.bottom)
            make.height.equalTo(54)
        }
        
        logOutView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        deleteAccountView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - Recognizers
    private func addRecognizers() {
        let logOutRecognizer = UITapGestureRecognizer(target: self, action: #selector(logOutAction))
        let deleteAccountRecognizer = UITapGestureRecognizer(target: self, action: #selector(deleteAccountAction))
        logOutViewButton.addGestureRecognizer(logOutRecognizer)
        deleteAccountViewButton.addGestureRecognizer(deleteAccountRecognizer)
    }
    
        // MARK: - Actions
    @objc
    private func backButtonPressed() {
        viewModel?.backButtonPressed()
    }
    
    @objc
    private func logOutAction() {
        viewModel?.logOutPressed()
    }
    
    @objc
    private func deleteAccountAction() {
        viewModel?.deleteAccountPressed()
    }
    
}

extension AccountViewController: AccountViewModelDelegate {
    func showDeleteAccount() {
        deleteAccountView.showView()
    }
    
    func showLogOut() {
        logOutView.showView()
    }
}
