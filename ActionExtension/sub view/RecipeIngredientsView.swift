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
        label.text = "Ingredients".localized
        return label
    }()
    
    private lazy var servingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 17).font
        label.textColor = R.color.primaryDark()
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
            setupServings(servings: servings)
        }
        
        ingredientsStack.removeAllArrangedSubviews()

        for ingredient in recipe.ingredients where !ingredient.name.isEmpty {
            let title = ingredient.name.firstCharacterUpperCase()
            let quantity = ingredient.amount
            let unitTitle = ingredient.unit
            let view = IngredientView()
            view.setTitle(title: title)
            view.setServing(serving: quantity == "" ? R.string.localizable.byTaste()
                                                    : quantity + " " + unitTitle)
            ingredientsStack.addArrangedSubview(view)
        }
    }
    
    func setupServings(servings: Int) {
        var servingsString = ""
        switch servings {
        case 1:
            servingsString = "servings-1".localized
        case 2...4:
            servingsString = "servings-2-4".localized
        case 5...:
            servingsString = "servings>4".localized
        default:
            servingsString = "servings-1".localized
        }
        servingLabel.text = "\(servings) " + servingsString
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
