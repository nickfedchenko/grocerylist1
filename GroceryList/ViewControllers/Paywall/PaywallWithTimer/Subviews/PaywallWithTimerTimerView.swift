//
//  PaywallWithTimerTimerView.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 26.12.2023.
//

import Foundation
import UIKit

final class PaywallWithTimerTimerView: UIView {
    
    private let minutesView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor(hex: "#00B59B").cgColor
        return view
    }()
    
    private var minutesLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = R.font.sfProTextBold(size: 34)
        return label
    }()
    
    private let dotsImageView: UIImageView = {
        let view = UIImageView()
        view.image = R.image.dotsImageView()
        return view
    }()
    
    private let secondsView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor(hex: "#00B59B").cgColor
        return view
    }()
    
    private var secondsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = R.font.sfProTextBold(size: 34)
        return label
    }()
    
    private let oldAndNewPriceView: PaywallWithTimerOldAndNewPrice = {
        let view = PaywallWithTimerOldAndNewPrice()
        return view
    }()
    
    // MARK: - Init
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupTimer(minutes: String, seconds: String) {
        minutesLabel.text = minutes
        secondsLabel.text = seconds
    }
    
    func configurePrice(oldPrice: String, newPrice: String) {
        oldAndNewPriceView.configure(oldPrice: oldPrice, newPrice: newPrice)
    }
}

extension PaywallWithTimerTimerView {
    // MARK: - SetupView
    private func setupView() {
        addSubview()
        setupConstraint()
    }
    
    private func addSubview() {
        addSubviews([minutesView, dotsImageView, secondsView, oldAndNewPriceView])
        minutesView.addSubview(minutesLabel)
        secondsView.addSubview(secondsLabel)
    }
    
    private func setupConstraint() {
        
        dotsImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(minutesView.snp.centerY)
        }
        
        minutesView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.equalTo(72)
            make.height.equalTo(81)
            make.right.equalTo(dotsImageView.snp.left).inset(-16)
        }
        
        minutesLabel.snp.makeConstraints { make in
            make.center.equalTo(minutesView)
        }
        
        secondsView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.equalTo(72)
            make.height.equalTo(81)
            make.left.equalTo(dotsImageView.snp.right).inset(-16)
        }
        
        secondsLabel.snp.makeConstraints { make in
            make.center.equalTo(secondsView)
        }
        
        oldAndNewPriceView.snp.makeConstraints { make in
            make.top.equalTo(minutesView.snp.bottom).inset(-16)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
