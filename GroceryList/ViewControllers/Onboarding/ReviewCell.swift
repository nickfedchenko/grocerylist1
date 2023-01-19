//
//  ReviewCell.swift
//  GroceryList
//
//  Created by Admin on 19.01.2023.
//

import UIKit

final class ReviewCell: UICollectionViewCell {
    static let identifier = String(describing: ReviewCell.self)
    
    private let reviewImage: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure (with image : UIImage?) {
        reviewImage.image = image
    }
    
    private func setupSubviews() {
        contentView.addSubview(reviewImage)
        
        reviewImage.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
}
