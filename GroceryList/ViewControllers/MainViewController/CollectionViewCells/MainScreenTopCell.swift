//
//  MainScreenTopCell.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 08.11.2022.
//

import SnapKit
import UIKit

enum MainScreenPresentationMode {
    case lists, recipes
}

protocol MainScreenTopCellDelegate: AnyObject {
    func modeChanged(to mode: MainScreenPresentationMode)
}

class MainScreenTopCell: UICollectionViewCell {
    
    var settingsTapped: (() -> Void)?
    weak var delegate: MainScreenTopCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with mode: MainScreenPresentationMode) {
        segmentControl.selectedSegmentIndex = mode == .recipes ? 1 : 0
    }
    
    func setupUser(photo: UIImage?, name: String?) {
        settingsButton.setImage(photo, for: .normal)
        userNameLabel.text = name
        
        settingsButton.clipsToBounds = UserAccountManager.shared.getUser() != nil
    }
    
    @objc
    private func searchButtonAction() {
        print("search button pressed")
    }
    
    @objc
    private func settingsButtonAction() {
        settingsTapped?()
    }
    
    private lazy var settingsButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(settingsButtonAction), for: .touchUpInside)
        button.setImage(R.image.profile_icon(), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.layer.cornerRadius = 16
        return button
    }()
    
    private lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "#1A645A")
        label.font = UIFont.SFProRounded.semibold(size: 18).font
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    private lazy var searchButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(searchButtonAction), for: .touchUpInside)
        button.setImage(UIImage(named: "searchButtonImage"), for: .normal)
        button.alpha = 0
        return button
    }()
    
    private let segmentControl: UISegmentedControl = {
        let control = CustomSegmentedControl(items: ["Grocery Lists".localized, "Recipes".localized])
        control.setTitleFont(UIFont.SFProRounded.bold(size: 18).font)
        control.setTitleColor(UIColor(hex: "#657674"))
        control.setTitleColor(UIColor(hex: "#31635A"), state: .selected)
        control.selectedSegmentIndex = 0
        control.backgroundColor = UIColor(hex: "#D2E7E4")
        control.selectedSegmentTintColor = .white
        return control
    }()
    
    private func setupActions() {
        segmentControl.addTarget(self, action: #selector(segmentChanged(sender:)), for: .valueChanged)
    }
    
    // MARK: - UI
    private func setupConstraints() {
        contentView.addSubviews([settingsButton, userNameLabel, searchButton, segmentControl])
        settingsButton.snp.makeConstraints { make in
            make.width.height.equalTo(32)
            make.left.equalTo(28)
            make.top.equalToSuperview()
        }
        
        userNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(settingsButton.snp.trailing).offset(10)
            make.centerY.equalTo(settingsButton)
            make.height.equalTo(24)
            make.trailing.equalTo(searchButton.snp.leading).offset(-10)
        }
        
        searchButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(28)
            make.centerY.equalTo(settingsButton)
            make.width.height.equalTo(40)
        }
        
        segmentControl.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(22)
            make.top.equalTo(settingsButton.snp.bottom).inset(-16)
            make.height.equalTo(48)
            
        }
        
    }
    
    @objc
    private func segmentChanged(sender: UISegmentedControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if sender.selectedSegmentIndex == 1 {
                sender.selectedSegmentIndex = 0
            } else {
                sender.selectedSegmentIndex = 1
            }
        }
        delegate?.modeChanged(to: sender.selectedSegmentIndex == 0 ? .lists : .recipes)
    }
}
