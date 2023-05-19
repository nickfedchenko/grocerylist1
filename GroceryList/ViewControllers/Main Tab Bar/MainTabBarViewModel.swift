//
//  MainTabBarViewModel.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 19.05.2023.
//

import UIKit

final class MainTabBarViewModel {
    
    weak var router: RootRouter?
    
    private var isRightHanded: Bool
    private let disableVCs = [StopperViewController(), StopperViewController()]
    private let viewControllers: [UIViewController]
    
    init(isRightHanded: Bool, viewControllers: [UIViewController]) {
        self.isRightHanded = isRightHanded
        self.viewControllers = viewControllers
    }
    
    func getIsRightHanded() -> Bool {
        return isRightHanded
    }
    
    func getViewControllers() -> [UIViewController] {
        if isRightHanded {
            return viewControllers + disableVCs
        } else {
            return disableVCs + viewControllers
        }
    }
    
    func tappedAddItem(state: MainTabBarController.Items) {
        switch state {
        case .list:
            router?.goCreateNewList(compl: { [weak self] model, _  in
                self?.router?.goProductsVC(model: model, compl: { })
            })
        case .pantry: break
        case .recipe: break
        }
    }
}
