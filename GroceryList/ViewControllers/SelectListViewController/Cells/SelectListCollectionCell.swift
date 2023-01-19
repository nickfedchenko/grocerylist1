//
//  SelectListCollectionCell.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 23.11.2022.
//

import Foundation

class SelectListCollectionCell: GroceryCollectionViewCell {
    override func addGestureRecognizers() {}
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        replaceFont()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func replaceFont() {
        nameLabel.font = R.font.sfProTextSemibold(size: 17)
    }
}
