//
//  ProductListCell.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 14.11.2022.
//

import SnapKit
import UIKit

class ProductListCell: UICollectionViewListCell {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
         let attrs = super.preferredLayoutAttributesFitting(layoutAttributes)
         attrs.bounds.size.height = 56
         return attrs
     }
    
    func setupCell(bcgColor: UIColor?, text: String?, isPurchased: Bool) {
        contentView.backgroundColor = bcgColor
        checkmarkImage.image = isPurchased ? UIImage(named: "purchasedCheckmark") : UIImage(named: "emptyCheckmark")
        nameLabel.text = text
    }
    
    private let contentViews: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    private let checkmarkImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "emptyCheckmark")
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 16).font
        label.textColor = .black
        return label
    }()
    
    // MARK: - UI
    private func setupConstraints() {
        contentView.addSubviews([contentViews])
        contentViews.addSubviews([nameLabel, checkmarkImage])
        
        contentViews.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(8)
            make.bottom.equalToSuperview()
        }
        
        checkmarkImage.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(checkmarkImage.snp.right).inset(-12)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(8)
        }
       
    }
}
