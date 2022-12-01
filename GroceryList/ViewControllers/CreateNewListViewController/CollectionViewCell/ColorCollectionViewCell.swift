//
//  ColorCollectionViewCell.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 09.11.2022.
//

import SnapKit
import UIKit

class ColorCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }
    
    override var isSelected: Bool {
        didSet {
             isSelected ? selectCell() : deselectCell()
        }
    }
    
    private func selectCell() {
        whiteBackground.isHidden = false
        checkmarkImage.isHidden = false
    }
    
    private func deselectCell() {
        whiteBackground.isHidden = true
        checkmarkImage.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell(listColor: UIColor, backgroundColor: UIColor) {
        backgroundColorView.backgroundColor = backgroundColor
        roundColorView.backgroundColor = listColor
    }
    
    private let whiteBackground: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 6
        view.layer.masksToBounds = true
        view.backgroundColor = .white
        view.isHidden = true
        return view
    }()
    
    private let backgroundColorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.masksToBounds = true
        return view
    }()
    
    private let roundColorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    private let checkmarkImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "#checkmark")
        imageView.isHidden = true
        return imageView
    }()

    // MARK: - UI

    private func setupConstraints() {
        contentView.addSubviews([whiteBackground, backgroundColorView, roundColorView, checkmarkImage])
        whiteBackground.snp.makeConstraints { make in
            make.left.right.top.bottom.equalTo(backgroundColorView).inset(-3)
        }
        
        backgroundColorView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview().inset(4)
        }
        
        roundColorView.snp.makeConstraints { make in
            make.width.height.equalTo(32)
            make.centerY.centerX.equalToSuperview()
        }
        
        checkmarkImage.snp.makeConstraints { make in
            make.width.height.equalTo(16)
            make.centerY.centerX.equalToSuperview()
        }
    }
}
