//
//  AutoCategoryInfoView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 16.05.2023.
//

import UIKit

class AutoCategoryInfoView: UIView {
    
    var tappedOk: (() -> Void)?
    var tappedOnView: (() -> Void)?
    
    private lazy var okButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.autocategoryOk(), for: .normal)
        button.addTarget(self, action: #selector(tappedOkButton), for: .touchUpInside)
        button.layer.cornerRadius = 24
        button.addDefaultShadowForPopUp()
        return button
    }()
    
    private lazy var infoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.autocategoryInfo()
        return imageView
    }()
    
    private lazy var infoShadowView: UIView = {
        let view = UIView()
        view.backgroundColor = R.color.action()
        view.layer.cornerRadius = 12
        view.addDefaultShadowForPopUp()
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.SFPro.bold(size: 17).font
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.SFPro.medium(size: 15).font
        label.numberOfLines = 0
        label.minimumScaleFactor = 0.1
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setup() {
        let tapOnView = UITapGestureRecognizer(target: self, action: #selector(tappedOnViewRecognizer))
        self.addGestureRecognizer(tapOnView)
        
        makeConstraints()
        
        if let isActiveAutoCategory = FeatureManager.shared.isActiveAutoCategory {
            if isActiveAutoCategory {
                titleLabel.textAlignment = .center
                descriptionLabel.textAlignment = .center
                titleLabel.text = R.string.localizable.autoCategoryTitleOn()
                descriptionLabel.text = R.string.localizable.autoCategoryDescOn()
            } else {
                descriptionLabel.text = R.string.localizable.autoCategoryDescOff()
                descriptionLabel.snp.updateConstraints {
                    $0.top.equalTo(infoImageView).offset(22)
                    $0.bottom.equalTo(infoImageView).offset(-41)
                }
            }
        }

    }
    
    @objc
    private func tappedOkButton() {
        tappedOk?()
    }
    
    @objc
    private func tappedOnViewRecognizer() {
        tappedOnView?()
    }
    
    private func makeConstraints() {
        self.addSubviews([infoShadowView, infoImageView,
                          titleLabel, descriptionLabel, okButton])
        
        infoShadowView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(infoImageView)
            $0.bottom.equalTo(infoImageView).offset(-28)
        }
        
        infoImageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(24)
            $0.height.equalTo(138)
            $0.width.equalTo(311)
            $0.bottom.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(infoImageView).offset(25)
            $0.leading.trailing.equalTo(infoImageView)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(infoImageView).offset(45)
            $0.leading.equalTo(infoImageView).offset(15)
            $0.trailing.equalTo(infoImageView).offset(-15)
            $0.bottom.equalTo(infoImageView).offset(-30)
        }
        
        okButton.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.height.width.equalTo(48)
        }
    }
}
