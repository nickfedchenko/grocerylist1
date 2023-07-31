//
//  CreateNewRecipeShowCostView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 28.06.2023.
//

import UIKit

class CreateNewRecipeShowCostView: UIView {

    var changedSwitchValue: ((Bool) -> Void)?
    var requiredHeight: Int {
        20 + 40
    }
    
    private let contentViews = UIView()
    private var imageView = UIImageView()
    private var titleLabel = UILabel()
    private let costSwitch = UISwitch()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        
        imageView.image = R.image.bankCard()?.withTintColor(R.color.darkGray() ?? .black)
        titleLabel.text = R.string.localizable.displayCostAndStore()
        titleLabel.textColor = R.color.darkGray()
        titleLabel.font = UIFont.SFPro.medium(size: 16).font
        costSwitch.onTintColor = R.color.darkGray()
        costSwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureSwitch(isVisibleCost: Bool) {
        costSwitch.isOn = isVisibleCost
    }
    
    @objc
    private func switchChanged() {
        changedSwitchValue?(costSwitch.isOn)
    }
    
    private func makeConstraints() {
        self.addSubview(contentViews)
        contentViews.addSubviews([imageView, titleLabel, costSwitch])

        contentViews.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalToSuperview().offset(20)
            $0.height.equalTo(40)
        }
        
        imageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview()
            $0.height.width.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(costSwitch.snp.leading).offset(-8)
        }
        
        costSwitch.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
        }
    }
}
