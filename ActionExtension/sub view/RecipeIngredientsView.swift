//
//  RecipeIngredientsView.swift
//  ActionExtension
//
//  Created by Хандымаа Чульдум on 02.08.2023.
//

import UIKit

class RecipeIngredientsView: UIView {

    private lazy var ingredientsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProRounded.bold(size: 18).font
        label.textColor = R.color.primaryDark()
        label.text = R.string.localizable.ingredients()
        return label
    }()
    
    private lazy var servingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 17).font
        label.textColor = R.color.primaryDark()
        label.text = R.string.localizable.servings()
        return label
    }()
    
    let ingredientsStack: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillProportionally
        stackView.spacing = 8
        stackView.axis = .vertical
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(recipe: WebRecipe) {
        if let servings = recipe.servings {
            var servingsString = ""
            switch servings {
            case 1:
                servingsString = R.string.localizable.servings1()
            case 2...4:
                servingsString = R.string.localizable.servings24()
            case 5...:
                servingsString = R.string.localizable.servings4()
            default:
                servingsString = R.string.localizable.servings1()
            }
            servingLabel.text = "\(servings) " + servingsString
        }
        
        ingredientsStack.removeAllArrangedSubviews()

        for ingredient in recipe.ingredients where !ingredient.name.isEmpty {
            let title = ingredient.name.firstCharacterUpperCase()
            var quantity = ingredient.amount
            var unitTitle = ingredient.unit
            let view = IngredientView()
            view.setTitle(title: title)
            view.setServing(serving: quantity == "" ? R.string.localizable.byTaste()
                            : quantity + " " + unitTitle)
            ingredientsStack.addArrangedSubview(view)
        }
    }
    
    private func makeConstraints() {
        self.addSubviews([ingredientsLabel, servingLabel, ingredientsStack])
        
        ingredientsLabel.snp.makeConstraints {
            $0.horizontalEdges.top.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        servingLabel.snp.makeConstraints {
            $0.top.equalTo(ingredientsLabel.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        ingredientsStack.setContentHuggingPriority(.init(1000), for: .vertical)
        ingredientsStack.setContentCompressionResistancePriority(.init(1000), for: .vertical)
        ingredientsStack.snp.makeConstraints {
            $0.top.equalTo(servingLabel.snp.bottom).offset(8)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }
}
