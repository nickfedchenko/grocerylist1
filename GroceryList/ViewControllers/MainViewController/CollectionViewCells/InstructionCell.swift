//
//  InstructionCell.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 04.11.2022.
//

import SnapKit
import UIKit

class InstructionCell: UICollectionViewCell {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let contentViews: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    private func createImageView(with name: String) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: name)
        return imageView
    }
    
    private lazy var blackPinch = createImageView(with: "grayPinch")
    private lazy var rightArrow = createImageView(with: "#arrowRigth")
    private lazy var hand = createImageView(with: "#hand")
    private lazy var leftArrow = createImageView(with: "#arrowLeft")
    private lazy var trash = createImageView(with: "#trash")
    
    // MARK: - UI
    private func setupConstraints() {
        contentViews.backgroundColor = UIColor(hex: "#DAEAEE")
        self.addSubviews([contentViews])
        contentViews.addSubviews([blackPinch, rightArrow, hand, leftArrow, trash])
        
        contentViews.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        blackPinch.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(22)
            make.centerY.equalToSuperview()
            make.height.equalTo(24)
            make.width.equalTo(27)
        }
        
        rightArrow.snp.makeConstraints { make in
            make.left.equalTo(blackPinch.snp.right).inset(-15)
            make.centerY.equalToSuperview()
            make.height.equalTo(11)
            make.width.equalTo(15)
        }
        
        hand.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.height.equalTo(23)
            make.width.equalTo(17)
        }
        
        trash.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(22)
            make.centerY.equalToSuperview()
            make.height.equalTo(25)
            make.width.equalTo(17)
        }
        
        leftArrow.snp.makeConstraints { make in
            make.right.equalTo(trash.snp.left).inset(-19)
            make.centerY.equalToSuperview()
            make.height.equalTo(11)
            make.width.equalTo(15)
        }
    }
}
