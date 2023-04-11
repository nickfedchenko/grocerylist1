//
//  AddListView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 11.04.2023.
//

import UIKit

final class AddListView: UIView {
    
    private let plusImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = R.image.new_createList()
        return imageView
    }()
    
    private let createListLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProRounded.semibold(size: 18).font
        label.textColor = UIColor(hex: "#31635A")
        label.text = "CreateList".localized
        label.numberOfLines = 2
        return label
    }()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        self.layer.cornerRadius = 32
        self.layer.masksToBounds = true
        self.layer.maskedCorners = [.layerMinXMinYCorner]
        self.backgroundColor = .white
        self.layer.borderColor = UIColor(hex: "#EBFEFE").cgColor
        self.layer.borderWidth = 2
        self.addCustomShadow(color: UIColor(hex: "#484848"), offset: CGSize(width: 0, height: 0.5))
        
        makeConstraints()
    }
    
    private func makeConstraints() {
        self.addSubviews([plusImage, createListLabel])
        
        plusImage.snp.makeConstraints { make in
            make.left.top.equalToSuperview().inset(16)
            make.height.width.equalTo(32)
        }
        
        createListLabel.snp.makeConstraints { make in
            make.left.equalTo(plusImage.snp.right).inset(-12)
            make.right.equalToSuperview().inset(8)
            make.centerY.equalTo(plusImage)
        }
    }
}
