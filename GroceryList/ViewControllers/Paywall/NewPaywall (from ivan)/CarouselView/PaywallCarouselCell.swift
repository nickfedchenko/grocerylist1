//
//  PaywallCarouselCell.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 17.07.2023.
//

import UIKit

final class PaywallCarouselCell: UICollectionViewCell {
    
    let imageView = UIImageView()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        imageView.contentMode = .scaleAspectFill
        self.contentView.addSubviews([imageView])
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
