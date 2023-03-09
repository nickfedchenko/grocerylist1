//
//  ShowCollectionCell.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 08.03.2023.
//

import UIKit

final class ShowCollectionCell: UITableViewCell {
    
    private lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#62D3B4")
        view.layer.cornerRadius = 1
        return view
    }()
    
    private lazy var selectView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#85F3D5")
        return view
    }()
    
    private lazy var collectionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProRounded.bold(size: 18).font
        label.textColor = UIColor(hex: "#1A645A")
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
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

    private func setup() {
        self.selectionStyle = .none
        self.backgroundColor = .clear
        
        makeConstraints()
    }
    
    private func setSeparator(_ isVisible: Bool) {
        separatorView.isHidden = !isVisible
    }
    
    private func makeConstraints() {
        self.addSubview(bgView)
        bgView.addSubviews([separatorView, selectView, iconImageView, collectionLabel, countLabel])
        
        bgView.snp.makeConstraints {
            $0.edges.equalToSuperview()
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
            $0.height.equalTo(24)
        }
        
        countLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-31)
            $0.centerY.equalTo(iconImageView)
        }
    }

}
