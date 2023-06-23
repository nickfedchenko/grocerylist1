//
//  DisplayCostListCell.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 20.04.2023.
//

import UIKit

class DisplayCostListCell: UICollectionViewListCell {
    
    var changedSwitchValue: ((Bool) -> Void)?
    
    private let contentViews = UIView()
    private var imageView = UIImageView()
    private var titleLabel = UILabel()
    private let costSwitch = UISwitch()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.backgroundConfiguration = .clear()
        
        imageView.image = R.image.bankCard()
        titleLabel.text = R.string.localizable.displayCostAndStore()
        titleLabel.textColor = UIColor(hex: "#537979")
        titleLabel.font = UIFont.SFPro.medium(size: 16).font
        costSwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        costSwitch.isOn = false
    }
    
    func configureSwitch(isVisibleCost: Bool, tintColor: UIColor?) {
        costSwitch.isOn = isVisibleCost
        costSwitch.onTintColor = tintColor
    }
    
    @objc
    private func switchChanged() {
        changedSwitchValue?(costSwitch.isOn)
    }
    
    private func makeConstraints() {
        self.contentView.addSubview(contentViews)
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
