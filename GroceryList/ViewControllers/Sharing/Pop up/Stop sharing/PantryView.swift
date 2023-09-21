//
//  PantryView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 04.09.2023.
//

import UIKit

class PantryView: UIView {
    
    private let mainContainer = UIView()
    private let mainContainerShadowOneView = UIView()
    private let mainContainerShadowTwoView = UIView()
    
    private let topContainer = UIView()
    private let topColorView = UIView()
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.SFPro.semibold(size: 20).font
        label.numberOfLines = 2
        return label
    }()
    private let capitalLetterLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.SFProRounded.heavy(size: 22).font
        label.textAlignment = .center
        return label
    }()
    private let iconImageView = UIImageView()
    private let sharingView = SharingView()
    
    private let bottomColorContainer = UIView()
    private let bottomWhiteView = UIView()
    private let outOfStockView = OutOfStockView()
    private var contextMenuButton = UIButton()
    private var moveImageView = UIImageView()
    
    private let moveImage = R.image.pantry_move()
    private let menuImage = R.image.pantry_context_menu()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ cellModel: PantryCell.CellModel) {
        topColorView.backgroundColor = cellModel.theme.medium
        if let icon = cellModel.icon {
            iconImageView.image = icon.withTintColor(.white)
            capitalLetterLabel.isHidden = true
        } else {
            iconImageView.isHidden = true
            capitalLetterLabel.text = cellModel.name.first?.uppercased()
        }
        
        nameLabel.text = cellModel.name
        sharingView.configure(state: cellModel.sharingState, viewState: .pantry,
                              color: cellModel.theme.medium, images: cellModel.sharingUser)
        
        bottomColorContainer.backgroundColor = cellModel.theme.medium
        moveImageView.image = moveImage?.withTintColor(cellModel.theme.medium)
        contextMenuButton.setImage(menuImage?.withTintColor(cellModel.theme.dark), for: .normal)
        outOfStockView.configure(color: cellModel.theme.dark,
                                 total: cellModel.stockCount, outOfStock: cellModel.outOfStockCount)
    }
    
    private func setupCell() {
        [mainContainerShadowOneView, mainContainerShadowTwoView, mainContainer].forEach {
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 8
            $0.layer.cornerCurve = .continuous
        }
        mainContainer.clipsToBounds = true
        mainContainer.layer.borderColor = UIColor.white.cgColor
        mainContainer.layer.borderWidth = 1
        mainContainerShadowOneView.addShadow(color: .black, opacity: 0.15,
                                                   radius: 11, offset: .init(width: 0, height: 12))
        mainContainerShadowTwoView.addShadow(color: .black, opacity: 0.06,
                                                   radius: 3, offset: .init(width: 0, height: 2))
        
        topContainer.backgroundColor = .white
        topColorView.layer.cornerRadius = 8
        topColorView.layer.maskedCorners = [.layerMaxXMaxYCorner]
        
        bottomWhiteView.backgroundColor = .white
        bottomWhiteView.layer.cornerRadius = 8
        bottomWhiteView.layer.maskedCorners = [.layerMinXMinYCorner]
    }
    
    private func makeConstraints() {
        self.addSubviews([mainContainerShadowOneView, mainContainerShadowTwoView, mainContainer])
        mainContainer.addSubviews([topContainer, bottomColorContainer])
        topContainer.addSubviews([topColorView, capitalLetterLabel, iconImageView, nameLabel, sharingView])
        bottomColorContainer.addSubviews([bottomWhiteView, outOfStockView, moveImageView, contextMenuButton])
        
        mainContainer.snp.makeConstraints {
            $0.top.centerX.leading.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-8)
        }
        
        mainContainerShadowOneView.snp.makeConstraints {
            $0.edges.equalTo(mainContainer)
        }
        
        mainContainerShadowTwoView.snp.makeConstraints {
            $0.edges.equalTo(mainContainer)
        }
        
        topContainer.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }
        
        bottomColorContainer.snp.makeConstraints {
            $0.top.equalTo(topContainer.snp.bottom)
            $0.bottom.leading.trailing.equalToSuperview()
        }
        
        makeTopContainerConstraints()
        makeBottomContainerConstraints()
    }
    
    private func makeTopContainerConstraints() {
        topColorView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        iconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(8)
            $0.top.equalToSuperview().offset(12)
            $0.height.width.equalTo(32)
        }
        
        capitalLetterLabel.snp.makeConstraints {
            $0.edges.equalTo(iconImageView)
        }
        
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(4)
            $0.trailing.equalTo(sharingView.snp.leading).offset(16)
            $0.centerY.equalTo(iconImageView)
        }
        
        sharingView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-12)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(32)
        }
    }
    
    private func makeBottomContainerConstraints() {
        bottomWhiteView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        outOfStockView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(4)
            $0.trailing.lessThanOrEqualTo(moveImageView.snp.leading).offset(-4)
            $0.bottom.equalToSuperview().offset(-4)
        }
        
        moveImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.width.equalTo(32)
        }
        
        contextMenuButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-8)
            $0.height.width.equalTo(32)
        }
    }
}
