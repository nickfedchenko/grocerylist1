//
//  UpdatedPaywallViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 11.07.2023.
//

import ApphudSDK
import UIKit

class UpdatedPaywallViewController: UIViewController {
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = R.image.updatedPaywall_imgBg()
        return imageView
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = R.image.updatedPaywall_logoImg()
        return imageView
    }()
    
    private lazy var closeCrossButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
        button.setImage(R.image.updatedPaywall_crossButton(), for: .normal)
        return button
    }()
    
    private let titleView = UpdatedPaywallTitleView()
    private let featuresView = UpdatedPaywallFeaturesView()
    private let productsView =  UpdatedPaywallProductView()
    
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
        button.setTitleColor(UIColor(hex: "#608080"), for: .normal)
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
                         .foregroundColor: UIColor(hex: "#608080"),
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
        button.setTitleColor(UIColor(hex: "#608080"), for: .normal)
        button.titleLabel?.font = UIFont.SFProRounded.medium(size: 12).font
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.3
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.textAlignment = .right
        button.addTarget(self, action: #selector(termsDidTap), for: .touchUpInside)
        return button
    }()
    
    private var weekPrice = 0.0
    private let loadingInfoString = "Loading info".localized
    private let isSmallSize = !UIScreen.main.isSizeAsIPhone8PlusOrBigger
    private var products: [ApphudProduct] = []
    private var selectedPrice: PayWallModel?
    private var selectedProduct: ApphudProduct?
    private var selectedProductIndex = 1 {
        didSet {
            selectedProduct = products[selectedProductIndex]
            productsView.selectProduct(selectedProductIndex)
        }
    }
    private var choiceOfCostArray = [PayWallModelWithSave(),
                                     PayWallModelWithSave(),
                                     PayWallModelWithSave()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        makeConstraints()
        
        Apphud.paywallsDidLoadCallback { [weak self] paywalls in
            guard let products = paywalls.first(where: { $0.identifier == "main2_trial" })?.products,
                  let self = self else {
                return
            }
            self.products = products
            self.choiceOfCostArray = self.products.enumerated().map { index, product in
                .init(isVisibleBadge: index != 0,
                      badgeColor: index == 1 ? UIColor(hex: "FF7A00") : index == 2 ? UIColor(hex: "FF0000") : nil,
                      savePrecent: self.getSave(from: product),
                      period: self.getTitle(from: product),
                      price: self.getPriceString(from: product),
                      description: self.getAdviceString(from: product))
            }
            self.productsView.configure(products: self.choiceOfCostArray)
            self.selectedProductIndex = 1
        }
    }
    
    private func setupViews() {
        setGradientBackground()
        
        productsView.configure(products: choiceOfCostArray)
        productsView.selectProduct(selectedProductIndex)
        productsView.tapProduct = { [weak self] selectedIndex in
            self?.selectedProductIndex = selectedIndex
        }
    }
    
    func setGradientBackground() {
        let colorTop =  UIColor(hex: "86FFD9").cgColor
        let colorBottom = UIColor(hex: "40F3DA").cgColor
                    
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.view.bounds
                
        self.view.layer.insertSublayer(gradientLayer, at:0)
    }
    
    @objc
    private func closeButtonAction() {
        AmplitudeManager.shared.logEvent(.paywallClose)
        self.dismiss(animated: true)
    }
    
    @objc
    private func nextButtonPressed() {
        guard let selectedProduct = selectedProduct else { return }
        
        Apphud.purchase(selectedProduct) { [weak self] result in
            if let error = result.error {
                self?.alertOk(title: "Error", message: error.localizedDescription)
            }
            
            if let duration = self?.getDuration(from: selectedProduct) {
                AmplitudeManager.shared.logEvent(.subscribtionBuy, properties: [.subscribtionType: duration])
            }

            if let subscription = result.subscription, subscription.isActive() {
                self?.dismiss(animated: true)
            } else if let purchase = result.nonRenewingPurchase, purchase.isActive() {
                self?.dismiss(animated: true)
            } else {
                if Apphud.hasActiveSubscription() {
                    self?.dismiss(animated: true)
                }
            }
        }
    }

    @objc
    private func didTapToRestorePurchases() {
        Apphud.restorePurchases { [weak self] subscriptions, _, error in
            if let error = error {
                self?.alertOk(title: "Error", message: error.localizedDescription)
            }
            if subscriptions?.first?.isActive() ?? false {
                self?.dismiss(animated: true)
                return
            }
            
            if Apphud.hasActiveSubscription() {
                self?.dismiss(animated: true)
                return
            } else {
                self?.alertOk(title: "No subscription", message: "No active subscriptions found")
            }
        }
    }

    @objc
    private func privacyDidTap() {
        let urlString = "https://docs.google.com/document/d/1FBzdkA2rqRdDLhimwz7fgF3b7VTA-lh4PvOdMHBGKSA/edit?usp=sharing"
        openUrl(urlString: urlString)
    }
    
    @objc
    private func termsDidTap() {
        let urlString = "https://docs.google.com/document/d/1rC8SV2n9UBZL42jYjtpRgL8pKmMWlwTI6UJOGx-BDsE/edit?usp=sharing"
        openUrl(urlString: urlString)
    }
    
    private func openUrl(urlString: String) {
        guard let url = URL(string: urlString),
              UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url)
    }
    
    private func getTitle(from product: ApphudProduct) -> String {
        guard let skProduct = product.skProduct else {
            return loadingInfoString
        }
        switch skProduct.subscriptionPeriod?.unit {
        case .year:
            return "yearly".localized
        case .month:
            if skProduct.subscriptionPeriod?.numberOfUnits == 6 {
                return "6 Month".localized
            } else if skProduct.subscriptionPeriod?.numberOfUnits == 1 {
                return "Monthly".localized
            } else {
                return loadingInfoString
            }
        case .day:
            if skProduct.subscriptionPeriod?.numberOfUnits == 7 {
                return "Week".localized
            } else {
                return loadingInfoString
            }
        default:
            return loadingInfoString
        }
    }
    
    private func getSave(from product: ApphudProduct) -> Int {
        guard let skProduct = product.skProduct else {
            return 0
        }
        let price = skProduct.price.doubleValue
        
        switch skProduct.subscriptionPeriod?.unit {
        case .week:
            weekPrice = skProduct.price.doubleValue
        case .day:
            if skProduct.subscriptionPeriod?.numberOfUnits == 7 {
                weekPrice = skProduct.price.doubleValue
            }
        default:
            break
        }
 
        switch skProduct.subscriptionPeriod?.unit {
        case .year:
            return weekPrice == 0 ? 0 : Int(100 - (price * 100) / (weekPrice * 52.1786))
        case .month:
            return weekPrice == 0 ? 0 : Int(100 - (price * 100) / (weekPrice * 4.13))
        default:
            return 0
        }
    }
    
    private func getPriceString(from product: ApphudProduct) -> String {
        guard let skProduct = product.skProduct else {
            return loadingInfoString
        }
        let price = skProduct.price.doubleValue
        let currencySymbol = "\(skProduct.priceLocale.currencySymbol ?? "$")"
        switch skProduct.subscriptionPeriod?.unit {
        case .year:
            return currencySymbol + String(format: "%.2f", price)
        case .month:
            let numberOfUnits = skProduct.subscriptionPeriod?.numberOfUnits
            if numberOfUnits == 6 || numberOfUnits == 1 {
                return currencySymbol + String(format: "%.2f", price)
            }
        case .day:
            if skProduct.subscriptionPeriod?.numberOfUnits == 7 {
                return currencySymbol + String(format: "%.2f", price)
            }
        default:
            return loadingInfoString
        }
        return loadingInfoString
    }
    
    private func getAdviceString(from product: ApphudProduct) -> String {
        guard let skProduct = product.skProduct else {
            return loadingInfoString
        }
        let price = skProduct.price.doubleValue
        let currencySymbol = "\(skProduct.priceLocale.currencySymbol ?? "$")"
        switch skProduct.subscriptionPeriod?.unit {
        case .year:
            return currencySymbol + String(format: "%.2f", price / 52.1786)
        case .month:
            if skProduct.subscriptionPeriod?.numberOfUnits == 1 {
                return currencySymbol + String(format: "%.2f", price / 4.13)
            }
        case .week:
            if skProduct.subscriptionPeriod?.numberOfUnits == 1 {
                return currencySymbol + String(format: "%.2f", price)
            }
        case .day:
            if skProduct.subscriptionPeriod?.numberOfUnits == 7 {
                return currencySymbol + String(format: "%.2f", price)
            }
        default:
            return loadingInfoString
        }
        return loadingInfoString
    }

    private func getDuration(from product: ApphudProduct) -> String? {
        guard let skProduct = product.skProduct else {
            return nil
        }
        switch skProduct.subscriptionPeriod?.unit {
        case .year: return .yearly
        case .month: return .monthly
        case .day:
            if skProduct.subscriptionPeriod?.numberOfUnits == 7 {
                return .weekly
            } else {
                return nil
            }
        default: return nil
        }
    }
    
    private func makeConstraints() {
        self.view.addSubviews([backgroundImageView, iconImageView, closeCrossButton,
                               titleView, featuresView, productsView,
                               continueButton, privacyButton, restorePurchasesButton, termsButton])
        
        backgroundImageView.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
            $0.height.equalTo(isSmallSize ? 449 : 516)
        }
        
        iconImageView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(17)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(120)
            $0.height.equalTo(104)
        }
        
        titleView.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.bottom).offset(isSmallSize ? 16 : 40)
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.height.greaterThanOrEqualTo(76)
        }
        
        featuresView.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(isSmallSize ? 24 : 48)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(300)
            $0.height.equalTo(230)
        }
        
        productsView.snp.makeConstraints {
            $0.bottom.equalTo(continueButton.snp.top).offset(isSmallSize ? -16 : -24)
            $0.centerX.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(112)
        }
        
        makeButtonsConstraints()
    }
    
    private func makeButtonsConstraints() {
        closeCrossButton.snp.makeConstraints {
            $0.top.equalTo(iconImageView)
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.height.equalTo(40)
        }
        
        continueButton.snp.makeConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-40)
            $0.leading.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(64)
        }
        
        restorePurchasesButton.setContentCompressionResistancePriority(.init(1000), for: .horizontal)
        restorePurchasesButton.snp.makeConstraints {
            $0.top.equalTo(continueButton.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(18)
        }
        privacyButton.setContentCompressionResistancePriority(.init(1), for: .horizontal)
        privacyButton.snp.makeConstraints {
            $0.top.equalTo(restorePurchasesButton)
            $0.leading.equalToSuperview().offset(17)
            $0.trailing.equalTo(restorePurchasesButton.snp.leading).offset(-16)
        }
        termsButton.setContentCompressionResistancePriority(.init(1), for: .horizontal)
        termsButton.snp.makeConstraints {
            $0.top.equalTo(restorePurchasesButton)
            $0.leading.equalTo(restorePurchasesButton.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
    }
}
