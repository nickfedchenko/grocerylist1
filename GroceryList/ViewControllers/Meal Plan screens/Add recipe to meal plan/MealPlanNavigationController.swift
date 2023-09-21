//
//  MealPlanNavigationController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 20.09.2023.
//

import UIKit

class MealPlanNavigationController: UINavigationController {
    
    var dismissController: (() -> Void)?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dismissController?()
    }
}
