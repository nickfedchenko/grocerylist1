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
        label.textColor = R.color.primaryDark()
        label.font = UIFont.SFProRounded.semibold(size: 18).font
        return label
    }()
    
    private lazy var searchButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(searchButtonAction), for: .touchUpInside)
        button.setImage(R.image.searchButtonImage(), for: .normal)
        return button
    }()
    
    private lazy var profileView: UIView = {
        let view = UIView()
        let tapOnView = UITapGestureRecognizer(target: self, action: #selector(settingsButtonAction))
        view.addGestureRecognizer(tapOnView)
        return view
    }()
    
    private var gearIconImageView = UIImageView(image: R.image.setting_icon_gear())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
//        updateImageChangeViewButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with mode: TabBarItemView.Item, animate: Bool = true) {
//        recipeEditCollectionButton.snp.updateConstraints {
//            $0.width.height.equalTo(mode == .recipe ? 40 : 0)
//        }
//
//        recipeChangeViewButton.snp.updateConstraints {
//            $0.width.height.equalTo(mode == .recipe ? 40 : 0)
//        }
        
        searchButton.snp.updateConstraints {
            $0.width.height.equalTo(mode == .list ? 40 : 0)
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
        
    private func setupConstraints() {
        self.addSubviews([profileView, searchButton]) //,
//                          recipeChangeViewButton, recipeEditCollectionButton])
        profileView.addSubviews([settingsButton, userNameLabel, gearIconImageView])

        profileView.snp.makeConstraints {
            $0.leading.equalTo(24)
            $0.trailing.lessThanOrEqualToSuperview().offset(-128)
            $0.bottom.top.equalToSuperview()
        }
        
        settingsButton.snp.makeConstraints {
            $0.leading.equalTo(4)
            $0.top.equalToSuperview()
            $0.width.height.equalTo(32)
        }
        
        gearIconImageView.snp.makeConstraints {
            $0.leading.equalTo(settingsButton).offset(-4)
            $0.bottom.equalTo(settingsButton).offset(4)
            $0.width.height.equalTo(14)
        }
        
        userNameLabel.snp.makeConstraints {
            $0.leading.equalTo(settingsButton.snp.trailing).offset(10)
            $0.trailing.equalToSuperview()
            $0.centerY.equalTo(settingsButton)
//            $0.height.equalTo(24)
        }
        
        searchButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-19)
            $0.centerY.equalTo(settingsButton)
            $0.width.height.equalTo(40)
        }
        
//        recipeChangeViewButton.snp.makeConstraints {
//            $0.trailing.equalTo(recipeEditCollectionButton.snp.leading).inset(-8)
//            $0.centerY.equalTo(settingsButton)
//            $0.width.height.equalTo(40)
//        }
//
//        recipeEditCollectionButton.snp.makeConstraints {
//            $0.trailing.equalToSuperview().inset(28)
//            $0.centerY.equalTo(settingsButton)
//            $0.width.height.equalTo(40)
//        }
    }

}
