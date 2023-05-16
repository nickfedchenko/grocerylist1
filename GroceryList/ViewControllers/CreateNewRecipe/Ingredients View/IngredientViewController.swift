//
//  IngredientViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 09.03.2023.
//

import UIKit

final class IngredientViewController: UIViewController {

    var viewModel: IngredientViewModel?
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = R.color.primaryDark()
        button.setTitle(R.string.localizable.save().uppercased(), for: .normal)
        button.titleLabel?.font = UIFont.SFProDisplay.semibold(size: 20).font
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let contentView = ViewWithOverriddenPoint()
    private let categoryView = CategoryView()
    private let ingredientView = AddIngredientView()
    private let quantityView = QuantityView()
    private let predictiveTextView = PredictiveTextView()
    private var predictiveTextViewHeight = 86
    private var viewDidLayout = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        categoryView.makeCustomRound(topLeft: 4, topRight: 40, bottomLeft: 0, bottomRight: 4)
        if !viewDidLayout {
            ingredientView.productTextField.becomeFirstResponder()
            viewDidLayout.toggle()
        }
    }
    
    private func setup() {
        let tapOnView = UITapGestureRecognizer(target: self, action: #selector(tappedOnView))
        tapOnView.delegate = self
        self.view.addGestureRecognizer(tapOnView)
        
        viewModel?.delegate = self
        setupContentView()
        setupPredictiveTextView()
        makeConstraints()
        updateSaveButton(isActive: false)
        categoryIsActive(false, categoryTitle: R.string.localizable.category())
        quantityView.setActive(false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardAppear),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    private func setupContentView() {
        contentView.backgroundColor = UIColor(hex: "#E5F5F3")
        
        categoryView.delegate = self
        ingredientView.delegate = self
        quantityView.delegate = self
        
        let swipeDownRecognizer = UIPanGestureRecognizer(target: self, action: #selector(swipeDownAction(_:)))
        contentView.addGestureRecognizer(swipeDownRecognizer)
    }
    
    private func setupPredictiveTextView() {
        guard FeatureManager.shared.isActivePredictiveText else {
            predictiveTextViewHeight = 0
            return
        }
        
        viewModel?.productsChangedCallback = { [weak self] titles in
            guard let self else { return }
            self.predictiveTextView.configure(texts: titles)
        }
        ingredientView.productTextField.autocorrectionType = .no
        ingredientView.productTextField.spellCheckingType = .no
        predictiveTextView.delegate = self
    }
    
    private func updateSaveButton(isActive: Bool) {
        saveButton.backgroundColor = isActive ? R.color.primaryDark() : R.color.lightGray()
        saveButton.isUserInteractionEnabled = isActive
    }
    
    private func categoryIsActive(_ isActive: Bool, categoryTitle: String) {
        let color = isActive ? (R.color.primaryDark() ??  UIColor(hex: "#045C5C")) : UIColor(hex: "#777777")
        categoryView.setCategory(categoryTitle, textColor: color)
    }
    
    @objc
    private func saveButtonTapped() {
        viewModel?.save(title: ingredientView.productTitle ?? "",
                        quantity: quantityView.quantityCount,
                        quantityStr: ingredientView.quantityTitle,
                        description: ingredientView.descriptionTitle)
        hidePanel()
    }
    
    @objc
    private func onKeyboardAppear(notification: NSNotification) {
        let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        guard let keyboardFrame = value?.cgRectValue else { return }
        let height = Double(keyboardFrame.height)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.updateConstraints(with: height, alpha: 0.2)
        }
    }
    
    @objc
    private func swipeDownAction(_ recognizer: UIPanGestureRecognizer) {
        let tempTranslation = recognizer.translation(in: contentView)
        if tempTranslation.y >= 100 {
            hidePanel()
        }
    }
    
    @objc
    private func tappedOnView() {
        hidePanel()
    }
    
    private func updateConstraints(with inset: Double, alpha: Double) {
        UIView.animate(withDuration: 0.4) { [weak self] in
            guard let self = self else { return }
            self.contentView.snp.updateConstraints {
                $0.bottom.equalToSuperview().inset(inset)
            }
            self.view.backgroundColor = .black.withAlphaComponent(alpha)
            self.view.layoutIfNeeded()
        }
    }
    
    func updatePredictiveViewConstraints(isVisible: Bool) {
        let height = isVisible ? predictiveTextViewHeight : 0
        predictiveTextView.snp.updateConstraints { $0.height.equalTo(height) }
        contentView.snp.updateConstraints { $0.height.greaterThanOrEqualTo(220 + height) }
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.view.layoutIfNeeded()
        }
    }

    private func hidePanel() {
        updateConstraints(with: -400, alpha: 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    private func makeConstraints() {
        self.view.addSubview(contentView)
        contentView.addSubviews([categoryView, ingredientView, quantityView, saveButton, predictiveTextView])
        
        contentView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.greaterThanOrEqualTo(220 + predictiveTextViewHeight)
            $0.bottom.equalToSuperview().inset(-268 - predictiveTextViewHeight)
        }
        
        categoryView.snp.makeConstraints {
            $0.bottom.equalTo(contentView.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        ingredientView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(categoryView.snp.bottom).offset(7)
        }
        
        quantityView.snp.makeConstraints {
            $0.top.equalTo(ingredientView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(62)
        }
        
        saveButton.snp.makeConstraints {
            $0.top.equalTo(quantityView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(64)
        }
        
        predictiveTextView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(saveButton.snp.bottom)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(predictiveTextViewHeight)
        }
    }
}

extension IngredientViewController: IngredientViewModelDelegate {
    func categoryChange(title: String) {
        categoryIsActive(title == R.string.localizable.selectCategory(), categoryTitle: title)
    }
    
    func unitChange(_ unit: UnitSystem) {
        quantityView.setUnit(title: unit.title)
        quantityView.setQuantityValueStep(unit.stepValue)
        quantityView.setActive(true)
    }
}

extension IngredientViewController: CategoryViewDelegate {
    func categoryTapped() {
        viewModel?.goToSelectCategoryVC()
    }
}

extension IngredientViewController: AddIngredientViewDelegate {
    func productInput(title: String?) {
        viewModel?.checkIsProductFromCategory(name: title)
        updateSaveButton(isActive: !(title?.isEmpty ?? true))
        quantityView.setActive(!(title?.isEmpty ?? true))
    }
    
    func quantityInput() {
        quantityView.setActive(false)
        quantityView.quantityCount = 0
    }
    
    func isFirstResponderProductTextField(_ flag: Bool) {
        updatePredictiveViewConstraints(isVisible: flag)
    }
}

extension IngredientViewController: QuantityViewDelegate {
    func quantityChange(text: String?) {
        ingredientView.setQuantity(text)
    }
    
    func getUnitsNumberOfCells() -> Int {
        viewModel?.getNumberOfCells ?? 0
    }
    
    func getTitleForCell(at index: Int) -> String? {
        viewModel?.getTitleForCell(at: index)
    }
    
    func cellSelected(at index: Int) {
        viewModel?.cellSelected(at: index)
    }
}

extension IngredientViewController: PredictiveTextViewDelegate {
    func selectTitle(_ title: String) {
        AmplitudeManager.shared.logEvent(.itemPredictAdd)
        ingredientView.productTextField.text = title
        viewModel?.checkIsProductFromCategory(name: title)
    }
}
extension IngredientViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view?.isDescendant(of: self.contentView) ?? false)
    }
}
