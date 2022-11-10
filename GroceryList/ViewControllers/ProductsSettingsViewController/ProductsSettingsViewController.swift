//
//  ProductsSettingsViewController.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 10.11.2022.
//

import SnapKit
import UIKit

class ProductsSettingsViewController: UIViewController {
    
    var viewModel: ProductsSettingsViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        addRecognizers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showPanel()
    }
    
    deinit {
        print("Products settings deinited")
    }
    
    // MARK: - close vc
    @objc
    private func doneButtonPressed() {
        hidePanel()
    }
    
    // MARK: - swipeDown
    
    private func hidePanel() {
        updateConstr(with: -602)
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func showPanel() {
        updateConstr(with: 0)
    }
    
    func updateConstr(with inset: Double) {
        UIView.animate(withDuration: 0.3) { [ weak self ] in
            self?.contentView.snp.updateConstraints { make in
                make.bottom.equalToSuperview().inset(inset)
            }
            self?.view.layoutIfNeeded()
        }
    }
    
    // MARK: - UI
    private let contentView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.backgroundColor = .white
        return view
    }()
    
    private let pinchView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.5402887464, green: 0.5452626944, blue: 0.5623689294, alpha: 1)
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        return view
    }()
    
    private let parametrsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 18).font
        label.textColor = UIColor(hex: "#70B170")
        label.text = "Parametrs".localized
        return label
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        let attributedTitle = NSAttributedString(string: "Done".localized, attributes: [
            .font: UIFont.SFPro.semibold(size: 16).font ?? UIFont(),
            .foregroundColor: UIColor(hex: "#000000")
        ])
        button.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }()

    // MARK: - Constraints
    private func setupConstraints() {
        view.backgroundColor = .black.withAlphaComponent(0.5)
        view.addSubview(contentView)
        contentView.addSubviews([pinchView, parametrsLabel, doneButton])
       
        contentView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(-602)
            make.height.equalTo(602)
        }
        
        pinchView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(65)
            make.height.equalTo(4)
            make.top.equalToSuperview().inset(8)
        }
        
        parametrsLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(pinchView.snp.bottom).offset(14)
        }
        
        doneButton.snp.makeConstraints { make in
            make.centerY.equalTo(parametrsLabel)
            make.right.equalToSuperview().inset(20)
        }
    }
}

// MARK: - recognizer actions
extension ProductsSettingsViewController {
    
    private func addRecognizers() {
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(swipeDownAction(_:)))
        contentView.addGestureRecognizer(panRecognizer)
    }
    
    @objc
    private func swipeDownAction(_ recognizer: UIPanGestureRecognizer) {
        let tempTranslation = recognizer.translation(in: contentView)
        if tempTranslation.y >= 100 {
            hidePanel()
        }
    }
}
