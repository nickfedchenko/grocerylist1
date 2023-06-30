//
//  PhotoFromRecipesCell.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 22.06.2023.
//

import UIKit

class PhotoFromRecipesCell: UICollectionViewCell {
    
    let mainImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()
    
    let checkmarkImage: UIImageView = {
        let image = UIImageView()
        image.image = R.image.photoEmptyCheckmark()
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        mainImage.image = nil
    }
    
    func configure(image: UIImage) {
        mainImage.image = image
    }
    
    func markAsSelect() {
        checkmarkImage.image = R.image.photoSelected()
    }

    func makeConstraints() {
        contentView.addSubviews([mainImage, checkmarkImage])
        
        mainImage.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        checkmarkImage.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.trailing.equalToSuperview().offset(-8)
            $0.width.height.equalTo(32)
        }
    }
} 
