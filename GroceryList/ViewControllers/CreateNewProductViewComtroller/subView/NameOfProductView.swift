//
//  NameOfProductView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 14.04.2023.
//

import UIKit

protocol NameOfProductViewDelegate: AnyObject {
    func enterProductName(name: String?)
    func isFirstResponderProductTextField(_ flag: Bool)
    func tappedAddImage()
}

class NameOfProductView: UIView {
    
    weak var delegate: NameOfProductViewDelegate?
    var productTitle: String? {
        productTextField.text
    }
    var descriptionTitle: String? {
        descriptionTextField.text
    }
    var productImage: UIImage? {
        productImageView.image == emptyImage ? nil : productImageView.image
    }
    
    lazy var productTextField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.font = UIFont.SFPro.semibold(size: 17).font
        textField.textColor = .black
        textField.tintColor = .black
        textField.placeholder = " " + R.string.localizable.name()
        return textField
    }()
    
    lazy var descriptionTextField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.font = UIFont.SFPro.medium(size: 15).font
        textField.textColor = .black
        textField.tintColor = .black
        textField.placeholder = R.string.localizable.addNote()
        return textField
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let checkmarkImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = R.image.emptyCheckmark()
        return imageView
    }()
    
    private let productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = R.image.addImage()
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private lazy var removeImageButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.removeImage(), for: .normal)
        button.addTarget(self, action: #selector(removeImageTapped), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private let shadowOneView = UIView()
    private let shadowTwoView = UIView()
    private let emptyImage = R.image.addImage()
    private var quantityText = ""
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setTintColor(_ tintColor: UIColor) {
        productTextField.tintColor = tintColor
        descriptionTextField.tintColor = tintColor
    }
    
    func setQuantity(_ quantity: String) {
        defer {
            quantityText = quantity
        }
        
        guard let descriptionTitle else {
            descriptionTextField.text = quantity
            return
        }
        
        var descriptionTitleWithoutQuantity = descriptionTitle.replacingOccurrences(of: quantityText, with: "")
        
        if descriptionTitleWithoutQuantity.isEmpty {
            descriptionTextField.text = quantity
            return
        }
        
        if descriptionTitleWithoutQuantity.first != "," {
            descriptionTitleWithoutQuantity = ", " + descriptionTitleWithoutQuantity
        }
        
        if quantity == "" {
            descriptionTitleWithoutQuantity = descriptionTitleWithoutQuantity.replacingOccurrences(of: ", ", with: "")
        }
        
        let newDescription = quantity + descriptionTitleWithoutQuantity
        descriptionTextField.text = newDescription
    }
    
    func setImage(imageURL: String, imageData: Data?) {
        if let imageData {
            productImageView.image = UIImage(data: imageData)
            setupRemoveImageButton()
            return
        }
        guard !imageURL.isEmpty else {
            productImageView.image = emptyImage
            setupRemoveImageButton()
            return
        }
        productImageView.kf.indicatorType = .activity
        productImageView.kf.setImage(with: URL(string: imageURL), placeholder: nil, options: nil, completionHandler: nil)
        setupRemoveImageButton()
    }
    
    func setImage(_ image: UIImage?) {
        productImageView.image = image
        setupRemoveImageButton()
    }
    
    func reset() {
        productImageView.image = emptyImage
        descriptionTextField.text = ""
        setupRemoveImageButton()
    }
    
    private func setup() {
        let tapOnAddImageRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOnImage))
        productImageView.addGestureRecognizer(tapOnAddImageRecognizer)
        
        setupShadowView()
        makeConstraints()
    }
    
    private func setupRemoveImageButton() {
        removeImageButton.isHidden = productImageView.image == emptyImage
    }
    
    @objc
    private func removeImageTapped() {
        AmplitudeManager.shared.logEvent(.photoDelete)
        productImageView.image = emptyImage
        setupRemoveImageButton()
    }
    
    @objc
    private func tapOnImage() {
        AmplitudeManager.shared.logEvent(.photoAdd)
        delegate?.tappedAddImage()
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
        contentView.addSubviews([checkmarkImage, productTextField, descriptionTextField, productImageView, removeImageButton])
        
        contentView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        [shadowOneView, shadowTwoView].forEach { shadowView in
            shadowView.snp.makeConstraints { $0.edges.equalTo(contentView) }
        }
        
        checkmarkImage.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(8)
            $0.height.width.equalTo(40)
        }
        
        productTextField.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.equalTo(checkmarkImage.snp.trailing).offset(12)
            $0.trailing.equalTo(productImageView.snp.leading).offset(-12)
            $0.height.equalTo(21)
        }
        
        descriptionTextField.snp.makeConstraints {
            $0.top.equalTo(productTextField.snp.bottom)
            $0.leading.equalTo(checkmarkImage.snp.trailing).offset(12)
            $0.trailing.equalTo(productImageView.snp.leading).offset(-12)
            $0.height.greaterThanOrEqualTo(19)
        }
        
        productImageView.snp.makeConstraints {
            $0.bottom.trailing.equalToSuperview().offset(-8)
            $0.height.width.equalTo(40)
        }
        
        removeImageButton.snp.makeConstraints { make in
            make.top.equalTo(productImageView).offset(-8)
            make.trailing.equalTo(productImageView).offset(8)
            make.width.height.equalTo(16)
        }
    }
}

extension NameOfProductView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == productTextField {
            descriptionTextField.becomeFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.isFirstResponderProductTextField(textField == productTextField)
        if textField == descriptionTextField {
            AmplitudeManager.shared.logEvent(.secondInputManual)
            guard !(descriptionTextField.text?.isEmpty ?? true) else {
                return
            }
            if descriptionTextField.text == quantityText {
                descriptionTextField.text = quantityText + ", "
            }
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == productTextField {
            delegate?.enterProductName(name: productTextField.text)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength < 25
    }
}
