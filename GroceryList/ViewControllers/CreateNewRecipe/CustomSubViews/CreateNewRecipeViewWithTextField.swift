//
//  CreateNewRecipeViewWithTextField.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 02.03.2023.
//

import UIKit

final class CreateNewRecipeViewWithTextField: UIView {
    
    enum ViewState {
        case required
        case optional
        case used
    }
    
    var textFieldReturnPressed: (() -> Void)?
    var requiredHeight: Int {
        16 + 20 + 4 + 48
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 16).font
        label.textColor = UIColor(hex: "#777777")
        return label
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        return view
    }()
    
    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.font = UIFont.SFPro.medium(size: 16).font
        textField.tintColor = UIColor(hex: "#1A645A")
        return textField
    }()
    
    private let shadowOneView = UIView()
    private let shadowTwoView = UIView()
    private var isNumber = false
    private var initialState: ViewState = .required
    private var state: ViewState = .required {
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
    
    func configure(title: String, state: ViewState) {
        titleLabel.text = title
        initialState = state
        self.state = state
    }
    
    func setOnlyNumber() {
        isNumber = true
        textField.keyboardType = .numberPad
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
        textField.placeholder = state.placeholder
    }
    
    private func makeConstraints() {
        self.addSubviews([titleLabel, shadowOneView, shadowTwoView, contentView])
        contentView.addSubview(textField)
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(28)
            $0.top.equalToSuperview().offset(16)
            $0.height.equalTo(20)
        }
        
        contentView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        shadowViews.forEach { shadowView in
            shadowView.snp.makeConstraints { $0.edges.equalTo(contentView) }
        }
        
        textField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.center.equalToSuperview()
            $0.height.equalTo(20)
        }
    }
}

extension CreateNewRecipeViewWithTextField: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        state = .used
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        state = initialState
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textFieldReturnPressed?()
        return true
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if isNumber {
            return CharacterSet(charactersIn: "0123456789").isSuperset(of: CharacterSet(charactersIn: string))
        }
        return true
    }
}

extension CreateNewRecipeViewWithTextField.ViewState {
    
    var borderWidth: CGFloat {
        switch self {
        case .required: return 2
        case .optional: return 1
        case .used:     return 2
        }
    }
    
    var borderColor: UIColor {
        switch self {
        case .required: return UIColor(hex: "#62D3B4")
        case .optional: return UIColor(hex: "#B3EFDE")
        case .used:     return UIColor(hex: "#1A645A")
        }
    }
    
    var shadowColors: [UIColor] {
        switch self {
        case .required: return [UIColor(hex: "#484848"), UIColor(hex: "#858585")]
        case .optional: return [UIColor(hex: "#123E5E"), UIColor(hex: "#06BBBB")]
        case .used:     return [.clear, .clear]
        }
    }
    
    var shadowOpacity: [Float] {
        switch self {
        case .required: return [0.15, 0.1]
        case .optional: return [0.25, 0.2]
        case .used:     return [0, 0]
        }
    }
    
    var shadowRadius: [CGFloat] {
        switch self {
        case .required: return [1, 6]
        case .optional: return [1, 5]
        case .used:     return [0, 0]
        }
    }
    
    var shadowOffset: [CGSize] {
        switch self {
        case .required: return [.init(width: 0, height: 0.5), .init(width: 0, height: 4)]
        case .optional: return [.init(width: 0, height: 0.5), .init(width: 0, height: 4)]
        case .used:     return [.zero, .zero]
        }
    }
    
    var placeholder: String {
        switch self {
        case .required: return R.string.localizable.required()
        case .optional: return R.string.localizable.optional()
        case .used:     return ""
        }
    }
}
