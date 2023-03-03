//
//  CreateNewRecipeViewWithButton.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 03.03.2023.
//

import UIKit

final class CreateNewRecipeViewWithButton: UIView {

    var buttonPressed: (() -> Void)?
    var requiredHeight: Int {
        16 + 20 + 4 + 48
    }
    var text: String? {
        let text = placeholderLabel.text
        return text == initialState.placeholder ? nil : text
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
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.medium(size: 16).font
        label.textColor = UIColor(hex: "#777777")
        return label
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let shadowOneView = UIView()
    private let shadowTwoView = UIView()

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
    
    func configure(title: String, state: CreateNewRecipeViewState) {
        titleLabel.text = title
        initialState = state
        self.state = state
    }
    
    private func setup() {
        self.backgroundColor = .clear
        let tapOnView = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        contentView.addGestureRecognizer(tapOnView)
        
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
        placeholderLabel.text = state.placeholder
    }
    
    @objc
    private func viewTapped() {
        buttonPressed?()
    }
    
    private func makeConstraints() {
        self.addSubviews([titleLabel, shadowOneView, shadowTwoView, contentView])
        contentView.addSubviews([placeholderLabel, iconImageView])
        
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
        
        placeholderLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.center.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        iconImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.center.equalToSuperview()
            $0.height.width.equalTo(24)
        }
    }

}
