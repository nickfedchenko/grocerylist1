//
//  CreateNewRecipeViewWithTextField.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 02.03.2023.
//

import UIKit

final class CreateNewRecipeViewWithTextField: UIView {
    
    var textFieldDidChange: (() -> Void)?
    var textFieldReturnPressed: (() -> Void)?
    var updateLayout: (() -> Void)?
    var requiredHeight: Int {
        var contentHeight = Int(textView.contentSize.height)
        contentHeight = textView.text == "" ? 0 : contentHeight
        return 16 + 20 + 4 + (contentHeight == 0 ? 48 : contentHeight + 14)
    }
    var isEmpty: Bool {
        textView.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true
    }
    
    var maxLineNumber = 0
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 16).font
        label.textColor = R.color.darkGray()
        return label
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        return view
    }()
    
    lazy var textView: TextViewWithPlaceholder = {
        let textView = TextViewWithPlaceholder()
        textView.delegate = self
        textView.font = UIFont.SFPro.medium(size: 16).font
        textView.tintColor = R.color.primaryDark()
        textView.isScrollEnabled = false
        textView.textColor = .black
        return textView
    }()
    
    private let shadowOneView = UIView()
    private let shadowTwoView = UIView()
    private var isNumber = false
    private var modeIsTextField = true
    private var initialState: CreateNewRecipeViewState = .required
    private var state: CreateNewRecipeViewState = .required {
        didSet { updateState() }
    }
    private var shadowViews: [UIView] {
        [shadowOneView, shadowTwoView]
    }
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(title: String, state: CreateNewRecipeViewState, modeIsTextField: Bool = true) {
        titleLabel.text = title
        initialState = state
        self.state = state
        self.modeIsTextField = modeIsTextField
    }
    
    func setOnlyNumber() {
        isNumber = true
        textView.keyboardType = .numberPad
    }
    
    func setMaxLine(_ number: Int) {
        
    }
    
    func setText(_ text: String?) {
        textView.text = text
        textView.checkPlaceholder()
    }
    
    private func setup() {
        self.backgroundColor = .clear
        shadowViews.forEach { shadowView in
            shadowView.backgroundColor = .white
            shadowView.layer.cornerRadius = 8
        }
        
        makeConstraints()
    }
    
    private func updateState() {
        shadowViews.enumerated().forEach { index, shadowView in
            shadowView.addCustomShadow(color: state.shadowColors[index],
                                       opacity: state.shadowOpacity[index],
                                       radius: state.shadowRadius[index],
                                       offset: state.shadowOffset[index])
        }
        contentView.layer.borderWidth = state.borderWidth
        contentView.layer.borderColor = state.borderColor.cgColor
        textView.setPlaceholder(placeholder: state.placeholder,
                                textColor: state.placeholderColor,
                                font: UIFont.SFPro.medium(size: 16).font)
    }
    
    private func sizeOfString(string: String, constrainedToWidth width: Double,
                              font: UIFont) -> CGSize {
        return (string as NSString).boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude),
                                                 options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                 attributes: [NSAttributedString.Key.font: font],
                                                 context: nil).size
    }
    
    private func makeConstraints() {
        self.addSubviews([titleLabel, shadowOneView, shadowTwoView, contentView])
        contentView.addSubview(textView)
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalToSuperview().offset(16)
            $0.height.equalTo(20)
        }
        
        contentView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
            $0.height.greaterThanOrEqualTo(48)
        }
        
        shadowViews.forEach { shadowView in
            shadowView.snp.makeConstraints { $0.edges.equalTo(contentView) }
        }
        
        textView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.equalToSuperview().offset(7)
            $0.bottom.equalToSuperview()
        }
    }
}

extension CreateNewRecipeViewWithTextField: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        state = .used
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        state = (textView.text?.isEmpty ?? true) ? initialState : .filled
        self.textView.checkPlaceholder()
    }

    func textViewDidChange(_ textView: UITextView) {
        textFieldDidChange?()
        updateLayout?()
        self.textView.checkPlaceholder()
    }
    
    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        if isNumber {
            return CharacterSet(charactersIn: "0123456789").isSuperset(of: CharacterSet(charactersIn: text))
        }
        if modeIsTextField && text == "\n" {
            textFieldReturnPressed?()
            return false
        }
        
        if maxLineNumber > 0 {
            let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
            var textWidth = CGRectGetWidth(textView.frame.inset(by: textView.textContainerInset))
            textWidth -= 2.0 * textView.textContainer.lineFragmentPadding

            let boundingRect = sizeOfString(string: newText, constrainedToWidth: Double(textWidth), font: textView.font!)
            let numberOfLines = boundingRect.height / (textView.font?.lineHeight ?? 16)

            return numberOfLines <= CGFloat(maxLineNumber)
        }
        
        return true
    }
}
