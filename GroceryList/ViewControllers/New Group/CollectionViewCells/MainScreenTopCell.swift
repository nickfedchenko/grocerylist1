//
//  MainScreenTopCell.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 08.11.2022.
//

import SnapKit
import UIKit

class MainScreenTopCell: UICollectionViewCell {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func searchButtonAction() {
        
    }
    
    private let avatarImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "profileImage")
        return imageView
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 18).font
        label.textColor = UIColor(hex: "#31635A")
        label.text = "Unnamed"
        return label
    }()
    
    private lazy var searchButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(searchButtonAction), for: .touchUpInside)
        button.setImage(UIImage(named: "searchButtonImage"), for: .normal)
        return button
    }()
    
    private let segmentControl: UISegmentedControl = {
        let control = CustomSegmentedControl(items: ["Grocery Lists".localized, "Recipes".localized])
        control.setTitleFont(UIFont.SFPro.bold(size: 18).font)
        control.setTitleColor(UIColor(hex: "#657674"))
        control.setTitleColor(UIColor(hex: "#31635A"), state: .selected)
        control.selectedSegmentIndex = 0
        control.backgroundColor = UIColor(hex: "#D2E7E4")
        control.selectedSegmentTintColor = .white
        return control
    }()
    
    // MARK: - UI
    private func setupConstraints() {
        contentView.addSubviews([avatarImage, userNameLabel, searchButton, segmentControl])
        avatarImage.snp.makeConstraints { make in
            make.width.height.equalTo(32)
            make.left.equalTo(22)
            make.top.equalToSuperview().inset(-20)
        }
        
        userNameLabel.snp.makeConstraints { make in
            make.left.equalTo(avatarImage.snp.right).inset(-10)
            make.centerY.equalTo(avatarImage)
        }
        
        searchButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(22)
            make.centerY.equalTo(avatarImage)
            make.width.height.equalTo(40)
        }
        
        segmentControl.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(22)
            make.top.equalTo(avatarImage.snp.bottom).inset(-16)
            make.height.equalTo(48)
        }
        
    }
}
