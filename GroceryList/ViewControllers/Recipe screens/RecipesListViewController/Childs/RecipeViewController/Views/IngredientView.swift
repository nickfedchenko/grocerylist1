//
//  IngredientView.swift
//  GroceryList
//
//  Created by Vladimir Banushkin on 12.12.2022.
//

import UIKit

class IngredientView: UIView {
    
    let contentView = ViewWithOverriddenPoint()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 8
        imageView.layer.cornerCurve = .continuous
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = R.font.sfProTextMedium(size: 16)
        label.textColor = .black
        label.textAlignment = .left
        label.numberOfLines = 0
        label.sizeToFit()
        return label
    }()
    
    let servingLabel: UILabel = {
        let label = UILabel()
        label.font = R.font.sfProTextMedium(size: 16)
        label.textColor = UIColor(hex: "FF764B")
        label.textAlignment = .right
        return label
    }()
    
    var servingText: String? {
        servingLabel.text
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        let labelWidth = servingLabel.intrinsicContentSize.width
        let viewWidth = self.frame.width / 2.2
        let maxWidth = labelWidth > viewWidth ? viewWidth : labelWidth
        servingLabel.numberOfLines = 3
        servingLabel.snp.updateConstraints {
            $0.width.greaterThanOrEqualTo(maxWidth)
        }
    }
    
    private func setupAppearance() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 8
        contentView.layer.cornerCurve = .continuous
    }
    
    func setTitle(title: String) {
        titleLabel.text = title
    }
    
    func setServing(serving: String) {
        servingLabel.text = serving
    }
    
    func setImage(imageURL: String, imageData: Data?) {
        if let imageData {
            imageView.image = UIImage(data: imageData)
            titleLabel.snp.updateConstraints { make in
                make.leading.equalToSuperview().offset(50)
            }
            return
        }
        guard !imageURL.isEmpty else {
            imageView.snp.updateConstraints { make in
                make.width.equalTo(0)
            }
            return
        }
        imageView.kf.setImage(with: URL(string: imageURL), placeholder: nil,
                              options: nil, completionHandler: nil)
        titleLabel.snp.updateConstraints { make in
            make.leading.equalToSuperview().offset(50)
        }
    }
    
    private func setupSubviews() {
        addSubview(contentView)
        contentView.addSubviews([imageView, titleLabel, servingLabel])
        
        contentView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(4)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.top.bottom.equalToSuperview().inset(15)
            make.trailing.equalTo(servingLabel.snp.leading).inset(-18)
        }
        
        servingLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(15)
            make.top.greaterThanOrEqualTo(15)
            make.trailing.equalToSuperview().inset(12)
            make.width.greaterThanOrEqualTo(50)
        }
    }
}
