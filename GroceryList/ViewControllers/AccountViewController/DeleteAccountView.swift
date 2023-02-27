//
//  DeleteAccountView.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 14.02.2023.
//

import Foundation
import UIKit

final class DeleteAccountView: UIView {
    
    var deletePressed: (() -> Void)?
    var cancelPressed: (() -> Void)?
    
    private let topLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProRounded.bold(size: 22).font
        label.textColor = UIColor(hex: "#19645A")
        label.text = R.string.localizable.settingsAccountDeleteAcc()
        label.textAlignment = .center
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.regular(size: 17).font
        label.textColor = UIColor(hex: "#023B45")
        label.text = R.string.localizable.settingsAccountPremanentDel()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#F3FFFE")
        view.layer.cornerRadius = 14
        view.layer.cornerCurve = .continuous
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        let attributedTitle = NSAttributedString(string: R.string.localizable.settingsAccountCancel(),
                                                 attributes: [
                                                    .font: UIFont.SFProRounded.semibold(size: 18).font ?? UIFont(),
                                                    .foregroundColor: UIColor(hex: "#FFFFFF")
                                                 ])
        button.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.backgroundColor = UIColor(hex: "#19645A")
        button.layer.cornerRadius = 8
        button.layer.cornerCurve = .continuous
        button.layer.masksToBounds = true
        button.addShadowForView(radius: 5)
        return button
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setTitle(R.string.localizable.settingsAccountDelete(), for: .normal)
        button.titleLabel?.font = UIFont.SFProRounded.semibold(size: 17).font
        button.setTitleColor(UIColor(hex: "#FF0200"), for: .normal)
        button.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        button.backgroundColor = .clear
        return button
    }()
    
    // MARK: - LifeCycle
    
    init() {
        super.init(frame: .zero)
        setupConstraint()
        contentView.transform = CGAffineTransform(scaleX: 0, y: 0)
        self.isHidden = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showView() {
        self.isHidden = false
        
        UIView.animate(withDuration: 0.3, delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: .curveLinear) {
            self.contentView.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.backgroundColor = .black.withAlphaComponent(0.5)
            self.layoutIfNeeded()
        } completion: { _ in
            
        }

    }
    
    func hideView() {
        UIView.animate(withDuration: 0.3, delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: .curveLinear) {
            self.contentView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            self.backgroundColor = .black.withAlphaComponent(0.0)
            self.layoutIfNeeded()
        } completion: { _ in
            self.isHidden = true
        }
    }
    
    // MARK: - setupView and constraints

    private func setupConstraint() {
        self.addSubviews([contentView])
        contentView.addSubviews([topLabel ,descriptionLabel, cancelButton, deleteButton])
       
        contentView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalTo(270)
        }
        
        topLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(23)
            make.left.right.equalToSuperview().inset(16)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(topLabel.snp.bottom).inset(-8)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).inset(-24)
            make.height.equalTo(48)
            make.left.right.equalToSuperview().inset(16)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.top.equalTo(cancelButton.snp.bottom).inset(-16)
            make.height.equalTo(48)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
        }
    }
    
    @objc
    private func deleteTapped() {
        deletePressed?()
    }
    
    @objc
    private func cancelTapped() {
        cancelPressed?()
    }
}
