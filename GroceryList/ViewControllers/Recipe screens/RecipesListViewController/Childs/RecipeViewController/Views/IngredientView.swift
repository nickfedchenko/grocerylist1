//
//  IngredientView.swift
//  GroceryList
//
//  Created by Vladimir Banushkin on 12.12.2022.
//

import UIKit

class IngredientView: UIView {
    
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
        backgroundColor = .white
        layer.cornerRadius = 8
        layer.cornerCurve = .continuous
    }
    
    func setTitle(title: String) {
        titleLabel.text = title
    }
    
    func setServing(serving: String) {
        servingLabel.text = serving
    }
    
    private func setupSubviews() {
        addSubview(titleLabel)
        addSubview(servingLabel)
        
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
