//
//  SettingsFeatureMessageView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 22.11.2023.
//

import UIKit

class SettingsFeatureMessageView: UIView {

    var tapOnView: (() -> Void)?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 16).font
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = R.string.localizable.enjoyWithTheWholeICloudFamily()
        return label
    }()
    
    private lazy var messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.settingsFeatureMessage()
        imageView.layer.cornerRadius = 8
        imageView.layer.cornerCurve = .continuous
        imageView.isUserInteractionEnabled = true
        imageView.addDefaultShadowForPopUp()
        return imageView
    }()

    private var tapRecognizer = UITapGestureRecognizer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if UserDefaultsManager.shared.countShowSettingsMessageFeature < 2 {
            tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedOnView))
            self.addGestureRecognizer(tapRecognizer)
        }
        
        makeConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc
    private func tappedOnView() {
        UserDefaultsManager.shared.countShowSettingsMessageFeature += 1
        tapRecognizer.isEnabled = false
        tapOnView?()
    }
    
    private func makeConstraints() {
        self.addSubviews([messageImageView])
        messageImageView.addSubview(titleLabel)
        
        messageImageView.snp.makeConstraints {
            $0.height.equalTo(88)
            $0.width.equalTo(236)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.lessThanOrEqualToSuperview().offset(36)
            $0.bottom.lessThanOrEqualToSuperview().offset(-4)
            $0.trailing.equalToSuperview().offset(-15)
            $0.leading.equalToSuperview().offset(17)
        }
    }
}
