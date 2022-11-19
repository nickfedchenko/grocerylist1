//
//  HeaderListCell.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 14.11.2022.
//

import SnapKit
import UIKit

class HeaderListCell: UICollectionViewListCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        pinchView.isHidden = true
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let attrs = super.preferredLayoutAttributesFitting(layoutAttributes)
        attrs.bounds.size.height = 50
        return attrs
    }
    
    func collapsing(color: UIColor?, isPurchased: Bool) {
        UIView.animate(withDuration: 0.5) {
            self.checkmarkView.transform = CGAffineTransform(rotationAngle: .pi * 2)
            guard self.nameLabel.text != "" else { return }
            if !isPurchased {
                self.coloredView.backgroundColor = color
            }
        }
    }
    
    func expanding(isPurchased: Bool) {
        UIView.animate(withDuration: 0.5) {
            self.checkmarkView.transform = CGAffineTransform(rotationAngle: -.pi )
           
            if !isPurchased {
                self.coloredView.backgroundColor = .clear
            }
        }
        
    }
    
    func setupCell(text: String?, color: UIColor?, bcgColor: UIColor?, isExpand: Bool) {
        if text == "Purchased".localized {
            coloredView.backgroundColor = .white
            nameLabel.textColor = color
            collapsedColoredView.backgroundColor = .clear
            nameLabel.text = text
        } else if text == "Favorite" {
            nameLabel.text = ""
            contentViews.backgroundColor = .clear
            collapsedColoredView.backgroundColor = .clear
            pinchView.isHidden = false
        } else {
            if isExpand {
                coloredView.backgroundColor = .clear
                collapsedColoredView.backgroundColor = color
                contentViews.backgroundColor = bcgColor
                nameLabel.textColor = .white
                nameLabel.text = text
            } else {
                collapsedColoredView.backgroundColor = color
                coloredView.backgroundColor = color
                contentViews.backgroundColor = bcgColor
                nameLabel.textColor = .white
                nameLabel.text = text
            }
            
        }
        contentViews.backgroundColor = bcgColor
    }
    
    private let contentViews: UIView = {
        let view = UIView()
        return view
    }()
    
    private let coloredView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let checkmarkView: CheckmarkView = {
        let view = CheckmarkView()
        view.backgroundColor = .clear
        view.transform = CGAffineTransform(rotationAngle: .pi )
        return view
    }()
    
    private let collapsedColoredView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMaxXMinYCorner]
        view.layer.masksToBounds = true
        view.backgroundColor = .orange
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 17).font
        return label
    }()
    
    private let pinchView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "blackPinch")
        imageView.isHidden = true
        return imageView
    }()
    
    // MARK: - UI
    private func setupConstraints() {
        self.addSubviews([contentViews])
        contentViews.addSubviews([coloredView, collapsedColoredView, nameLabel, checkmarkView, pinchView])
        
        contentViews.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        coloredView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().inset(8)
        }
        
        collapsedColoredView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalTo(nameLabel.snp.right).inset(-28)
            make.bottom.equalToSuperview().inset(4)
            make.top.equalToSuperview().inset(12)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(28)
            make.centerY.equalTo(coloredView.snp.centerY)
        }
        
        checkmarkView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(20)
            make.width.equalTo(20)
            make.height.equalTo(12)
            make.centerY.equalTo(coloredView.snp.centerY)
        }
       
        pinchView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(28)
            make.centerY.equalTo(coloredView.snp.centerY)
            make.width.equalTo(26)
        }
    }
}
