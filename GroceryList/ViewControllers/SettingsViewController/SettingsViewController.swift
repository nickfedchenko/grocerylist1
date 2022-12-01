//
//  SettingsViewController.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 01.12.2022.
//

import SnapKit
import UIKit

class SettingsViewController: UIViewController {
    
    var viewModel: SettingsViewModel?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        addRecognizer()
    }
    
    deinit {
        print("SettingsViewController deinited")
    }
    
    @objc
    private func closeButtonAction(_ recognizer: UIPanGestureRecognizer) {
        viewModel?.closeButtonTapped()
    }
    
    // MARK: - UI
    
    private let topView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#E8F5F3")
        return view
    }()
    
    private let preferenciesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.bold(size: 22).font
        label.textColor = UIColor(hex: "#31635A")
        label.text = "preferencies".localized
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
        button.setImage(UIImage(named: "greenCross"), for: .normal)
        return button
    }()
    
    private let unitsView: SettingsParametrView = {
        let view = SettingsParametrView()
        view.setupView(text: "Quantity Units".localized, unitSustemText: "fe")
        return view
    }()
    
    private let hapticView: SettingsParametrView = {
        let view = SettingsParametrView()
        view.setupView(text: "Haptic Feedback".localized, isHaptickView: true)
        return view
    }()
    
    private let likeAppView: SettingsParametrView = {
        let view = SettingsParametrView()
        view.setupView(text: "DoYouLikeApp?".localized)
        return view
    }()
    
    private let contactUsView: SettingsParametrView = {
        let view = SettingsParametrView()
        view.setupView(text: "Problems?".localized)
        return view
    }()
    
    private func setupConstraints() {
        view.backgroundColor = UIColor(hex: "#E8F5F3")
        view.addSubviews([preferenciesLabel, closeButton, unitsView, hapticView, likeAppView, contactUsView, contactUsView])
        
        preferenciesLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(20)
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).inset(20)
        }
        
        closeButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(31)
            make.centerY.equalTo(preferenciesLabel)
            make.height.width.equalTo(18)
        }
        
        unitsView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(preferenciesLabel.snp.bottom).inset(-42)
            make.height.equalTo(54)
        }
        
        hapticView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(unitsView.snp.bottom)
            make.height.equalTo(54)
        }
        
        likeAppView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(hapticView.snp.bottom)
            make.height.equalTo(54)
        }
        
        contactUsView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(likeAppView.snp.bottom)
            make.height.equalTo(54)
        }
    }
}

extension SettingsViewController {
    
    private func addRecognizer() {
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(swipeDownAction(_:)))
      //  contentView.addGestureRecognizer(panRecognizer)
    }
    
    @objc
    private func swipeDownAction(_ recognizer: UIPanGestureRecognizer) {
    
    }
}

extension SettingsViewController: SettingsViewModelDelegate {
    
}
