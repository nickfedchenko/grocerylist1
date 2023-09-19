//
//  ShowCollectionDeleteAlertView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 27.06.2023.
//

import UIKit

final class ShowCollectionDeleteAlertView: UIView {
    
    var deleteTapped: (() -> Void)?
    var cancelTapped: (() -> Void)?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = R.string.localizable.deleteCollection()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.SFProRounded.bold(size: 22).font
        label.textColor = UIColor(hex: "#1A645A")
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = R.string.localizable.youAreDeletingACollection()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.SFPro.regular(size: 17).font
        label.textColor = UIColor(hex: "#1A645A")
        return label
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        button.setTitle(R.string.localizable.delete(), for: .normal)
        button.setTitleColor(UIColor(hex: "#FF0000"), for: .normal)
        button.titleLabel?.font = UIFont.SFProRounded.semibold(size: 17).font
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(hex: "#1A645A")
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        button.setTitle(R.string.localizable.cancel(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.SFProRounded.semibold(size: 18).font
        button.layer.cornerRadius = 8
        button.addDefaultShadowForPopUp()
        return button
    }()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setup() {
        self.layer.cornerRadius = 14
        self.backgroundColor = UIColor(hex: "F3FFFE")
        self.addShadow(opacity: 0.13, radius: 11, offset: CGSize(width: 0, height: 8))
        
        makeConstraints()
    }
    
    @objc
    private func deleteButtonTapped() {
        deleteTapped?()
    }
    
    @objc
    private func cancelButtonTapped() {
        cancelTapped?()
    }
    
    private func makeConstraints() {
        self.addSubviews([titleLabel, descriptionLabel, deleteButton, cancelButton])
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
        }
        
        cancelButton.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        deleteButton.snp.makeConstraints {
            $0.top.equalTo(cancelButton.snp.bottom).offset(13)
            $0.leading.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview().offset(-8)
        }
    }

}
