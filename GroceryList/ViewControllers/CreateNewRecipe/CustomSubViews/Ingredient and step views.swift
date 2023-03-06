//
//  IngredientForCreateRecipeView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 03.03.2023.
//

import UIKit

final class IngredientForCreateRecipeView: IngredientView {

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.regular(size: 14).font
        label.textColor = UIColor(hex: "#303030")
        label.textAlignment = .left
        label.numberOfLines = 0
        label.sizeToFit()
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setDescription(_ description: String?) {
        guard let description else {
            return
        }
        descriptionLabel.text = description
        setupDescriptionLabel()
    }
    
    private func setupDescriptionLabel() {
        self.addSubview(descriptionLabel)
        
        descriptionLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(titleLabel)
            $0.top.equalTo(titleLabel.snp.bottom).offset(2)
            $0.bottom.equalToSuperview().offset(-7)
        }
        
        titleLabel.snp.removeConstraints()
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.top.equalToSuperview().inset(7)
            make.trailing.equalTo(servingLabel.snp.leading).inset(-18)
        }
    }
}

final class StepForCreateRecipeView: UIView {
    
    private lazy var stepLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProRounded.medium(size: 16).font
        label.textColor = UIColor(hex: "#1A645A")
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 16).font
        label.textColor = .black
        label.numberOfLines = 0
        label.sizeToFit()
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(step: String, description: String?) {
        stepLabel.text = step
        descriptionLabel.text = description
        
        if descriptionLabel.intrinsicContentSize.height > stepLabel.intrinsicContentSize.height {
            stepLabel.snp.updateConstraints {
                $0.top.equalTo(descriptionLabel.snp.top).offset(10)
            }
        }
    }
    
    private func setup() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 8
        
        makeConstraints()
    }
    
    private func makeConstraints() {
        self.addSubviews([stepLabel, descriptionLabel])
        
        stepLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalTo(descriptionLabel.snp.leading)
            $0.top.equalTo(descriptionLabel.snp.top).offset(0)
            $0.height.equalTo(20)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(54)
            $0.trailing.equalToSuperview().offset(-8)
            $0.top.equalToSuperview().offset(12)
            $0.bottom.equalToSuperview().offset(-12)
        }
    }
}
