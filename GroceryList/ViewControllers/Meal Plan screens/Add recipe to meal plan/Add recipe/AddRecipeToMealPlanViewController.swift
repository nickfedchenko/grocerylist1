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
        button.setTitle("   " + R.string.localizable.back(), for: .normal)
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
    private let ingredientsView = MealPlanIngredientsView()
    private let descriptionView = RecipeDescriptionView()
    private let instructionsView = RecipeInstructionsView()
    
    private let calendarView = MealPlanUpdateDateView()
    
    init(viewModel: AddRecipeToMealPlanViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        makeConstraints()
        
        setupRecipe()
        setupMealPlan()
    }
    
    private func setup() {
        self.view.backgroundColor = R.color.background()
        grabberBackgroundView.backgroundColor = viewModel.theme.light.withAlphaComponent(0.95)
        
        dateView.delegate = self
        mealPlanLabelView.delegate = self
        destinationListView.delegate = self
        ingredientsView.delegate = self
        
        calendarView.fadeOut()
        
        viewModel.updateDestinationList = { [weak self] in
            self?.destinationListView.configure(list: self?.viewModel.getListName())
        }
        
        viewModel.updateLabels = { [weak self] in
            guard let self else { return }
            self.mealPlanLabelView.configure(allLabels: self.viewModel.labels)
            self.mealPlanLabelView.snp.updateConstraints {
                $0.height.greaterThanOrEqualTo(self.viewModel.labels.count * 42 + 38)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    private func setupRecipe() {
        let recipe = viewModel.recipe
        let theme = viewModel.theme
        recipeView.configure(with: recipe)
        recipeView.configureColor(theme: theme)
        
        if !recipe.description.isEmpty {
            descriptionView.configure(description: recipe.description)
            descriptionView.updateTitle()
        } else {
            descriptionView.snp.remakeConstraints {
                $0.top.equalTo(ingredientsView.snp.bottom).offset(0)
                $0.height.equalTo(0)
            }
            descriptionView.isHidden = true
        }
        
        ingredientsView.setupIngredients(recipe: recipe)
        
        instructionsView.setupInstructions(instructions: recipe.instructions ?? [])
        instructionsView.updateViewsConstraints()
    }
    
    private func setupMealPlan() {
        mealPlanLabelView.configure(allLabels: viewModel.labels)
        dateView.configure(date: viewModel.mealPlanDate)
        calendarView.configure(date: viewModel.mealPlanDate)
        destinationListView.configure(list: viewModel.getListName())
        
        calendarView.labelColors = { [weak self] date in
            self?.viewModel.getLabelColors(by: date) ?? []
        }
        
        calendarView.selectDate = { [weak self] selectedDate in
            self?.calendarView.fadeOut()
            if let selectedDate {
                self?.dateView.configure(date: selectedDate)
            }
        }
        
        guard let mealPlan = viewModel.mealPlan else {
            return
        }
        backButton.isHidden = true
        
        dateView.configure(date: mealPlan.date)
        calendarView.configure(date: mealPlan.date)
        destinationListView.configure(list: viewModel.getListName())
    }
    
    @objc
    private func tappedBackButton() {
        if self.navigationController != nil {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
    
    @objc
    private func tappedDoneButton() {
        Vibration.success.vibrate()
        viewModel.saveMealPlan(date: dateView.currentDate)
    }
    
    private func makeConstraints() {
        self.view.addSubviews([scrollView, grabberBackgroundView, grabberView, backButton, doneButton])
        self.scrollView.addSubview(contentView)
        contentView.addSubviews([recipeView, dateView, mealPlanLabelView, destinationListView,
                                 ingredientsView, descriptionView, instructionsView])
        self.view.addSubviews([calendarView])
        
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
            $0.height.greaterThanOrEqualTo(viewModel.labels.count * 41 + 38)
            $0.leading.trailing.equalTo(recipeView)
        }
        
        destinationListView.snp.makeConstraints {
            $0.top.equalTo(mealPlanLabelView.snp.bottom).offset(16)
            $0.height.equalTo(96)
            $0.leading.trailing.equalTo(recipeView)
        }
        
        calendarView.snp.makeConstraints {
            $0.edges.equalToSuperview()
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
            $0.leading.equalToSuperview().offset(4)
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
            $0.top.equalTo(descriptionView.snp.bottom).offset(16)
            $0.leading.trailing.equalTo(recipeView)
            $0.bottom.equalToSuperview()
        }
    }
}

extension AddRecipeToMealPlanViewController: MealPlanDateViewDelegate {
    func selectDate() {
        calendarView.fadeIn()
    }
}

extension AddRecipeToMealPlanViewController: MealPlanLabelViewDelegate {
    func tapMenuLabel() {
        viewModel.showLabels()
    }
    
    func tapLabel(index: Int) {
        viewModel.selectLabel(index: index)
    }
}

extension AddRecipeToMealPlanViewController: MealPlanDestinationListViewDelegate {
    func selectList() {
        viewModel.showDestinationLabel()
    }
}

extension AddRecipeToMealPlanViewController: MealPlanIngredientsViewDelegate {
    func unit(unitID: Int?) -> UnitSystem? {
        viewModel.unit(unitID: unitID)
    }
    
    func convertValue() -> Double {
        viewModel.convertValue()
    }
    
    func servingChangedTo(count: Double) {
        Vibration.rigid.vibrate()
        let servings = viewModel.getIngredientsSizeAccordingToServings(servings: count)
        ingredientsView.updateIngredientsCount(by: servings)
    }
    
    func addToCartButton() {
        Vibration.heavy.vibrate()
        viewModel.addToCart(photo: ingredientsView.photos)
    }
}
