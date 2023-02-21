//
//  IngredientView.swift
//  GroceryList
//
//  Created by Vladimir Banushkin on 12.12.2022.
//

import UIKit

final class IngredientView: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = R.font.sfProTextMedium(size: 16)
        label.textColor = .black
        label.textAlignment = .left
        return label
    }()
    
    private let servingLabel: UILabel = {
        let label = UILabel()
        label.font = R.font.sfProTextMedium(size: 16)
        label.textColor = UIColor(hex: "FF764B")
        label.textAlignment = .right
        label.numberOfLines = 0
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
    
    private func setupAppearance() {
        backgroundColor = .white
        layer.cornerRadius = 8
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
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalTo(servingLabel.snp.leading).inset(12).priority(.low)
        }
        
        servingLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(14)
            make.trailing.equalToSuperview().inset(12)
            make.leading.equalTo(titleLabel.snp.trailing).offset(12).priority(.high)
        }
    }
}
