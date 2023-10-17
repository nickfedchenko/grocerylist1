//
//  CreateNewRecipeViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 01.03.2023.
//

import UIKit

// swiftlint:disable:next type_body_length
final class CreateNewRecipeStepOneViewController: UIViewController {
    
    var viewModel: CreateNewRecipeStepOneViewModel?
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInset.bottom = 150
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
        let tapOnLabel = UITapGestureRecognizer(target: self, action: #selector(backButtonTapped))
        label.addGestureRecognizer(tapOnLabel)
        label.isUserInteractionEnabled = true
        label.font = UIFont.SFProRounded.semibold(size: 17).font
        label.textColor = R.color.primaryDark()
        label.text = R.string.localizable.cancel()
        return label
    }()
    
    private lazy var savedToDraftsButton: UIButton = {
        let button = UIButton()
        button.setTitle(R.string.localizable.saveToDrafts(), for: .normal)
        button.setTitleColor(R.color.background(), for: .normal)
        button.titleLabel?.font = UIFont.SFProRounded.semibold(size: 17).font
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.3
        button.setImage(R.image.collection()?.withTintColor(R.color.background() ?? .white),
                        for: .normal)
        button.layer.cornerRadius = 8
        button.semanticContentAttribute = .forceRightToLeft
        button.contentEdgeInsets.left = 8
        button.addTarget(self, action: #selector(savedToDraftsButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton()
        button.setTitle(R.string.localizable.continue().uppercased(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.SFProDisplay.semibold(size: 20).font
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        button.addDefaultShadowForPopUp()
        return button
    }()
    
    private let topSafeAreaView = UIView()
    private let navigationView = UIView()
    private let contentView = UIView()
    
    private let savedToDraftsAlertView = CreateNewRecipeSavedToDraftsAlertView()
    private let titleView = CreateNewRecipeTitleView()
    private let nameView = CreateNewRecipeViewWithTextField()
    private let descriptionView = CreateNewRecipeViewWithTextField()
    private let ingredientsView = CreateNewRecipeViewWithButton()
    private let stepsView = CreateNewRecipeViewWithButton()
    private var stepNumber = 1
    private let showCostView = CreateNewRecipeShowCostView()
    
    private var isVisibleKeyboard = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !(viewModel?.currentRecipe?.description.isEmpty ?? true) {
            descriptionView.snp.updateConstraints { $0.height.equalTo(descriptionView.requiredHeight) }
        }
    }
    
    private func setup() {
        self.view.backgroundColor = R.color.background()
        valueChanged()
        setupNavigationView()
        setupCustomView()
        setupStackView()
        makeConstraints()
        
        setupCurrentRecipe()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardAppear),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground),
                                               name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    private func valueChanged() {
        viewModel?.preparationStepChanged = { [weak self] description in
            guard let self else { return }
            self.updateSteps(description)
        }
        
        viewModel?.ingredientChanged = { [weak self] ingredient, insetIndex in
            guard let self else { return }
            self.updateIngredient(ingredient, insetIndex: insetIndex)
        }
        
        viewModel?.updateSaveToDraftButton = { [weak self] in
            self?.updateIsActiveSavedToDraftsButton()
        }
    }
    
    private func setupNavigationView() {
        topSafeAreaView.backgroundColor = R.color.background()
        navigationView.backgroundColor = R.color.background()
        
        updateSavedToDraftsButton()
        savedToDraftsAlertView.isHidden = true
        savedToDraftsAlertView.leaveCreatingRecipeTapped = { [weak self] in
            self?.savedToDraftsAlertView.fadeOut()
            self?.viewModel?.back()
        }
        
        savedToDraftsAlertView.continueWorkTapped = { [weak self] in
            self?.savedToDraftsAlertView.fadeOut()
        }
    }
    
    private func setupCustomView() {
        titleView.setStep(R.string.localizable.step1Of2())
        setupNameView()
        
        descriptionView.configure(title: R.string.localizable.description(), state: .optional,
                                  modeIsTextField: false)
        descriptionView.updateLayout = { [weak self] in
            guard let self else { return }
            self.descriptionView.snp.updateConstraints {
                $0.height.equalTo(self.descriptionView.requiredHeight)
            }
        }
        
        setupIngredientView()
        setupStepView()
        
        showCostView.changedSwitchValue = { [weak self] isShowCost in
            guard let self else {
                return
            }
            if isShowCost {
                AmplitudeManager.shared.logEvent(.recipeCreateShowPriceStore)
            }
            self.viewModel?.setIsShowCost(isShowCost)
            self.ingredientsView.stackView.arrangedSubviews.enumerated().forEach({ index, view in
                let ingredientView = (view as? IngredientForCreateRecipeView)
                if (self.viewModel?.isShowCost ?? false) {
                    let store = self.viewModel?.getStoreAndCost(by: index)
                    ingredientView?.setupCost(isVisible: self.viewModel?.isShowCost ?? false,
                                              storeTitle: store?.store, costValue: store?.cost)
                } else {
                    ingredientView?.setupCost(isVisible: self.viewModel?.isShowCost ?? false,
                                              storeTitle: nil, costValue: nil)
                }
            })
        }
        
        let name = nameView.textView.text?.trimmingCharacters(in: .whitespaces)
        let isActive = !(name?.isEmpty ?? true) && ingredientsView.stackSubviewsCount >= 2
        updateNextButton(isActive: isActive)
    }
    
    private func setupNameView() {
        nameView.maxLineNumber = 1
        nameView.configure(title: R.string.localizable.name(), state: .required)
        nameView.textView.becomeFirstResponder()
        nameView.textFieldReturnPressed = { [weak self] in
            self?.descriptionView.textView.becomeFirstResponder()
        }
        nameView.textFieldDidChange = { [weak self] in
            self?.updateSavedToDraftsButton()
        }
    }
    
    private func setupIngredientView() {
        ingredientsView.setPlaceholder(R.string.localizable.requiredMinimum2())
        ingredientsView.setIconImage(image: R.image.recipePlus())
        ingredientsView.stackView.reorderDelegate = self
        ingredientsView.configure(title: R.string.localizable.ingredients(), state: .required)
        ingredientsView.buttonPressed = { [weak self] in
            guard let self else { return }
            self.nameView.textView.resignFirstResponder()
            self.descriptionView.textView.resignFirstResponder()
            self.viewModel?.presentIngredient()
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
        stepsView.stackView.reorderDelegate = self
        stepsView.configure(title: R.string.localizable.preparationSteps(), state: .optional)
        stepsView.buttonPressed = { [weak self] in
            guard let self else { return }
            self.nameView.textView.resignFirstResponder()
            self.descriptionView.textView.resignFirstResponder()
            self.viewModel?.presentPreparationStep(stepNumber: self.stepNumber)
        }
        stepsView.updateLayout = { [weak self] in
            guard let self else { return }
            self.stepsView.snp.updateConstraints {
                $0.height.equalTo(self.stepsView.requiredHeight)
            }
        }
    }
    
    private func setupStackView() {
        stackView.addArrangedSubview(navigationView)
        stackView.addArrangedSubview(titleView)
        stackView.addArrangedSubview(nameView)
        stackView.addArrangedSubview(descriptionView)
        stackView.addArrangedSubview(ingredientsView)
        stackView.addArrangedSubview(stepsView)
        stackView.addArrangedSubview(showCostView)
    }
    
    private func setupCurrentRecipe() {
        guard let currentRecipe = viewModel?.currentRecipe else {
            return
        }
        savedToDraftsButton.isHidden = true
        nameView.setText(currentRecipe.title)
        descriptionView.setText(currentRecipe.description)

        currentRecipe.ingredients.forEach { ingredient in
            updateIngredient(ingredient, insetIndex: nil)
        }
        currentRecipe.instructions?.forEach({ step in
            updateSteps(step)
        })
    }
    
    private func updateNextButton(isActive: Bool) {
        nextButton.backgroundColor = isActive ? R.color.primaryDark() : R.color.lightGray()
        nextButton.layer.shadowOpacity = isActive ? 0.15 : 0
        nextButton.isUserInteractionEnabled = isActive
    }

    private func updateSavedToDraftsButton() {
        let text = nameView.textView.text ?? ""
        savedToDraftsButton.backgroundColor = text.count > 0 ? R.color.darkGray()
                                                             : R.color.lightGray()
        if savedToDraftsButton.titleLabel?.text == R.string.localizable.savedInDrafts() {
            savedToDraftsButton.backgroundColor = R.color.background()
        }
        if text.count == 0 || savedToDraftsButton.titleLabel?.text == R.string.localizable.savedInDrafts() {
            savedToDraftsButton.isUserInteractionEnabled = false
        } else {
            savedToDraftsButton.isUserInteractionEnabled = true
        }
    }
    
    private func updateIngredient(_ ingredient: Ingredient, insetIndex: Int?) {
        var serving = ""
        if ingredient.quantity == 0 {
            let quantityStr = ingredient.quantityStr ?? ""
            serving = quantityStr.isEmpty ? R.string.localizable.byTaste() : quantityStr
        } else {
            serving = "\(ingredient.quantity.asString) \(ingredient.unit?.title.localized ?? "")"
        }
        setupIngredientView(title: ingredient.product.title,
                            serving: serving,
                            description: ingredient.description,
                            imageURL: ingredient.product.photo,
                            imageData: ingredient.product.localImage,
                            isVisibleStore: viewModel?.isShowCost ?? false,
                            storeTitle: ingredient.product.store?.title,
                            costValue: ingredient.product.cost,
                            insetIndex: insetIndex)
        updateIngredientsViewIsActive()
        ingredientsView.snp.updateConstraints {
            $0.height.equalTo(ingredientsView.requiredHeight)
        }
    }
    
    private func updateIngredientsViewIsActive() {
        let name = nameView.textView.text?.trimmingCharacters(in: .whitespaces)
        let isActive = ingredientsView.stackSubviewsCount >= 2
        
        let isActiveNextButton = !(name?.isEmpty ?? true) && isActive
        updateNextButton(isActive: isActiveNextButton)
        if isActive {
            ingredientsView.setPlaceholder(R.string.localizable.addIngredient())
            ingredientsView.setState(.filled)
        } else {
            ingredientsView.setPlaceholder(R.string.localizable.requiredMinimum2())
            ingredientsView.setState(.required)
        }
    }
    
    private func updateSteps(_ description: String) {
        setupStepView(stepNumber: stepNumber, description: description)
        stepsView.setPlaceholder(R.string.localizable.addStep())
        stepsView.setState(.filled)
        stepsView.snp.updateConstraints {
            $0.height.equalTo(stepsView.requiredHeight)
        }
        self.stepNumber += 1
    }
    
    private func setupIngredientView(title: String, serving: String, description: String?,
                                     imageURL: String, imageData: Data?,
                                     isVisibleStore: Bool, storeTitle: String?, costValue: Double?,
                                     insetIndex: Int?) {
        let view = IngredientForCreateRecipeView()
        view.setTitle(title: title)
        view.setServing(serving: serving)
        view.setDescription(description)
        view.setImage(imageURL: imageURL, imageData: imageData)
        view.setupCost(isVisible: isVisibleStore, storeTitle: storeTitle, costValue: costValue)
        ingredientsView.addViewToStackView(view, insertIndex: insetIndex)
        
        if let insetIndex {
            view.originalIndex = insetIndex
        } else {
            view.originalIndex = ingredientsView.stackSubviewsCount - 1
        }
        view.swipeDeleteAction = { [weak self] index in
            guard let self else {
                return
            }
            self.viewModel?.removeIngredient(by: index)
            self.ingredientsView.removeView(view)
            self.ingredientsView.stackView.arrangedSubviews.enumerated().forEach { index, view in
                (view as? IngredientForCreateRecipeView)?.originalIndex = index
            }
            self.updateIngredientsViewIsActive()
            self.ingredientsView.snp.updateConstraints {
                $0.height.equalTo(self.ingredientsView.requiredHeight)
            }
        }
        view.tapOnViewAction = { [weak self] index in
            self?.viewModel?.showIngredient(by: index)
        }
    }
    
    private func setupStepView(stepNumber: Int, description: String) {
        let view = StepForCreateRecipeView()
        view.configure(step: "\(stepNumber)", description: description)
        stepsView.addViewToStackView(view, insertIndex: nil)
        view.swipeDeleteAction = { [weak self] in
            guard let self else {
                return
            }
            self.stepsView.removeView(view)
            var updatedSteps: [String] = []
            self.stepsView.stackView.arrangedSubviews.enumerated().forEach { index, view in
                (view as? StepForCreateRecipeView)?.updateStep(step: "\(index + 1)")
                updatedSteps.append((view as? StepForCreateRecipeView)?.getDescription() ?? "")
            }
            self.viewModel?.updateSteps(updatedSteps: updatedSteps)
            self.stepsView.snp.updateConstraints {
                $0.height.equalTo(self.stepsView.requiredHeight)
            }
            
            self.stepNumber = self.stepsView.stackView.arrangedSubviews.count + 1
        }
    }
    
    private func updateIsActiveSavedToDraftsButton() {
        guard (viewModel?.isDraftRecipe ?? false) else {
            return
        }
        savedToDraftsButton.setTitle(R.string.localizable.savedInDrafts(), for: .normal)
        savedToDraftsButton.setTitleColor(R.color.darkGray(), for: .normal)
        savedToDraftsButton.setImage(R.image.collection()?.withTintColor(R.color.darkGray() ?? .black),
                                     for: .normal)
        savedToDraftsButton.backgroundColor = R.color.background()
        savedToDraftsButton.layer.borderColor = R.color.darkGray()?.cgColor
        savedToDraftsButton.layer.borderWidth = 1
        savedToDraftsButton.isUserInteractionEnabled = false
    }
    
    @objc
    private func backButtonTapped() {
        Vibration.medium.vibrate()
        viewModel?.savedToDrafts(title: nameView.textView.text,
                                 description: descriptionView.textView.text)
        viewModel?.back()
    }
    
    @objc
    private func savedToDraftsButtonTapped() {
        Vibration.medium.vibrate()
        viewModel?.isDraftRecipe = true
        updateIsActiveSavedToDraftsButton()
        viewModel?.savedToDrafts(title: nameView.textView.text,
                                 description: descriptionView.textView.text)
        savedToDraftsAlertView.fadeIn()
    }
    
    @objc
    private func nextButtonTapped() {
        guard let name = nameView.textView.text?.trimmingCharacters(in: .whitespaces) else {
            updateNextButton(isActive: false)
            return
        }
        Vibration.medium.vibrate()
        viewModel?.saveRecipe(title: name, description: descriptionView.textView.text)
        viewModel?.savedToDrafts(title: name, description: descriptionView.textView.text)
        viewModel?.next()
    }
    
    @objc
    private func onKeyboardAppear(notification: NSNotification) {
        isVisibleKeyboard = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    @objc
    private func dismissKeyboard() {
        isVisibleKeyboard = false
        let name = nameView.textView.text?.trimmingCharacters(in: .whitespaces)
        let isActive = !(name?.isEmpty ?? true) && ingredientsView.stackSubviewsCount >= 2
        updateNextButton(isActive: isActive)
        
        guard let gestureRecognizers = self.view.gestureRecognizers else {
            return
        }
        gestureRecognizers.forEach { $0.isEnabled = false }
        self.view.endEditing(true)
    }
    
    @objc
    private func appMovedToBackground() {
        viewModel?.savedToDrafts(title: nameView.textView.text,
                                 description: descriptionView.textView.text)
    }
    
    private func makeConstraints() {
        self.view.addSubviews([scrollView, topSafeAreaView, nextButton, savedToDraftsAlertView])
        self.scrollView.addSubview(contentView)
        contentView.addSubviews([stackView])
        navigationView.addSubviews([backButton, backLabel, savedToDraftsButton])
        
        topSafeAreaView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.top)
        }
        
        nextButton.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(stackView.snp.bottom).offset(37)
            $0.leading.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(64)
            $0.bottom.greaterThanOrEqualTo(self.view).offset(-80)
        }
        
        savedToDraftsAlertView.snp.makeConstraints {
            $0.edges.equalToSuperview()
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
        
        savedToDraftsButton.snp.makeConstraints {
            $0.leading.greaterThanOrEqualTo(backLabel.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.equalToSuperview()
            $0.height.equalTo(40)
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
            $0.edges.equalToSuperview()
            $0.width.equalTo(self.view)
        }
    }
    
    private func makeCustomViewConstraints() {
        navigationView.snp.makeConstraints {
            $0.height.equalTo(40)
            $0.width.equalToSuperview()
        }
        
        titleView.snp.makeConstraints {
            $0.height.equalTo(titleView.requiredHeight)
            $0.width.equalToSuperview()
        }
        
        nameView.snp.makeConstraints {
            $0.height.equalTo(nameView.requiredHeight)
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
        
        showCostView.snp.makeConstraints {
            $0.height.equalTo(showCostView.requiredHeight)
            $0.width.equalToSuperview()
        }
    }
}

extension CreateNewRecipeStepOneViewController: StackViewReorderDelegate {
    func didEndReordering(_ stackView: UIStackView) {
        ingredientsView.stackView.clipsToBounds = false
        guard stackView == ingredientsView.stackView else {
            var updatedSteps: [String] = []
            stackView.arrangedSubviews.enumerated().forEach { index, view in
                (view as? StepForCreateRecipeView)?.updateStep(step: "\(index + 1)")
                updatedSteps.append((view as? StepForCreateRecipeView)?.getDescription() ?? "")
            }
            viewModel?.updateSteps(updatedSteps: updatedSteps)
            return
        }
        
        var originalIndexes: [Int] = []
        stackView.arrangedSubviews.enumerated().forEach { index, view in
            originalIndexes.append((view as? IngredientForCreateRecipeView)?.originalIndex ?? -1)
            (view as? IngredientForCreateRecipeView)?.originalIndex = index
        }
        viewModel?.updateIngredients(originalIndexes: originalIndexes)
    }
}
