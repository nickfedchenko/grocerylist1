//
//  RecipeColorCell.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 19.06.2023.
//

import UIKit

final class RecipeColorCell: UICollectionViewCell {
    
    private let colorView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(color: UIColor) {
        colorView.backgroundColor = color
    }
    
    private func setupSubviews() {
        colorView.layer.cornerRadius = 8
        colorView.layer.cornerCurve = .continuous
        colorView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        colorView.clipsToBounds = true
        
        contentView.addSubview(colorView)
        
        colorView.snp.makeConstraints {
            $0.leading.top.equalToSuperview()
            $0.height.equalTo(128)
            $0.width.equalTo(8)
        }
    }
}
