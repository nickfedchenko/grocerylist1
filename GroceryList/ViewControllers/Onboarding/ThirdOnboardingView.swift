//
//  ThirdOnboardingView.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 02.11.2022.
//

import UIKit

class ThirdOnboardingView: UIView {
    
    var firstAnimationFinished: (() -> Void)?
    var secondAnimationFinished: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
        preparationsForAnimation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func preparationsForAnimation() {
        addItemImage.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        addItemLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
    }
    
    func firstAnimation() {
        UIView.animate(withDuration: 1.0, delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: .curveLinear) {
            self.addItemImage.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.addItemLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.firstSideView.isHidden = false
            self.secondSideView.isHidden = false
            self.thirdSideView.isHidden = false
            self.forthSideView.isHidden = false
            if UIScreen.main.isMoreIphonePlus {
                self.fifthSideView.isHidden = false
            }
       
            self.firstSideView.snp.updateConstraints { make in
                make.left.equalToSuperview()
            }
            
            self.secondSideView.snp.updateConstraints { make in
                make.right.equalToSuperview()
            }
            
            self.thirdSideView.snp.updateConstraints { make in
                make.left.equalToSuperview()
            }
            
            self.forthSideView.snp.updateConstraints { make in
                make.right.equalToSuperview()
            }
            
            self.fifthSideView.snp.updateConstraints { make in
                make.left.equalToSuperview()
            }
            self.layoutIfNeeded()
        } completion: { _ in
            self.firstAnimationFinished?()
        }
    }
    
    func secondAnimation() {
        UIView.animate(withDuration: 1.0, delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: .curveLinear) {
            self.firstSideView.isHidden = false
            self.secondSideView.isHidden = false
            self.thirdSideView.isHidden = false
            self.forthSideView.isHidden = false
            if UIScreen.main.isMoreIphonePlus {
                self.fifthSideView.isHidden = false
            }
       
            self.firstSideView.snp.updateConstraints { make in
                make.left.equalToSuperview().inset(-151)
            }
            
            self.secondSideView.snp.updateConstraints { make in
                make.right.equalToSuperview().inset(-166)
            }
            
            self.thirdSideView.snp.updateConstraints { make in
                make.left.equalToSuperview().inset(-217)
            }
            
            self.forthSideView.snp.updateConstraints { make in
                make.right.equalToSuperview().inset(-219)
            }
            
            self.fifthSideView.snp.updateConstraints { make in
                make.left.equalToSuperview().inset(-214)
            }
            self.layoutIfNeeded()
        } completion: { _ in
            self.secondAnimationFinished?()
        }
        
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
        view.backgroundColor = .black.withAlphaComponent(0.3)
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
    
    private let firstSideView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "firstSideView")
        imageView.isHidden = true
        return imageView
    }()
    
    private let secondSideView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "secondSideView")
        imageView.isHidden = true
        return imageView
    }()
    
    private let thirdSideView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "thirdSideView")
        imageView.isHidden = true
        return imageView
    }()
    
    private let forthSideView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "forthSideView")
        imageView.isHidden = true
        return imageView
    }()
    
    private let fifthSideView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "fifthSideView")
        imageView.isHidden = true
        return imageView
    }()
    
    // swiftlint:disable:next function_body_length
    private func setupConstraints() {
        addSubviews([backgroundView, phoneView, shadowView, mainTextView, addItemImage,
                     firstSideView, secondSideView, thirdSideView, forthSideView, fifthSideView])
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
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).inset(130)
        }
        
        shadowView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(44)
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).inset(122)
            make.height.equalTo(mainTextView.snp.height).multipliedBy(1.06)
        }
        
        addItemImage.snp.makeConstraints { make in
            make.right.equalTo(mainTextView.snp.right)
            make.centerY.equalTo(mainTextView.snp.top)
            make.width.equalTo(164)
            make.height.equalTo(65)
        }
        
        mainTextLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(30)
            make.top.equalTo(addItemImage.snp.bottom)
        }
        
        addItemLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-2)
            make.left.equalToSuperview().inset(58)
        }
        
        fifthSideView.snp.makeConstraints { make in
            make.width.equalTo(214)
            make.height.equalTo(32)
            make.top.equalTo(phoneView.snp.top).inset(318)
            make.left.equalToSuperview().inset(-214)
        }
        
        forthSideView.snp.makeConstraints { make in
            make.width.equalTo(219)
            make.height.equalTo(32)
            make.top.equalTo(phoneView.snp.top).inset(246)
            make.right.equalToSuperview().inset(-219)
        }
        
        thirdSideView.snp.makeConstraints { make in
            make.width.equalTo(217)
            make.height.equalTo(32)
            make.top.equalTo(phoneView.snp.top).inset(169)
            make.left.equalToSuperview().inset(-217)
        }
        
        secondSideView.snp.makeConstraints { make in
            make.width.equalTo(166)
            make.height.equalTo(32)
            make.top.equalTo(phoneView.snp.top).inset(81)
            make.right.equalToSuperview().inset(-166)
        }
        
        firstSideView.snp.makeConstraints { make in
            make.width.equalTo(151)
            make.height.equalTo(32)
            make.top.equalTo(phoneView.snp.top).inset(51)
            make.left.equalToSuperview().inset(-151)
        }
    }
}
