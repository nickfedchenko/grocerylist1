//
//  ProductSettingsTableViewCell.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 15.11.2022.
//

import SnapKit
import UIKit

class ProductSettingsTableViewCell: UITableViewCell {
    
    var switchValueChanged: ((Bool) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        imageSwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
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
        label.snp.removeConstraints()
        label.snp.makeConstraints { make in
            make.left.equalTo(image.snp.right).inset(-8)
            make.right.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
        image.isHidden = false
        sharingView.isHidden = true
        imageSwitch.isHidden = true
        checkmarkImage.isHidden = true
        label.textColor = .black
    }
    
    func setupCell(imageForCell: UIImage?, text: String?,
                   separatorColor: UIColor, checkmarkColor: UIColor, isCheckmarkActive: Bool) {
        if text == "delete".localized {
            label.textColor = R.color.attention()
        }
        if isCheckmarkActive {
            checkmarkImage.image = checkmarkImage.image?.withTintColor(checkmarkColor)
        }
        checkmarkImage.isHidden = !isCheckmarkActive
        separatorLine.backgroundColor = separatorColor
        image.image = imageForCell
        label.text = text
    }
    
    func setupSortCell(text: String?, imageForCell: UIImage?, separatorColor: UIColor,
                       checkmarkColor: UIColor, isCheckmarkActive: Bool) {
        separatorLine.backgroundColor = separatorColor
        checkmarkImage.isHidden = !isCheckmarkActive
        if isCheckmarkActive {
            checkmarkImage.image = checkmarkImage.image?.withTintColor(checkmarkColor)
            image.image = imageForCell?.withTintColor(checkmarkColor)
            label.textColor = checkmarkColor
            label.text = text
        } else {
            label.textColor = R.color.darkGray()
            label.text = text
            image.image = imageForCell?.withTintColor(R.color.darkGray() ?? UIColor(hex: "537979"))
        }
    }
    
    func setupSwitch(isVisible: Bool, value: Bool, tintColor: UIColor) {
        imageSwitch.isHidden = !isVisible
        if isVisible {
            imageSwitch.isOn = value
            imageSwitch.onTintColor = tintColor
        }
    }
    
    func setupShareView(isVisible: Bool, users: [String?], tintColor: UIColor) {
        sharingView.isHidden = !isVisible
        if isVisible {
            sharingView.configure(state: .added, viewState: .productsSettings,
                                  color: tintColor, images: users)
            image.isHidden = isVisible
            label.snp.removeConstraints()
            label.snp.makeConstraints { make in
                make.left.equalTo(sharingView.snp.right).inset(-8)
                make.right.equalToSuperview().inset(20)
                make.centerY.equalToSuperview()
            }
        }
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
    
    private let imageSwitch: UISwitch = {
        let imageSwitch = UISwitch()
        imageSwitch.isHidden = true
        return imageSwitch
    }()
    
    private let sharingView = SharingView()
    
    @objc
    private func switchChanged() {
        switchValueChanged?(imageSwitch.isOn)
    }
    
    // MARK: - UI
    private func setupConstraints() {
        backgroundColor = .clear
        contentView.addSubviews([image, label, separatorLine, checkmarkImage, imageSwitch, sharingView])
        
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
            make.height.equalTo(2)
            make.right.equalToSuperview()
            make.left.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
        }
        
        checkmarkImage.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(30)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(20)
        }
        
        imageSwitch.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
        
        sharingView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
            make.height.equalTo(40)
        }
    }
    
}
