//
//  SettingsProfileView.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 13.02.2023.
//

import Foundation
import UIKit

final class SettingsProfileView: UIView {
    
    var accountButtonPressed: (() -> Void)?
    var avatarButtonPressed: (() -> Void)?
    var saveNewNamePressed: ((String) -> Void)?
    
    private var userName: String?
    
    private let profileTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProRounded.bold(size: 18).font
        label.textColor = UIColor(hex: "#19645A")
        label.text = R.string.localizable.settingsProfile()
        return label
    }()
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = R.image.settingsEmptyAvatar()
        imageView.isUserInteractionEnabled = true
        imageView.layer.cornerRadius = 36
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let addPhotoStickerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = R.image.settingsAddPhotoSticker()
        return imageView
    }()
    
    private let addPhotoStickerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 15).font
        label.textColor = .black
        label.text = R.string.localizable.settingsAddPhoto()
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var screenNameTextFieldView: SignUpViewForTyping = {
        let view = SignUpViewForTyping(type: .screenName)
       
        view.textFieldReturnPressed = { [weak self] _ in
            self?.screenNameTextFieldView.resignTextfieldFirstResponder()
            self?.saveUserName()
        }
       
        view.isFieldCorrect = { [weak self] _, text in
            self?.userName = text
        }
        return view
    }()
    
    private let emailView: SettingsParametrView = {
        let view = SettingsParametrView()
        view.setupView(text: "SDsdsf@yandex.ru", isAttrHidden: true)
        return view
    }()
    
    private let accountView: SettingsParametrView = {
        let view = SettingsParametrView()
        view.setupView(text: R.string.localizable.settingsAccount())
        return view
    }()
    
    private let groceryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProRounded.bold(size: 18).font
        label.textColor = UIColor(hex: "#19645A")
        label.text = R.string.localizable.settingsGroceryListApp()
        return label
    }()
    
    // MARK: - LifeCycle
    
    init() {
        super.init(frame: .zero)
        setupConstraint()
        addRecognizers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView(avatarImage: UIImage?, email: String) {
        emailView.setupView(text: email, isAttrHidden: true)
        setupImage(avatarImage: avatarImage)
    }
    
    func setupImage(avatarImage: UIImage?) {
        guard let avatarImage = avatarImage else { return }
        addPhotoStickerImageView.isHidden = true
        avatarImageView.image = avatarImage
    }
    
    // MARK: - setupView and constraints

    private func setupConstraint() {
        self.addSubviews([profileTitleLabel, avatarImageView, addPhotoStickerImageView,
                          screenNameTextFieldView, emailView, accountView, groceryLabel])
        addPhotoStickerImageView.addSubview(addPhotoStickerLabel)
       
        profileTitleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(20)
            make.top.equalToSuperview()
        }
        
        avatarImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(18)
            make.top.equalTo(profileTitleLabel.snp.bottom).inset(-6)
            make.width.height.equalTo(72)
        }
        
        addPhotoStickerImageView.snp.makeConstraints { make in
            make.centerY.equalTo(avatarImageView)
            make.left.equalTo(avatarImageView.snp.right).inset(-5)
            make.height.equalTo(54)
            make.width.equalTo(233)
        }
        
        addPhotoStickerLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(22)
            make.top.right.bottom.equalToSuperview().inset(8)
        }
        
        screenNameTextFieldView.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).inset(-5)
            make.left.right.equalToSuperview().inset(20)

        }
        
        emailView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(screenNameTextFieldView.snp.bottom)
            make.height.equalTo(54)
        }
        
        accountView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(emailView.snp.bottom)
            make.height.equalTo(54)
        }
        
        groceryLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(20)
            make.top.equalTo(accountView.snp.bottom).inset(-32)
            make.bottom.equalToSuperview()
        }
    }
    
    private func addRecognizers() {
        let accountPressedRecognizer = UITapGestureRecognizer(target: self, action: #selector(accountPressedAction))
        let avatarPressedRecognizer = UITapGestureRecognizer(target: self, action: #selector(avatarPressedAction))
        accountView.addGestureRecognizer(accountPressedRecognizer)
        avatarImageView.addGestureRecognizer(avatarPressedRecognizer)
    }
    
    @objc
    private func accountPressedAction() {
        accountButtonPressed?()
    }
    
    @objc
    private func avatarPressedAction() {
        avatarButtonPressed?()
    }
    
    private func saveUserName() {
        guard let userName = userName else { return }
        saveNewNamePressed?(userName)
    }
    
}
