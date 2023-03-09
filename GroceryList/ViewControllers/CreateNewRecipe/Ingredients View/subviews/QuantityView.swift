//
//  QuantityView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 09.03.2023.
//

import UIKit

class QuantityView: UIView {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 15).font
        label.textColor = UIColor(hex: "#777777")
        label.text = "Quantity"
        return label
    }()
    
    private let quantityBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor(hex: "#31635A").cgColor
        view.layer.borderWidth = 1
        view.isHidden = false
        view.addShadowForView()
        return view
    }()
    
    lazy var quantityTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.SFPro.medium(size: 18).font
        textField.textColor = .black
        textField.textAlignment = .center
        textField.placeholder = "0"
        return textField
    }()
    
    private lazy var minusButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(minusButtonAction), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        button.setImage(R.image.minusInactive(), for: .normal)
        return button
    }()
    
    private lazy var plusButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(plusButtonAction), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        button.setImage(R.image.plusInactive(), for: .normal)
        return button
    }()
    
    private let unitsView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#D2D5DA")
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.addShadowForView()
        return view
    }()
    
    private let whiteArrowForSelectUnit: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = R.image.whiteArrowRight()
        return imageView
    }()
    
    private let unitLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFPro.semibold(size: 17).font
        label.textColor = .white
        label.textAlignment = .center
        label.text = "pieces".localized
        return label
    }()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setActive(_ isActive: Bool) {
        
    }
    
    private func setup() {
        self.backgroundColor = .clear

        makeConstraints()
    }
    
    @objc
    private func categoryButtonTapped() {
    }
    
    @objc
    private func plusButtonAction() {
//        quantityCount += quantityValueStep
//        quantityLabel.text = getDecimalString()
//        setupText()
//        quantityAvailable()
    }

    @objc
    private func minusButtonAction() {
//        guard quantityCount > 1 else {
//            return quantityNotAvailable()
//        }
//        quantityCount -= quantityValueStep
//        quantityLabel.text = getDecimalString()
//                             
//        setupText()
    }
    
    private func makeConstraints() {
        self.addSubviews([titleLabel, quantityBackgroundView, unitsView])
        quantityBackgroundView.addSubviews([quantityTextField, minusButton, plusButton])
        unitsView.addSubviews([unitLabel, whiteArrowForSelectUnit])

        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(29)
            $0.top.equalToSuperview()
            $0.height.equalTo(17)
        }
        
        quantityBackgroundView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.height.equalTo(40)
            $0.width.equalTo(200)
        }

        unitsView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.height.equalTo(40)
            $0.width.equalTo(134)
        }
        
        makeQuantityViewConstraints()
        makeUnitsViewConstraints()
    }
    
    private func makeQuantityViewConstraints() {
        quantityTextField.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        minusButton.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.height.width.equalTo(40)
        }
        
        plusButton.snp.makeConstraints {
            $0.trailing.top.bottom.equalToSuperview()
            $0.height.width.equalTo(40)
        }
    }
    
    private func makeUnitsViewConstraints() {
        unitLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(8)
            $0.trailing.equalTo(whiteArrowForSelectUnit.snp.leading).offset(-16)
            $0.centerY.equalToSuperview()
        }
        
        whiteArrowForSelectUnit.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-12)
            $0.top.equalToSuperview().inset(8)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(17)
        }
    }
}
