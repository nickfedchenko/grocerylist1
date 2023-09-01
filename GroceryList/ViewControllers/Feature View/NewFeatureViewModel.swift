//
//  NewFeatureViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 21.08.2023.
//

import Foundation
import UIKit

final class NewFeatureViewModel {
    
    weak var router: RootRouter?
    var dismiss: (() -> Void)?
    
    func tappedGreatEnable() {
        AmplitudeManager.shared.logEvent(.iCloudAccept)
        
        CloudManager.shared.getICloudStatus { [weak self] status in
            if status == .available {
                UserDefaultsManager.shared.isICloudDataBackupOn = true
                DispatchQueue.global(qos: .default).async {
                    let group = DispatchGroup()
                    CloudManager.shared.enable(enableGroup: group)
                }
                self?.router?.navigationDismiss()
                self?.dismiss?()
                return
            }
            
            UserDefaultsManager.shared.isICloudDataBackupOn = false
            var alertTitle = ""
            switch status {
            case .couldNotDetermine:
                alertTitle = R.string.localizable.couldNotDetermine()
            case .restricted:
                alertTitle = R.string.localizable.restricted()
            case .noAccount:
                alertTitle = R.string.localizable.noAccount()
            case .temporarilyUnavailable:
                alertTitle = R.string.localizable.temporarilyUnavailable()
            default:
                break
            }
            
            self?.router?.showAlertVC(title: "", message: alertTitle,
                                      completion: { [weak self] in
                self?.router?.navigationDismiss()
                self?.dismiss?()
            })
        }
    }
    
    func tappedMaybeLater() {
        AmplitudeManager.shared.logEvent(.iCloudLater)
        router?.navigationDismiss()
        dismiss?()
    }
}
