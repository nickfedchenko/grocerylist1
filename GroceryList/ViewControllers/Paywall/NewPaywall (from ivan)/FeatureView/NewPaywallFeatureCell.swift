//
//  NewPaywallFeatureCell.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 17.07.2023.
//

import UIKit

final class NewPaywallFeatureCell: UICollectionViewCell {
    
    private let containerView = UIView()
    private let colorView = UIView()
    private let imageView = UIImageView()
    private let freeImageView = UIImageView()
    private let premiumImageView = UIImageView()
    
    private lazy var titleLabel: UILabel = {
        var label = UILabel()
        label.textColor = .black
        label.font = UIFont.SFPro.medium(size: 15).font
        label.numberOfLines = 0
        return label
    }()

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 8
        containerView.layer.cornerCurve = .continuous
        containerView.clipsToBounds = true
        freeImageView.image = R.image.checkmarkPaywall()?.withTintColor(UIColor(hex: "00D9D9"))
        premiumImageView.image = R.image.checkmarkPaywall()
        
        makeConstraints()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        freeImageView.isHidden = true
    }
    
    func configure(feature: NewPaywallFeatureView.FeatureModel) {
        colorView.backgroundColor = feature.color
        imageView.image = feature.image
        titleLabel.text = feature.title
        freeImageView.isHidden = feature.free
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeConstraints() {
        self.contentView.addSubview(containerView)
        containerView.addSubviews([colorView, titleLabel, freeImageView, premiumImageView])
        colorView.addSubview(imageView)
        
        containerView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.verticalEdges.equalToSuperview()
        }
        
        colorView.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
            $0.width.equalTo(48)
        }
        
        imageView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        freeImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(premiumImageView.snp.leading).offset(-8)
            $0.height.width.equalTo(40)
        }
        
        premiumImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-8)
            $0.height.width.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(6)
            $0.leading.equalTo(colorView.snp.trailing).offset(8)
            $0.trailing.equalTo(freeImageView.snp.leading).offset(-8)
            $0.centerY.equalToSuperview()
        }
    }
}
