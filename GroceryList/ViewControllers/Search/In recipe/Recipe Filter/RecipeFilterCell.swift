//
//  RecipeFilterCell.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 07.07.2023.
//

import UIKit

class RecipeFilterCell: PredictiveTextCell {
    
    var markAsSelect = false {
        didSet { updateView() }
    }
    
    private var borderColor = R.color.primaryLight() {
        didSet { self.layer.borderColor = borderColor?.cgColor }
    }
    private var selectColor = R.color.darkGray()
    
    override func setup() {
        super.setup()
        self.contentView.backgroundColor = .white
        self.layer.borderWidth = 1
        self.addCustomShadow(color: UIColor(hex: "484848"), radius: 1.5, offset: .init(width: 0, height: 0.8))
    }
    
    override func tappedOnView() {
        super.tappedOnView()
        markAsSelect.toggle()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.contentView.backgroundColor = .white
        titleLabel.textColor = .black
    }
    
    func setupColor(border: UIColor?, select: UIColor?) {
        borderColor = border
        selectColor = select
    }
    
    func updateView() {
        guard markAsSelect else {
            self.contentView.backgroundColor = .white
            titleLabel.textColor = .black
            return
        }
        self.contentView.backgroundColor = selectColor
        titleLabel.textColor = .white
    }
    
}
