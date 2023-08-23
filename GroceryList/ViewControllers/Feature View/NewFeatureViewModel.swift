//
//  NewFeatureViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 21.08.2023.
//

import Foundation

final class NewFeatureViewModel {
    
    weak var router: RootRouter?
    var dismiss: (() -> Void)?
    
    func tappedGreatEnable() {
        AmplitudeManager.shared.logEvent(.iCloudAccept)
        UserDefaultsManager.shared.isICloudDataBackupOn = true
        DispatchQueue.main.async {
            CloudManager.saveCloudAllData()
        }
        router?.navigationDismiss()
        dismiss?()
    }
    
    func tappedMaybeLater() {
        AmplitudeManager.shared.logEvent(.iCloudLater)
        router?.navigationDismiss()
        dismiss?()
    }
}
