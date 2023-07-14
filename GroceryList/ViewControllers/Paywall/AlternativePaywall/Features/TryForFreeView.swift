//
//  TryForFreeView.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 31.01.2023.
//

import UIKit

final class TryForFreeView: UIView {
    
    private lazy var titleLabel: UILabel = {
        var view = UILabel()
        view.textColor = UIColor(hex: "#014E43")
        view.font = UIFont.SFPro.black(size: 32).font
        view.text = R.string.localizable.try3DaysForFree()
        view.textAlignment = .center
        view.adjustsFontSizeToFitWidth = true
        view.minimumScaleFactor = 0.1
        return view
    }()
    
    private lazy var subTitleLabel: UILabel = {
        var view = UILabel()
        view.textColor = UIColor(hex: "#19645A")
        view.font = UIFont.SFPro.black(size: 15).font
        view.text = R.string.localizable.saveTimeAndMoneyWithApp()
        view.numberOfLines = 2
        view.adjustsFontSizeToFitWidth = true
        view.minimumScaleFactor = 0.1
        view.textAlignment = .center
        return view
    }()
    // MARK: - LifeCycle
    
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
        
//        snp.makeConstraints { make in
//            make.height.equalTo(66)
//        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.centerX.equalToSuperview()
        }
        
        subTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.bottom.leading.centerX.equalToSuperview()
        }
    }
}
