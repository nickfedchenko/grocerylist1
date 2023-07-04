//
//  RecipeListMessageView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 23.06.2023.
//

import UIKit

class RecipeListMessageView: UIView {
    
    private let containerView = UIView()
    
    private let addToLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 18).font
        label.textColor = R.color.darkGray()
        label.text = R.string.localizable.addedTo()
        return label
    }()
    
    private let iconImageView = UIImageView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.bold(size: 18).font
        label.textColor = R.color.darkGray()
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.layer.cornerRadius = 32
        self.layer.cornerCurve = .continuous
        self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        self.addDefaultShadowForPopUp()
        
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setState(state: RecipeListContextMenuView.MainMenuState) {
        iconImageView.image = state.image?.withTintColor(R.color.darkGray() ?? .black)
        titleLabel.text = state.message
    }
    
    private func makeConstraints() {
        self.addSubviews([containerView])
        containerView.addSubviews([addToLabel, iconImageView, titleLabel])

        containerView.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-16)
            $0.centerX.equalToSuperview()
            $0.width.greaterThanOrEqualTo(200)
            $0.height.equalTo(40)
        }
        
        addToLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(iconImageView.snp.leading)
        }
        
        iconImageView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.trailing.equalTo(titleLabel.snp.leading)
            $0.width.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
}
