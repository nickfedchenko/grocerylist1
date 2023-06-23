//
//  MainNavigationView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 22.05.2023.
//

import Kingfisher
import UIKit

protocol MainNavigationViewDelegate: AnyObject {
    func searchButtonTapped()
    func settingsTapped()
    func contextMenuTapped()
    func sortCollectionTapped()
}

final class MainNavigationView: UIView {

    weak var delegate: MainNavigationViewDelegate?
    
    private lazy var settingsButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(R.image.profile_icon(), for: .normal)
        button.addTarget(self, action: #selector(settingsButtonAction), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        button.layer.cornerRadius = 16
        button.layer.cornerCurve = .continuous
        return button
    }()
    
    private lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "#617774")
        label.font = UIFont.SFProRounded.semibold(size: 17).font
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()
    
    private lazy var searchButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(searchButtonAction), for: .touchUpInside)
        button.setImage(R.image.searchButtonImage(), for: .normal)
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
    
    private lazy var profileView: UIView = {
        let view = UIView()
        let tapOnView = UITapGestureRecognizer(target: self, action: #selector(settingsButtonAction))
        view.addGestureRecognizer(tapOnView)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with mode: TabBarItemView.Item, animate: Bool = true) {
        sortButton.snp.updateConstraints {
            $0.width.height.equalTo(mode == .recipe ? 40 : 0)
        }
        menuButton.snp.updateConstraints {
            $0.width.height.equalTo(mode == .recipe ? 40 : 0)
        }
        searchButton.snp.updateConstraints {
            $0.width.height.equalTo(mode == .pantry ? 0 : 40)
        }
        
        if animate {
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.layoutIfNeeded()
            }
        }
    }
    
    func setupName(name: String?) {
        userNameLabel.text = name
    }
    
    func setupImage(photo: String?, photoAsData: Data?) {
        settingsButton.clipsToBounds = UserAccountManager.shared.getUser() != nil
        
        if UserAccountManager.shared.getUser() == nil {
            userNameLabel.text = ""
            settingsButton.setImage(R.image.profile_noreg(), for: .normal)
            return
        }
        
        if let photoAsData {
            settingsButton.setImage(UIImage(data: photoAsData), for: .normal)
            return
        }
        
        guard let userAvatarUrl = photo,
              let url = URL(string: userAvatarUrl) else {
            return settingsButton.setImage(R.image.profile_icon(), for: .normal)
        }
        
        KingfisherManager.shared.retrieveImage(with: url, options: nil, progressBlock: nil,
                                               completionHandler: { result in
            switch result {
            case .success(let image):
                print(image)
                self.settingsButton.setImage(image.image, for: .normal)
            case .failure: break
            }
        })
    }
    
    @objc
    private func searchButtonAction() {
        delegate?.searchButtonTapped()
    }
    
    @objc
    private func settingsButtonAction() {
        delegate?.settingsTapped()
    }
    
    @objc
    private func menuButtonAction() {
        delegate?.contextMenuTapped()
    }
    
    @objc
    private func sortButtonAction() {
        delegate?.sortCollectionTapped()
    }
        
    private func setupConstraints() {
        self.addSubviews([profileView, searchButton, menuButton, sortButton])
        profileView.addSubviews([settingsButton, userNameLabel])
        
        profileView.snp.makeConstraints {
            $0.leading.equalTo(24)
            $0.trailing.lessThanOrEqualTo(menuButton.snp.leading).offset(-10)
            $0.bottom.top.equalToSuperview()
        }
        
        settingsButton.snp.makeConstraints {
            $0.leading.equalTo(4)
            $0.top.equalToSuperview()
            $0.width.height.equalTo(32)
        }
        
        userNameLabel.snp.makeConstraints {
            $0.leading.equalTo(settingsButton.snp.trailing).offset(10)
            $0.trailing.equalToSuperview()
            $0.centerY.equalTo(settingsButton)
            $0.height.equalTo(24)
        }
        
        searchButton.snp.makeConstraints {
            $0.trailing.equalTo(sortButton.snp.leading).inset(-8)
            $0.centerY.equalTo(settingsButton)
            $0.width.height.equalTo(40)
        }
        
        menuButton.snp.makeConstraints {
            $0.trailing.equalTo(searchButton.snp.leading).inset(-8)
            $0.centerY.equalTo(settingsButton)
            $0.width.height.equalTo(40)
        }
        
        sortButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(28)
            $0.centerY.equalTo(settingsButton)
            $0.width.height.equalTo(40)
        }
    }

}
