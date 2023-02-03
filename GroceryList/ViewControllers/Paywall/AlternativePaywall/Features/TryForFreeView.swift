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
        view.text = "Try 3 days for free"
        return view
    }()
    
    private lazy var subTitleLabel: UILabel = {
        var view = UILabel()
        view.textColor = UIColor(hex: "#19645A")
        view.font = UIFont.SFPro.black(size: 15).font
        view.text = "Save time and money with Shopping List"
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
        
        snp.makeConstraints { make in
            make.height.equalTo(66)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        subTitleLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
}
