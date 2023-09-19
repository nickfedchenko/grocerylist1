//
//  NameOfProductView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 14.04.2023.
//

import Kingfisher
import UIKit

protocol NameOfProductViewDelegate: AnyObject {
    func enterProductName(name: String?)
    func isFirstResponderProductTextField(_ flag: Bool)
    func tappedAddImage()
}

class NameOfProductView: UIView {
    
    weak var delegate: NameOfProductViewDelegate?
    var productTitle: String? {
        productTextView.text
    }
    var descriptionTitle: String? {
        descriptionTextField.text
    }
    var productImage: UIImage? {
        productImageView.image == emptyImage ? nil : productImageView.image
    }

    lazy var productTextView: TextViewWithPlaceholder = {
        let textView = TextViewWithPlaceholder()
        textView.delegate = self
        textView.font = UIFont.SFPro.semibold(size: 17).font
        textView.textColor = .black
        textView.tintColor = .black
        textView.backgroundColor = .clear
        textView.keyboardAppearance = .light
        textView.setPlaceholder(placeholder: R.string.localizable.name(),
                                textColor: R.color.mediumGray(),
                                 font: UIFont.SFPro.semibold(size: 17).font)
        textView.textContainer.maximumNumberOfLines = 4
        textView.isScrollEnabled = false
        if UIDevice.isSEorXor12mini {
            textView.autocorrectionType = .no
            textView.spellCheckingType = .no
        }
        return textView
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
    
    private(set) lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        return view
    }()
    
    let checkmarkImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = R.image.emptyCheckmark()
        return imageView
    }()
    
    let productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = R.image.addImage()
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private(set) lazy var removeImageButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.removeImage(), for: .normal)
        button.addTarget(self, action: #selector(removeImageTapped), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private let shadowOneView = UIView()
    private let shadowTwoView = UIView()
    let emptyImage = R.image.addImage()
    private var quantityText = ""
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setTintColor(_ tintColor: UIColor) {
        productTextView.tintColor = tintColor
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
        if let url = URL(string: imageURL) {
            let resource = ImageResource(downloadURL: url, cacheKey: url.absoluteString)
            productImageView.kf.setImage(with: resource, options: [
                .processor(DownsamplingImageProcessor(size: CGSize(width: 30, height: 30))),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage
            ])
            setupRemoveImageButton()
        }
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
    
    func setup() {
        let tapOnAddImageRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOnImage))
        productImageView.addGestureRecognizer(tapOnAddImageRecognizer)
        
        setupShadowView()
        makeConstraints()
    }
    
    func setupRemoveImageButton() {
        removeImageButton.isHidden = productImageView.image == emptyImage
    }
    
    @objc
    func removeImageTapped() {
        AmplitudeManager.shared.logEvent(.photoDelete)
        productImageView.image = emptyImage
        setupRemoveImageButton()
    }
    
    @objc
    func tapOnImage() {
        AmplitudeManager.shared.logEvent(.photoAdd)
        delegate?.tappedAddImage()
    }
    
    private func setupShadowView() {
        [shadowOneView, shadowTwoView].forEach { shadowView in
            shadowView.backgroundColor = UIColor(hex: "#E5F5F3")
            shadowView.layer.cornerRadius = 16
        }
        shadowOneView.addShadow(color: UIColor(hex: "#484848"),
                                      opacity: 0.15,
                                      radius: 1,
                                      offset: .init(width: 0, height: 0.5))
        shadowTwoView.addShadow(color: UIColor(hex: "#858585"),
                                      opacity: 0.1,
                                      radius: 6,
                                      offset: .init(width: 0, height: 6))
    }
    
    private func sizeOfString(string: String, constrainedToWidth width: Double,
                              font: UIFont) -> CGSize {
        return (string as NSString).boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude),
                                                 options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                 attributes: [NSAttributedString.Key.font: font],
                                                 context: nil).size
    }
    
    private func makeConstraints() {
        self.addSubviews([shadowOneView, shadowTwoView, contentView])
        contentView.addSubviews([checkmarkImage, productTextView, descriptionTextField, productImageView, removeImageButton])
        
        contentView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        [shadowOneView, shadowTwoView].forEach { shadowView in
            shadowView.snp.makeConstraints { $0.edges.equalTo(contentView) }
        }
        
        checkmarkImage.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(8)
            $0.centerY.equalToSuperview()
            $0.height.width.equalTo(40)
        }
        
        productTextView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.leading.equalTo(checkmarkImage.snp.trailing).offset(12)
            $0.trailing.equalTo(productImageView.snp.leading).offset(-12)
            $0.height.greaterThanOrEqualTo(21)
        }
        
        descriptionTextField.snp.makeConstraints {
            $0.top.equalTo(productTextView.snp.bottom)
            $0.leading.equalTo(checkmarkImage.snp.trailing).offset(12)
            $0.trailing.equalTo(productImageView.snp.leading).offset(-12)
            $0.height.greaterThanOrEqualTo(19)
            $0.bottom.equalToSuperview().offset(-8)
        }
        
        productImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-8)
            $0.centerY.equalToSuperview()
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
        if textField == productTextView {
            descriptionTextField.becomeFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.isFirstResponderProductTextField(false)
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength < 30
    }
}

extension NameOfProductView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        delegate?.isFirstResponderProductTextField(true)
        productTextView.checkPlaceholder()
    }

    func textViewDidChange(_ textView: UITextView) {
        productTextView.checkPlaceholder()
        delegate?.enterProductName(name: productTextView.text)
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        var textWidth = textView.frame.inset(by: textView.textContainerInset).width
        textWidth -= 2.0 * textView.textContainer.lineFragmentPadding

        let boundingRect = sizeOfString(string: newText, constrainedToWidth: Double(textWidth), font: textView.font ?? UIFont())
        let numberOfLines = boundingRect.height / (textView.font?.lineHeight ?? 1)

        return numberOfLines <= 4
    }
}
