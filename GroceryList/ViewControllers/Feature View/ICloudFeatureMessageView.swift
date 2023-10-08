//
//  ICloudFeatureMessageView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 23.08.2023.
//

import UIKit

final class ICloudFeatureMessageView: UIView {

    var tapOnView: (() -> Void)?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 16).font
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        let text = R.string.localizable.turnOnICloudDataBackup()
        label.text = text
        let boldRange = (text as NSString).range(of: R.string.localizable.iCloudDataBackup())
        let boldString = NSMutableAttributedString(string: text)
        boldString.addAttribute(NSAttributedString.Key.font,
                                value: UIFont.SFPro.bold(size: 16).font ?? .systemFont(ofSize: 16),
                                range: boldRange)
        boldString.addAttribute(NSAttributedString.Key.foregroundColor,
                                value: UIColor.black,
                                range: boldRange)
        label.attributedText = boldString
        return label
    }()
    
    private lazy var messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.featureMessage()
        imageView.layer.cornerRadius = 8
        imageView.layer.cornerCurve = .continuous
        imageView.isUserInteractionEnabled = true
        imageView.addDefaultShadowForPopUp()
        return imageView
    }()

    private var tapRecognizer = UITapGestureRecognizer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if UserDefaultsManager.shared.countShowMessageNewFeature < 4 {
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
        UserDefaultsManager.shared.countShowMessageNewFeature += 1
        tapRecognizer.isEnabled = false
        tapOnView?()
    }
    
    private func makeConstraints() {
        self.addSubviews([messageImageView])
        messageImageView.addSubview(titleLabel)
        
        messageImageView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(42)
            $0.leading.equalToSuperview().offset(16)
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
