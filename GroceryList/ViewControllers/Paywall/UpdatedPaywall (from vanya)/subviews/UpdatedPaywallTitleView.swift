//
//  UpdatedPaywallTitleView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 12.07.2023.
//

import UIKit

class UpdatedPaywallTitleView: UIView {

    private lazy var titleLabel: UILabel = {
        var label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        let font = UIFont.SFProDisplay.heavy(size: 40).font ?? UIFont()
        let greenColor = R.color.primaryDark() ?? UIColor.green
        let red = UIColor(hex: "F81C0E")
        let attributesGreen = [NSAttributedString.Key.font: font,
                               NSAttributedString.Key.foregroundColor: greenColor]
        let attributesRed = [NSAttributedString.Key.font: font,
                             NSAttributedString.Key.foregroundColor: red]
        let attributedStringGreen = NSMutableAttributedString(string: R.string.localizable.threeDays().uppercased(),
                                                              attributes: attributesGreen)
        let attributedStringRed = NSMutableAttributedString(string: R.string.localizable.free().uppercased(),
                                                            attributes: attributesRed)
        attributedStringGreen.append(attributedStringRed)
        label.attributedText = attributedStringGreen
        label.textAlignment = .center
        return label
    }()
    
    private lazy var subTitleLabel: UILabel = {
        var label = UILabel()
        label.textColor = R.color.primaryDark()
        label.font = UIFont.SFProDisplay.semibold(size: 20).font
        label.text = R.string.localizable.howDoesYourTrialPeriodWork()
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        makeConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeConstraints() {
        self.addSubviews([titleLabel, subTitleLabel])

        titleLabel.snp.makeConstraints {
            $0.top.leading.centerX.equalToSuperview()
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.bottom.leading.trailing.equalToSuperview()
        }
    }
}
