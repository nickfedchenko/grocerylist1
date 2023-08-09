//
//  SharedCell.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 16.02.2023.
//

import Kingfisher
import UIKit

final class SharedCell: UITableViewCell {

    private lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.addCustomShadow(color: UIColor(hex: "#8585851A"), opacity: 0.1,
                             radius: 6, offset: CGSize(width: 0, height: 4))
        return view
    }()
    
    private lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 17).font
        label.textColor = .black
        return label
    }()
    
    private lazy var userPhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = R.image.share_checkmark()
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(name: String?, photo: String?) {
        userNameLabel.text = name
        guard let userAvatarUrl = photo,
              let url = URL(string: userAvatarUrl) else {
            return userPhotoImageView.image = R.image.profile_icon()
        }
        
        let resource = ImageResource(downloadURL: url, cacheKey: url.absoluteString)
        userPhotoImageView.kf.setImage(with: resource,
                                       options: [
            .processor(DownsamplingImageProcessor(size: CGSize(width: 30, height: 30))),
            .scaleFactor(UIScreen.main.scale),
            .cacheOriginalImage
        ])
    }

    private func setup() {
        self.selectionStyle = .none
        self.backgroundColor = .clear
        
        makeConstraints()
    }
    
    private func makeConstraints() {
        self.addSubview(bgView)
        bgView.addSubviews([userPhotoImageView, userNameLabel, checkmarkImageView])
        
        bgView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalToSuperview()
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview().offset(-8)
        }
        
        userPhotoImageView.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(8)
            $0.centerY.equalToSuperview()
            $0.height.width.equalTo(32)
        }
        
        userNameLabel.snp.makeConstraints {
            $0.leading.equalTo(userPhotoImageView.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(checkmarkImageView.snp.leading).offset(-20)
            $0.height.equalTo(36)
        }
        
        checkmarkImageView.snp.makeConstraints {
            $0.trailing.bottom.equalToSuperview().offset(-4)
            $0.height.width.equalTo(40)
        }
    }
}
