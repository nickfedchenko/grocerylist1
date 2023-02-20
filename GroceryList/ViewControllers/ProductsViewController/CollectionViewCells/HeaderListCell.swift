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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        pinchView.isHidden = true
        checkmarkView.isHidden = false
        coloredViewForSorting.isHidden = true
        coloredView.backgroundColor = .clear
        titleLabel.textColor = .white
        collapsedColoredView.backgroundColor = .clear
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let attrs = super.preferredLayoutAttributesFitting(layoutAttributes)
        attrs.bounds.size.height = 50
        return attrs
    }
    
    func collapsing(color: UIColor?, isPurchased: Bool) {
        UIView.animate(withDuration: 0.5) {
            self.checkmarkView.transform = CGAffineTransform(rotationAngle: .pi * 2)
            self.checkmarkView.tintColor = .white
            self.pinchView.tintColor = .white
            if !isPurchased {
                self.coloredView.backgroundColor = color
            } else {
                self.checkmarkView.tintColor = color
            }
        }
    }
    
    func expanding(color: UIColor?, isPurchased: Bool) {
        UIView.animate(withDuration: 0.5) {
            self.checkmarkView.transform = CGAffineTransform(rotationAngle: -.pi )
            self.checkmarkView.tintColor = color
            self.pinchView.tintColor = color
            if !isPurchased {
                self.coloredView.backgroundColor = .clear
            }
        }
    }
    
    func setupCell(text: String?, color: UIColor?, bcgColor: UIColor?, isExpand: Bool, typeOfCell: TypeOfCell) {
        switch typeOfCell {
        case .favorite:
            titleLabel.text = ""
            pinchView.isHidden = false
            pinchView.tintColor = color
            if !isExpand { coloredView.backgroundColor = color }
        case .purchased:
            coloredView.backgroundColor = .white
            titleLabel.textColor = color
            titleLabel.text = text
            collapsedColoredView.backgroundColor = .clear
        case .sortedByAlphabet:
            checkmarkView.isHidden = true
            titleLabel.text = "AlphabeticalSorted".localized
            coloredViewForSorting.backgroundColor = color
            coloredViewForSorting.isHidden = false
        case .sortedByDate:
            checkmarkView.isHidden = true
            titleLabel.text = text// "AddedEarlier".localized
            coloredViewForSorting.backgroundColor = color
            coloredViewForSorting.isHidden = false
        case .normal:
            titleLabel.text = text
            if isExpand {
                collapsedColoredView.backgroundColor = color
            } else {
                collapsedColoredView.backgroundColor = color
                coloredView.backgroundColor = color
            }
        }
        
        checkmarkView.tintColor = color
        
        if isExpand {
            checkmarkView.transform = CGAffineTransform(rotationAngle: -.pi )
        } else {
            checkmarkView.transform = CGAffineTransform(rotationAngle: .pi * 2)
        }
        
        containerView.backgroundColor = bcgColor
    }
    
    private let containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let coloredView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let checkmarkView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .clear
        view.image = R.image.chevronDown()
        view.tintColor = UIColor(hex: "#58B368")
        view.transform = CGAffineTransform(rotationAngle: .pi )
        return view
    }()
    
    let collapsedColoredView: CorneredView = {
        let view = CorneredView()
        view.layer.masksToBounds = true
        view.backgroundColor = .clear
        return view
    }()
    
    private let coloredViewForSorting: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMaxXMinYCorner]
        view.layer.masksToBounds = true
        view.isHidden = true
        return view
    }()
    
    private let checkmarkForSorting: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "sheckmarkForSorting")
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 17).font
        label.textColor = .white
        return label
    }()
    
    private let pinchView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "blackPinch")
        imageView.isHidden = true
        return imageView
    }()
    
    // MARK: - UI
    // swiftlint:disable:next function_body_length
    private func setupConstraints() {
        contentView.addSubviews([containerView])
        containerView.addSubviews([coloredView, collapsedColoredView, coloredViewForSorting, titleLabel, checkmarkView, pinchView])
        coloredViewForSorting.addSubview(checkmarkForSorting)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        coloredView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().inset(8)
        }
        
        collapsedColoredView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalTo(titleLabel.snp.right).inset(-26)
            make.height.equalTo(34)
            make.top.equalToSuperview().offset(12)
        }
        
        coloredViewForSorting.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalTo(checkmarkForSorting.snp.right).inset(-18)
            make.bottom.equalToSuperview().inset(4)
            make.top.equalToSuperview().inset(12)
        }
        
        checkmarkForSorting.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.right).inset(-22)
            make.width.equalTo(12)
            make.height.equalTo(7)
            make.centerY.equalTo(titleLabel)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(28)
            make.centerY.equalTo(coloredView.snp.centerY)
        }
        
        checkmarkView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(30)
            make.width.equalTo(19)
            make.height.equalTo(11)
            make.centerY.equalTo(coloredView.snp.centerY)
        }
        
        pinchView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(28)
            make.centerY.equalTo(coloredView.snp.centerY)
            make.width.equalTo(26)
        }
    }
}

class CorneredView: UIView {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        makeCustomRound(topLeft: 0, topRight: 20, bottomLeft: 0, bottomRight: 4)
    }
}
