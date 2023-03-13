//
//  IngredientView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 09.03.2023.
//

import UIKit

protocol AddIngredientViewDelegate: AnyObject {
    func productInput(title: String?)
    func quantityInput()
}

class AddIngredientView: UIView {
   
    weak var delegate: AddIngredientViewDelegate?
    var productTitle: String? { productTextField.text }
    var descriptionTitle: String { descriptionTextView.text }
    var quantityTitle: String? { quantityTextField.text }
    
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
        textField.tintColor = .black
        textField.placeholder = R.string.localizable.name()
        return textField
    }()
    
    lazy var descriptionTextView: TextViewWithPlaceholder = {
        let textView = TextViewWithPlaceholder()
        textView.delegate = self
        textView.font = UIFont.SFPro.medium(size: 15).font
        textView.textColor = .black
        textView.tintColor = .black
        textView.setPlaceholder(placeholder: R.string.localizable.note())
        textView.isScrollEnabled = false
        textView.textContainer.maximumNumberOfLines = 10
        return textView
    }()
    
    lazy var quantityTextField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.font = UIFont.SFPro.bold(size: 15).font
        textField.textColor = UIColor(hex: "#D6600A")
        textField.placeholder = R.string.localizable.quantity1()
        textField.tintColor = .black
        textField.textAlignment = .right
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
    
    func setQuantity(_ quantity: String?) {
        quantityTextField.text = quantity
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
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(17)
        }
        
        descriptionTextView.snp.makeConstraints {
            $0.top.equalTo(productTextField.snp.bottom)
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalTo(quantityTextField.snp.leading).offset(-10)
            $0.height.greaterThanOrEqualTo(15)
            $0.bottom.equalToSuperview().offset(-5)
        }
        
        quantityTextField.snp.makeConstraints {
            $0.bottom.equalTo(descriptionTextView).offset(-5)
            $0.trailing.equalToSuperview().offset(-10)
        }
        
        quantityTextField.setContentCompressionResistancePriority(.init(1000), for: .horizontal)
        quantityTextField.setContentHuggingPriority(.init(1000), for: .horizontal)
    }
}

extension AddIngredientView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == productTextField {
            descriptionTextView.becomeFirstResponder()
        }
        if textField == quantityTextField {
            quantityTextField.becomeFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == quantityTextField {
            delegate?.quantityInput()
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == productTextField {
            delegate?.productInput(title: productTextField.text)
        }
    }
}

extension AddIngredientView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        descriptionTextView.checkPlaceholder()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        descriptionTextView.checkPlaceholder()
    }
}

final class TextViewWithPlaceholder: UITextView {
    
    func setPlaceholder(placeholder: String) {
        let placeholderLabel = UILabel()
        placeholderLabel.text = placeholder
        placeholderLabel.font = UIFont.SFPro.medium(size: 15).font
        placeholderLabel.sizeToFit()
        placeholderLabel.tag = 222
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (self.font?.pointSize ?? 10) / 2)
        placeholderLabel.textColor = .black.withAlphaComponent(0.3)
        placeholderLabel.isHidden = !self.text.isEmpty

        self.addSubview(placeholderLabel)
    }

    func checkPlaceholder() {
        guard let placeholderLabel = self.viewWithTag(222) as? UILabel else {
            return
        }
        placeholderLabel.isHidden = !self.text.isEmpty
    }
}
