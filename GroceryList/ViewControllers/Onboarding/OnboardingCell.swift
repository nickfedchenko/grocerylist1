//
//  OnboardingCell.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 08.08.2023.
//

import UIKit

final class OnboardingCell: UICollectionViewCell {
    
    let imageView = UIImageView()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        imageView.contentMode = .scaleAspectFit
        self.contentView.addSubview(imageView)
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
