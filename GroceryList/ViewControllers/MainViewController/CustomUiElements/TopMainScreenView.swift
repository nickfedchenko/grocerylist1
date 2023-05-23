//
//  TopMainScreenView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 04.05.2023.
//

import Kingfisher
import UIKit

enum MainScreenPresentationMode {
    case lists, recipes
}

protocol TopMainScreenViewDelegate: AnyObject {
    func modeChanged(to mode: MainScreenPresentationMode)
    func searchButtonTapped()
    func settingsTapped()
    func contextMenuTapped()
    func sortCollectionTapped()
}

final class TopMainScreenView: UIView {
    
    weak var delegate: TopMainScreenViewDelegate?
    
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
    
    private lazy var segmentControl: CustomSegmentedControlView = {
        let control = CustomSegmentedControlView(items: [R.string.localizable.groceryLists(), R.string.localizable.recipes()])
        control.delegate = self
        control.selectedSegmentIndex = 0
        return control
    }()
    
    private lazy var blurView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "E5F5F3", alpha: 0.9)
        return view
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
    
    func configure(with mode: MainScreenPresentationMode) {
        segmentControl.selectedSegmentIndex = mode == .recipes ? 1 : 0
        
        sortButton.snp.updateConstraints {
            $0.width.height.equalTo(mode == .recipes ? 40 : 0)
        }
        menuButton.snp.updateConstraints {
            $0.width.height.equalTo(mode == .recipes ? 40 : 0)
        }
    }
    
    func isScrolledView(_ offset: CGFloat) {
        profileView.isHidden = offset > 32
        searchButton.isHidden = offset > 32
        menuButton.isHidden = offset > 32
        sortButton.isHidden = offset > 32
        
        guard offset > 0 else {
            blurView.snp.updateConstraints {
                $0.height.equalTo(0)
            }
            return
        }
        blurView.snp.updateConstraints {
            $0.height.equalTo(113)
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
    
    // MARK: - UI
    private func setupConstraints() {
        self.addSubviews([profileView, searchButton, menuButton, sortButton, blurView, segmentControl])
        profileView.addSubviews([settingsButton, userNameLabel])

        setupProfileConstraints()
        
        menuButton.snp.makeConstraints {
            $0.trailing.equalTo(searchButton.snp.leading).inset(-8)
            $0.centerY.equalTo(settingsButton)
            $0.width.height.equalTo(0)
        }
        
        sortButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(28)
            $0.centerY.equalTo(settingsButton)
            $0.width.height.equalTo(0)
        }
        
        searchButton.snp.makeConstraints {
            $0.trailing.equalTo(sortButton.snp.leading).inset(-8)
            $0.centerY.equalTo(settingsButton)
            $0.width.height.equalTo(40)
        }
        
        segmentControl.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(22)
            $0.top.equalTo(settingsButton.snp.bottom).inset(-16)
            $0.bottom.equalToSuperview().offset(-8)
            $0.height.equalTo(48)
        }
        
        blurView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview()
            $0.height.equalTo(0)
        }
    }
    
    private func setupProfileConstraints() {
        profileView.snp.makeConstraints {
            $0.leading.equalTo(24)
            $0.trailing.lessThanOrEqualTo(menuButton.snp.leading).offset(-10)
            $0.bottom.equalTo(segmentControl.snp.top).offset(-14)
            $0.height.equalTo(32)
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
    }
}

extension TopMainScreenView: CustomSegmentedControlViewDelegate {
    func segmentChanged(_ selectedSegmentIndex: Int) {
        delegate?.modeChanged(to: selectedSegmentIndex == 0 ? .lists : .recipes)
    }
}
