//
//  PaywallWithTimerReachability.swift
//  GroceryList
//
//  Created by Шамиль Моллачиев on 28.12.2023.
//

import ApphudSDK
import Foundation

class PaywallWithTimerReachability {
    
    var showPresentCallback: (() -> Void)?
    var hidePresentCallback: (() -> Void)?
    var timerCallback: ((String, String) -> Void)?
    
    private var timer: Timer?
    private var numberOfSeconds: Int = 0
    static var shared = PaywallWithTimerReachability()
    
    private init() {
        if isDateCorrect() {
            startTimer()
        }
    }
    
    func setupInitialDate() {
        UserDefaultsManager.shared.paywallWithTimerStartedDate = Date()
        if isDateCorrect() {
            startTimer()
            showPresentCallback?()
        }
    }
    
    func isDateCorrect() -> Bool {
        guard let date = UserDefaultsManager.shared.paywallWithTimerStartedDate,
                !Apphud.hasActiveSubscription() else {
            return false
        }
        
        let time = Date().timeIntervalSince(date)
        
        numberOfSeconds = 3600 - Int(time)
        
        if numberOfSeconds > 0 {
            return true
        } else {
            return false
        }
    }
    
    private func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(timerAction),
            userInfo: nil,
            repeats: true)
    }
    @objc
    private func timerAction() {
        guard numberOfSeconds > 0 else {
            stopTimer()
            return
        }
        
        numberOfSeconds -= 1
        let min = (numberOfSeconds % 3600) / 60
        let sec = (numberOfSeconds % 3600) % 60
        timerCallback?(min.asString, sec.asString)
    }
    
    private func stopTimer() {
        hidePresentCallback?()
        timer?.invalidate()
        timer = nil
    }
}
