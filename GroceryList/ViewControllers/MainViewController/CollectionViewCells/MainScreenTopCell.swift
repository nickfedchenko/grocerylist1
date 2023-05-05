//
//  MainScreenTopCell.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 08.11.2022.
//

import SnapKit
import UIKit

class MainScreenTopCell: UICollectionViewCell {
    
    private let view = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        contentView.addSubview(view)
        view.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(113)
        }
    }
}
