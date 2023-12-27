//
//  PaywallWithTimerOldAndNewPrice.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 27.12.2023.
//

import Foundation
import UIKit

final class PaywallWithTimerOldAndNewPrice: UIView {
    
    private var oldPriceLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "FFFFFF", alpha: 0.6)
        label.font = R.font.sfProTextSemibold(size: 17)
        return label
    }()
    
    private var arrowLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "FFFFFF", alpha: 0.6)
        label.font = R.font.sfProTextSemibold(size: 17)
        label.text = "→"
        return label
    }()
    
    private var newPriceLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "6FF4E1")
        label.font = R.font.sfProTextSemibold(size: 17)
        return label
    }()
    
    private var firstYearLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "6FF4E1")
        label.font = R.font.sfProTextRegular(size: 17)
        label.text = R.string.localizable.onboardingWithQuestionsPaywallFirstYear()
        return label
    }()
    
    // MARK: - Init
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(oldPrice: String, newPrice: String) {
        let attributeString = NSMutableAttributedString(string: oldPrice)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                     value: NSUnderlineStyle.single.rawValue,
                                     range: NSMakeRange(0, attributeString.length))
        oldPriceLabel.attributedText = attributeString
        newPriceLabel.text = newPrice
    }
}

extension PaywallWithTimerOldAndNewPrice {
    // MARK: - SetupView
    private func setupView() {
        addSubview()
        setupConstraint()
    }
    
    private func addSubview() {
        addSubviews([oldPriceLabel, arrowLabel, newPriceLabel, firstYearLabel])
    }
    
    private func setupConstraint() {
        oldPriceLabel.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
        }
        
        arrowLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(oldPriceLabel.snp.right).inset(-8)
        }
        
        newPriceLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(arrowLabel.snp.right).inset(-8)
        }
        
        firstYearLabel.snp.makeConstraints { make in
            make.top.right.bottom.equalToSuperview()
            make.left.equalTo(newPriceLabel.snp.right)
        }
    }
}
