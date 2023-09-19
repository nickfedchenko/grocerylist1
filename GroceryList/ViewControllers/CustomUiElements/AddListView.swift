//
//  AddListView.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 11.04.2023.
//

import UIKit

final class AddListView: UIView {
    
    private let plusImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = R.image.new_createList()
        imageView.layer.cornerRadius = 16
        imageView.layer.cornerCurve = .continuous
        return imageView
    }()
    
    private let createListLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.SFProRounded.semibold(size: 18).font
        label.textColor = UIColor(hex: "#31635A")
        label.text = R.string.localizable.list()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setColor(background: UIColor?, title: UIColor? = .white,
                  imageBg: UIColor? = .white, image: UIColor?) {
        self.backgroundColor = background
        createListLabel.textColor = title
        plusImage.backgroundColor = imageBg
        plusImage.image = R.image.new_createList()?.withTintColor(image ?? .black)
    }
    
    func setText(_ text: String) {
        createListLabel.text = text
    }
    
    func updateView(isRightHanded: Bool) {
        self.layer.cornerRadius = 32
        self.layer.cornerCurve = .continuous
        
        guard isRightHanded else {
            self.layer.maskedCorners = [.layerMaxXMinYCorner]
            createListLabel.textAlignment = .right
            plusImage.snp.remakeConstraints {
                $0.top.equalToSuperview().offset(16)
                $0.height.width.equalTo(32)
                $0.trailing.equalToSuperview().offset(-16)
            }
            createListLabel.snp.remakeConstraints {
                $0.centerY.equalTo(plusImage)
                $0.trailing.equalTo(plusImage.snp.leading).offset(-12)
                $0.leading.equalToSuperview().offset(8)
            }
           return
        }
        self.layer.maskedCorners = [.layerMinXMinYCorner]
        createListLabel.textAlignment = .left
        plusImage.snp.remakeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.height.width.equalTo(32)
            $0.leading.equalToSuperview().offset(16)
        }
        createListLabel.snp.remakeConstraints {
            $0.centerY.equalTo(plusImage)
            $0.leading.equalTo(plusImage.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().offset(-8)
        }
    }
    
    private func setup() {
        self.layer.cornerRadius = 32
        self.layer.cornerCurve = .continuous
        self.layer.maskedCorners = [.layerMinXMinYCorner]
        self.backgroundColor = .white
        self.layer.borderColor = UIColor(hex: "#EBFEFE").cgColor
        self.layer.borderWidth = 2
        self.addShadow(color: UIColor(hex: "#484848"), offset: CGSize(width: 0, height: 0.5))
        
        makeConstraints()
    }
    
    private func makeConstraints() {
        self.addSubviews([plusImage, createListLabel])
        
        plusImage.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.height.width.equalTo(32)
            $0.leading.equalToSuperview().offset(16)
        }
        
        createListLabel.snp.makeConstraints {
            $0.centerY.equalTo(plusImage)
            $0.leading.equalTo(plusImage.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().offset(-8)
        }
    }
}
