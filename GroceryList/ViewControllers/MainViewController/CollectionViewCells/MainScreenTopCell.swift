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
    var contextMenuTapped: (() -> Void)?
    var sortCollectionTapped: (() -> Void)?
    weak var delegate: MainScreenTopCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with mode: MainScreenPresentationMode) {
        segmentControl.selectedSegmentIndex = mode == .recipes ? 1 : 0
        sortButton.snp.updateConstraints {
            $0.width.height.equalTo(mode == .recipes ? 40 : 0)
        }
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
    
    @objc
    private func menuButtonAction() {
        contextMenuTapped?()
    }
    
    @objc
    private func sortButtonAction() {
        sortCollectionTapped?()
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
        button.setImage(R.image.searchButtonImage(), for: .normal)
        button.alpha = 0
        return button
    }()
    
    private lazy var menuButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(menuButtonAction), for: .touchUpInside)
        button.setImage(R.image.contextMenuPlus(), for: .normal)
        return button
    }()
    
    private lazy var sortButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(sortButtonAction), for: .touchUpInside)
        button.setImage(R.image.sortRecipeMenu(), for: .normal)
        return button
    }()
    
    private lazy var segmentControl: CustomSegmentedControlView = {
        let control = CustomSegmentedControlView(items: ["Grocery Lists".localized, "Recipes".localized])
        control.delegate = self
        control.selectedSegmentIndex = 0
        return control
    }()
    
    // MARK: - UI
    private func setupConstraints() {
        contentView.addSubviews([settingsButton, userNameLabel, searchButton,
                                 menuButton, sortButton, segmentControl])
        settingsButton.snp.makeConstraints { make in
            make.width.height.equalTo(32)
            make.left.equalTo(28)
            make.top.equalToSuperview()
        }
        
        userNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(settingsButton.snp.trailing).offset(10)
            make.centerY.equalTo(settingsButton)
            make.height.equalTo(24)
            make.trailing.equalTo(menuButton.snp.leading).offset(-10)
        }
        
        menuButton.snp.makeConstraints { make in
            make.trailing.equalTo(sortButton.snp.leading).inset(-8)
            make.centerY.equalTo(settingsButton)
            make.width.height.equalTo(40)
        }
        
        sortButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(28)
            make.centerY.equalTo(settingsButton)
            make.width.height.equalTo(0)
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
}

extension MainScreenTopCell: CustomSegmentedControlViewDelegate {
    func segmentChanged(_ selectedSegmentIndex: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.segmentControl.selectedSegmentIndex = selectedSegmentIndex == 1 ? 0 : 1
        }
        delegate?.modeChanged(to: selectedSegmentIndex == 0 ? .lists : .recipes)
        sortButton.snp.updateConstraints {
            $0.width.height.equalTo(selectedSegmentIndex == 0 ? 40 : 0)
        }
    }
}
