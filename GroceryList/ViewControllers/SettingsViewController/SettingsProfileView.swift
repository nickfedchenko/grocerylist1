//
//  SettingsProfileView.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 13.02.2023.
//

import Foundation
import UIKit

final class SettingsProfileView: UIView {
    
    var registerButtonPressed: (() -> Void)?
    
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
    
    // MARK: - LifeCycle
    
    init() {
        super.init(frame: .zero)
        setupConstraint()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - setupView and constraints

    private func setupConstraint() {
        self.addSubviews([profileTitleLabel, avatarImageView, addPhotoStickerImageView])
        addPhotoStickerImageView.addSubview(addPhotoStickerLabel)
       
        profileTitleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(20)
            make.top.equalToSuperview()
        }
        
        avatarImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(18)
            make.top.equalTo(profileTitleLabel.snp.bottom).inset(-6)
            make.width.height.equalTo(71)
            make.bottom.equalToSuperview()
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
    }
    
    @objc
    private func nextButtonPressed() {
        registerButtonPressed?()
    }
    
}
