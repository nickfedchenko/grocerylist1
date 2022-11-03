//
//  UITextFieldExtension.swift
//  LearnTrading
//
//  Created by Шамиль Моллачиев on 20.10.2022.
//

import UIKit

extension UITextField {
    func paddingLeft(inset: CGFloat) {
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: inset, height: self.frame.height))
        self.leftViewMode = UITextField.ViewMode.always
    }
}
