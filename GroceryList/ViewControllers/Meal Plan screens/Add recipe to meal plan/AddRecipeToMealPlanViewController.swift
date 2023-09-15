//
//  AddRecipeToMealPlanViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 14.09.2023.
//

import UIKit

class AddRecipeToMealPlanViewController: UIViewController {

    private let viewModel: AddRecipeToMealPlanViewModel
    
    private let grabberBackgroundView = UIView()
    
    private let grabberView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "3C3C43", alpha: 0.3)
        view.setCornerRadius(2.5)
        return view
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setTitle("  " + R.string.localizable.back(), for: .normal)
        button.setImage(R.image.greenArrowBack()?.withTintColor(UIColor(hex: "045C5C")), for: .normal)
        button.titleLabel?.font = UIFont.SFProRounded.bold(size: 16).font
        button.setTitleColor(R.color.primaryDark(), for: .normal)
        button.addTarget(self, action: #selector(tappedBackButton), for: .touchUpInside)
        button.setContentCompressionResistancePriority(.init(1000), for: .horizontal)
        return button
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(hex: "045C5C")
        button.setTitle("Done".localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.SFProRounded.heavy(size: 17).font
        button.addTarget(self, action: #selector(tappedDoneButton), for: .touchUpInside)
        button.contentEdgeInsets.left = 20
        button.contentEdgeInsets.right = 20
        button.layer.cornerRadius = 20
        button.layer.cornerCurve = .continuous
        button.layer.maskedCorners = [.layerMinXMaxYCorner]
        return button
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.contentInset.top = 78
        scrollView.contentInset.bottom = 120
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()
    
    private let contentView = UIView()
    
    private let recipeView = MealPlanRecipeView()
    private let dateView = MealPlanDateView()
    private let mealPlanLabelView = MealPlanLabelView()
    private let destinationListView = MealPlanDestinationListView()
    private let ingredientsView = RecipeIngredientsView()
    private let descriptionView = RecipeDescriptionView()
    private let instructionsView = RecipeInstructionsView()
    
    init(viewModel: AddRecipeToMealPlanViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = R.color.background()
        grabberBackgroundView.backgroundColor = viewModel.theme.light.withAlphaComponent(0.95)
        
        setupRecipe()
        setupMealPlan()
        makeConstraints()
    }
    
    private func setupRecipe() {
        let recipe = viewModel.recipe
        recipeView.configure(with: recipe)
        recipeView.configureColor(theme: viewModel.theme)
        
        if !recipe.description.isEmpty {
            descriptionView.configure(description: recipe.description)
        } else {
            descriptionView.snp.remakeConstraints {
                $0.top.equalTo(ingredientsView.snp.bottom).offset(0)
                $0.height.equalTo(0)
            }
        }
        
        instructionsView.setupInstructions(instructions: recipe.instructions ?? [])
        setupIngredients(recipe: recipe)
    }
    
    private func setupIngredients(recipe: Recipe) {
        ingredientsView.setupServings(servings: 0)
        
        ingredientsView.ingredientsStack.removeAllArrangedSubviews()

        for ingredient in recipe.ingredients {
            let title = ingredient.product.title.firstCharacterUpperCase()
            let quantity = ingredient.quantity
            let unitTitle = ingredient.unit?.shortTitle ?? ""
            let view = IngredientView()
            view.setTitle(title: title)
            view.setServing(serving: quantity <= 0 ? R.string.localizable.byTaste()
                            : quantity.asString + " " + unitTitle)
            ingredientsView.ingredientsStack.addArrangedSubview(view)
        }
    }
    
    private func setupMealPlan() {
        mealPlanLabelView.configure(allLabels: viewModel.labels)
        
        guard let mealPlan = viewModel.mealPlan else {
            return
        }
        
        dateView.configure(date: mealPlan.date)
        destinationListView.configure(list: viewModel.getListName())
    }
    
    @objc
    private func tappedBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func tappedDoneButton() {
//        self.
    }
    
    private func makeConstraints() {
        self.view.addSubviews([scrollView, grabberBackgroundView, grabberView, backButton, doneButton])
        self.scrollView.addSubview(contentView)
        contentView.addSubviews([recipeView, dateView, mealPlanLabelView, destinationListView,
                                 ingredientsView, descriptionView, instructionsView])
        
        navigationMakeConstraints()

        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(self.view)
        }
        
        recipeView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.height.equalTo(64)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        dateView.snp.makeConstraints {
            $0.top.equalTo(recipeView.snp.bottom).offset(16)
            $0.height.equalTo(56)
            $0.leading.trailing.equalTo(recipeView)
        }
        
        mealPlanLabelView.snp.makeConstraints {
            $0.top.equalTo(dateView.snp.bottom).offset(16)
            $0.height.greaterThanOrEqualTo(96)
            $0.leading.trailing.equalTo(recipeView)
        }
        
        destinationListView.snp.makeConstraints {
            $0.top.equalTo(mealPlanLabelView.snp.bottom).offset(16)
            $0.height.equalTo(96)
            $0.leading.trailing.equalTo(recipeView)
        }
        
        infoRecipeMakeConstraints()
    }
    
    private func navigationMakeConstraints() {
        grabberBackgroundView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(backButton.snp.bottom).offset(8)
        }
        
        grabberView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(5)
            $0.width.equalTo(36)
        }
        
        backButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(22)
            $0.leading.equalToSuperview().offset(8)
            $0.height.equalTo(40)
            $0.width.greaterThanOrEqualTo(96)
        }
        
        doneButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(48)
            $0.width.greaterThanOrEqualTo(120)
        }
        doneButton.setContentCompressionResistancePriority(.init(1000), for: .horizontal)
        doneButton.setContentHuggingPriority(.init(1000), for: .horizontal)
    }
    
    private func infoRecipeMakeConstraints() {
        ingredientsView.snp.makeConstraints {
            $0.top.equalTo(destinationListView.snp.bottom).offset(16)
            $0.leading.trailing.equalTo(recipeView)
        }
        
        descriptionView.setContentHuggingPriority(.init(1000), for: .vertical)
        descriptionView.setContentCompressionResistancePriority(.init(1000), for: .vertical)
        descriptionView.snp.makeConstraints {
            $0.top.equalTo(ingredientsView.snp.bottom).offset(24)
            $0.leading.trailing.equalTo(recipeView)
        }
        
        instructionsView.snp.makeConstraints {
            $0.top.equalTo(descriptionView.snp.bottom).offset(24)
            $0.leading.trailing.equalTo(recipeView)
            $0.bottom.equalToSuperview()
        }
    }
}
