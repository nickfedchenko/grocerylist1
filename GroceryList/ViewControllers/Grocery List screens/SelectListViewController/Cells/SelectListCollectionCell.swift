//
//  SelectListCollectionCell.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 23.11.2022.
//

import UIKit

class SelectListCollectionCell: GroceryCollectionViewCell {
    var theme: Theme?
    
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
    
    func markAsSelect(isSelect: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.contentViews.backgroundColor = isSelect ? self.theme?.dark
                                                         : self.theme?.medium
            self.sharingView.updateColorPlusImage(isSelect ? self.theme?.dark
                                                           : self.theme?.medium)
        }
        
    }
}
