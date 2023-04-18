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
        view.addShadowForView()
        return view
    }()
    
    lazy var shortView: ProductButtonView = {
        let view = ProductButtonView(title: shortTitle)
        view.configureBorder()
        view.addShadowForView()
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
    
    func setupColor(_ color: UIColor) {
        activeColor = color
        longView.configureColor(color)
        shortView.configureColor(color)
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
        return textField
    }()
    
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
    
    func configureColor(_ color: UIColor) {
        self.layer.borderColor = color.cgColor
        titleTextField.textColor = color
        titleTextField.tintColor = color
    }
    
    func configureBorder(width: CGFloat = 1, radius: CGFloat = 8) {
        self.layer.cornerRadius = radius
        self.layer.borderWidth = width
    }
    
    private func setup() {
        makeConstraints()
    }
    
    private func makeConstraints() {
        self.addSubview(titleTextField)
        
        titleTextField.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
