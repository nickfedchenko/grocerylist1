//
//  SynchronizationViewController.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 31.08.2023.
//

import UIKit

class SynchronizationViewController: UIViewController {
    
    private let synchronizationActivityView = SynchronizationActivityView()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func loadingIndicator(isVisible: Bool) {
        DispatchQueue.main.async {
            if isVisible {
                self.synchronizationActivityView.show(for: self.view)
            } else {
                self.synchronizationActivityView.removeFromView()
            }
        }
    }
}
