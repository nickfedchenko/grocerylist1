//
//  EditDeleteAlertView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 11.04.2023.
//

import UIKit

final class EditDeleteAlertView: UIView {
    
    var deleteTapped: (() -> Void)?
    var cancelTapped: (() -> Void)?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = R.string.localizable.wantDeleteTheseTasks()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.SFPro.regular(size: 17).font
        label.textColor = UIColor(hex: "#045C5C")
        return label
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = R.color.attention()
        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        button.setTitle(R.string.localizable.delete(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.SFProRounded.semibold(size: 18).font
        button.layer.cornerRadius = 8
        button.addDefaultShadowForPopUp()
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        button.setTitle(R.string.localizable.cancel(), for: .normal)
        button.setTitleColor(UIColor(hex: "#045C5C"), for: .normal)
        button.titleLabel?.font = UIFont.SFProRounded.semibold(size: 17).font
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
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.backgroundColor = .white
        self.addCustomShadow(opacity: 0.13, radius: 11, offset: CGSize(width: 0, height: 8))
        
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
        self.addSubviews([titleLabel, deleteButton, cancelButton])
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
        }
        
        deleteButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        cancelButton.snp.makeConstraints {
            $0.top.equalTo(deleteButton.snp.bottom).offset(13)
            $0.leading.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(48)
        }
    }
}
