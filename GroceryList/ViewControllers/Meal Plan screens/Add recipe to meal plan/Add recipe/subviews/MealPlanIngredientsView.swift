//
//  MealPlanIngredientsView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 18.09.2023.
//

import UIKit

protocol MealPlanIngredientsViewDelegate: AnyObject {
    func unit(unitID: Int?) -> UnitSystem?
    func convertValue() -> Double
    func servingChangedTo(count: Double)
    func addToCartButton()
}

class MealPlanIngredientsView: UIView {

    weak var delegate: MealPlanIngredientsViewDelegate?
    var photos: [Data?] {
        var photos: [Data?] = []
        ingredientsStack.arrangedSubviews.forEach {
            photos.append(($0 as? IngredientView)?.photo)
        }
        return photos
    }
    
    private let containerView = UIView()
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProRounded.bold(size: 18).font
        label.textColor = R.color.darkGray()
        label.text = R.string.localizable.ingredients()
        return label
    }()
    
    private lazy var servingView: RecipeServingSelector = {
       let view = RecipeServingSelector()
        view.delegate = self
        view.setColorForMealPlan()
        return view
    }()
    
    private lazy var addToCartButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(R.image.addToCartFilled(), for: .normal)
        button.addTarget(self, action: #selector(tappedAddToCartButton), for: .touchUpInside)
        button.backgroundColor = UIColor(hex: "1A645A")
        button.setCornerRadius(8)
        button.clipsToBounds = true
        return button
    }()
    
    private let vectorArrowImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.vectorArrow()?.withTintColor(UIColor(hex: "617774"))
        return imageView
    }()
    
    private let ingredientsStack: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillProportionally
        stackView.spacing = 8
        stackView.axis = .vertical
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupIngredients(recipe: Recipe) {
        servingView.setCountInitially(to: recipe.totalServings)

        ingredientsStack.removeAllArrangedSubviews()
        
        for ingredient in recipe.ingredients {
            let title = ingredient.product.title.firstCharacterUpperCase()
            var quantity = ingredient.quantity
            var unitTitle = ingredient.unit?.shortTitle ?? ""
            if let unit = delegate?.unit(unitID: ingredient.unit?.id) {
                quantity *= delegate?.convertValue() ?? 1
                unitTitle = unit.title
            }
            let unitCount = quantity
            let unitName = unitTitle
            let view = IngredientView()
            view.setTitle(title: title)
            view.setServing(serving: unitCount == 0 ? R.string.localizable.byTaste()
                                                    : unitCount.asString + " " + unitName)
            view.setDescription(ingredient.description)
            view.setImage(imageURL: ingredient.product.photo, imageData: ingredient.product.localImage)
            view.servingTextColor = UIColor(hex: "D6600A")
            ingredientsStack.addArrangedSubview(view)
        }
    }
    
    func updateIngredientsCount(by servings: [String]) {
        for (index, title) in servings.enumerated() {
            (ingredientsStack.arrangedSubviews[safe: index] as? IngredientView)?.setServing(serving: title)
        }
    }
    
    private func setup() {
        makeConstraints()
    }
    
    @objc
    private func tappedAddToCartButton() {
        delegate?.addToCartButton()
    }
    
    private func makeConstraints() {
        self.addSubview(containerView)
        containerView.addSubviews([titleLabel, servingView, addToCartButton, vectorArrowImage,
                                   ingredientsStack])
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(8)
            $0.height.equalTo(40)
        }
        
        servingView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.height.equalTo(40)
            $0.width.equalTo(200)
        }
        
        addToCartButton.snp.makeConstraints {
            $0.width.height.equalTo(40)
            $0.trailing.equalToSuperview()
            $0.centerY.equalTo(servingView)
        }
        
        vectorArrowImage.snp.makeConstraints {
            $0.centerY.equalTo(servingView)
            $0.leading.equalTo(servingView.snp.trailing).offset(9)
            $0.trailing.equalTo(addToCartButton.snp.leading).offset(-9)
        }
        
        ingredientsStack.setContentHuggingPriority(.init(1000), for: .vertical)
        ingredientsStack.setContentCompressionResistancePriority(.init(1000), for: .vertical)
        ingredientsStack.snp.makeConstraints {
            $0.top.equalTo(servingView.snp.bottom).offset(16)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
}

extension MealPlanIngredientsView: RecipeServingSelectorDelegate {
    func servingChangedTo(count: Double) {
        delegate?.servingChangedTo(count: count)
    }
}
