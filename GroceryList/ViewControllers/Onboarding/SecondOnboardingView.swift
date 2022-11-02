//
//  SecondView.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 01.11.2022.
//

import SnapKit
import UIKit

class SecondOnboardingView: UIView {
    
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
        sharedAlarmImage.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        secondBackgroundBlurView.alpha = 0
    }
    
    // анимация перехода на второй экран
    func firstAnimation() {
        UIView.animate(withDuration: 1.0, delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: .curveLinear) {
            self.addItemImage.transform = CGAffineTransform(scaleX: 1, y: 1)
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
    
    // анимация закрытия второго экрана
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
            self.showThirdState()
        }
    }
    
    // анимация перехода на третий экран
    private func showThirdState() {
        UIView.animate(withDuration: 1.5, delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.0,
                       options: .curveLinear) {
            self.phoneView.snp.remakeConstraints { make in
                make.right.equalTo(self.backgroundView.snp.left)
                make.centerY.equalToSuperview().multipliedBy(0.8)
                make.width.equalTo(232)
                make.height.equalTo(500)
            }
            
            self.secondPhoneView.snp.remakeConstraints { make in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview().multipliedBy(0.8)
                make.width.equalTo(232)
                make.height.equalTo(500)
            }
            
            self.addItemImage.snp.remakeConstraints { make in
                make.right.equalTo(self.backgroundView.snp.left)
                make.centerY.equalTo(self.textContainerViewView.snp.top)
                make.width.equalTo(164)
                make.height.equalTo(65)
            }
            
            self.backgroundView.snp.remakeConstraints { make in
                make.width.height.top.equalToSuperview()
                make.right.equalTo(self.snp.left)
            }
            
            self.firstTextLabel.snp.remakeConstraints { make in
                make.right.equalTo(self.textContainerViewView.snp.left)
                make.top.bottom.equalToSuperview()
            }
            
            self.secondTextLabel.snp.remakeConstraints { make in
                make.left.right.equalToSuperview().inset(20)
                make.bottom.equalToSuperview().inset(30)
                make.top.equalToSuperview().inset(30)
            }
            
            self.secondTextLabel.isHidden = false
            self.layoutIfNeeded()
        } completion: { _ in
            self.showSharedAlarm()
        }
    }
    
    private func showSharedAlarm() {
        UIView.animate(withDuration: 1.0, delay: 1,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: .curveLinear) {
            self.sharedAlarmImage.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.secondBackgroundBlurView.alpha = 1
            self.layoutIfNeeded()
        } completion: { _ in
        }
    }
    
    // анимация перехода на четвертый экран
    
    // UI
    private let backgroundView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "secondBG")
        return imageView
    }()
    
    private let secondBackgroundView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "thirdBG")
        return imageView
    }()
    
    private let secondBackgroundBlurView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "thirdBGBlur")
        return imageView
    }()
    
    private let phoneView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "firstScreen")
        return imageView
    }()
    
    private let secondPhoneView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "secondScreen")
        return imageView
    }()
    
    private let phoneShadowView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "phoneShadow")
        return imageView
    }()
    
    private let textContainerViewView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#D7F8EE")
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    private let firstTextLabel: UILabel = {
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
    
    private let secondTextLabel: UILabel = {
        let label = UILabel()
        label.font = .SFPro.semibold(size: 18).font
        label.textColor = UIColor(hex: "#31635A")
        let attributedString = NSMutableAttributedString(string: "Synchronize".localized)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle,
                                      value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        label.attributedText = attributedString
        label.numberOfLines = 0
        label.textAlignment = .center
        label.isHidden = true
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
    
    private let sharedAlarmImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "sharedAlarmImage")
        imageView.layer.shadowColor = UIColor.gray.cgColor
        imageView.layer.shadowOpacity = 0.5
        imageView.layer.shadowOffset = CGSize(width: 0, height: 0)
        imageView.layer.shadowRadius = 2
        imageView.layer.masksToBounds = false
        return imageView
    }()
    
    // swiftlint:disable:next function_body_length
    private func setupConstraints() {
        addSubviews([backgroundView, secondBackgroundView, secondBackgroundBlurView, phoneShadowView,
                     phoneView, secondPhoneView, shadowView, textContainerViewView,
                     addItemImage, firstSideView, secondSideView, thirdSideView,
                     forthSideView, fifthSideView, sharedAlarmImage])
        textContainerViewView.addSubviews([firstTextLabel, secondTextLabel])
        
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        secondBackgroundView.snp.makeConstraints { make in
            make.width.height.top.bottom.equalToSuperview()
            make.left.equalTo(backgroundView.snp.right)
        }
        
        secondBackgroundBlurView.snp.makeConstraints { make in
            make.width.height.top.bottom.equalToSuperview()
            make.left.equalTo(backgroundView.snp.right)
        }
        
        phoneView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.8)
            make.width.equalTo(232)
            make.height.equalTo(500)
        }
        
        secondPhoneView.snp.makeConstraints { make in
            make.left.equalTo(self.snp.right)
            make.centerY.equalToSuperview().multipliedBy(0.8)
            make.width.equalTo(232)
            make.height.equalTo(500)
        }
        
        phoneShadowView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.8)
            make.width.equalTo(232)
            make.height.equalTo(500)
        }
        
        textContainerViewView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(50)
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).inset(130)
        }
        
        firstTextLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(30)
            make.top.equalTo(addItemImage.snp.bottom)
        }
        
        secondTextLabel.snp.makeConstraints { make in
            make.left.equalTo(textContainerViewView.snp.right)
            make.bottom.equalToSuperview().inset(30)
            make.top.equalTo(addItemImage.snp.bottom)
        }
        
        shadowView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(44)
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).inset(124)
            make.height.equalTo(textContainerViewView.snp.height).multipliedBy(1.06)
        }
        
        addItemImage.snp.makeConstraints { make in
            make.right.equalTo(textContainerViewView.snp.right)
            make.centerY.equalTo(textContainerViewView.snp.top)
            make.width.equalTo(164)
            make.height.equalTo(65)
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
        
        sharedAlarmImage.snp.makeConstraints { make in
            make.width.equalTo(258)
            make.height.equalTo(190)
            make.centerY.equalTo(phoneView.snp.centerY)
            make.centerX.equalToSuperview()
        }
    }
}
