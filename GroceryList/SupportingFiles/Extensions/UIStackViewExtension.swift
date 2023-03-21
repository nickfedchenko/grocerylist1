//
//  UIStackViewExtension.swift
//  GroceryList
//
//  Created by Хандымаа Чульдум on 15.03.2023.
//

import UIKit

extension UIStackView {
    func removeAllArrangedSubviews() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.removeAllArrangedSubviews()
            }
            return
        }
        
        arrangedSubviews.forEach({ $0.removeFromSuperview() })
    }
}
