//
//  ShowCollectionCell.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 08.03.2023.
//

import UIKit

final class ShowCollectionCell: UITableViewCell {
    
    var contextMenuTapped: ((CGPoint, ShowCollectionCell) -> Void)?
    
    private lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = R.color.lightGray()
        view.layer.cornerRadius = 1
        return view
    }()
    
    private lazy var selectView: UIView = {
        let view = UIView()
        view.backgroundColor = R.color.action()
        return view
    }()
    
    private lazy var collectionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProRounded.bold(size: 18).font
        label.textColor = R.color.primaryDark()
        label.numberOfLines = 3
        return label
    }()
    
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProRounded.bold(size: 18).font
        label.textColor = UIColor(hex: "#7A948F")
        return label
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var contextMenuButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.pantry_context_menu()?.withTintColor(R.color.darkGray() ?? .black),
                        for: .normal)
        button.addTarget(self, action: #selector(tapContexMenuButton), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.autoresizingMask = .flexibleHeight
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contextMenuButton.isHidden = true
        countLabel.textColor = UIColor(hex: "#7A948F")
        collectionLabel.textColor = R.color.primaryDark()
        iconImageView.snp.updateConstraints { $0.leading.equalToSuperview().offset(20) }
        countLabel.snp.updateConstraints { $0.trailing.equalToSuperview().offset(-31) }
        bgView.snp.updateConstraints { $0.leading.trailing.equalToSuperview().offset(0) }
    }
    
    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        if !subview.description.contains("Reorder") {
            return
        }
        (subview.subviews.first as? UIImageView)?.removeFromSuperview()

        let imageView = UIImageView()
        imageView.image = R.image.rearrange()?.withTintColor(R.color.lightGray() ?? .lightGray)
        subview.addSubview(imageView)
            
        imageView.snp.makeConstraints {
            $0.height.width.equalTo(40)
            $0.centerY.equalToSuperview()
        }
    }
    
    func configureCreateCollection() {
        setSeparator(false)
        collectionLabel.text = R.string.localizable.createCollection()
        
        countLabel.text = ""
        iconImageView.image = R.image.recipePlus()
        selectView.isHidden = true
    }
    
    func configure(title: String?, count: Int?) {
        collectionLabel.text = title
        countLabel.text = "\(count ?? 0)"
        setSeparator(true)
    }
    
    func configure(isSelect: Bool) {
        iconImageView.image = isSelect ? R.image.menuFolder() : R.image.collection()
        selectView.isHidden = !isSelect
    }
    
    func configure(isTechnical: Bool) {
        guard isTechnical else {
            return
        }
        let color = R.color.mediumGray() ?? .systemGray5
        iconImageView.image = R.image.collection()?.withTintColor(color)
        collectionLabel.textColor = color
        countLabel.textColor = color
    }
    
    func configure(isTechnical: Bool, color: Theme) {
        contextMenuButton.isHidden = isTechnical
        guard isTechnical else {
            iconImageView.image = R.image.collection()?.withTintColor(color.medium)
            collectionLabel.textColor = color.dark
            countLabel.textColor = color.medium
            return
        }
        let color = R.color.mediumGray() ?? .systemGray5
        iconImageView.image = R.image.collection()?.withTintColor(color)
        collectionLabel.textColor = color
        countLabel.textColor = color
    }
    
    func updateConstraintsForEditState() {
        iconImageView.snp.updateConstraints { $0.leading.equalToSuperview().offset(68) }
        countLabel.snp.updateConstraints { $0.trailing.equalToSuperview().offset(-68) }
        contextMenuButton.isHidden = false
        contextMenuButton.snp.makeConstraints {
            $0.height.width.equalTo(40)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-20)
        }
    }

    private func setup() {
        self.selectionStyle = .none
        self.backgroundColor = .clear
        makeConstraints()
    }
    
    private func setSeparator(_ isVisible: Bool) {
        separatorView.isHidden = !isVisible
    }
    
    @objc
    private func tapContexMenuButton() {
        contextMenuTapped?(contextMenuButton.center, self)
    }
    
    private func makeConstraints() {
        self.addSubviews([separatorView, bgView])
        bgView.addSubviews([selectView, iconImageView, collectionLabel, countLabel,
                            contextMenuButton])
        
        bgView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().offset(0)
            $0.top.equalToSuperview()
            $0.height.equalTo(66)
        }
        
        separatorView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(2)
        }
        
        selectView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(2)
        }
        
        iconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(separatorView.snp.bottom).offset(12)
            $0.height.width.equalTo(40)
        }
        
        collectionLabel.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(17)
            $0.centerY.equalTo(iconImageView)
            $0.height.greaterThanOrEqualTo(24)
            $0.trailing.equalTo(countLabel.snp.leading).offset(-8)
        }
        
        countLabel.setContentHuggingPriority(.init(999), for: .horizontal)
        countLabel.setContentCompressionResistancePriority(.init(999), for: .horizontal)
        countLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-31)
            $0.centerY.equalTo(iconImageView)
        }
    }

}
