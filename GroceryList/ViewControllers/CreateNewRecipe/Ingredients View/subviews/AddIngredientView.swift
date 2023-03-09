//
//  IngredientView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 09.03.2023.
//

import UIKit

class AddIngredientView: UIView {
   
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    lazy var productTextField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.font = UIFont.SFPro.semibold(size: 17).font
        textField.textColor = .black
        return textField
    }()
    
    lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.delegate = self
        textView.font = UIFont.SFPro.medium(size: 15).font
        textView.textColor = .black
        textView.text = "Note"
        return textView
    }()
    
    lazy var quantityTextField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.font = UIFont.SFPro.bold(size: 15).font
        textField.textColor = UIColor(hex: "#D6600A")
        textField.placeholder = "Quantity"
        return textField
    }()
    
    private let shadowOneView = UIView()
    private let shadowTwoView = UIView()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setup() {
        self.backgroundColor = UIColor(hex: "#E5F5F3")
        setupShadowView()
        
        makeConstraints()
    }
    
    private func setupShadowView() {
        [shadowOneView, shadowTwoView].forEach { shadowView in
            shadowView.backgroundColor = UIColor(hex: "#E5F5F3")
            shadowView.layer.cornerRadius = 16
        }
        shadowOneView.addCustomShadow(color: UIColor(hex: "#484848"),
                                      opacity: 0.15,
                                      radius: 1,
                                      offset: .init(width: 0, height: 0.5))
        shadowTwoView.addCustomShadow(color: UIColor(hex: "#858585"),
                                      opacity: 0.1,
                                      radius: 6,
                                      offset: .init(width: 0, height: 6))
    }
    
    private func makeConstraints() {
        self.addSubviews([shadowOneView, shadowTwoView, contentView])
        contentView.addSubviews([productTextField, descriptionTextView, quantityTextField])
        
        contentView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        [shadowOneView, shadowTwoView].forEach { shadowView in
            shadowView.snp.makeConstraints { $0.edges.equalTo(contentView) }
        }
        
        productTextField.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(17)
        }
        
        descriptionTextView.snp.makeConstraints {
            $0.leading.equalTo(productTextField)
            $0.top.equalTo(productTextField.snp.bottom).offset(4)
            $0.height.greaterThanOrEqualTo(15)
        }
        
        quantityTextField.snp.makeConstraints {
            $0.bottom.equalTo(descriptionTextView)
            $0.trailing.equalToSuperview().offset(-10)
        }
        
        quantityTextField.setContentCompressionResistancePriority(.init(1000), for: .horizontal)
        quantityTextField.setContentHuggingPriority(.init(1000), for: .horizontal)
    }
}

extension AddIngredientView: UITextViewDelegate {
    
}

extension AddIngredientView: UITextFieldDelegate {
    
}
