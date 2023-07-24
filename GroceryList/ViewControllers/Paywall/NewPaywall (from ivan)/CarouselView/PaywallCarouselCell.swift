//
//  PaywallCarouselCell.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 17.07.2023.
//

import UIKit

final class PaywallCarouselCell: UICollectionViewCell {
    
    let imageView = UIImageView()
    private let colorView = UIView()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        colorView.backgroundColor = UIColor(hex: "59FFD4")
        
        imageView.contentMode = .scaleAspectFill
        self.contentView.addSubviews([imageView, colorView])
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        colorView.snp.makeConstraints {
            $0.leading.equalTo(self.contentView.snp.trailing)
            $0.verticalEdges.equalToSuperview()
            $0.width.equalTo(16)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
