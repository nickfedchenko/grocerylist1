//
//  NewPaywallBottomProductsView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 14.07.2023.
//

import UIKit

protocol NewPaywallProductsViewDelegate: AnyObject {
    func privacyDidTap()
    func termsDidTap()
    func didTapToRestorePurchases()
    func continueButtonPressed()
    func tapProduct(tag: Int)
}

class NewPaywallBottomProductsView: UIView {

    weak var delegate: NewPaywallProductsViewDelegate?
    
    private let contentView = UIView()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private lazy var continueButton: UIButton = {
        let button = UIButton()
        let font = UIFont.SFProDisplay.semibold(size: 20).font ?? UIFont()
        let attributedTitle = NSAttributedString(string: R.string.localizable.continue().uppercased(),
                                                 attributes: [.font: font,
                                                              .foregroundColor: UIColor.white])
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.backgroundColor = R.color.primaryDark()
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor(hex: "59FFD4").cgColor
        button.addTarget(self, action: #selector(nextButtonPressed), for: .touchUpInside)
        button.addDefaultShadowForPopUp()
        return button
    }()
    
    private lazy var privacyButton: UIButton = {
        let button = UIButton()
        button.setTitle(R.string.localizable.privacyPolicy(), for: .normal)
        button.setTitleColor(UIColor(hex: "#59FFD4"), for: .normal)
        button.titleLabel?.font = UIFont.SFProRounded.medium(size: 12).font
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.3
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.textAlignment = .left
        button.addTarget(self, action: #selector(privacyDidTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var restorePurchasesButton: UIButton = {
        let button = UIButton(type: .system)
        let style = NSMutableParagraphStyle()
        let attrTitle = NSAttributedString(
            string: R.string.localizable.restorePurchase(),
            attributes: [.font: UIFont.SFProRounded.medium(size: 15).font ?? UIFont(),
                         .foregroundColor: UIColor(hex: "#59FFD4"),
                         .underlineStyle: NSUnderlineStyle.single.rawValue,
                         .paragraphStyle: style]
        )
        button.setAttributedTitle(attrTitle, for: .normal)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(didTapToRestorePurchases), for: .touchUpInside)
        return button
    }()
    
    private lazy var termsButton: UIButton = {
        let button = UIButton()
        button.setTitle(R.string.localizable.termOfUse(), for: .normal)
        button.setTitleColor(UIColor(hex: "#59FFD4"), for: .normal)
        button.titleLabel?.font = UIFont.SFProRounded.medium(size: 12).font
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.3
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.textAlignment = .right
        button.addTarget(self, action: #selector(termsDidTap), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)

        self.layer.cornerRadius = 24
        self.addDefaultShadowForPopUp()
        contentView.layer.cornerRadius = 24
        contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        contentView.backgroundColor = R.color.primaryDark()

        makeConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(products: [PayWallModel]) {
        stackView.removeAllArrangedSubviews()
        
        products.enumerated().forEach { index, product in
            let view = NewPaywallProductView()
            view.configure(product: product)
            view.tag = index
            
            view.tapProduct = { [weak self] tag in
                self?.delegate?.tapProduct(tag: tag)
            }
            stackView.addArrangedSubview(view)
        }
        
    }
    
    func selectProduct(_ selectProduct: Int) {
        stackView.arrangedSubviews.forEach {
            ($0 as? NewPaywallProductView)?.markAsSelect(selectProduct == $0.tag)
        }
    }
    
    @objc
    private func nextButtonPressed() {
        delegate?.continueButtonPressed()
    }

    @objc
    private func didTapToRestorePurchases() {
        delegate?.didTapToRestorePurchases()
    }

    @objc
    private func privacyDidTap() {
        delegate?.privacyDidTap()
    }
    
    @objc
    private func termsDidTap() {
        delegate?.termsDidTap()
    }
    
    private func makeConstraints() {
        self.addSubviews([contentView])
        contentView.addSubviews([stackView, continueButton,
                                 restorePurchasesButton, privacyButton, termsButton])
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        stackView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(103)
        }
        
        continueButton.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(64)
        }
        
        restorePurchasesButton.setContentCompressionResistancePriority(.init(1000), for: .horizontal)
        restorePurchasesButton.snp.makeConstraints {
            $0.top.equalTo(continueButton.snp.bottom).offset(9)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(18)
        }
        
        privacyButton.setContentCompressionResistancePriority(.init(1), for: .horizontal)
        privacyButton.snp.makeConstraints {
            $0.top.equalTo(continueButton.snp.bottom).offset(11)
            $0.leading.equalToSuperview().offset(17)
            $0.trailing.equalTo(restorePurchasesButton.snp.leading).offset(-16)
        }
        
        termsButton.setContentCompressionResistancePriority(.init(1), for: .horizontal)
        termsButton.snp.makeConstraints {
            $0.top.equalTo(privacyButton)
            $0.leading.equalTo(restorePurchasesButton.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
    }

}
