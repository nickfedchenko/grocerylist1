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
        button.backgroundColor = UIColor(hex: "#1A645A")
        button.setTitle("SAVE", for: .normal)
        button.titleLabel?.font = UIFont.SFProDisplay.semibold(size: 20).font
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let contentView = UIView()
    private let categoryView = CategoryView()
    private let ingredientView = AddIngredientView()
    private let quantityView = QuantityView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentView.makeCustomRound(topLeft: 4, topRight: 40, bottomLeft: 0, bottomRight: 0)
    }
    
    private func setup() {
        setupContentView()
        updateSaveButton(isActive: false)
        makeConstraints()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardAppear),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    private func setupContentView() {
        contentView.backgroundColor = UIColor(hex: "#E5F5F3")
        categoryView.backgroundColor = UIColor(hex: "#FCFCFE")
        categoryView.delegate = self
        ingredientView.productTextField.becomeFirstResponder()
        
        let swipeDownRecognizer = UIPanGestureRecognizer(target: self, action: #selector(swipeDownAction(_:)))
        contentView.addGestureRecognizer(swipeDownRecognizer)
    }
    
    private func updateSaveButton(isActive: Bool) {
        saveButton.backgroundColor = UIColor(hex: isActive ? "#1A645A" : "#D8ECE9")
        saveButton.isUserInteractionEnabled = isActive
    }
    
    @objc
    private func saveButtonTapped() {
        hidePanel()
    }
    
    @objc
    private func onKeyboardAppear(notification: NSNotification) {
        let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        guard let keyboardFrame = value?.cgRectValue else { return }
        let height = Double(keyboardFrame.height)
        updateConstraints(with: height, alpha: 0.2)
    }
    
    @objc
    private func swipeDownAction(_ recognizer: UIPanGestureRecognizer) {
        let tempTranslation = recognizer.translation(in: contentView)
        if tempTranslation.y >= 100 {
            hidePanel()
        }
    }
    
    private func updateConstraints(with inset: Double, alpha: Double) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.contentView.snp.updateConstraints {
                $0.bottom.equalToSuperview().inset(inset)
            }
            self.view.backgroundColor = .black.withAlphaComponent(alpha)
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
        contentView.addSubviews([categoryView, ingredientView, quantityView, saveButton])
        
        contentView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.greaterThanOrEqualTo(268)
            $0.bottom.equalToSuperview().inset(-268)
        }
        
        categoryView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
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
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(64)
        }
    }
}

extension IngredientViewController: CategoryViewDelegate {
    func categoryTapped() {
        // show select category
    }
}
