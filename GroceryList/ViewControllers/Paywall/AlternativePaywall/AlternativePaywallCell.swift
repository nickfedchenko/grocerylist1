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
        view.backgroundColor = UIColor(hex: "#D8F8EF")
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
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
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
    
    private let descriptLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 28).font
        label.textColor = UIColor(hex: "#31635A")
        label.text = "$43.54 / per month"
        return label
    }()
    
    private let perWeekLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 28).font
        label.textColor = UIColor(hex: "#31635A")
        label.text = "/WEEK"
        return label
    }()
    
    private let periodLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.bold(size: 17).font
        label.textColor = UIColor(hex: "#31635A")
        label.text = "Year"
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 13).font
        label.textColor = UIColor(hex: "#657674")
        label.text = "$43.54"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func selectCell() {
        containerView.layer.borderColor = UIColor(hex: "#31635A").cgColor
    }
    
    private func deselectCell() {
        containerView.layer.borderColor = UIColor.white.cgColor
    }
    
    func setupCell(isTopCell: Bool = false, price: String, description: String, period: String) {
        if isTopCell { mostPopularView.isHidden = false }
        descriptLabel.text = description
        periodLabel.text = period
        priceLabel.text = price
    }

    // MARK: - UI

    private func setupConstraints() {
        contentView.addSubviews([containerView, mostPopularView])
        mostPopularView.addSubviews([mostPopularLabel])
        containerView.addSubviews([descriptLabel, periodLabel, priceLabel, perWeekLabel])
        
        mostPopularView.snp.makeConstraints { make in
            make.left.equalTo(containerView.snp.left).inset(16)
            make.bottom.equalTo(containerView.snp.top)
            make.width.equalTo(138)
            make.height.equalTo(26)
        }
        
        containerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(72)
        }
        
        mostPopularLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(3)
            make.centerY.equalToSuperview()
        }
        
        descriptLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
        
        periodLabel.snp.remakeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(16)
        }
        
        priceLabel.snp.remakeConstraints { make in
            make.bottom.equalToSuperview().inset(16)
            make.left.equalToSuperview().inset(16)
        }
        
        perWeekLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        
    }
}
