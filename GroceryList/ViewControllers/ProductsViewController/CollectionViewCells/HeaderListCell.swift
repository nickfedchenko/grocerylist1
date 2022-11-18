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
    
        override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
         let attrs = super.preferredLayoutAttributesFitting(layoutAttributes)
         attrs.bounds.size.height = 50
         return attrs
     }
    
    func collapsing() {
        coloredView.backgroundColor = .blue
    }
    
    func expanding() {
        coloredView.backgroundColor = .red
    }
    
    func setupCell(text: String?, color: UIColor?, bcgColor: UIColor?) {
        if text == "Purchased".localized {
            coloredView.backgroundColor = .white
            nameLabel.textColor = color
        } else {
            coloredView.backgroundColor = color
            contentViews.backgroundColor = bcgColor
            nameLabel.textColor = .white
        }
        contentViews.backgroundColor = bcgColor
        nameLabel.text = text
    }
    
    private let contentViews: UIView = {
        let view = UIView()
        return view
    }()
    
    private let coloredView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 17).font
        return label
    }()
    
    // MARK: - UI
    private func setupConstraints() {
        self.addSubviews([contentViews])
        contentViews.addSubviews([coloredView ,nameLabel])
        
        contentViews.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        coloredView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().inset(8)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(28)
            make.centerY.equalTo(coloredView.snp.centerY)
        }
       
    }
}
