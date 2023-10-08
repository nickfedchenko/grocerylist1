//
//  FeatureCloudView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 21.08.2023.
//

import UIKit

final class FeatureCloudView: UIView {
    
    var tappedGreatEnable: (() -> Void)?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "1A645A")
        label.text = R.string.localizable.iconICloudDataBackup()
        label.font = UIFont.SFProRounded.heavy(size: 19).font
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "1A645A")
        label.text = R.string.localizable.synchronizeYourData()
        label.font = UIFont.SFProRounded.semibold(size: 17).font
        label.numberOfLines = 0
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()
    
    private lazy var asteriskLabel: UILabel = {
        let label = UILabel()
        label.textColor = R.color.darkGray()
        label.text = R.string.localizable.iCloudRegistrationRequired()
        label.font = UIFont.SFProRounded.semibold(size: 14).font
        label.textAlignment = .center
        return label
    }()
    
    private lazy var greatEnableButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(hex: "1A645A")
        button.setTitle(R.string.localizable.greatEnable(), for: .normal)
        button.titleLabel?.font = UIFont.SFProRounded.semibold(size: 17).font
        button.layer.cornerRadius = 8
        button.layer.cornerCurve = .continuous
        button.semanticContentAttribute = .forceRightToLeft
        button.addTarget(self, action: #selector(tappedGreatEnableButton), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc
    private func tappedGreatEnableButton() {
        tappedGreatEnable?()
    }
    
    private func makeConstraints() {
        self.addSubviews([titleLabel, descriptionLabel, greatEnableButton])
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.height.greaterThanOrEqualTo(24)
            $0.bottom.equalTo(descriptionLabel.snp.top).offset(-10)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.height.equalTo(72)
            $0.bottom.equalTo(greatEnableButton.snp.top).offset(-24)
        }
        
        greatEnableButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.leading.greaterThanOrEqualTo(8)
            $0.width.greaterThanOrEqualTo(214)
            $0.height.equalTo(56)
            $0.bottom.equalToSuperview().offset(-13)
        }
    }
}
