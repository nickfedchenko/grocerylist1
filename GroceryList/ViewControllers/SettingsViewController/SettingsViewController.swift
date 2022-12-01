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
    
    // MARK: - UI
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#E8F5F3")
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    private let topView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#E8F5F3")
        return view
    }()
    
    private let createListLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 17).font
        label.textColor = UIColor(hex: "#31635A")
        label.text = "PickItem".localized
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
       // button.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
        button.setImage(UIImage(named: "closeButtonCross"), for: .normal)
        return button
    }()
    
    private func setupConstraints() {
        view.backgroundColor = .black
        view.addSubviews([])
    }
}

extension SettingsViewController {
    
    private func addRecognizer() {
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(swipeDownAction(_:)))
        contentView.addGestureRecognizer(panRecognizer)
    }
    
    @objc
    private func swipeDownAction(_ recognizer: UIPanGestureRecognizer) {
    
    }
}

extension SettingsViewController: SettingsViewModelDelegate {
    
}
