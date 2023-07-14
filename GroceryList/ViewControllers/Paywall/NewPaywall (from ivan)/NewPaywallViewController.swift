//
//  NewPaywallViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 14.07.2023.
//

import ApphudSDK
import UIKit

class NewPaywallViewController: UIViewController {

    private lazy var closeCrossButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
        button.setImage(R.image.updatedPaywall_crossButton(), for: .normal)
        return button
    }()
    
    private let topCarouselView = NewPaywallCarouselView()
    private let featureView = NewPaywallFeatureView()
    private let productsView = NewPaywallProductsView()
    
    private var weekPrice = 0.0
    private let loadingInfoString = "Loading info".localized
    private let isSmallSize = !UIScreen.main.isSizeAsIPhone8PlusOrBigger
    private var products: [ApphudProduct] = []
    private var selectedPrice: PayWallModel?
    private var selectedProduct: ApphudProduct?
    private var selectedProductIndex = 1 {
        didSet {
            selectedProduct = products[selectedProductIndex]
//            productsView.selectProduct(selectedProductIndex)
        }
    }
    private var choiceOfCostArray = [PayWallModelWithSave(),
                                     PayWallModelWithSave(),
                                     PayWallModelWithSave()]
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @objc
    private func closeButtonAction() {
        AmplitudeManager.shared.logEvent(.paywallClose)
        self.dismiss(animated: true)
    }

}
