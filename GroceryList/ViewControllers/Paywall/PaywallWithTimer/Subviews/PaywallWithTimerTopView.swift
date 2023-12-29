//
//  PaywallWithTimerTopView.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 26.12.2023.
//

import Foundation
import UIKit

final class PaywallWithTimerTopView: UIView {
    
    private let iconImageView: UIImageView = {
        let view = UIImageView()
        view.image = R.image.onboardingWithQuestionsIcon()
        return view
    }()
    
    private let oneHourContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#E8FEFE")
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    private var oneHourLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "#00B59B")
        label.font = R.font.sfProTextSemibold(size: 16)
        label.text = R.string.localizable.onboardingWithQuestionsPaywallOnlyOneHour().uppercased()
        return label
    }()
    
    private var saleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = R.font.sfProTextHeavy(size: 64)
        label.text = R.string.localizable.onboardingWithQuestionsPaywallSale().uppercased() + "%"
        label.textAlignment = .center
        return label
    }()
    
    private var subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = R.font.sfProTextSemibold(size: 17)
        label.text = R.string.localizable.onboardingWithQuestionsPaywallSaveMoney()
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
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
}

extension PaywallWithTimerTopView {
    // MARK: - SetupView
    private func setupView() {
        addSubview()
        setupConstraint()
    }
    
    private func addSubview() {
        addSubviews([
            iconImageView,
            oneHourContainer,
            saleLabel,
            subtitleLabel
            ])
        oneHourContainer.addSubview(oneHourLabel)
    }
    
    private func setupConstraint() {
        iconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(88)
        }
        
        oneHourContainer.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).inset(-32)
            //  make.top.greaterThanOrEqualTo(iconImageView.snp.bottom).inset(-32)
            make.centerX.equalToSuperview()
        }
        
        oneHourLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.left.right.equalToSuperview().inset(8)
        }
        
        saleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(oneHourContainer.snp.bottom).inset(-4)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(saleLabel.snp.bottom).inset(-4)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview()
        }
    }
}
