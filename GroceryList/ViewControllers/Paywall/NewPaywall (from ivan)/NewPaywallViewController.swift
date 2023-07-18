//
//  NewPaywallViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 14.07.2023.
//

import ApphudSDK
import UIKit

class NewPaywallViewController: UIViewController {

    private let contentView = UIView()
    private lazy var closeCrossButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
        button.setImage(R.image.updatedPaywall_crossButton(), for: .normal)
        return button
    }()
    
    private let topCarouselView = NewPaywallCarouselView()
    private let featureView = NewPaywallFeatureView()
    private let productsView = NewPaywallBottomProductsView()
    
    private var weekPrice = 0.0
    private let loadingInfoString = "Loading info".localized
    private let isSmallSize = !UIScreen.main.isSizeAsIPhone8PlusOrBigger
    private var products: [ApphudProduct] = []
    private var selectedPrice: PayWallModel?
    private var selectedProduct: ApphudProduct?
    private var selectedProductIndex = 2 {
        didSet {
            selectedProduct = products[selectedProductIndex]
            productsView.selectProduct(selectedProductIndex)
        }
    }
    private var choiceOfCostArray = [PayWallModel(),
                                     PayWallModel(),
                                     PayWallModel()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        makeConstraints()
        
        Apphud.paywallsDidLoadCallback { [weak self] paywalls in
            guard let products = paywalls.first(where: { $0.isDefault })?.products,
                  let self = self else {
                return
            }
            self.products = products
            let lastNumber = products.count - 1
            self.choiceOfCostArray = self.products.enumerated().map { index, product in
                    .init(isPopular: index == lastNumber,
                          isVisibleSave: index == lastNumber,
                          badgeColor: nil,
                          savePrecent: product.savePercent(allProducts: products),
                          period: product.period,
                          price: product.priceString,
                          description: product.pricePerWeek)
            }
            self.productsView.configure(products: self.choiceOfCostArray)
            self.selectedProductIndex = lastNumber
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        topCarouselView.startCarousel()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        topCarouselView.stopCarousel()
    }
    
    private func setupView() {
        contentView.layer.cornerRadius = 24
        contentView.backgroundColor = .white
        contentView.addDefaultShadowForContentView()
        
        productsView.delegate = self
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
        self.view.addSubviews([contentView])
        contentView.addSubviews([topCarouselView, featureView, productsView, closeCrossButton])

        contentView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
        
        closeCrossButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(20)
            $0.height.width.equalTo(40)
        }
        
        topCarouselView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.height.equalTo(232)
        }
        
        featureView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(175)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(553)
        }
        
        productsView.snp.makeConstraints {
            $0.bottom.horizontalEdges.equalToSuperview()
            $0.height.equalTo(247)
        }
    }

}

extension NewPaywallViewController: NewPaywallProductsViewDelegate {
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
    
    func tapProduct(tag: Int) {
        selectedProductIndex = tag
    }
    
}
