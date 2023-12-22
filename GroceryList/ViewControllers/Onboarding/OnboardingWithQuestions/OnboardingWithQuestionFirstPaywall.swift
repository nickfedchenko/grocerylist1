//
//  OnboardingWithQuestionFirstPaywall.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 22.12.2023.
//

import ApphudSDK

class OnboardingWithQuestionFirstPaywall: FamilyPaywallViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initWithoutFamilyParams()
    }
    
    func initWithoutFamilyParams() {
        hideFamilyPlan()
        Apphud.paywallsDidLoadCallback { [weak self] paywalls in
            
            guard let products = paywalls.first?.products,
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
    
    override func configureProducts() { }
}
