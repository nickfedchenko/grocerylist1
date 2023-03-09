//
//  CreateNewRecipeViewWithButton.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 03.03.2023.
//

import UIKit

final class CreateNewRecipeViewWithButton: UIView {

    var buttonPressed: (() -> Void)?
    var updateLayout: (() -> Void)?
    var requiredHeight: Int {
        Int(CGFloat(top + offset + 20 + 4 + 48) + stackContentSize.height)
    }
    var text: String? {
        let text = placeholderLabel.text
        return text == initialState.placeholder ? nil : text
    }
    var stackSubviewsCount: Int {
        stackView.arrangedSubviews.count
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
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillProportionally
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
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
    
    private lazy var closeStackButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.chevronUpGreen(), for: .normal)
        button.addTarget(self, action: #selector(closeStackButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let shadowOneView = UIView()
    private let shadowTwoView = UIView()
    private var stackContentSize: CGSize {
        stackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
    private var top = 16
    private var offset = 0
    private var initialState: CreateNewRecipeViewState = .required
    private var state: CreateNewRecipeViewState = .required {
        didSet { updateState() }
    }
    private var shadowViews: [UIView] {
        [shadowOneView, shadowTwoView]
    }
    private var placeholderTitle: String?
    private var stackViewIsVisible = true
    
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
    
    func updateCollectionPlaceholder(_ title: String) {
        guard !title.isEmpty else {
            placeholderLabel.textColor = UIColor(hex: "#777777")
            iconImageView.image = nil
            placeholderTitle = nil
            state = initialState
            return
        }
        placeholderTitle = title
        placeholderLabel.textColor = UIColor(hex: "#0C695E")
        iconImageView.image = R.image.collectionChevron()
        state = .filled
    }
    
    func closeStackButton(isVisible: Bool) {
        closeStackButton.isHidden = !isVisible
        if isVisible {
            top = 26
            offset = 10
            titleLabel.snp.updateConstraints { $0.top.equalToSuperview().offset(top) }
            stackView.snp.updateConstraints { $0.top.equalTo(titleLabel.snp.bottom).offset(10) }
        }
    }
    
    func addViewToStackView(_ view: UIView) {
        stackView.addArrangedSubview(view)
        view.layoutIfNeeded()
        contentView.snp.updateConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(8)
        }
    }
    
    func setIconImage(image: UIImage?) {
        iconImageView.image = image
    }
    
    func setPlaceholder(_ placeholder: String? = nil) {
        placeholderTitle = placeholder
    }
    
    func setState(_ state: CreateNewRecipeViewState) {
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
        placeholderLabel.text = placeholderTitle ?? state.placeholder
        placeholderLabel.textColor = UIColor(hex: state == .filled ? "#0C695E" : "#777777")
    }
    
    private func stackView(isVisible: Bool) {
        closeStackButton.setImage(isVisible ? R.image.chevronUpGreen() : R.image.chevronDownGreen(),
                                  for: .normal)
        DispatchQueue.main.async {
            self.stackView.arrangedSubviews.forEach {
                $0.isHidden = !isVisible
            }
            self.updateLayout?()
        }
    }
    
    @objc
    private func viewTapped() {
        buttonPressed?()
    }
    
    @objc
    private func closeStackButtonTapped() {
        stackViewIsVisible.toggle()
        stackView(isVisible: stackViewIsVisible)
    }
    
    private func makeConstraints() {
        self.addSubviews([titleLabel, shadowOneView, shadowTwoView, contentView,
                          stackView, closeStackButton])
        contentView.addSubviews([placeholderLabel, iconImageView])
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(28)
            $0.top.equalToSuperview().offset(top)
            $0.height.equalTo(20)
        }
        
        closeStackButton.snp.makeConstraints {
            $0.trailing.equalTo(stackView)
            $0.bottom.equalTo(stackView.snp.top)
            $0.height.width.equalTo(40)
        }
        
        stackView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(stackView.snp.bottom).offset(0)
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
            $0.trailing.equalToSuperview().offset(-8)
            $0.centerY.equalToSuperview()
            $0.height.width.equalTo(40)
        }
    }
}
