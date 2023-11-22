//
//  FamilyPaywallTitleView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 22.11.2023.
//

import UIKit

final class FamilyPaywallTitleView: UIView {
    
    private lazy var titleLabel: UILabel = {
        var view = UILabel()
        view.textColor = R.color.primaryDark()
        view.font = UIFont.SFPro.black(size: 32).font
        view.text = R.string.localizable.try3DaysForFree()
        view.textAlignment = .center
        view.adjustsFontSizeToFitWidth = true
        view.minimumScaleFactor = 0.3
        return view
    }()
    
    private lazy var subTitleLabel: UILabel = {
        var view = UILabel()
        view.textColor = R.color.primaryDark()
        view.font = UIFont.SFPro.semibold(size: 17).font
        view.text = R.string.localizable.saveTimeAndMoneyWithApp()
        view.adjustsFontSizeToFitWidth = true
        view.minimumScaleFactor = 0.3
        view.textAlignment = .center
        return view
    }()

    init() {
        super.init(frame: .zero)
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Constraints
    private func setupConstraint() {
        self.addSubviews([titleLabel, subTitleLabel])
        
        titleLabel.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }
        
        subTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.bottom.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }
    }
}
