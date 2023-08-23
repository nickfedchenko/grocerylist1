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
        UserDefaultsManager.shared.isICloudDataBackupOn = true
        DispatchQueue.main.async {
            CloudManager.saveCloudAllData()
        }
        router?.navigationDismiss()
        dismiss?()
    }
    
    func tappedMaybeLater() {
        router?.navigationDismiss()
        dismiss?()
    }
}
