//
//  RecipeKcalView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 05.07.2023.
//

import UIKit

class RecipeKcalView: UIView {
    
    private let chartImage = UIImageView()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillProportionally
        stackView.axis = .horizontal
        return stackView
    }()

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setKcalValue(value: Value?) {
        stackView.removeAllArrangedSubviews()
        NutritionFacts.allCases.forEach { nutritionFacts in
            let view = RecipeKcalSubView()
            let nutritionValue: Double?
            switch nutritionFacts {
            case .carb:     nutritionValue = value?.netCarbs
            case .protein:  nutritionValue = value?.proteins
            case .fat:      nutritionValue = value?.fats
            case .kcal:     nutritionValue = value?.kcal
            }
            
            view.setKcalValue(nutritionState: nutritionFacts, value: nutritionValue)
            
            stackView.addArrangedSubview(view)
        }
        
        let isActiveChart = !(value?.netCarbs == nil || value?.proteins == nil ||
                              value?.fats == nil || value?.kcal == nil)
        
        chartImage.image = isActiveChart ? R.image.kcalChart() : R.image.onlyKcalChart()
    }
    
    private func setup() {
        self.backgroundColor = .white
        
        makeConstraints()
    }
    
    private func makeConstraints() {
        self.addSubviews([chartImage, stackView])
        
        chartImage.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(8)
            $0.centerY.equalToSuperview()
            $0.height.width.equalTo(48)
        }

        stackView.snp.makeConstraints {
            $0.leading.equalTo(chartImage.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().offset(-8)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(36)
        }
    }
    
}

private final class RecipeKcalSubView: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 14).font
        label.textAlignment = .center
        return label
    }()
    
    private let gramLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 14).font
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setKcalValue(nutritionState: NutritionFacts, value: Double?) {
        titleLabel.text = nutritionState.recipeTitle
        
        guard let value else {
            titleLabel.textColor = R.color.lightGray()
            gramLabel.textColor = R.color.lightGray()
            gramLabel.text = "--"
            return
        }
        
        titleLabel.textColor = nutritionState.activeColor
        gramLabel.text = value.asInt.asString + " " + nutritionState.placeholder
    }
    
    private func setup() {
        self.backgroundColor = .white
        makeConstraints()
    }
    
    private func makeConstraints() {
        self.addSubviews([titleLabel, gramLabel])
        
        titleLabel.setContentHuggingPriority(.init(1000), for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.init(1000), for: .horizontal)
        titleLabel.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
        }

        gramLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}
