//
//  SecondView.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 01.11.2022.
//

import UIKit

class SecondOnboardingView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
      }

      required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
      }
    
    func firstAnimation() {
        
    }
    
    func secndAnimation() {
        
    }
    
    private let backgroundView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "secondBG")
        return imageView
    }()
    
    private let phoneView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "firstScreen")
        return imageView
    }()
    
    private let mainTextView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#D7F8EE")
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = false
        return view
    }()
    
    private let mainTextLabel: UILabel = {
        let label = UILabel()
        label.font = .SFPro.semibold(size: 18).font
        label.textColor = UIColor(hex: "#31635A")
        let attributedString = NSMutableAttributedString(string: "CreateLists".localized)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle,
                                      value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        label.attributedText = attributedString
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let shadowView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray.withAlphaComponent(0.5)
        view.layer.cornerRadius = 18
        return view
    }()
    
    private let addItemImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "addItemImage")
        return imageView
    }()
    
    private let addItemLabel: UILabel = {
        let label = UILabel()
        label.font = .SFPro.semibold(size: 18).font
        label.textColor = .white
        label.textAlignment = .center
        label.text = "AddItem".localized
        return label
    }()
    
    private func setupConstraints() {
       
        addSubviews([backgroundView, phoneView, shadowView, mainTextView, addItemImage])
        mainTextView.addSubview(mainTextLabel)
        addItemImage.addSubview(addItemLabel)
        
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        phoneView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.8)
            make.width.equalTo(232)
            make.height.equalTo(500)
        }
        
        mainTextView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(50)
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).inset(114)
            make.height.equalTo(201)
        }
        
        shadowView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(44)
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).inset(104)
            make.height.equalTo(210)
        }
        
        addItemImage.snp.makeConstraints { make in
            make.right.equalTo(mainTextView.snp.right)
            make.centerY.equalTo(mainTextView.snp.top)
            make.width.equalTo(164)
            make.height.equalTo(65)
        }
        
        mainTextLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(30)
            make.top.equalToSuperview().inset(46)
        }
        
        addItemLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-2)
            make.left.equalToSuperview().inset(58)
        }

    }
}
