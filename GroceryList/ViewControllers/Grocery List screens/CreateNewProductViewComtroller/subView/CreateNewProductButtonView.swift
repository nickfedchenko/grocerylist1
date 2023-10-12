//
//  CreateNewProductButtonView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 14.04.2023.
//

import UIKit

class CreateNewProductButtonView: ViewWithOverriddenPoint {
    
    lazy var longView: ProductButtonView = {
        let view = ProductButtonView(title: longTitle)
        view.configureBorder()
        return view
    }()
    
    lazy var shortView: ProductButtonView = {
        let view = ProductButtonView(title: shortTitle)
        view.configureBorder()
        return view
    }()
    
    var activeColor: UIColor = .black
    
    private var longTitle: String
    private var shortTitle: String
    
    init(longTitle: String, shortTitle: String) {
        self.longTitle = longTitle
        self.shortTitle = shortTitle
        
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        makeConstraints()
        let tapOnLongView = UITapGestureRecognizer(target: self, action: #selector(longViewTapped))
        longView.addGestureRecognizer(tapOnLongView)
        
        let tapOnShortView = UITapGestureRecognizer(target: self, action: #selector(shortViewTapped))
        shortView.addGestureRecognizer(tapOnShortView)
    }
    
    func isLongTitleEnableUserInteraction(_ enabled: Bool) {
        longView.isUserInteractionEnabled = enabled
    }
    
    func isShortTitleEnableUserInteraction(_ enabled: Bool) {
        shortView.isUserInteractionEnabled = enabled
    }
    
    func setupColor(backgroundColor: UIColor, tintColor: UIColor) {
        activeColor = tintColor
        longView.configureColor(backgroundColor: backgroundColor, tintColor: tintColor)
        shortView.configureColor(backgroundColor: backgroundColor, tintColor: tintColor)
    }
    
    @objc
    func longViewTapped() { }
    
    @objc
    func shortViewTapped() { }
    
    func makeConstraints() {
        self.addSubviews([longView, shortView])
        
        longView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalTo(shortView.snp.leading).offset(-20)
        }
        
        shortView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.equalTo(144)
        }
    }
}

class ProductButtonView: UIView {
    
    lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.SFPro.semibold(size: 17).font
        textField.textAlignment = .center
        textField.layer.shadowOpacity = 0
        textField.isUserInteractionEnabled = false
        textField.adjustsFontSizeToFitWidth = true
        textField.minimumFontSize = 10
        return textField
    }()
    
    var shadowViews: [UIView] {
        [shadowOneView, shadowTwoView]
    }
    
    private let shadowOneView = UIView()
    private let shadowTwoView = UIView()
    
    init(title: String) {
        super.init(frame: .zero)
        
        titleTextField.text = title
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func isTitleEnableUserInteraction(_ enabled: Bool) {
        titleTextField.isUserInteractionEnabled = enabled
    }
    
    func configureTitle(_ title: String) {
        titleTextField.text = title
    }
    
    func configureColor(backgroundColor: UIColor, tintColor: UIColor) {
        shadowViews.forEach {
            $0.backgroundColor = backgroundColor
        }
        
        shadowTwoView.layer.borderColor = tintColor.cgColor
        titleTextField.textColor = tintColor
        titleTextField.tintColor = tintColor
    }
    
    func configureBorder(width: CGFloat = 1, radius: CGFloat = 8) {
        shadowViews.forEach {
            $0.layer.cornerRadius = radius
            $0.layer.borderWidth = width
        }
    }
    
    private func setup() {
        shadowOneView.addShadow(color: UIColor(hex: "#858585"), opacity: 0.1,
                                      radius: 6, offset: .init(width: 0, height: 4))
        shadowTwoView.addShadow(color: UIColor(hex: "#484848"), opacity: 0.15,
                                      radius: 1, offset: .init(width: 0, height: 0.5))
        
        makeConstraints()
    }
    
    private func makeConstraints() {
        self.addSubviews(shadowViews)
        shadowTwoView.addSubview(titleTextField)
        
        shadowViews.forEach {
            $0.snp.makeConstraints { $0.edges.equalToSuperview() }
        }
        
        titleTextField.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
