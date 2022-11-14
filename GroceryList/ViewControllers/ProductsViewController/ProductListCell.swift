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
    
    func setupCell(bcgColor: UIColor?) {
        contentView.backgroundColor = bcgColor
    }
    
    private let contentViews: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.masksToBounds = true
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 17).font
        label.textColor = .white
        return label
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 17).font
        label.textColor = .white
        return label
    }()
    
    private let shareAvatarImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "shareAvatar")
        return imageView
    }()
     
    // MARK: - UI
    private func setupConstraints() {
        contentViews.backgroundColor = .white
        contentView.backgroundColor = .white
        self.addSubviews([contentViews])
        contentViews.addSubviews([nameLabel, countLabel, shareAvatarImage])
        
        contentViews.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().inset(1)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(11)
        }
        
        countLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(11)
        }
        
        shareAvatarImage.snp.makeConstraints { make in
            make.height.width.equalTo(32)
            make.right.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
       
    }
}
