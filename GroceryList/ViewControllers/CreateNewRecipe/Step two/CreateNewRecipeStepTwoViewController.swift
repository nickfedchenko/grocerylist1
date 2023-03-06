//
//  CreateNewRecipeStepTwoViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 03.03.2023.
//

import UIKit

final class CreateNewRecipeStepTwoViewController: UIViewController {

    var viewModel: CreateNewRecipeStepTwoViewModel?
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInset.top = CGFloat(titleView.requiredHeight + 40)
        return scrollView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillProportionally
        stackView.axis = .vertical
        stackView.spacing = 0
        return stackView
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.greenArrowBack(), for: .normal)
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var backLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProRounded.semibold(size: 17).font
        label.textColor = UIColor(hex: "#1A645A")
        label.text = R.string.localizable.recipes()
        return label
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("Complete".uppercased(), for: .normal)
        button.titleLabel?.font = UIFont.SFProDisplay.semibold(size: 20).font
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        button.addDefaultShadowForPopUp()
        return button
    }()
    
    private let topSafeAreaView = UIView()
    private let navigationView = UIView()
    private let contentView = UIView()
    private let titleView = CreateNewRecipeTitleView()
    private let timeView = CreateNewRecipeViewWithTextField()
    private let descriptionView = CreateNewRecipeViewWithTextField()
    private let ingredientsView = CreateNewRecipeViewWithButton()
    private let stepsView = CreateNewRecipeViewWithButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        self.view.backgroundColor = UIColor(hex: "#E5F5F3")
        navigationView.backgroundColor = UIColor(hex: "#E5F5F3").withAlphaComponent(0.9)
        topSafeAreaView.backgroundColor = UIColor(hex: "#E5F5F3").withAlphaComponent(0.9)
        setupCustomView()
        setupStackView()
        updateNextButton(isActive: false)
        makeConstraints()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardAppear),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    private func setupCustomView() {
        titleView.setRecipe(title: viewModel?.recipeTitle)
        titleView.setStep("Step 2 of 2")
        timeView.setOnlyNumber()
        timeView.configure(title: "Preparation Time (minutes)", state: .optional)
        descriptionView.configure(title: "Description", state: .optional)
        setupIngredientView()
        setupStepView()
        
        timeView.textFieldReturnPressed = { [weak self] in
            self?.descriptionView.textField.becomeFirstResponder()
        }
        descriptionView.textFieldReturnPressed = { [weak self] in
            self?.descriptionView.textField.resignFirstResponder()
        }
    }
    
    private func setupIngredientView() {
        ingredientsView.setPlaceholder("Required (minimum 2)")
        ingredientsView.setIconImage(image: R.image.recipePlus())
        ingredientsView.closeStackButton(isVisible: false)
        ingredientsView.configure(title: "Ingredients", state: .required)
        ingredientsView.buttonPressed = { [weak self] in
            guard let self else { return }
            // показываем окно создания продукта
            self.setupIngredientView(title: "", serving: "", description: nil)
            let isActive = self.ingredientsView.stackSubviewsCount >= 2
            self.updateNextButton(isActive: isActive)
            if isActive {
                self.ingredientsView.setPlaceholder("Add Ingredient")
                self.ingredientsView.setState(.filled)
                self.ingredientsView.closeStackButton(isVisible: isActive)
            }
            self.ingredientsView.snp.updateConstraints {
                $0.height.equalTo(self.ingredientsView.requiredHeight)
            }
        }
        ingredientsView.updateLayout = { [weak self] in
            guard let self else { return }
            self.ingredientsView.snp.updateConstraints {
                $0.height.equalTo(self.ingredientsView.requiredHeight)
            }
        }
    }
    
    private func setupStepView() {
        stepsView.setIconImage(image: R.image.recipePlus())
        stepsView.closeStackButton(isVisible: false)
        stepsView.configure(title: "Preparation Steps", state: .optional)
        stepsView.buttonPressed = { [weak self] in
            guard let self else { return }
            // показываем окно добавления шага приготовления
            self.setupStepView(stepNumber: 1, description: "sdad\ndfdf\ndfdf")
            self.stepsView.setPlaceholder("Add Step")
            self.stepsView.setState(.filled)
            self.stepsView.closeStackButton(isVisible: true)
            self.stepsView.snp.updateConstraints {
                $0.height.equalTo(self.stepsView.requiredHeight)
            }
        }
        stepsView.updateLayout = { [weak self] in
            guard let self else { return }
            self.stepsView.snp.updateConstraints {
                $0.height.equalTo(self.stepsView.requiredHeight)
            }
        }
    }
    
    private func setupStackView() {
        stackView.addArrangedSubview(timeView)
        stackView.addArrangedSubview(descriptionView)
        stackView.addArrangedSubview(ingredientsView)
        stackView.addArrangedSubview(stepsView)
    }
    
    private func updateNextButton(isActive: Bool) {
        nextButton.backgroundColor = UIColor(hex: isActive ? "#1A645A" : "#D8ECE9")
        nextButton.layer.shadowOpacity = isActive ? 0.15 : 0
        nextButton.isUserInteractionEnabled = isActive
    }
    
    private func setupIngredientView(title: String, serving: String, description: String?) {
        let view = IngredientForCreateRecipeView()
        view.setTitle(title: title)
        view.setServing(serving: serving)
        view.setDescription(description)
        ingredientsView.addViewToStackView(view)
    }
    
    private func setupStepView(stepNumber: Int, description: String) {
        let view = StepForCreateRecipeView()
        view.configure(step: "\(stepNumber)", description: description)
        stepsView.addViewToStackView(view)
    }
    
    @objc
    private func backButtonTapped() {
        viewModel?.back()
    }
    
    @objc
    private func nextButtonTapped() {
//        viewModel?.saveRecipe()
        viewModel?.next()
    }
    
    @objc
    private func onKeyboardAppear(notification: NSNotification) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    @objc
    private func dismissKeyboard() {
        guard let gestureRecognizers = self.view.gestureRecognizers else {
            return
        }
        gestureRecognizers.forEach { $0.isEnabled = false }
        self.view.endEditing(true)
    }
    
    private func makeConstraints() {
        self.view.addSubviews([scrollView, topSafeAreaView, navigationView, titleView])
        self.scrollView.addSubview(contentView)
        contentView.addSubviews([stackView, nextButton])
        navigationView.addSubviews([backButton, backLabel])
        
        topSafeAreaView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.top)
        }
        
        navigationView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.height.equalTo(40)
        }
        
        titleView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(navigationView.snp.bottom)
            $0.height.equalTo(titleView.requiredHeight)
        }
        
        nextButton.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(37)
            $0.leading.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(64)
            $0.bottom.equalToSuperview().offset(-80)
        }
        
        makeScrollConstraints()
        makeNavViewConstraints()
        makeCustomViewConstraints()
    }
    
    private func makeNavViewConstraints() {
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalToSuperview()
            $0.height.width.equalTo(40)
        }
        
        backLabel.snp.makeConstraints {
            $0.leading.equalTo(backButton.snp.trailing)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(24)
        }
    }
    
    private func makeScrollConstraints() {
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(self.view)
        }
        
        stackView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.width.equalTo(self.view)
        }
    }
    
    private func makeCustomViewConstraints() {
        timeView.snp.makeConstraints {
            $0.height.equalTo(timeView.requiredHeight)
            $0.width.equalToSuperview()
        }
        
        descriptionView.snp.makeConstraints {
            $0.height.equalTo(descriptionView.requiredHeight)
            $0.width.equalToSuperview()
        }
        
        ingredientsView.snp.makeConstraints {
            $0.height.equalTo(ingredientsView.requiredHeight)
            $0.width.equalToSuperview()
        }
        
        stepsView.snp.makeConstraints {
            $0.height.equalTo(stepsView.requiredHeight)
            $0.width.equalToSuperview()
        }
    }
}
