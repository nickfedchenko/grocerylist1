//
//  SendInvitationCell.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 16.02.2023.
//

import UIKit

final class SendInvitationCell: UITableViewCell {

    var sendInvitationAction: (() -> Void)?
    
    private lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.addCustomShadow(color: UIColor(hex: "#8585851A"), opacity: 0.1,
                             radius: 6, offset: CGSize(width: 0, height: 4))
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 15).font
        label.textColor = R.color.primaryDark()
        label.text = "Hello! Here is a great app".localized
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "AppIcon")
        imageView.layer.cornerRadius = 4
        imageView.clipsToBounds = true
        imageView.addCustomShadow(color: UIColor(hex: "#8585851A"), opacity: 0.1,
                                  radius: 6, offset: CGSize(width: 0, height: 4))
        return imageView
    }()
    
    private lazy var shareButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.share_button(), for: .normal)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setup() {
        self.selectionStyle = .none
        self.backgroundColor = .clear
        
        shareButton.addTarget(self, action: #selector(shareButtonAction), for: .touchUpInside)
        
        makeConstraints()
    }
    
    @objc
    private func shareButtonAction() {
        sendInvitationAction?()
    }
    
    private func makeConstraints() {
        self.addSubview(bgView)
        bgView.addSubviews([iconImageView, titleLabel, shareButton])
        
        bgView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        iconImageView.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(8)
            $0.centerY.equalToSuperview()
            $0.height.width.equalTo(32)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(shareButton.snp.leading).offset(-20)
            $0.height.equalTo(36)
        }
        
        shareButton.snp.makeConstraints {
            $0.trailing.bottom.equalToSuperview().offset(-4)
            $0.height.width.equalTo(40)
        }
    }
}
