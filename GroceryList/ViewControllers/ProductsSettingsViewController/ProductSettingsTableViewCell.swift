//
//  ProductSettingsTableViewCell.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 15.11.2022.
//

import SnapKit
import UIKit

class ProductSettingsTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        image.snp.updateConstraints { make in
            make.left.equalToSuperview().inset(20)
        }
        separatorLine.snp.updateConstraints { make in
            make.left.equalToSuperview().inset(20)
        }
        
        label.textColor = .black
    }
    
    func setupCell(imageForCell: UIImage?, text: String?, inset: Bool,
                   separatorColor: UIColor, isCheckmarkActive: Bool) {
        if inset {
            image.snp.updateConstraints { make in
                make.left.equalToSuperview().inset(40)
            }
            separatorLine.snp.updateConstraints { make in
                make.left.equalToSuperview().inset(40)
            }
        }
        
        if text == "delete".localized {
            label.textColor = UIColor(hex: "#DF0404")
        }
        
        checkmarkImage.isHidden = !isCheckmarkActive
        separatorLine.backgroundColor = separatorColor
        image.image = imageForCell
        label.text = text
    }
    
    private let image: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 16).font
        label.textColor = .black
        label.text = "AddItem".localized
        return label
    }()
    
    private let separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private let checkmarkImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "cellCheckmark")
        return imageView
    }()
    
    // MARK: - UI
    private func setupConstraints() {
        backgroundColor = .clear
        contentView.addSubviews([image, label, separatorLine, checkmarkImage])
        
        image.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(20)
            make.height.width.equalTo(40)
            make.top.bottom.equalToSuperview().inset(1)
        }
        
        label.snp.makeConstraints { make in
            make.left.equalTo(image.snp.right).inset(-8)
            make.right.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
        
        separatorLine.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.right.equalToSuperview()
            make.left.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
        }
        
        checkmarkImage.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(30)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(20)
        }
    }
    
}
