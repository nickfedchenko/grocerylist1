//
//  NameOfStockView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 03.06.2023.
//

import UIKit

class NameOfStockView: NameOfProductView {

    var isAvailability: Bool {
        stockImageView.image == checkImage
    }
    
    private let stockView = UIView()
    private let colorView = UIView()
    private let stockImageView = UIImageView()
    
    private let checkImage = R.image.checkmark()?.withTintColor(.white)
    private let crossImage = R.image.whiteCross()?.withTintColor(.black)
    private var color: UIColor = .white
    
    override func setup() {
        super.setup()
        
        let tapOnStockRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOnStockView))
        stockView.addGestureRecognizer(tapOnStockRecognizer)
        
        colorView.layer.cornerRadius = 4
        colorView.layer.cornerCurve = .continuous
        
        makeConstraints()
    }
    
    @objc
    override func removeImageTapped() {
        AmplitudeManager.shared.logEvent(.pantryCreateItemDeletePhoto)
        productImageView.image = emptyImage
        setupRemoveImageButton()
    }
    
    @objc
    override func tapOnImage() {
        delegate?.tappedAddImage()
    }
    
    func setStock(isAvailability: Bool) {
        stockImageView.image = isAvailability ? checkImage : crossImage
        colorView.backgroundColor = isAvailability ? color : R.color.lightGray()
    }
    
    func setStockColor(color: UIColor) {
        colorView.backgroundColor = color
        self.color = color
    }
    
    @objc
    private func tapOnStockView() {
        if isAvailability {
            stockImageView.image = crossImage
            colorView.backgroundColor = R.color.lightGray()
        } else {
            stockImageView.image = checkImage
            colorView.backgroundColor = color
        }
    }
    
    private func makeConstraints() {
        contentView.addSubview(stockView)
        stockView.addSubviews([colorView, stockImageView])
        
        updateViewConstraints()
        
        stockView.snp.makeConstraints {
            $0.bottom.trailing.equalToSuperview().offset(-8)
            $0.height.width.equalTo(40)
        }
        
        colorView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.width.equalTo(26)
        }
        
        stockImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.width.equalTo(14)
        }
    }
    
    private func updateViewConstraints() {
        checkmarkImage.snp.updateConstraints {
            $0.width.equalTo(0)
        }
        
        productImageView.snp.removeConstraints()
        productImageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(8)
            $0.height.width.equalTo(40)
        }
        
        removeImageButton.snp.removeConstraints()
        removeImageButton.snp.makeConstraints {
            $0.top.leading.equalTo(productImageView).offset(-8)
            $0.width.height.equalTo(16)
        }
        
        productTextField.snp.removeConstraints()
        productTextField.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.equalTo(productImageView.snp.trailing).offset(12)
            $0.trailing.equalTo(stockView.snp.leading).offset(-12)
            $0.height.equalTo(21)
        }
        
        descriptionTextField.snp.removeConstraints()
        descriptionTextField.snp.makeConstraints {
            $0.top.equalTo(productTextField.snp.bottom)
            $0.leading.equalTo(productImageView.snp.trailing).offset(12)
            $0.trailing.equalTo(stockView.snp.leading).offset(-12)
            $0.height.greaterThanOrEqualTo(19)
        }
    }
}
