//
//  IngredientViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 09.03.2023.
//

import UIKit

final class IngredientViewController: CreateNewProductViewController {
    
    private var ingredientViewDidLayout = false
    private let ingredientView = AddIngredientView()
    
    init(viewModel: IngredientViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !ingredientViewDidLayout {
            ingredientView.productTextField.becomeFirstResponder()
            ingredientViewDidLayout = true
        }
    }
    
    override func saveButtonTapped() {
        (viewModel as? IngredientViewModel)?.save(title: ingredientView.productTitle ?? "",
                                                  quantity: quantityView.quantity,
                                                  quantityStr: ingredientView.quantityTitle,
                                                  description: ingredientView.descriptionTitle)
        hidePanel()
    }
    
    override func setupPredictiveTextView() {
        super.setupPredictiveTextView()
        ingredientView.productTextField.autocorrectionType = .no
        ingredientView.productTextField.spellCheckingType = .no
    }
    
    override func updateStoreView(isVisible: Bool) {
        storeView.isHidden = !isVisible
        let height = (isVisible ? 280 : 220) + predictiveTextViewHeight
        contentView.snp.updateConstraints { $0.height.greaterThanOrEqualTo(height) }
        storeView.snp.updateConstraints {
            $0.top.equalTo(ingredientView.snp.bottom).offset(isVisible ? 20 : 0)
            $0.height.equalTo(isVisible ? 40 : 0)
        }
    }
    
    override func applyPredictiveInput(_ title: String) {
        AmplitudeManager.shared.logEvent(.itemPredictAdd)
        ingredientView.productTextField.text = title
        viewModel?.checkIsProductFromCategory(name: title)
    }
    
    override func updateQuantity(_ quantity: Double) {
        let quantityString = String(format: "%.\(quantity.truncatingRemainder(dividingBy: 1) == 0.0 ? 0 : 1)f", quantity)
        ingredientView.setQuantity(quantity > 0 ? "\(quantityString) \(unit.title)" : "")
    }
    
    override func tappedQuantityButtons(_ quantity: Double) {
        guard let costOfProductPerUnit = viewModel?.costOfProductPerUnit else {
            return
        }
        let cost = quantity * costOfProductPerUnit
        storeView.setCost(value: "\(cost)")
    }
    
    override func updateProductView(text: String, imageURL: String, imageData: Data?, defaultSelectedUnit: UnitSystem?) {
        categoryIsActive(text != R.string.localizable.selectCategory(), categoryTitle: text)
        ingredientView.setImage(imageURL: imageURL, imageData: imageData)
        quantityView.setDefaultUnit(defaultSelectedUnit ?? .piece)

        if !imageURL.isEmpty || imageData != nil {
            isUserImage = false
        }
        
        if ingredientView.productTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true {
            categoryIsActive(false, categoryTitle: R.string.localizable.selectCategory())
            updateSaveButton(isActive: false)
        } else {
            updateSaveButton(isActive: true)
        }
    }
    
    override func setupUserImage(_ image: UIImage?) {
        ingredientView.setImage(image)
    }
    
    override func makeConstraints() {
        super.makeConstraints()
        contentView.insertSubview(ingredientView, belowSubview: productView)
        productView.isHidden = true
        productView.snp.removeConstraints()
        storeView.snp.removeConstraints()
        
        ingredientView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(categoryView.snp.bottom).offset(20)
        }
        
        storeView.snp.makeConstraints {
            $0.top.equalTo(ingredientView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
    }
    
    private func setup() {
        contentView.backgroundColor = R.color.background()
        ingredientView.backgroundColor = R.color.background()
        
        viewModel?.delegate = self
        (viewModel as? IngredientViewModel)?.ingredientDelegate = self
        categoryView.delegate = self
        ingredientView.delegate = self
        quantityView.delegate = self
        predictiveTextView.delegate = self
        
        makeConstraints()
    }
    
    private func updateSaveButton(isActive: Bool) {
        saveButton.backgroundColor = isActive ? R.color.primaryDark() : R.color.lightGray()
        saveButton.isUserInteractionEnabled = isActive
    }
    
    private func categoryIsActive(_ isActive: Bool, categoryTitle: String) {
        let color = isActive ? (R.color.primaryDark() ?? UIColor(hex: "#045C5C")) : inactiveColor
        categoryView.setCategoryInProduct(categoryTitle, backgroundColor: color)
    }
}

extension IngredientViewController: IngredientViewModelDelegate {
    func categoryChange(title: String) {
        categoryIsActive(title == R.string.localizable.selectCategory(), categoryTitle: title)
    }
    
    func unitChange(_ unit: UnitSystem) {
        quantityView.setDefaultUnit(unit)
    }
}

extension IngredientViewController: AddIngredientViewDelegate {
    func productInput(title: String?) {
        viewModel?.checkIsProductFromCategory(name: title)
        updateSaveButton(isActive: !(title?.isEmpty ?? true))
        
        if title?.isEmpty ?? true {
            quantityView.reset()
        }
    }
    
    func quantityInput() { }
}
