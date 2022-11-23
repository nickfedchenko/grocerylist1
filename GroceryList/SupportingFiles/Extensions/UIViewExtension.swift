//
//  UIViewExtension.swift
//  LearnTrading
//
//  Created by Шамиль Моллачиев on 19.10.2022.
//

import UIKit

extension UIView {
    func addSubviews(_ views: [UIView]) {
        for view in views {
            addSubview(view)
        }
    }
    
    func blink() {
        UIView.animate(withDuration: 0.9, delay: 0.0, options: [.curveLinear, .repeat, .autoreverse], animations: {
            self.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            
        }, completion: nil)
    }
}
