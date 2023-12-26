//
//  PaywallWithTimerViewModel.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 26.12.2023.
//

import ApphudSDK
import UIKit

class PaywallWithTimerViewModel {
    
    weak var router: RootRouter?
    
    var timerCallback: ((String, String) -> Void)?
    var showErrorAlertCallback: ((String) -> Void)?
   
    private var numberOfSeconds: Int
    private var timer: Timer?
    private var selectedProduct: ApphudProduct?
    private var products: [ApphudProduct] = []
    
    init() {
        if UserDefaultsManager.shared.paywallWithTimerSeconds == nil {
            UserDefaultsManager.shared.paywallWithTimerSeconds = 3600
        }
        numberOfSeconds = UserDefaultsManager.shared.paywallWithTimerSeconds ?? 0
        configureApphud()
        startTimer()
    }
    
    func closeButtonTapped() {
        router?.dismissCurrentController()
    }
    
    func privacyDidTap() {
        let urlString = "https://docs.google.com/document/d/1FBzdkA2rqRdDLhimwz7fgF3b7VTA-lh4PvOdMHBGKSA/edit?usp=sharing"
        openUrl(urlString: urlString)
    }
    
    func termsDidTap() {
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
    
    func continueButtonPressed() {
        guard let selectedProduct = selectedProduct else { return }
        
        Apphud.purchase(selectedProduct) { [weak self] result in
            if let error = result.error {
                self?.showErrorAlertCallback?(error.localizedDescription)
            }
            
            if let duration = selectedProduct.duration {
                AmplitudeManager.shared.logEvent(.subscribtionBuy, properties: [.subscribtionType: duration])
            }

            if let subscription = result.subscription, subscription.isActive() {
                self?.router?.dismissCurrentController()
            } else if let purchase = result.nonRenewingPurchase, purchase.isActive() {
                self?.router?.dismissCurrentController()
            } else {
                if Apphud.hasActiveSubscription() {
                    self?.router?.dismissCurrentController()
                }
            }
        }
    }

    private func configureApphud() {
        Apphud.paywallsDidLoadCallback { [weak self] paywalls in
            // TODO: - Айдишник
            guard let products = paywalls.first(where: { $0.identifier == "" })?.products,
                  let self = self else {
                return
            }
            self.products = products
            selectedProduct = products.first
        }
    }
    
    // MARK: - Timer
    func viewWillDisappear() {
        stopTimer()
    }
    
    private func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(checkStatus),
            userInfo: nil,
            repeats: true)
    }
    @objc
    private func checkStatus() {
        numberOfSeconds -= 1
        let min = (numberOfSeconds % 3600) / 60
        let sec = (numberOfSeconds % 3600) % 60
        timerCallback?(min.asString, sec.asString)
        UserDefaultsManager.shared.paywallWithTimerSeconds = numberOfSeconds
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}