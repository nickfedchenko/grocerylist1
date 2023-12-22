//
//  FamilyPaywallViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 22.11.2023.
//

import ApphudSDK
import UIKit

class FamilyPaywallViewController: UIViewController {

    var isHardPaywall = false
    var isSettings = false
    var products: [ApphudProduct] = []
    var choiceOfCostArray = Array(repeating: PayWallModel(), count: 3)
    var isFamilyIndex = [3, 4, 5]
    var selectedProductIndex = 0 {
        didSet {
            selectedProduct = products[selectedProductIndex]
            productsView.selectProduct(selectedProductIndex)
        }
    }
    
    private let contentView = UIView()
    private lazy var closeCrossButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
        button.setImage(R.image.whiteCross(), for: .normal)
        return button
    }()
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = R.image.paywall_family_bg()
        return imageView
    }()
    
    private let titleView = FamilyPaywallTitleView()
    private let featureView = FamilyPaywallFeatureView()
    private let productsView = FamilyPaywallProductsView()
    
    private let isSmallSize = !UIScreen.main.isSizeAsIPhone8PlusOrBigger
    private var selectedPrice: PayWallModel?
    private var selectedProduct: ApphudProduct?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        makeConstraints()
        closeCrossButton.isHidden = isHardPaywall
        configureProducts()
    }
    
    func configureProducts() {
        Apphud.paywallsDidLoadCallback { [weak self] paywalls in
            
            guard let products = paywalls.first(where: { $0.identifier == "Family_AB_test" })?.products,
                  let self = self else {
                return
            }
            
            self.products = products
            self.choiceOfCostArray = self.products.enumerated().map { index, product in
                    .init(isPopular: (index + 3) % 3 == 0,
                          isVisibleSave: false,
                          isFamily: self.isFamilyIndex.contains(index),
                          badgeColor: nil,
                          savePrecent: product.savePercent(allProducts: products),
                          period: product.period,
                          price: product.priceString,
                          description: product.getPricePerMinPeriod(allProducts: products))
            }
            self.changeFamilySwitch(value: false)
            self.selectedProductIndex = 0
        }
    }
    
    func hideFamilyPlan() {
        productsView.hideFamilyPlan()
    }
    
    private func setupView() {
        productsView.delegate = self
        productsView.familyDelegate = self
        productsView.configure(products: choiceOfCostArray)
        productsView.selectProduct(selectedProductIndex)
    }
    
    private func openUrl(urlString: String) {
        guard let url = URL(string: urlString),
              UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url)
    }
    
    @objc
    private func closeButtonAction() {
        AmplitudeManager.shared.logEvent(.paywallClose)
        self.dismiss(animated: true)
    }
    
    private func makeConstraints() {
        self.view.addSubviews([backgroundImageView, contentView])
        contentView.addSubviews([titleView, featureView, productsView, closeCrossButton])

        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.horizontalEdges.bottom.equalToSuperview()
        }

        closeCrossButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(5)
            $0.trailing.equalToSuperview().inset(20)
            $0.height.width.equalTo(40)
        }
        
        titleView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(self.view.frame.height * (UIDevice.isLessPhoneSE ? 0.11 : 0.16))
            $0.horizontalEdges.equalToSuperview()
            $0.height.lessThanOrEqualTo(88)
        }
        
        featureView.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(13)
            $0.centerX.equalToSuperview()
            $0.leading.greaterThanOrEqualTo(20)
            $0.height.greaterThanOrEqualTo(UIDevice.isSEorXor12mini ? 80 : 88)
            $0.width.greaterThanOrEqualTo(32)
        }
        
        productsView.snp.makeConstraints {
            $0.top.equalTo(featureView.snp.bottom).offset(UIDevice.isSEorXor12mini ? 12 : 15)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(UIDevice.isSEorXor12mini ? 0 : 15)
        }
    }
}

extension FamilyPaywallViewController: BottomProductsViewDelegate {
    func privacyDidTap() {
        let urlString = "https://docs.google.com/document/d/1FBzdkA2rqRdDLhimwz7fgF3b7VTA-lh4PvOdMHBGKSA/edit?usp=sharing"
        openUrl(urlString: urlString)
    }
    
    func termsDidTap() {
        let urlString = "https://docs.google.com/document/d/1rC8SV2n9UBZL42jYjtpRgL8pKmMWlwTI6UJOGx-BDsE/edit?usp=sharing"
        openUrl(urlString: urlString)
    }
    
    func didTapToRestorePurchases() {
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
    
    func continueButtonPressed() {
        guard let selectedProduct = selectedProduct else { return }
        
        Apphud.purchase(selectedProduct) { [weak self] result in
            if let error = result.error {
                self?.alertOk(title: "Error", message: error.localizedDescription)
            }
            
            if let duration = selectedProduct.duration {
                AmplitudeManager.shared.logEvent(.subscribtionBuy, properties: [.subscribtionType: duration])
            }

            if let subscription = result.subscription, subscription.isActive() {
                if self?.isSettings ?? false {
                    AmplitudeManager.shared.logEvent(.upgradeSub, properties: [.type: selectedProduct.forAnalitcs])
                }
                self?.dismiss(animated: true)
            } else if let purchase = result.nonRenewingPurchase, purchase.isActive() {
                if self?.isSettings ?? false {
                    AmplitudeManager.shared.logEvent(.upgradeSub, properties: [.type: selectedProduct.forAnalitcs])
                }
                self?.dismiss(animated: true)
                
            } else {
                if Apphud.hasActiveSubscription() {
                    self?.dismiss(animated: true)
                }
            }
        }
    }
    
    func tapProduct(tag: Int) {
        selectedProductIndex = tag
    }
}

extension FamilyPaywallViewController: FamilyPaywallProductsDelegate {
    func changeFamilySwitch(value: Bool) {
        if value && !isSettings {
            AmplitudeManager.shared.logEvent(.familySubToggle)
        }
        let currentProducts = choiceOfCostArray.filter { $0.isFamily == value }
        productsView.configure(products: currentProducts)
        productsView.selectProduct(selectedProductIndex)
    }
}
