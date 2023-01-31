//
//  AlternativePaywallViewController.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 31.01.2023.
//

import ApphudSDK
import SnapKit
import UIKit

class AlternativePaywallViewController: UIViewController {
  
    private var products: [ApphudProduct] = []
    private var selectedPrice: PayWallModel?
    private var selectedProduct: ApphudProduct?
    private let featuresView = CheckmarkCompositionView()
    private let tryForFreeView = TryForFreeView()
    private let isSmallSize = UIScreen.main.isSmallSize
    
    private var choiceOfCostArray = [
        PayWallModel(
            isPopular: true,
            period: "Loading".localized,
            price: "Loading".localized,
            description: "Loading".localized
        ),
        PayWallModel(
            isPopular: false,
            period: "Loading".localized,
            price: "Loading".localized,
            description: "Loading".localized
        ),
        PayWallModel(
            isPopular: false,
            period: "Loading".localized,
            price: "Loading".localized,
            description: "Loading".localized
        )
    ]
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "paywallBackground")
        return imageView
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton()
        let attributedTitle = NSAttributedString(string: "Next".localized, attributes: [
            .font: UIFont.SFPro.semibold(size: 20).font ?? UIFont(),
            .foregroundColor: UIColor(hex: "#FFFFFF")
        ])
        button.addTarget(self, action: #selector(nextButtonPressed), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.backgroundColor = UIColor(hex: "#31635A")
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.masksToBounds = true
        button.addShadowForView()
        return button
    }()
    
    private let nextArrow: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "nextArrow")
        return imageView
    }()
    
    private lazy var termsButton: UIButton = {
        let button = UIButton()
        button.setTitle("Term of use".localized, for: .normal)
        button.setTitleColor(UIColor(hex: "#31635A"), for: .normal)
        button.titleLabel?.font = UIFont.SFPro.medium(size: 12).font
        button.addTarget(self, action: #selector(termsDidTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var privacyButton: UIButton = {
        let button = UIButton()
        button.setTitle("Privacy Policy".localized, for: .normal)
        button.setTitleColor(UIColor(hex: "#31635A"), for: .normal)
        button.titleLabel?.font = UIFont.SFPro.medium(size: 12).font
        button.addTarget(self, action: #selector(privacyDidTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel anytime".localized, for: .normal)
        button.setTitleColor(UIColor(hex: "#31635A"), for: .normal)
        button.titleLabel?.font = UIFont.SFPro.medium(size: 15).font
        return button
    }()
    
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        layout.scrollDirection = .vertical
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private let productShelfImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "productShelf")
        return imageView
    }()
    
    private let lockScreenView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.4)
        view.isHidden = true
        return view
    }()
    
    private let backgroundShadowView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        return view
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
        button.setImage(UIImage(named: "#whiteCross"), for: .normal)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .top)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundShadowView.applyGradient(colours: [UIColor(hex: "#E8F4F3"), .clear])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        setupCollectionView()
        Apphud.paywallsDidLoadCallback { [weak self] paywalls in
            guard
                let products = paywalls.first?.products,
                let self = self
            else { return }
            self.products = products.reversed()
       
            self.choiceOfCostArray = self.products.map {
                .init(
                    isPopular: false,
                    period: self.getTitle(from: $0),
                    price: self.getPriceString(from: $0),
                    description: self.getAdviceString(from: $0)
                )
            }
            self.choiceOfCostArray[0].isPopular = true
            self.collectionView.reloadData()
        }
    }
    // MARK: - Func
    private func lockUI() {
        lockScreenView.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func unlockUI() {
        lockScreenView.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    private func getAdviceString(from product: ApphudProduct) -> String {
        guard
            let skProduct = product.skProduct
        else { return "Loading info".localized }
        let price = skProduct.price.doubleValue
        switch skProduct.subscriptionPeriod?.unit {
        case .year:
            return "\(skProduct.priceLocale.currencySymbol ?? "$")"
            + String(format: "%.2f", price / 52.1786)
        case .month:
            if skProduct.subscriptionPeriod?.numberOfUnits == 1 {
                return "\(skProduct.priceLocale.currencySymbol ?? "$")"
                + String(format: "%.2f", price / 4.13)
            } else {
                return "Loading info".localized
            }
        case .week:
            if skProduct.subscriptionPeriod?.numberOfUnits == 1 {
                return "\(skProduct.priceLocale.currencySymbol ?? "$")"
                + String(format: "%.2f", price)
            } else {
                return "Loading info".localized
            }
        case .day:
            if skProduct.subscriptionPeriod?.numberOfUnits == 7 {
                return "\(skProduct.priceLocale.currencySymbol ?? "$")"
                + String(format: "%.2f", price)
            } else {
                return "Loading info".localized
            }
        default:
            return "Loading info".localized
        }
    }
    
    private func getPriceString(from product: ApphudProduct) -> String {
        guard
            let skProduct = product.skProduct
        else { return "Loading info".localized }
        let price = skProduct.price.doubleValue
        switch skProduct.subscriptionPeriod?.unit {
        case .year:
            return "\(skProduct.priceLocale.currencySymbol ?? "$")"
            + String(format: "%.2f", price)
        case .month:
            if skProduct.subscriptionPeriod?.numberOfUnits == 6 {
                return "\(skProduct.priceLocale.currencySymbol ?? "$")"
                + String(format: "%.2f", price)
                
            } else if skProduct.subscriptionPeriod?.numberOfUnits == 1 {
                return "\(skProduct.priceLocale.currencySymbol ?? "$")"
                + String(format: "%.2f", price)
            } else {
                return "Loading info".localized
            }
        case .day:
            if skProduct.subscriptionPeriod?.numberOfUnits == 7 {
                return "\(skProduct.priceLocale.currencySymbol ?? "$")"
                + String(format: "%.2f", price)
            } else {
                return "Loading info".localized
            }
        default:
            return "Loading info".localized
        }
    }
    
    private func getTitle(from product: ApphudProduct) -> String {
        guard let skProduct = product.skProduct else { return "Loading info" }
        switch skProduct.subscriptionPeriod?.unit {
        case .year:
            return "yearly".localized
        case .month:
            if skProduct.subscriptionPeriod?.numberOfUnits == 6 {
                return "6 Month".localized
            } else if skProduct.subscriptionPeriod?.numberOfUnits == 1 {
                return "Monthly".localized
            } else {
                return "Loading info".localized
            }
        case .day:
            if skProduct.subscriptionPeriod?.numberOfUnits == 7 {
                return "Week".localized
            } else {
                return "Loading info".localized
            }
        default:
            return "Loading info".localized
        }
    }
    
    // swiftlint:disable:next function_body_length
    private func setupConstraints() {
        view.addSubviews([backgroundImageView, productShelfImage, backgroundShadowView, nextButton, nextArrow, termsButton, privacyButton,
                          cancelButton, collectionView, lockScreenView,
                          activityIndicator, closeButton, featuresView, tryForFreeView])
        nextButton.addSubviews([nextArrow])
        lockScreenView.addSubviews([activityIndicator])
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        backgroundShadowView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
         
            make.top.equalTo(tryForFreeView.snp.top).inset(-40)
        }
    
        productShelfImage.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(22)
            make.height.equalTo(176)
            make.bottom.equalTo(tryForFreeView.snp.top).inset(isSmallSize ? 20 : -10)
        }
        
        tryForFreeView.snp.makeConstraints { make in
            make.bottom.equalTo(featuresView.snp.top).inset(isSmallSize ? -18 : -26)
            make.centerX.equalToSuperview()
        }
        
        featuresView.snp.makeConstraints { make in
            make.bottom.equalTo(collectionView.snp.top).inset(isSmallSize ? -8 : -26)
            make.centerX.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalTo(nextButton.snp.top).inset(isSmallSize ? 0 : -20)
            make.height.equalTo(260)
        }
        
        nextButton.snp.makeConstraints { make in
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).inset(30)
            make.width.equalTo(300)
            make.centerX.equalToSuperview()
            make.height.equalTo(64)
        }
        
        nextArrow.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview().offset(45)
            make.width.equalTo(24)
            make.height.equalTo(20)
        }
        
        privacyButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview().multipliedBy(0.4)
            make.top.equalTo(nextButton.snp.bottom).inset(-8)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(privacyButton)
        }
        
        termsButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview().multipliedBy(1.6)
            make.centerY.equalTo(privacyButton)
        }
        
        lockScreenView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.centerY.centerX.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(23)
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).inset(20)
            make.width.height.equalTo(20)
        }
    }
    
    @objc
    private func nextButtonPressed() {
        guard let selectedProduct = selectedProduct else { return }
        lockUI()
        Apphud.purchase(selectedProduct) { [weak self] result in
            if let error = result.error {
                self?.alertOk(title: "Error", message: error.localizedDescription)
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
            self?.unlockUI()
        }
    }
    
    @objc
    private func termsDidTap() {
        guard let url = URL(
            string: "https://docs.google.com/document/d/1FBzdkA2rqRdDLhimwz7fgF3b7VTA-lh4PvOdMHBGKSA/edit?usp=sharing"
        ),
                UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url)
    }
    
    @objc
    private func privacyDidTap() {
        guard
            let url = URL(
                string: "https://docs.google.com/document/d/1rC8SV2n9UBZL42jYjtpRgL8pKmMWlwTI6UJOGx-BDsE/edit?usp=sharing"
            ),
            UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url)
    }
    
    @objc
    private func closeButtonAction() {
        self.dismiss(animated: true)
    }
}

// MARK: - CollcetionView
extension AlternativePaywallViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(AlternativePaywallCell.self, forCellWithReuseIdentifier: "AlternativePaywallCell")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return choiceOfCostArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlternativePaywallCell",
            for: indexPath) as? AlternativePaywallCell else { return UICollectionViewCell() }
       
        cell.layer.masksToBounds = false
        let isTopCell = choiceOfCostArray[indexPath.row].isPopular
        let description = choiceOfCostArray[indexPath.row].description
        let period = choiceOfCostArray[indexPath.row].period
        let price = choiceOfCostArray[indexPath.row].price
        
        cell.setupCell(isTopCell: isTopCell, price: price, description: description, period: period)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 40, height: 72)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !products.isEmpty else { return }
        selectedProduct = products[indexPath.item]
    }
}
