//
//  RecipeListTableCell.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 21.06.2023.
//

import UIKit

final class RecipeListTableCell: RecipeListCell {

    let kcalView = UIView()
    let timeView = UIView()
    
    override func setupSubviews() {
        titleLabel.textAlignment = .center
        mainImage.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner]
        
        contentView.addSubviews([titleLabel, mainImage, contextMenuButton])
        contentView.addSubviews([timeBadgeView, kcalBadgeView, favoriteImage])
        timeBadgeView.addSubviews([timeView])
        kcalBadgeView.addSubviews([kcalView])
        timeView.addSubviews([timeLabel, timeImage])
        kcalView.addSubviews([kcalImage, kcalLabel])
        
        mainImage.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(1)
            make.height.equalTo(88)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(mainImage.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(48)
        }
        
        contextMenuButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.leading.equalTo(mainImage.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.width.height.equalTo(32)
        }
        
        favoriteImage.snp.makeConstraints {
            $0.top.leading.equalTo(mainImage).offset(3)
            $0.height.equalTo(20)
        }
        
        badgeMakeConstraints()
    }
    
    override func badgeMakeConstraints() {
        kcalBadgeView.snp.makeConstraints {
            $0.top.equalTo(contextMenuButton.snp.bottom).offset(6)
            $0.leading.equalTo(mainImage.snp.trailing).offset(4)
            $0.trailing.equalToSuperview().offset(-4)
            $0.height.equalTo(20)
            $0.width.equalTo(48)
        }
        
        timeBadgeView.snp.makeConstraints {
            $0.top.equalTo(kcalBadgeView.snp.bottom).offset(6)
            $0.leading.equalTo(mainImage.snp.trailing).offset(4)
            $0.trailing.equalToSuperview().offset(-4)
            $0.height.equalTo(20)
            $0.width.equalTo(48)
        }
        
        kcalView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        timeView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        kcalImage.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
            $0.height.width.equalTo(16)
        }
        
        kcalLabel.snp.makeConstraints {
            $0.leading.equalTo(kcalImage.snp.trailing)
            $0.centerY.equalTo(kcalImage)
            $0.trailing.equalToSuperview()
        }
        
        timeImage.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
            $0.height.width.equalTo(16)
        }
        
        timeLabel.snp.makeConstraints {
            $0.leading.equalTo(timeImage.snp.trailing)
            $0.centerY.equalTo(timeImage)
            $0.trailing.equalToSuperview()
        }
    }
}
