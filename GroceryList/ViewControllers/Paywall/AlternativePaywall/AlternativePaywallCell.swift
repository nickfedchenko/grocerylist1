//
//  AlternativePaywallCell.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 31.01.2023.
//

import SnapKit
import UIKit

class AlternativePaywallCell: UICollectionViewCell {
    
    override var isSelected: Bool {
        didSet {
             isSelected ? selectCell() : deselectCell()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        containerView.layer.borderColor = UIColor.white.cgColor
        containerView.backgroundColor = .white
        mostPopularView.isHidden = true
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.masksToBounds = true
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
    
    private let mostPopularView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#31635A")
        view.layer.cornerRadius = 12
        view.layer.cornerCurve = .continuous
        view.layer.masksToBounds = true
        view.isHidden = true
        return view
    }()
    
    private let mostPopularLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.bold(size: 13).font
        label.textColor = .white
        label.text = "MostPopular".localized.uppercased()
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProDisplay.bold(size: 19).font
        label.textColor = UIColor(hex: "#1A645A")
        return label
    }()
    
    private let perWeekLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 13).font
        label.textColor = UIColor(hex: "#617774")
        label.text = "/WEEK".localized.lowercased()
        return label
    }()
    
    private let periodLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.bold(size: 17).font
        label.textColor = UIColor(hex: "#1A645A")
        label.text = "Year"
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 13).font
        label.textColor = UIColor(hex: "#617774")
        label.text = "$43.54"
        return label
    }()
    
    private let threeDaysFreeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 13).font
        label.textColor = UIColor(hex: "#657674")
        label.text = "3 days free".localized
        return label
    }()
    
    private let dotImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "paywallDot")
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func selectCell() {
        containerView.layer.borderColor = UIColor(hex: "#1A645A").cgColor
        threeDaysFreeLabel.textColor = UIColor(hex: "#1A645A")
    }
    
    private func deselectCell() {
        containerView.layer.borderColor = UIColor.white.cgColor
        threeDaysFreeLabel.textColor = UIColor(hex: "#617774")
    }
    
    func setupCell(isTopCell: Bool = false, price: String, description: String, period: String) {
        if isTopCell { mostPopularView.isHidden = false }
        priceLabel.text = price
        periodLabel.text = period
        perWeekLabel.text = "/ " + period.lowercased()
        descriptionLabel.text = price
    }

    // MARK: - UI

    // swiftlint:disable:next function_body_length
    private func setupConstraints() {
        contentView.addSubviews([containerView, mostPopularView])
        mostPopularView.addSubviews([mostPopularLabel])
        containerView.addSubviews([priceLabel, periodLabel, descriptionLabel, perWeekLabel, threeDaysFreeLabel, dotImage])
        
        mostPopularView.snp.makeConstraints { make in
            make.right.equalTo(containerView.snp.right).inset(16)
            make.centerY.equalTo(containerView.snp.top)
//            make.width.equalTo(138)
            make.height.equalTo(24)
        }
        
        containerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(72)
        }
        
        mostPopularLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        
        priceLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        
        periodLabel.snp.remakeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(16)
        }
        
        descriptionLabel.snp.remakeConstraints { make in
            make.bottom.equalToSuperview().inset(16)
            make.left.equalToSuperview().inset(16)
        }
        
        perWeekLabel.snp.makeConstraints { make in
            make.left.equalTo(descriptionLabel.snp.right).inset(-1)
            make.bottom.equalTo(priceLabel.snp.bottom).inset(2)
            make.centerY.equalTo(descriptionLabel.snp.centerY)
        }
        
        threeDaysFreeLabel.snp.makeConstraints { make in
            make.left.equalTo(perWeekLabel.snp.right).inset(-13)
            make.centerY.equalTo(descriptionLabel.snp.centerY)
        }
        
        dotImage.snp.makeConstraints { make in
            make.centerY.equalTo(threeDaysFreeLabel.snp.centerY)
            make.width.equalTo(3)
            make.height.equalTo(3)
            make.right.equalTo(threeDaysFreeLabel.snp.left).inset(-5)
        }
        
    }
}
