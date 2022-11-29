//
//  SelectCategoryCell.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 28.11.2022.
//

import SnapKit
import UIKit

class SelectCategoryCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell(title: String?, isSelected: Bool, foregroundColor: UIColor?, lineColor: UIColor?) {
        titleLabel.text = title
        lineView.backgroundColor = lineColor
        
        if isSelected {
            containerView.backgroundColor = foregroundColor
            titleLabel.textColor = .white
        } else {
            containerView.backgroundColor = .white
            titleLabel.textColor = foregroundColor
        }
        
    }

    // MARK: - UI
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 16).font
        label.text = "selectAll".localized
        label.textColor = .black
        return label
    }()
    
    private let checkmarkImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "#checkmark")
        return imageView
    }()
    
    private let lineView: UIView = {
        let view = UIView()
        return view
    }()
    
    private func setupConstraints() {
        contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        contentView.addSubviews([containerView])
        containerView.addSubviews([titleLabel, checkmarkImage, lineView])
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        checkmarkImage.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(26)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(28)
            make.centerY.equalToSuperview()
            make.right.equalTo(checkmarkImage.snp.left).inset(-8)
        }
        
        lineView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(2)
        }
       
    }
}
