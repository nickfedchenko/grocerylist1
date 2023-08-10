//
//  SecondView.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 01.11.2022.
//

import SnapKit
import UIKit
// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
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
        backgroundBlurView.alpha = 0
        secondBackgroundBlurView.alpha = 0
        thirdBackgroundBlurView.alpha = 0
        forthBackgroundBlurView.alpha = 0
    }
    
    // анимация перехода на первый экран
    func firstAnimation() {
        UIView.animate(withDuration: 0.6, delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: .curveLinear) {
            self.addItemImage.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.backgroundBlurView.alpha = 1
            self.firstSideView.isHidden = false
            self.secondSideView.isHidden = false
            self.thirdSideView.isHidden = false
            self.forthSideView.isHidden = false
            if UIScreen.main.isMoreIphonePlus {
                self.fifthSideView.isHidden = false
            }
            
            self.firstSideView.snp.updateConstraints { make in
                make.left.equalToSuperview().offset(Constants.firstSideViewAnimationInset)
            }
            
            self.secondSideView.snp.updateConstraints { make in
                make.right.equalToSuperview().offset(Constants.secondSideViewAnimationInset)
            }
            
            self.thirdSideView.snp.updateConstraints { make in
                make.left.equalToSuperview().offset(Constants.thirdSideViewAnimationInset)
            }
            
            self.forthSideView.snp.updateConstraints { make in
                make.right.equalToSuperview().offset(Constants.fourthSideViewAnimationInset)
            }
            
            self.fifthSideView.snp.updateConstraints { make in
                make.left.equalToSuperview().offset(Constants.fifthSideViewAnimationInset)
            }
            self.layoutIfNeeded()
        } completion: { _ in
            self.unlockButton?()
        }
    }
    
    // анимация закрытия первого экрана
    func secondAnimation() {
        UIView.animate(withDuration: 0.6, delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: .curveLinear) {
            self.firstSideView.isHidden = false
            self.secondSideView.isHidden = false
            self.thirdSideView.isHidden = false
            self.forthSideView.isHidden = false
            self.backgroundBlurView.alpha = 0
            if UIScreen.main.isMoreIphonePlus {
                self.fifthSideView.isHidden = false
            }
            
            self.firstSideView.snp.updateConstraints { make in
                make.left.equalToSuperview().inset(-300)
            }
            
            self.secondSideView.snp.updateConstraints { make in
                make.right.equalToSuperview().inset(-300)
            }
            
            self.thirdSideView.snp.updateConstraints { make in
                make.left.equalToSuperview().inset(-300)
            }
            
            self.forthSideView.snp.updateConstraints { make in
                make.right.equalToSuperview().inset(-300)
            }
            
            self.fifthSideView.snp.updateConstraints { make in
                make.left.equalToSuperview().inset(-300)
            }
            
            self.layoutIfNeeded()
        } completion: { _ in
            self.lockButton?()
            self.showsecondState()
        }
    }
    
    // анимация перехода на второй экран
    private func showsecondState() {
        UIView.animate(withDuration: 1.0, delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: .curveLinear) {
            
            self.addItemImage.snp.remakeConstraints { make in
                make.right.equalTo(self.backgroundView.snp.left)
                make.bottom.equalTo(self.textContainerViewView.snp.bottom).inset(Constants.addItemBottomInset)
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
                make.left.right.equalToSuperview().inset(Constants.secondLabelSideInset)
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
        UIView.animate(withDuration: 0.5, delay: 0,
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
                make.left.right.equalToSuperview().inset(Constants.thirdLabelSideInset)
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
        UIView.animate(withDuration: 0.5, delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: .curveLinear) {
            self.thirdBackgroundBlurView.alpha = 1
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
            // Для временно выпиленного экрана(third stage)
            self.sharedAlarmImage.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            self.secondBackgroundBlurView.alpha = 0
            self.sharedAlarmImage.alpha = 0
            
            self.thirdBackgroundView.snp.remakeConstraints { make in
                make.width.height.top.equalToSuperview()
                make.right.equalTo(self.snp.left)
            }
            
            self.secondTextLabel.snp.remakeConstraints { make in
                make.right.equalTo(self.textContainerViewView.snp.left)
                make.width.equalTo(200)
                make.top.bottom.equalToSuperview()
            }
            
            self.thirdTextLabel.snp.remakeConstraints { make in
                make.right.equalTo(self.textContainerViewView.snp.left)
                make.width.equalTo(200)
                make.top.bottom.equalToSuperview()
            }
            
            self.forthTextLabel.snp.remakeConstraints { make in
                make.left.right.equalToSuperview().inset(Constants.fourthLabelSideInset)
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
        UIView.animate(withDuration: 0.5, delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: .curveLinear) {
            self.contextualMenuImage.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.forthBackgroundBlurView.alpha = 1
            self.layoutIfNeeded()
        } completion: { _ in
            self.changeImage()
        }
    }
    
    private func changeImage() {
        UIView.animate(withDuration: 0.9, delay: 1.3,
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
    private func createTextLabel(with text: String, fontSize: CGFloat = 18, lineHeight: CGFloat = 21) -> UILabel {
        let label = UILabel()
        label.font = .SFPro.semibold(size: fontSize).font
        label.textColor = UIColor(hex: "#31635A")
        let attributedString = NSMutableAttributedString(string: text.localized)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        paragraphStyle.maximumLineHeight = lineHeight
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle,
                                      value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        label.attributedText = attributedString
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }
    
    private func createImageView(with name: String, isHidden: Bool = false,
                                 shouldAddShadow: Bool = false, isSideView: Bool = false) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: name)
        imageView.isHidden = isHidden
        if shouldAddShadow { imageView.addShadow() }
        if isSideView { imageView.addShadow(color: .black, height: 3) }
        return imageView
    }
    
    // UI
    private lazy var backgroundView = createImageView(with: "secondBG")
    private lazy var backgroundBlurView = createImageView(with: "secondBGBlur")
    private lazy var secondBackgroundView = createImageView(with: "thirdBG")
    private lazy var secondBackgroundBlurView = createImageView(with: "thirdBGBlur")
    private lazy var thirdBackgroundView = createImageView(with: "forthBG")
    private lazy var thirdBackgroundBlurView = createImageView(with: "forthBGBlur")
    private lazy var forthBackgroundView = createImageView(with: "fifthBG")
    private lazy var forthBackgroundBlurView = createImageView(with: "fifthBGBlur")
    
    private lazy var phoneView = createImageView(with: "firstScreen")
    private lazy var secondPhoneView = createImageView(with: "secondScreen")
    private lazy var thirdPhoneView = createImageView(with: "thirdScreen")
    private lazy var forthPhoneView = createImageView(with: "thirdScreen")
    private lazy var fifthPhoneView = createImageView(with: "forthScreen")
    private lazy var phoneShadowView = createImageView(with: "phoneShadow")
    
    private lazy var addItemImage = createImageView(with: "addItemImage")
    
    private lazy var firstSideView = createImageView(with: "firstSideView", isHidden: true, isSideView: true)
    private lazy var secondSideView = createImageView(with: "secondSideView", isHidden: true, isSideView: true)
    private lazy var thirdSideView = createImageView(with: "thirdSideView", isHidden: true, isSideView: true)
    private lazy var forthSideView = createImageView(with: "forthSideView", isHidden: true, isSideView: true)
    private lazy var fifthSideView = createImageView(with: "fifthSideView", isHidden: true, isSideView: true)
    
    private lazy var firstTextLabel = createTextLabel(
        with: "CreateLists",
        fontSize: Constants.firstLabelFontSize,
        lineHeight: Constants.firstLabelLineHeight
    )
    private lazy var secondTextLabel = createTextLabel(
        with: "Synchronize",
        fontSize: Constants.secondLabelFontSize,
        lineHeight: Constants.secondLabelLineHeight
    )
    private lazy var thirdTextLabel = createTextLabel(
        with: "OrganizeRecepts",
        fontSize: Constants.thirdLabelFontSize,
        lineHeight: Constants.thirdLabelLineHeight
    )
    private lazy var forthTextLabel = createTextLabel(
        with: "AddRecipes",
        fontSize: Constants.fourthLabelFontSize,
        lineHeight: Constants.fourthLabelLineHeight
    )
    
    private lazy var sharedAlarmImage = createImageView(with: "sharedAlarmImage", shouldAddShadow: true)
    private lazy var collectionsAlarmImage = createImageView(with: "collectionsAlarmImage", shouldAddShadow: true)
    private lazy var contextualMenuImage = createImageView(with: "contextualMenu", shouldAddShadow: true)
    private lazy var greenCartImage = createImageView(with: "greenCart", shouldAddShadow: true)
    
    private let textContainerViewView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#D7F8EE")
        view.layer.cornerRadius = 16
        view.layer.cornerCurve = .continuous
        view.layer.masksToBounds = true
        return view
    }()
    
    private let shadowView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.2)
        view.layer.cornerCurve = .continuous
        view.layer.cornerRadius = 20
        return view
    }()
    
    // swiftlint:disable:next function_body_length
    private func setupConstraints() {
        addSubviews([backgroundView, backgroundBlurView, secondBackgroundView, secondBackgroundBlurView,
                     thirdBackgroundView, thirdBackgroundBlurView, forthBackgroundView, forthBackgroundBlurView, phoneShadowView, phoneView,
                     secondPhoneView, thirdPhoneView, fifthPhoneView, forthPhoneView, collectionsAlarmImage,
                     shadowView, textContainerViewView, addItemImage, firstSideView, secondSideView, thirdSideView,
                     forthSideView, fifthSideView, sharedAlarmImage, contextualMenuImage, greenCartImage])
        textContainerViewView.addSubviews([firstTextLabel, secondTextLabel, thirdTextLabel, forthTextLabel])
        
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        backgroundBlurView.snp.makeConstraints { make in
            make.edges.equalTo(backgroundView)
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
        
        thirdBackgroundBlurView.snp.makeConstraints { make in
            make.edges.equalTo(thirdBackgroundView)
        }
        
        forthBackgroundView.snp.makeConstraints { make in
            make.width.height.top.bottom.equalToSuperview()
            make.left.equalTo(thirdBackgroundView.snp.right)
        }
        
        forthBackgroundBlurView.snp.makeConstraints { make in
            make.edges.equalTo(forthBackgroundView)
        }
        
        phoneView.snp.makeConstraints { make in
            make.centerX.equalTo(backgroundView)
            make.centerY.equalToSuperview().multipliedBy(0.8)
            make.width.equalTo(220)
            make.height.equalTo(480)
        }
        
        secondPhoneView.snp.makeConstraints { make in
            make.centerX.equalTo(secondBackgroundView)
            make.centerY.equalToSuperview().multipliedBy(0.8)
            make.width.equalTo(218)
            make.height.equalTo(476)
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
            make.bottom.equalToSuperview().inset(148)
        }
        
        firstTextLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(Constants.firstLabelSideInset)
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
            make.bottom.equalTo(textContainerViewView.snp.bottom).offset(7)
            make.top.equalTo(textContainerViewView.snp.top).offset(-2)
        }
        
        addItemImage.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(196)
            make.centerY.equalTo(textContainerViewView.snp.top)
            make.width.equalTo(164)
            make.height.equalTo(65)
        }
        
        fifthSideView.snp.makeConstraints { make in
            make.height.equalTo(32)
            make.top.equalTo(phoneView.snp.top).inset(Constants.fifthSideViewTopOffset)
            make.left.equalToSuperview().inset(-214)
            make.width.equalTo(Constants.fifthSideViewWidth)
        }
        
        forthSideView.snp.makeConstraints { make in
            make.height.equalTo(36)
            make.top.equalTo(phoneView.snp.top).inset(Constants.fourthSideViewTopOffset)
            make.right.equalToSuperview().inset(-219)
            make.width.equalTo(Constants.fourthSideViewWidth)
        }
        
        thirdSideView.snp.makeConstraints { make in
            make.height.equalTo(36)
            make.top.equalTo(phoneView.snp.top).inset(Constants.thirdSideViewTopOffset)
            make.left.equalToSuperview().inset(-217)
            make.width.equalTo(Constants.thirdSideViewWidth)
        }
        
        secondSideView.snp.makeConstraints { make in
            make.height.equalTo(36)
            make.top.equalTo(phoneView.snp.top).inset(Constants.secondSideViewTopOffset)
            make.right.equalToSuperview().inset(-166)
            make.width.equalTo(Constants.secondSideViewWidth)
        }
        
        firstSideView.snp.makeConstraints { make in
            make.height.equalTo(36)
            make.top.equalTo(phoneView.snp.top).inset(Constants.firstSideViewTopOffset)
            make.left.equalToSuperview().inset(-200)
            make.width.equalTo(Constants.firstSideViewWidth)
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

extension OnboardingContentView {
    enum PossibleLocales {
        case ru, en, fr, de
        
        static var currentLocale: PossibleLocales {
            guard let langCode = Locale.current.languageCode else {
                return .en
            }
            switch langCode {
            case "de":
                return .de
            case "en", "en_US":
                return .en
            case "ru":
                return .ru
            case "fr":
                return .fr
            default:
                return .en
            }
        }
    }
    
    enum Constants {
        static var firstSideViewWidth: CGFloat {
            switch PossibleLocales.currentLocale {
            case .ru:
                return 252.fitW
            case .en:
                return 171.fitW
            case .fr:
                return 244.fitW
            case .de:
                return 275.fitW
            }
        }
        
        static var secondSideViewWidth: CGFloat {
            switch PossibleLocales.currentLocale {
            case .ru:
                return 187.fitW
            case .en:
                return 187.fitW
            case .fr:
                return 222.fitW
            case .de:
                return 187.fitW
            }
        }
        
        static var thirdSideViewWidth: CGFloat {
            switch PossibleLocales.currentLocale {
            case .ru:
                return 230.fitW
            case .en:
                return 237.fitW
            case .fr:
                return 237.fitW
            case .de:
                return 260.fitW
            }
        }
        
        static var fourthSideViewWidth: CGFloat {
            switch PossibleLocales.currentLocale {
            case .ru:
                return 234.fitW
            case .en:
                return 244.fitW
            case .fr:
                return 248.fitW
            case .de:
                return 258.fitW
            }
        }
        
        static var fifthSideViewWidth: CGFloat {
            switch PossibleLocales.currentLocale {
            case .ru:
                return 234.fitW
            case .en:
                return 234.fitW
            case .fr:
                return 234.fitW
            case .de:
                return 266.fitW
            }
        }
        
        static var firstSideViewAnimationInset: CGFloat {
            switch PossibleLocales.currentLocale {
            case .ru:
                return -5
            case .en:
                return -13
            case .fr:
                return -10
            case .de:
                return -10
            }
        }
        
        static var secondSideViewAnimationInset: CGFloat {
            switch PossibleLocales.currentLocale {
            case .ru:
                return 5
            case .en:
                return 15.fitW
            case .fr:
                return 8
            case .de:
                return 7
            }
        }
        
        static var thirdSideViewAnimationInset: CGFloat {
            switch PossibleLocales.currentLocale {
            case .ru:
                return -10
            case .en:
                return -10
            case .fr:
                return -10
            case .de:
                return -9
            }
        }
        
        static var fourthSideViewAnimationInset: CGFloat {
            switch PossibleLocales.currentLocale {
            case .ru:
                return 10
            case .en:
                return 14
            case .fr:
                return 8
            case .de:
                return 8
            }
        }
        
        static var fifthSideViewAnimationInset: CGFloat {
            switch PossibleLocales.currentLocale {
            case .ru:
                return -55
            case .en:
                return -14
            case .fr:
                return -58
            case .de:
                return -8
            }
        }
        
        static var firstLabelSideInset: CGFloat {
            switch PossibleLocales.currentLocale {
            case .ru:
                return 20
            case .en:
                return 28
            case .fr:
                return 15
            case .de:
                return 13
            }
        }
        
        static var firstLabelFontSize: CGFloat {
            switch PossibleLocales.currentLocale {
            case .ru:
                return 18
            case .en:
                return UIScreen.main.isSmallSize ? 15 : 18
            case .fr:
                return 15
            case .de:
                return 15
            }
        }
        
        static var firstLabelLineHeight: CGFloat {
            switch PossibleLocales.currentLocale {
            case .ru:
                return 21.48
            case .en:
                return 21.48
            case .fr:
                return 17
            case .de:
                return 18
            }
        }
        
        static var secondLabelFontSize: CGFloat {
            switch PossibleLocales.currentLocale {
            case .ru:
                return 18
            case .en:
                return 18
            case .fr:
                return 18
            case .de:
                return 18
            }
        }
        
        static var secondLabelLineHeight: CGFloat {
            switch PossibleLocales.currentLocale {
            case .ru:
                return 21.48
            case .en:
                return 21.48
            case .fr:
                return 21.48
            case .de:
                return 21.48
            }
        }
        
        static var thirdLabelFontSize: CGFloat {
            switch PossibleLocales.currentLocale {
            case .ru:
                return 18
            case .en:
                return 18
            case .fr:
                return 18
            case .de:
                return 18
            }
        }
        
        static var thirdLabelLineHeight: CGFloat {
            switch PossibleLocales.currentLocale {
            case .ru:
                return 21.48
            case .en:
                return 21.48
            case .fr:
                return 21.48
            case .de:
                return 21.48
            }
        }
        
        static var fourthLabelFontSize: CGFloat {
            switch PossibleLocales.currentLocale {
            case .ru:
                return 18
            case .en:
                return 18
            case .fr:
                return 18
            case .de:
                return 18
            }
        }
        
        static var fourthLabelLineHeight: CGFloat {
            switch PossibleLocales.currentLocale {
            case .ru:
                return 21.48
            case .en:
                return 21.48
            case .fr:
                return 21.48
            case .de:
                return 21.48
            }
        }
        
        static var secondLabelSideInset: CGFloat {
            switch PossibleLocales.currentLocale {
            case .ru:
                return 28
            case .en:
                return 28
            case .fr:
                return 28
            case .de:
                return 17
            }
        }
        
        static var thirdLabelSideInset: CGFloat {
            switch PossibleLocales.currentLocale {
            case .ru:
                return 16
            case .en:
                return 28
            case .fr:
                return 16
            case .de:
                return 16
            }
        }
        
        static var fourthLabelSideInset: CGFloat {
            switch PossibleLocales.currentLocale {
            case .ru:
                return 28
            case .en:
                return 28
            case .fr:
                return 28
            case .de:
                return 28
            }
        }
        
        static var firstSideViewTopOffset: CGFloat {
            switch PossibleLocales.currentLocale {
            case .ru:
                return 45
            case .en:
                return 45
            case .fr:
                return 45
            case .de:
                return 45
            }
        }
        
        static var secondSideViewTopOffset: CGFloat {
            switch PossibleLocales.currentLocale {
            case .ru:
                return 77
            case .en:
                return 77
            case .fr:
                return 97
            case .de:
                return 97
            }
        }
        
        static var thirdSideViewTopOffset: CGFloat {
            switch PossibleLocales.currentLocale {
            case .ru:
                return 134
            case .en:
                return 164
            case .fr:
                return 165
            case .de:
                return 164
            }
        }
        
        static var fourthSideViewTopOffset: CGFloat {
            switch PossibleLocales.currentLocale {
            case .ru:
                return 209
            case .en:
                return 241
            case .fr:
                return 239
            case .de:
                return 225
            }
        }
        
        static var fifthSideViewTopOffset: CGFloat {
            switch PossibleLocales.currentLocale {
            case .ru:
                return 280
            case .en:
                return 313
            case .fr:
                return 311
            case .de:
                return 315
            }
        }
        
        static var addItemBottomInset: CGFloat {
            switch PossibleLocales.currentLocale {
            case .ru:
                return 114
            case .en:
                return 174
            case .fr:
                return 135
            case .de:
                return 141
            }
        }
    }
}
