//
//  SecondView.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 01.11.2022.
//

import SnapKit
import UIKit

class OnboardingContentView: UIView {
    
    var unlockButton: (() -> Void)?
    var lockButton: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
        preparationsForAnimation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func preparationsForAnimation() {
        addItemImage.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        sharedAlarmImage.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        collectionsAlarmImage.transform = CGAffineTransform(scaleX: 0, y: 0)
        contextualMenuImage.transform = CGAffineTransform(scaleX: 0, y: 0)
        greenCartImage.transform = CGAffineTransform(scaleX: 0, y: 0)
        secondBackgroundBlurView.alpha = 0
        fifthPhoneView.alpha = 0
    }
    
    // анимация перехода на первый экран
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
            self.unlockButton?()
        }
    }
    
    // анимация закрытия первого экрана
    func secondAnimation() {
        UIView.animate(withDuration: 1.3, delay: 0,
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
            self.lockButton?()
            self.showsecondState()
        }
    }
    
    // анимация перехода на второй экран
    private func showsecondState() {
        UIView.animate(withDuration: 1.3, delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: .curveLinear) {
            
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
    // появление картинки шаред
    private func showSharedAlarm() {
        UIView.animate(withDuration: 1.0, delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: .curveLinear) {
            self.sharedAlarmImage.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.secondBackgroundBlurView.alpha = 1
            self.layoutIfNeeded()
        } completion: { _ in
            self.unlockButton?()
        }
    }
    
    // анимация перехода на третий экран
    func goToThirdState() {
        self.lockButton?()
        UIView.animate(withDuration: 1.0, delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: .curveLinear) {
            self.sharedAlarmImage.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            self.secondBackgroundBlurView.alpha = 0
            self.sharedAlarmImage.alpha = 0
           
            self.secondBackgroundView.snp.remakeConstraints { make in
                make.width.height.top.equalToSuperview()
                make.right.equalTo(self.snp.left)
            }

            self.secondTextLabel.snp.remakeConstraints { make in
                make.right.equalTo(self.textContainerViewView.snp.left)
                make.width.equalTo(200)
                make.top.bottom.equalToSuperview()
            }
            
            self.thirdTextLabel.snp.remakeConstraints { make in
                make.left.right.equalToSuperview().inset(20)
                make.bottom.equalToSuperview().inset(30)
                make.top.equalToSuperview().inset(30)
            }
            
            self.layoutIfNeeded()
        } completion: { _ in
            self.showCollectionsAlarm()
        }
    }
    // показывает коллекцию справа
    private func showCollectionsAlarm() {
        UIView.animate(withDuration: 1.3, delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: .curveLinear) {
            self.collectionsAlarmImage.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.layoutIfNeeded()
        } completion: { _ in
            self.unlockButton?()
        }
    }
    
    // анимация перехода на четвертый экран
    func goToForthState() {
        self.lockButton?()
        UIView.animate(withDuration: 1.0, delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: .curveLinear) {
           
            self.thirdBackgroundView.snp.remakeConstraints { make in
                make.width.height.top.equalToSuperview()
                make.right.equalTo(self.snp.left)
            }

            self.thirdTextLabel.snp.remakeConstraints { make in
                make.right.equalTo(self.textContainerViewView.snp.left)
                make.width.equalTo(200)
                make.top.bottom.equalToSuperview()
            }
            
            self.forthTextLabel.snp.remakeConstraints { make in
                make.left.right.equalToSuperview().inset(20)
                make.bottom.equalToSuperview().inset(30)
                make.top.equalToSuperview().inset(30)
            }
            
            self.layoutIfNeeded()
        } completion: { _ in
            self.showContextualMenu()
        }
    }
    // показывает контекстное меню сверху
    private func showContextualMenu() {
        UIView.animate(withDuration: 1.3, delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: .curveLinear) {
            self.contextualMenuImage.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.layoutIfNeeded()
        } completion: { _ in
            self.changeImage()
        }
    }
    
    private func changeImage() {
        UIView.animate(withDuration: 0.5, delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: .curveLinear) {
            self.contextualMenuImage.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            self.contextualMenuImage.alpha = 0
            self.forthPhoneView.alpha = 0
            self.fifthPhoneView.alpha = 1
            self.layoutIfNeeded()
        } completion: { _ in
            self.showCart()
        }
    }
    
    private func showCart() {
        UIView.animate(withDuration: 1, delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: .curveLinear) {
            self.greenCartImage.transform = CGAffineTransform(scaleX: 1, y: 1)

            self.layoutIfNeeded()
        } completion: { _ in
            self.unlockButton?()
        }
    }
    
    // UI
    private func createTextLabel(with text: String) -> UILabel {
        let label = UILabel()
        label.font = .SFPro.semibold(size: 18).font
        label.textColor = UIColor(hex: "#31635A")
        let attributedString = NSMutableAttributedString(string: text.localized)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle,
                                      value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        label.attributedText = attributedString
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    private func createImageView(with name: String, isHidden: Bool = false,
                                 shouldAddShadow: Bool = false) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: name)
        imageView.isHidden = isHidden
        if shouldAddShadow { imageView.addShadow() }
        return imageView
    }
    
    // UI
    private lazy var backgroundView = createImageView(with: "secondBG")
    private lazy var secondBackgroundView = createImageView(with: "thirdBG")
    private lazy var secondBackgroundBlurView = createImageView(with: "thirdBGBlur")
    private lazy var thirdBackgroundView = createImageView(with: "forthBG")
    private lazy var forthBackgroundView = createImageView(with: "fifthBG")
    
    private lazy var phoneView = createImageView(with: "firstScreen")
    private lazy var secondPhoneView = createImageView(with: "secondScreen")
    private lazy var thirdPhoneView = createImageView(with: "thirdScreen")
    private lazy var forthPhoneView = createImageView(with: "thirdScreen")
    private lazy var fifthPhoneView = createImageView(with: "forthScreen")
    private lazy var phoneShadowView = createImageView(with: "phoneShadow")
    
    private lazy var addItemImage = createImageView(with: "addItemImage")
    
    private lazy var firstSideView = createImageView(with: "firstSideView", isHidden: true)
    private lazy var secondSideView = createImageView(with: "secondSideView", isHidden: true)
    private lazy var thirdSideView = createImageView(with: "thirdSideView", isHidden: true)
    private lazy var forthSideView = createImageView(with: "forthSideView", isHidden: true)
    private lazy var fifthSideView = createImageView(with: "fifthSideView", isHidden: true)
    
    private lazy var firstTextLabel = createTextLabel(with: "CreateLists")
    private lazy var secondTextLabel = createTextLabel(with: "Synchronize")
    private lazy var thirdTextLabel = createTextLabel(with: "OrganizeRecepts")
    private lazy var forthTextLabel = createTextLabel(with: "AddRecipes")
    
    
    private lazy var sharedAlarmImage = createImageView(with: "sharedAlarmImage", shouldAddShadow: true)
    private lazy var collectionsAlarmImage = createImageView(with: "collectionsAlarmImage", shouldAddShadow: true)
    private lazy var contextualMenuImage = createImageView(with: "contextualMenu", shouldAddShadow: true)
    private lazy var greenCartImage = createImageView(with: "greenCart", shouldAddShadow: true)
    
    private let textContainerViewView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#D7F8EE")
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()

    private let shadowView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.3)
        view.layer.cornerRadius = 18
        return view
    }()
    
    // swiftlint:disable:next function_body_length
    private func setupConstraints() {
        addSubviews([backgroundView, secondBackgroundView, secondBackgroundBlurView,
                     thirdBackgroundView, forthBackgroundView, phoneShadowView, phoneView,
                     secondPhoneView, thirdPhoneView, forthPhoneView, fifthPhoneView, collectionsAlarmImage,
                     shadowView, textContainerViewView, addItemImage, firstSideView, secondSideView, thirdSideView,
                                   forthSideView, fifthSideView, sharedAlarmImage, contextualMenuImage, greenCartImage])
        textContainerViewView.addSubviews([firstTextLabel, secondTextLabel, thirdTextLabel, forthTextLabel])

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
        
        thirdBackgroundView.snp.makeConstraints { make in
            make.width.height.top.bottom.equalToSuperview()
            make.left.equalTo(secondBackgroundView.snp.right)
        }
        
        forthBackgroundView.snp.makeConstraints { make in
            make.width.height.top.bottom.equalToSuperview()
            make.left.equalTo(thirdBackgroundView.snp.right)
        }
        
        phoneView.snp.makeConstraints { make in
            make.centerX.equalTo(backgroundView)
            make.centerY.equalToSuperview().multipliedBy(0.8)
            make.width.equalTo(222)
            make.height.equalTo(480)
        }
        
        secondPhoneView.snp.makeConstraints { make in
            make.centerX.equalTo(secondBackgroundView)
            make.centerY.equalToSuperview().multipliedBy(0.8)
            make.width.equalTo(222)
            make.height.equalTo(480)
        }
        
        thirdPhoneView.snp.makeConstraints { make in
            make.centerX.equalTo(thirdBackgroundView)
            make.centerY.equalToSuperview().multipliedBy(0.8)
            make.width.equalTo(222)
            make.height.equalTo(480)
        }
        
        forthPhoneView.snp.makeConstraints { make in
            make.centerX.equalTo(forthBackgroundView)
            make.centerY.equalToSuperview().multipliedBy(0.8)
            make.width.equalTo(phoneView)
            make.height.equalTo(480)
        }
        
        fifthPhoneView.snp.makeConstraints { make in
            make.edges.equalTo(forthPhoneView)
        }
        
        phoneShadowView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.805)
            make.width.equalTo(222)
            make.height.equalTo(490)
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
        
        thirdTextLabel.snp.makeConstraints { make in
            make.left.equalTo(textContainerViewView.snp.right)
            make.bottom.equalToSuperview().inset(30)
            make.top.equalTo(addItemImage.snp.bottom)
        }
        
        forthTextLabel.snp.makeConstraints { make in
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
        
        collectionsAlarmImage.snp.makeConstraints { make in
            make.width.equalTo(206)
            make.height.equalTo(337)
            make.right.equalTo(thirdPhoneView.snp.right).inset(-44)
            make.top.equalTo(phoneView.snp.top).inset(155)
        }
        
        contextualMenuImage.snp.makeConstraints { make in
            make.width.equalTo(158)
            make.height.equalTo(115)
            make.right.equalTo(forthPhoneView.snp.right).inset(-20)
            make.top.equalTo(forthPhoneView.snp.top).inset(-28)
        }
        
        greenCartImage.snp.makeConstraints { make in
            make.height.width.equalTo(67)
            make.right.equalTo(forthPhoneView.snp.right).inset(-8)
            make.top.equalTo(forthPhoneView.snp.top).inset(200)
        }
    }
}
