//
//  IconCollectionViewCell.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 30.05.2023.
//

import UIKit

final class IconCollectionViewCell: UICollectionViewCell {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 4
        self.layer.cornerCurve = .continuous
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        self.backgroundColor = .clear
    }
    
    func configure(icon: UIImage?) {
        imageView.image = icon
        imageView.tintColor = .white
    }
    
    func selectCell(color: UIColor?) {
        self.backgroundColor = color
    }

    private func setupConstraints() {
        contentView.addSubviews([imageView])
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
