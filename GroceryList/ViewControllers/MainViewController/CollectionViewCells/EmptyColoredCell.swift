//
//  EmptyColoredCell.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 04.11.2022.
//

import SnapKit
import UIKit

class EmptyColoredCell: UICollectionViewCell {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentViews.layer.cornerRadius = 0
        self.layoutIfNeeded()
    }
    
    func setupCell(bckgColor: UIColor, isTopRounded: Bool, isBottomRounded: Bool) {
        contentViews.backgroundColor = bckgColor

        
        if isBottomRounded && isTopRounded {
            contentViews.layer.cornerRadius = 8
            contentViews.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            return
        }
        
        if isBottomRounded {
            contentViews.layer.cornerRadius = 8
            contentViews.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        }
        
        if isTopRounded {
            contentViews.layer.cornerRadius = 8
            contentViews.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        }
    }
    
    private let contentViews: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.masksToBounds = true
        return view
    }()
    
    // MARK: - UI
    private func setupConstraints() {
        backgroundColor = UIColor(hex: "#E8F5F3")
        self.addSubviews([contentViews])
        contentViews.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
